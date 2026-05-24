import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// An elegant, interactive image slider comparing the Normal and Shiny form of a Pokémon.
/// Uses a custom clip path and horizontal drag detector for high-performance visual shifting.
class ShinySlider extends StatefulWidget {
  final String normalImageUrl;
  final String shinyImageUrl;
  final double height;

  const ShinySlider({
    super.key,
    required this.normalImageUrl,
    required this.shinyImageUrl,
    this.height = 300,
  });

  @override
  State<ShinySlider> createState() => _ShinySliderState();
}

class _ShinySliderState extends State<ShinySlider> {
  double _dragRatio = 0.5; // Drag position (0.0 to 1.0)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = constraints.maxWidth;
        final handleX = _dragRatio * sliderWidth;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              // Calculate new ratio clamped between 0.0 and 1.0
              _dragRatio = (details.localPosition.dx / sliderWidth).clamp(0.0, 1.0);
            });
          },
          onTapDown: (details) {
            setState(() {
              _dragRatio = (details.localPosition.dx / sliderWidth).clamp(0.0, 1.0);
            });
          },
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Background: Shiny Pokémon Image (Right side)
                  _buildPokemonImage(widget.shinyImageUrl),

                  // 2. Foreground: Normal Pokémon Image clipped to current ratio (Left side)
                  ClipRect(
                    clipper: _ShinySliderClipper(_dragRatio),
                    child: _buildPokemonImage(widget.normalImageUrl),
                  ),

                  // 3. Labels indicating which side is which (fade out as the handle approaches)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: AnimatedOpacity(
                      opacity: (_dragRatio - 0.15).clamp(0.0, 1.0),
                      duration: Duration.zero,
                      child: _buildFormLabel('Normal', isDark),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: AnimatedOpacity(
                      opacity: (0.85 - _dragRatio).clamp(0.0, 1.0),
                      duration: Duration.zero,
                      child: _buildFormLabel('Shiny ✨', isDark, isShiny: true),
                    ),
                  ),

                  // 4. Custom dragging line indicator
                  Positioned(
                    left: handleX - 1.5,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      color: AppTheme.pokemonRed,
                    ),
                  ),

                  // 5. Custom glowing circular dragging handle
                  Positioned(
                    left: handleX - 20,
                    top: (widget.height / 2) - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.pokemonRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.pokemonRed.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Unified loader for images
  Widget _buildPokemonImage(String url) {
    if (url.isEmpty) {
      return const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey));
    }
    return CachedNetworkImage(
      imageUrl: url,
      height: widget.height - 40,
      width: widget.height - 40,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pokemonRed),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
      ),
    );
  }

  /// Badge Labels for Normal/Shiny sides
  Widget _buildFormLabel(String label, bool isDark, {bool isShiny = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isShiny
            ? AppTheme.pokemonBlue.withValues(alpha: 0.85)
            : (isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isShiny
              ? AppTheme.pokemonBlue
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isShiny ? Colors.white : (isDark ? Colors.white : Colors.black),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Custom Clipper that cuts an area vertically from 0.0 to clipRatio of its parent's width.
class _ShinySliderClipper extends CustomClipper<Rect> {
  final double clipRatio;

  _ShinySliderClipper(this.clipRatio);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * clipRatio, size.height);
  }

  @override
  bool shouldReclip(covariant _ShinySliderClipper oldClipper) {
    return oldClipper.clipRatio != clipRatio;
  }
}
