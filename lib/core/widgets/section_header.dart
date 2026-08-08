import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// Strictly DRY section header — used by Team Builder, Team Comparison, and
/// any future strictly organized screen. One source, no duplication.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const SectionHeader({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.pokemonRed.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppTheme.pokemonRed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.3)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Divider(height: 1, color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
      ],
    );
  }
}
