import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Displays a Pokémon sprite with an ordered recovery chain:
///
///   primary URL  →  [fallbackUrl]  →  placeholder icon
///
/// The bundled dataset is audited at build time (tools/fix_sprite_urls.py),
/// so every URL should resolve. This widget is the runtime safety net: a
/// flaky connection, an upstream file removal or an offline session degrades
/// to the base species render (usually already disk-cached from the grid)
/// instead of a broken-image icon.
class PokemonSprite extends StatelessWidget {
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

  /// When set, shows a centered [CircularProgressIndicator] of this size
  /// while the primary render downloads. When null, nothing is shown while
  /// loading (matching the previous slider/hero behavior).
  final double? loadingIndicatorSize;

  /// Color of the loading indicator; null keeps the ambient theme color.
  final Color? loadingColor;

  final IconData errorIcon;
  final double errorIconSize;
  final Color errorIconColor;

  /// Downscales the disk-cached copy to this many pixels on both axes —
  /// pass ~240 for grid thumbnails to keep memory usage flat.
  final int? diskCacheSize;

  static const String _homeBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home';

  /// HOME render for [id] — the canonical "base species art" fallback.
  static String homeArtworkUrl(int id) => '$_homeBase/$id.png';

  /// Shiny HOME render for [id].
  static String homeShinyUrl(int id) => '$_homeBase/shiny/$id.png';

  Widget _errorIcon() => Icon(errorIcon, size: errorIconSize, color: errorIconColor);

  Widget _loading() => Center(
        child: SizedBox(
          width: loadingIndicatorSize,
          height: loadingIndicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                loadingColor == null ? null : AlwaysStoppedAnimation<Color>(loadingColor!),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _errorIcon();

    final String? fallback = fallbackUrl;
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      maxHeightDiskCache: diskCacheSize,
      maxWidthDiskCache: diskCacheSize,
      placeholder: loadingIndicatorSize == null ? null : (context, url) => _loading(),
      errorWidget: (context, url, error) {
        if (fallback != null && fallback.isNotEmpty && fallback != imageUrl) {
          return CachedNetworkImage(
            imageUrl: fallback,
            fit: fit,
            maxHeightDiskCache: diskCacheSize,
            maxWidthDiskCache: diskCacheSize,
            errorWidget: (context, url, error) => _errorIcon(),
          );
        }
        return _errorIcon();
      },
    );
  }
}
