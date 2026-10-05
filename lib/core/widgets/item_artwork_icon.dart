import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:libredex/core/storage/offline_artwork_store.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// Item artwork with the same durable-offline, network-cache and fallback
/// behavior wherever an item is previewed in the app.
class ItemArtworkIcon extends StatelessWidget {
  final String imageUrl;
  final Color accent;
  final IconData fallbackIcon;
  final BoxFit fit;

  const ItemArtworkIcon({
    super.key,
    required this.imageUrl,
    required this.accent,
    required this.fallbackIcon,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: OfflineArtworkStore.instance.fileForUrl(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data!,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _networkImage(),
          );
        }
        return _networkImage();
      },
    );
  }

  Widget _networkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppTheme.pokemonRed,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(fallbackIcon, color: accent),
    );
  }
}
