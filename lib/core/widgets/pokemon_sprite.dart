import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:libredex/core/storage/offline_artwork_store.dart';

/// Displays a Pokémon sprite with an ordered recovery chain:
///
///   durable offline artwork → primary URL → fallback URL → placeholder icon
///
/// The user-managed offline library is checked before network image providers,
/// so a deliberately downloaded sprite works even when the normal cache has
/// been cleared or the device is disconnected.
class PokemonSprite extends StatefulWidget {
  const PokemonSprite({
    super.key,
    required this.imageUrl,
    this.fallbackUrl,
    this.fit = BoxFit.contain,
    this.loadingIndicatorSize,
    this.errorIcon = Icons.catching_pokemon,
    this.errorIconSize = 40,
    this.errorIconColor = Colors.grey,
    this.diskCacheSize,
    this.loadingColor,
  });

  /// Primary render to display (usually the Pokémon's own sprite).
  final String imageUrl;

  /// Render to try when the primary URL fails — typically the base species'
  /// HOME artwork via [homeArtworkUrl]. Skipped when empty or identical to
  /// [imageUrl].
  final String? fallbackUrl;

  final BoxFit fit;

  /// When set, shows a centered [CircularProgressIndicator] while artwork is
  /// being located or fetched. When null, the layout stays empty until ready.
  final double? loadingIndicatorSize;

  /// Color of the loading indicator; null keeps the ambient theme color.
  final Color? loadingColor;

  final IconData errorIcon;
  final double errorIconSize;
  final Color errorIconColor;

  /// Downscales the normal network disk cache to this many pixels on both
  /// axes — pass ~240 for grid thumbnails to keep memory usage flat.
  final int? diskCacheSize;

  static const String _homeBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home';

  /// HOME render for [id] — the canonical "base species art" fallback.
  static String homeArtworkUrl(int id) => '$_homeBase/$id.png';

  /// Shiny HOME render for [id].
  static String homeShinyUrl(int id) => '$_homeBase/shiny/$id.png';

  @override
  State<PokemonSprite> createState() => _PokemonSpriteState();
}

class _PokemonSpriteState extends State<PokemonSprite> {
  late Future<File?> _offlineArtwork;

  @override
  void initState() {
    super.initState();
    OfflineArtworkStore.instance.revision.addListener(_refreshOfflineArtwork);
    _offlineArtwork = _findOfflineArtwork();
  }

  void _refreshOfflineArtwork() {
    if (!mounted) return;
    setState(() => _offlineArtwork = _findOfflineArtwork());
  }

  @override
  void didUpdateWidget(covariant PokemonSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _offlineArtwork = _findOfflineArtwork();
    }
  }

  @override
  void dispose() {
    OfflineArtworkStore.instance.revision.removeListener(_refreshOfflineArtwork);
    super.dispose();
  }

  Future<File?> _findOfflineArtwork() async {
    final store = OfflineArtworkStore.instance;
    final primary = await store.fileForUrl(widget.imageUrl);
    if (primary != null) return primary;

    final fallback = widget.fallbackUrl;
    if (fallback == null || fallback.isEmpty || fallback == widget.imageUrl) {
      return null;
    }
    return store.fileForUrl(fallback);
  }

  Widget _errorIcon() => Icon(
        widget.errorIcon,
        size: widget.errorIconSize,
        color: widget.errorIconColor,
      );

  Widget _loading() => Center(
        child: SizedBox(
          width: widget.loadingIndicatorSize,
          height: widget.loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: widget.loadingColor == null
                ? null
                : AlwaysStoppedAnimation<Color>(widget.loadingColor!),
          ),
        ),
      );

  Widget _networkImage() {
    if (widget.imageUrl.isEmpty) return _errorIcon();

    final fallback = widget.fallbackUrl;
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      maxHeightDiskCache: widget.diskCacheSize,
      maxWidthDiskCache: widget.diskCacheSize,
      placeholder:
          widget.loadingIndicatorSize == null ? null : (_, __) => _loading(),
      errorWidget: (_, __, ___) {
        if (fallback != null &&
            fallback.isNotEmpty &&
            fallback != widget.imageUrl) {
          return CachedNetworkImage(
            imageUrl: fallback,
            fit: widget.fit,
            maxHeightDiskCache: widget.diskCacheSize,
            maxWidthDiskCache: widget.diskCacheSize,
            errorWidget: (_, __, ___) => _errorIcon(),
          );
        }
        return _errorIcon();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) return _errorIcon();

    return FutureBuilder<File?>(
      future: _offlineArtwork,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file != null) {
          return Image.file(
            file,
            fit: widget.fit,
            errorBuilder: (_, __, ___) => _networkImage(),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingIndicatorSize == null
              ? const SizedBox.expand()
              : _loading();
        }
        return _networkImage();
      },
    );
  }
}
