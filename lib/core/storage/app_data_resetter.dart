import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:libredex/core/storage/offline_artwork_store.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Deletes LibreDex data stored on this device.
///
/// App assets remain inside the installed APK, but all generated database data,
/// downloaded artwork, normal image cache and preferences are removed. A
/// restart creates a fresh local database exactly as a new install would.
class AppDataResetter {
  AppDataResetter._();

  static Future<void> deleteEverything() async {
    await DefaultCacheManager().emptyCache();
    await OfflineArtworkStore.instance.deleteAll();
    await _deleteDatabaseFiles();

    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  static Future<void> _deleteDatabaseFiles() async {
    final documents = await getApplicationDocumentsDirectory();
    const databaseName = 'libredex.db';
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File(p.join(documents.path, '$databaseName$suffix'));
      if (await file.exists()) await file.delete();
    }
  }
}
