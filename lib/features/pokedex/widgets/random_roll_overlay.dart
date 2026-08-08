import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';

/// Fullscreen dramatic slot-machine roll animation dialog.
class RandomRollOverlay extends StatefulWidget {
  final List<Pokemon> candidatePool;
  final ValueChanged<Pokemon> onViewDetails;

  const RandomRollOverlay({
    super.key,
    required this.candidatePool,
    required this.onViewDetails,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Pokemon> candidatePool,
    required ValueChanged<Pokemon> onViewDetails,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => RandomRollOverlay(
        candidatePool: candidatePool,
        onViewDetails: onViewDetails,
      ),
    );
  }

  @override
  State<RandomRollOverlay> createState() => _RandomRollOverlayState();
}

class _RandomRollOverlayState extends State<RandomRollOverlay>
    with SingleTickerProviderStateMixin {
  late List<Pokemon> _shuffleList;
  late Pokemon _selectedWinner;
  int _currentIndex = 0;
  bool _isSpinning = true;
  late AnimationController _animController;
  Timer? _spinTimer;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _setupAndStartRoll();
  }

  void _setupAndStartRoll() {
    setState(() {
      _isSpinning = true;
      _currentIndex = 0;
    });

    // Pick final winner
    _selectedWinner =
        widget.candidatePool[_rand.nextInt(widget.candidatePool.length)];

    // Generate 18 teaser items ending with winner
    final teasers = <Pokemon>[];
    for (int i = 0; i < 18; i++) {
      teasers.add(
        widget.candidatePool[_rand.nextInt(widget.candidatePool.length)],
      );
    }
    teasers.add(_selectedWinner);
    _shuffleList = teasers;

    _runSpinSequence();
  }

  void _runSpinSequence() async {
    _animController.reset();
    _animController.forward();

    int step = 0;
    // Decelerating interval sequence (ms)
    final intervals = [
      40, 40, 45, 50, 60, 70, 85, 100, 120, 150, 190, 240, 300, 380, 460, 560, 680, 800, 950
    ];

    void scheduleNextStep() {
      if (!mounted) return;
      if (step < _shuffleList.length - 1) {
        setState(() {
          _currentIndex = step;
        });
        HapticFeedback.selectionClick();
        final delay = step < intervals.length ? intervals[step] : 800;
        step++;
        _spinTimer = Timer(Duration(milliseconds: delay), scheduleNextStep);
      } else {
        // Final reveal!
        setState(() {
          _currentIndex = _shuffleList.length - 1;
          _isSpinning = false;
        });
        HapticFeedback.heavyImpact();
      }
    }

    scheduleNextStep();
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePokemon = _shuffleList[_currentIndex];
    final typeColor = pokemonTypeColor(activePokemon.type1);
    final bst = activePokemon.baseHp +
        activePokemon.baseAtk +
        activePokemon.baseDef +
        activePokemon.baseSpAtk +
        activePokemon.baseSpDef +
        activePokemon.baseSpd;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isSpinning
                  ? AppTheme.pokemonRed.withValues(alpha: 0.6)
                  : typeColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isSpinning ? AppTheme.pokemonRed : typeColor)
                    .withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isSpinning
                            ? Icons.casino_rounded
                            : Icons.auto_awesome_rounded,
                        color: _isSpinning ? AppTheme.pokemonRed : Colors.amber,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSpinning ? 'RANDOMIZING...' : 'TARGET ACQUIRED!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: _isSpinning ? Colors.white70 : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main Stage Card
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer animated aura glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (_isSpinning ? AppTheme.pokemonRed : typeColor)
                              .withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Pokeball icon background watermark
                  Opacity(
                    opacity: _isSpinning ? 0.12 : 0.22,
                    child: Icon(
                      Icons.catching_pokemon_rounded,
                      size: 170,
                      color: _isSpinning ? Colors.white : typeColor,
                    ),
                  ),

                  // Sprite Display
                  AnimatedScale(
                    scale: _isSpinning ? 0.95 : 1.15,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.elasticOut,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: PokemonSprite(
                            imageUrl: activePokemon.spriteUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pokemon Name & Type info
              Text(
                activePokemon.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: typeColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      activePokemon.type1.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ),
                  if (activePokemon.type2 != null &&
                      activePokemon.type2!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: pokemonTypeColor(activePokemon.type2!)
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: pokemonTypeColor(activePokemon.type2!)
                                .withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        activePokemon.type2!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: pokemonTypeColor(activePokemon.type2!),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 10),
                  Text(
                    'BST: $bst',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              if (!_isSpinning) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onViewDetails(_selectedWinner);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text(
                      'VIEW POKÉMON DETAILS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF333333)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _setupAndStartRoll,
                    icon: const Icon(Icons.casino_outlined, size: 18),
                    label: const Text(
                      'ROLL AGAIN',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 48,
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppTheme.pokemonRed,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
