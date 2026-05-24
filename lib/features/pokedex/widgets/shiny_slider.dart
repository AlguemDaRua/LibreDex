import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Um widget interativo e premium para comparar os sprites Normal e Shiny de um Pokémon.
/// Utiliza conversão de coordenadas locais via RenderBox para garantir precisão absoluta
/// ao arrastar, eliminando qualquer tipo de desvio (drift) ou distorção na linha de divisão.
class ShinySlider extends StatefulWidget {
  final String normalImageUrl;
  final String shinyImageUrl;

  const ShinySlider({
    super.key,
    required this.normalImageUrl,
    required this.shinyImageUrl,
  });

  @override
  State<ShinySlider> createState() => _ShinySliderState();
}

class _ShinySliderState extends State<ShinySlider> {
  // Posição inicial do slider (normalizada entre 0.0 e 1.0)
  double _position = 0.5;

  /// Atualiza a posição do slider convertendo o toque global para o espaço local do widget.
  /// Isto resolve o problema de offset incorreto ao arrastar diretamente em cima do botão.
  void _updatePosition(Offset globalPosition) {
    if (!mounted) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset localOffset = renderBox.globalToLocal(globalPosition);
    final double width = renderBox.size.width;

    if (width > 0) {
      setState(() {
        // Clamping entre 0.01 e 0.99 para evitar que a linha e o knob
        // desapareçam completamente ou fiquem inacessíveis nas bordas extremas.
        _position = (localOffset.dx / width).clamp(0.01, 0.99);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double height = 250.0; // Altura fixa para consistência visual na página de detalhes

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Rastreamento instantâneo do toque no início, atualização e fim
          onTapDown: (details) => _updatePosition(details.globalPosition),
          onHorizontalDragStart: (details) => _updatePosition(details.globalPosition),
          onHorizontalDragUpdate: (details) => _updatePosition(details.globalPosition),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Camada de Fundo: Sprite Normal (Estático e Centrado)
                Positioned.fill(
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

                // 2. Camada da Frente: Sprite Shiny (Recortado horizontalmente com precisão)
                // O ClipRect partilha exatamente os mesmos limites de tamanho que a camada anterior,
                // garantindo que não há qualquer desalinhamento de pixéis na sobreposição.
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

                // 3. Divisória vertical e botão de arrasto (Knob) de alta fidelidade
                Positioned(
                  left: (width * _position) - 20, // Centra o container interativo de 40px exatamente na linha
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: SizedBox(
                      width: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Linha vertical nítida de separação (com largura otimizada de 3px para cobrir imperfeições)
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
                          // Botão estilo Material Design 3 centrado na linha divisória
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.unfold_more_rounded, // Ícone vertical dinâmico para indicar arrasto lateral
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
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
        );
      },
    );
  }
}

/// Clipper personalizado que corta a porção direita do widget da frente (Shiny),
/// mantendo a imagem do Pokémon no centro perfeitamente intacta.
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