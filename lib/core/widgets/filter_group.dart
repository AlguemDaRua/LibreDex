import 'package:flutter/material.dart';

/// Icon-led, collapsible filter group — the organization you asked for.
/// Each group is an ExpansionTile so long filter lists stay scannable
/// on both phone portrait and tablet landscape.
class FilterGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Color? accent;
  const FilterGroup({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    required this.children,
    this.initiallyExpanded = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (accent ?? const Color(0xFFE3350D)).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: accent ?? const Color(0xFFE3350D),
            ),
          ),
          title: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: hint!,
                  triggerMode: TooltipTriggerMode.tap,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.35,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: children,
        ),
      ),
    );
  }
}

class FilterSectionLabel extends StatelessWidget {
  final String label;
  const FilterSectionLabel(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 2),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    ),
  );
}
