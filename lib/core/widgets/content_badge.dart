import 'package:flutter/material.dart';

/// Compact, accessible badge for source and regulation states.
class ContentBadge extends StatelessWidget {
  final String label;
  final Color color;
  final String? tooltip;

  const ContentBadge({
    super.key,
    required this.label,
    required this.color,
    this.tooltip,
  });

  const ContentBadge.mC({super.key, bool isNew = false, this.tooltip})
    : label = isNew ? 'NEW M-C' : 'M-C',
      color = isNew ? Colors.deepOrangeAccent : Colors.deepPurpleAccent;

  /// Marks a species that has more than one form, with the total count.
  ///
  /// The count includes the species' own row, which is how a Pokédex
  /// presents it: Charizard is 4 forms, not 3. Rendered only when there is
  /// more than one, so a single-form species carries no badge.
  const ContentBadge.forms({super.key, required int count, this.tooltip})
    : assert(count > 1, 'Use this badge only for species with several forms'),
      label = '$count FORMS',
      color = const Color(0xFF0284C7);

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.15,
        ),
      ),
    );
    return tooltip == null ? badge : Tooltip(message: tooltip!, child: badge);
  }
}
