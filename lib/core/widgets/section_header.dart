import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// Icon-first section header — no storytelling paragraphs.
/// The icon conveys meaning; extra detail lives in an optional ⓘ tooltip.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle; // legacy — kept for compat, rendered as hint tooltip
  final String? hint;
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isShortData = subtitle != null && subtitle!.length < 28 && hint == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.pokemonRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: AppTheme.pokemonRed),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                  ),
                  if (isShortData) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.pokemonRed.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.pokemonRed),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hint != null)
              Tooltip(
                message: hint!,
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 12, color: Colors.white, height: 1.35),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[500])),
              )
            else if (subtitle != null && !isShortData)
              Tooltip(
                message: subtitle!,
                triggerMode: TooltipTriggerMode.tap,
                showDuration: const Duration(seconds: 4),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 12, color: Colors.white, height: 1.35),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey[500])),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
      ],
    );
  }
}
