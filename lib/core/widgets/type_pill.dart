import 'package:flutter/material.dart';
import 'package:libredex/core/utils/type_utils.dart';

/// Strictly DRY type pills — one source for every team / dex surface.
class TypePill extends StatelessWidget {
  final String type;
  const TypePill({super.key, required this.type});
  @override
  Widget build(BuildContext context) {
    final color = pokemonTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        titleCasePokemonText(type),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class CountPill extends StatelessWidget {
  final String type;
  final int count;
  final String label;
  const CountPill({
    super.key,
    required this.type,
    required this.count,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final color = pokemonTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '${titleCasePokemonText(type)} · $count $label',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
