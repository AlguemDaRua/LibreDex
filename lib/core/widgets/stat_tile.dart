import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// Strictly DRY stat tile — single source for Team Builder Snapshot & Comparison.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const StatTile({super.key, required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(sub, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

/// Mini variant used in TeamComparison head-to-head.
class MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const MiniStat({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed)),
      ]),
    );
  }
}
