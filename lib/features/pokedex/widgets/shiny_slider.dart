import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Um widget interativo e premium para comparar os sprites Normal (Esquerda) e Shiny (Direita).
/// O fundo muda dinamicamente de acordo com o brilho (Light/Dark Mode).
class ShinySlider extends StatefulWidget {
  final String normalImageUrl;
  final String shinyImageUrl;
  final String normalLabel;
  final String shinyLabel;

  const ShinySlider({
    super.key,
    required this.normalImageUrl,
    required this.shinyImageUrl,
    this.normalLabel = 'Normal',
    this.shinyLabel = '★ Shiny',
  });

  @override
  State<ShinySlider> createState() => _ShinySliderState();
}

class _ShinySliderState extends State<ShinySlider> {
  double _position = 0.5;

  void _updatePosition(Offset globalPosition) {
    if (!mounted) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset localOffset = renderBox.globalToLocal(globalPosition);
    final double width = renderBox.size.width;

    if (width > 0) {
      setState(() {
        _position = (localOffset.dx / width).clamp(0.01, 0.99);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  // 1. Fundo: Sprite Shiny (Direita)
                  Positioned.fill(
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

                  // 2. Frente: Sprite Normal (Esquerda com Clipper)
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SliderClipper(_position),
                      child: Center(
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: CachedNetworkImage(
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
                  ),

                  // Etiquetas de ajuda visual
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.normalLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.shinyLabel,
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // 3. Divisória e Botão de Arrasto (Knob)
                  Positioned(
                    left: (width * _position) - 20,
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