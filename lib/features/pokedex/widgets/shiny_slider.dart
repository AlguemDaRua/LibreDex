import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// Um widget interativo e premium para comparar os sprites Normal (Esquerda) e Shiny (Direita).
/// O fundo muda dinamicamente de acordo com o brilho (Light/Dark Mode).
class ShinySlider extends StatefulWidget {
  final String normalImageUrl;
  final String shinyImageUrl;
  final String normalLabel;
  final String shinyLabel;
  final int? pokemonId;

  const ShinySlider({
    super.key,
    required this.normalImageUrl,
    required this.shinyImageUrl,
    this.normalLabel = 'Normal',
    this.shinyLabel = '★ Shiny',
    this.pokemonId,
  });

  @override
  State<ShinySlider> createState() => _ShinySliderState();
}

class _ShinySliderState extends State<ShinySlider> {
  double _position = 0.0; // Start at 100% Normal by default

  void _updatePosition(Offset globalPosition) {
    if (!mounted) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset localOffset = renderBox.globalToLocal(globalPosition);
    final double width = renderBox.size.width;

    if (width > 0) {
      setState(() {
        _position = (localOffset.dx / width).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Some forms ship without a bundled shiny render — Eternal Flower
    // Floette's only public shiny sprite is an upside-down broken model, for
    // example (and AZ's Floette cannot be shiny officially, so none exists).
    // Instead of a one-sided slider we show the normal artwork centered with
    // a short, honest note.
    if (widget.shinyImageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 240.0,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: widget.pokemonId != null
                  ? Hero(
                      tag: 'pokemon_${widget.pokemonId}',
                      child: CachedNetworkImage(
                        imageUrl: widget.normalImageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.normalImageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'No shiny sprite bundled for this form',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.grey[isDark ? 400 : 600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 240.0;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _updatePosition(details.globalPosition),
          onHorizontalDragStart: (details) => _updatePosition(details.globalPosition),
          onHorizontalDragUpdate: (details) => _updatePosition(details.globalPosition),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Fundo: Sprite Normal (Base)
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: widget.pokemonId != null
                            ? Hero(
                                tag: 'pokemon_${widget.pokemonId}',
                                child: CachedNetworkImage(
                                  imageUrl: widget.normalImageUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.normalImageUrl,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // 2. Frente: Sprite Shiny (Clipped to position)
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SliderClipper(_position),
                      child: Center(
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: CachedNetworkImage(
                            imageUrl: widget.shinyImageUrl,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Visual Toggles / Labels
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _position = 0.0; // 100% Normal
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _position < 0.1 
                              ? AppTheme.pokemonRed 
                              : Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _position < 0.1 ? Colors.white30 : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.normalLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _position = 1.0; // 100% Shiny
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _position > 0.9 
                              ? const Color(0xFFFFD700) 
                              : Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _position > 0.9 ? Colors.black26 : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.shinyLabel,
                          style: TextStyle(
                            color: _position > 0.9 ? Colors.black87 : const Color(0xFFFFD700), 
                            fontSize: 11, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Divisória e Botão de Arrasto (Knob) clamped to prevent boundary leaks
                  Positioned(
                    left: (width * _position - 20).clamp(0.0, width - 40),
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: SizedBox(
                        width: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 3.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                size: 18,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
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
}

class _SliderClipper extends CustomClipper<Rect> {
  final double position;

  _SliderClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0.0, 0.0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(covariant _SliderClipper oldClipper) {
    return oldClipper.position != position;
  }
}