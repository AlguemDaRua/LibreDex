import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A durable, user-managed artwork library.
///
/// This is intentionally separate from Flutter's normal image cache. Browsed
/// artwork may be removed by the operating system, while images deliberately
/// downloaded for offline use live in LibreDex's private app-support storage.
class OfflineArtworkStore {
  OfflineArtworkStore._();

  static final OfflineArtworkStore instance = OfflineArtworkStore._();

  static const _directoryName = 'offline_artwork';
  static const _manifestName = 'manifest.json';

  final Dio _downloadClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  final Map<String, _OfflineArtworkRecord> _records = {};
  final ValueNotifier<int> revision = ValueNotifier(0);
  final Map<String, Future<void>> _downloads = {};
  final Map<String, CancelToken> _downloadTokens = {};
  Future<void> _persistQueue = Future<void>.value();

  Future<void>? _ready;
  late Directory _directory;
  late File _manifest;

  Future<void> _ensureReady() => _ready ??= _load();

  Future<void> _load() async {
    final supportDirectory = await getApplicationSupportDirectory();
    _directory = Directory(p.join(supportDirectory.path, _directoryName));
    await _directory.create(recursive: true);
    _manifest = File(p.join(_directory.path, _manifestName));

    if (!await _manifest.exists()) return;

    try {
      final raw = await _manifest.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final records = json['records'] as Map<String, dynamic>? ?? const {};
      for (final entry in records.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          _records[entry.key] = _OfflineArtworkRecord.fromJson(value);
        } else if (value is Map) {
          _records[entry.key] = _OfflineArtworkRecord.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      }
    } catch (_) {
      // A damaged manifest should never make the artwork library unusable.
      // Existing image files can safely be replaced by a future download.
      _records.clear();
    }
  }

  Future<void> _persist() async {
    final json = <String, dynamic>{
      'version': 1,
      'records': {
        for (final entry in _records.entries) entry.key: entry.value.toJson(),
      },
    };
    final temporary = File('${_manifest.path}.part');
    await temporary.writeAsString(jsonEncode(json), flush: true);
    if (await _manifest.exists()) await _manifest.delete();
    await temporary.rename(_manifest.path);
  }

  /// Serializes manifest writes while multiple artwork workers finish together.
  Future<void> _queuePersist() {
    final queued = _persistQueue.then(
      (_) => _persist(),
      onError: (err, stack) => _persist(),
    );
    _persistQueue = queued;
    return queued;
  }

  /// Returns the durable image for [sourceUrl], if the user downloaded it.
  Future<File?> fileForUrl(String? sourceUrl) async {
    if (sourceUrl == null || sourceUrl.isEmpty) return null;
    try {
      await _ensureReady();
    } catch (_) {
      // Normal network artwork remains available if platform storage cannot be
      // opened (for example, a widget test without a path-provider channel).
      return null;
    }

    final record = _records[sourceUrl];
    if (record == null) return null;
    final file = File(p.join(_directory.path, record.fileName));
    if (await file.exists()) return file;

    _records.remove(sourceUrl);
    await _queuePersist();
    return null;
  }

  /// Whether [sourceUrl] is stored at [quality].
  Future<bool> hasArtwork(String sourceUrl, {required String quality}) async {
    await _ensureReady();
    final record = _records[sourceUrl];
    if (record == null || record.quality != quality) return false;
    return File(p.join(_directory.path, record.fileName)).exists();
  }

  /// Downloads [remoteUrl] and associates it with the display [sourceUrl].
  ///
  /// The source and remote URLs differ for small artwork: the UI still asks
  /// for the standard URL, while this store serves the user's smaller file.
  Future<void> downloadArtwork({
    required String sourceUrl,
    required String remoteUrl,
    required String quality,
  }) {
    if (sourceUrl.isEmpty || remoteUrl.isEmpty) return Future<void>.value();

    final inFlight = _downloads[sourceUrl];
    if (inFlight != null) return inFlight;

    late final Future<void> task;
    task = _downloadArtwork(
      sourceUrl: sourceUrl,
      remoteUrl: remoteUrl,
      quality: quality,
    ).whenComplete(() {
      if (identical(_downloads[sourceUrl], task)) {
        _downloads.remove(sourceUrl);
        _downloadTokens.remove(sourceUrl);
      }
    });
    _downloads[sourceUrl] = task;
    return task;
  }

  Future<void> _downloadArtwork({
    required String sourceUrl,
    required String remoteUrl,
    required String quality,
  }) async {
    await _ensureReady();
    if (await hasArtwork(sourceUrl, quality: quality)) return;

    final fileName = '${_fileKey(sourceUrl)}.img';
    final destination = File(p.join(_directory.path, fileName));
    final temporary = File('${destination.path}.part');
    if (await temporary.exists()) await temporary.delete();

    final cancelToken = CancelToken();
    _downloadTokens[sourceUrl] = cancelToken;
    await _downloadClient.download(
      remoteUrl,
      temporary.path,
      cancelToken: cancelToken,
    );
    if (!await temporary.exists() || await temporary.length() == 0) {
      throw StateError('Artwork download did not create a file.');
    }

    if (await destination.exists()) await destination.delete();
    await temporary.rename(destination.path);
    _records[sourceUrl] = _OfflineArtworkRecord(
      fileName: fileName,
      bytes: await destination.length(),
      quality: quality,
    );
    await _queuePersist();
  }

  /// Cancels active network requests before clearing the durable library.
  Future<void> cancelActiveDownloads() async {
    for (final token in _downloadTokens.values.toList()) {
      if (!token.isCancelled) token.cancel('Artwork library was deleted.');
    }
    await Future.wait(
      _downloads.values.toList().map((task) async {
        try {
          await task;
        } catch (_) {
          // Cancellation is expected while deleting the library.
        }
      }),
    );
  }

  /// Refreshes visible sprite widgets after a batched library change.
  void notifyLibraryChanged() => revision.value++;

  /// Whether the offline artwork for [pokemon] is already stored locally.
  Future<bool> isPokemonArtworkDownloaded(dynamic pokemon) async {
    await _ensureReady();
    final String spriteUrl = pokemon.spriteUrl ?? '';
    final String shinySpriteUrl = pokemon.shinySpriteUrl ?? '';
    final urls = [spriteUrl, shinySpriteUrl].where((u) => u.isNotEmpty);
    if (urls.isEmpty) return false;
    for (final url in urls) {
      final record = _records[url];
      if (record != null && await File(p.join(_directory.path, record.fileName)).exists()) {
        return true;
      }
    }
    return false;
  }

  /// Removes offline artwork files and manifest records for [pokemon].
  Future<void> deletePokemonArtwork(dynamic pokemon) async {
    await _ensureReady();
    final String spriteUrl = pokemon.spriteUrl ?? '';
    final String shinySpriteUrl = pokemon.shinySpriteUrl ?? '';
    for (final url in [spriteUrl, shinySpriteUrl]) {
      if (url.isNotEmpty) {
        final record = _records.remove(url);
        if (record != null) {
          final file = File(p.join(_directory.path, record.fileName));
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    }
    await _queuePersist();
    notifyLibraryChanged();
  }

  /// Removes only the durable offline artwork library.
  Future<void> deleteAll() async {
    await _ensureReady();
    await cancelActiveDownloads();
    try {
      await _persistQueue;
    } catch (_) {
      // A canceled download may have interrupted the previous manifest write.
    }
    if (await _directory.exists()) await _directory.delete(recursive: true);
    await _directory.create(recursive: true);
    _manifest = File(p.join(_directory.path, _manifestName));
    _records.clear();
    await _queuePersist();
    notifyLibraryChanged();
  }

  Future<OfflineArtworkSummary> summary() async {
    await _ensureReady();
    // File sizes are captured when an image is committed. Reading the manifest
    // keeps the Settings screen fast even for a library with thousands of art
    // files; missing files are removed lazily by [fileForUrl].
    return OfflineArtworkSummary(
      fileCount: _records.length,
      totalBytes: _records.values.fold(0, (sum, record) => sum + record.bytes),
      qualities: _records.values.map((record) => record.quality).toSet(),
    );
  }

  /// A stable 64-bit-like key built from two 32-bit rolling hashes.
  ///
  /// It avoids depending on a crypto package and keeps filenames short enough
  /// for Android's per-file limits.
  String _fileKey(String sourceUrl) {
    var first = 0x811c9dc5;
    var second = 0x9e3779b9;
    for (final unit in sourceUrl.codeUnits) {
      first = ((first ^ unit) * 0x01000193) & 0xffffffff;
      second = ((second + unit) * 0x85ebca6b) & 0xffffffff;
    }
    return '${first.toRadixString(16).padLeft(8, '0')}'
        '${second.toRadixString(16).padLeft(8, '0')}';
  }
}

class OfflineArtworkSummary {
  const OfflineArtworkSummary({
    required this.fileCount,
    required this.totalBytes,
    required this.qualities,
  });

  final int fileCount;
  final int totalBytes;
  final Set<String> qualities;

  String get sizeLabel {
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get qualityLabel {
    if (qualities.isEmpty) return 'No downloaded artwork';
    if (qualities.length > 1) return 'Mixed quality';
    return switch (qualities.single) {
      'small' => 'Small artwork',
      'standard' => 'Standard artwork',
      _ => 'Downloaded artwork',
    };
  }
}

class _OfflineArtworkRecord {
  const _OfflineArtworkRecord({
    required this.fileName,
    required this.bytes,
    required this.quality,
  });

  factory _OfflineArtworkRecord.fromJson(Map<String, dynamic> json) {
    return _OfflineArtworkRecord(
      fileName: json['fileName'] as String,
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      quality: json['quality'] as String? ?? 'standard',
    );
  }

  final String fileName;
  final int bytes;
  final String quality;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'bytes': bytes,
        'quality': quality,
      };
}
