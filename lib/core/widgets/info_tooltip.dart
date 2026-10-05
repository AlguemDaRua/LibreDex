import 'package:flutter/material.dart';

/// Lightweight info affordance — the "icon is there for a reason" widget.
///
/// Replaces paragraph-long storytelling subtitles with a tiny ⓘ icon.
/// Tap → tooltip / dialog with details. Keeps the screen clean and scannable.
class InfoTooltip extends StatelessWidget {
  final String message;
  final IconData icon;
  final double size;
  const InfoTooltip({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      preferBelow: true,
      textStyle: const TextStyle(fontSize: 12, color: Colors.white, height: 1.35),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: () {
          // Fallback dialog for long messages (tooltip truncates on some devices).
          if (message.length > 90) {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Info', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ],
                ),
                content: Text(message, style: const TextStyle(fontSize: 13, height: 1.45)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
                ],
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: size, color: Colors.grey[500]),
        ),
      ),
    );
  }
}

/// Compact icon + title row with optional hint ⓘ — no paragraph subtitle.
class CompactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  final VoidCallback onTap;
  final Color? iconColor;
  final Widget? trailing;

  const CompactTile({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    required this.onTap,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? const Color(0xFFE3350D)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (hint != null) ...[
                InfoTooltip(message: hint!),
                const SizedBox(width: 4),
              ],
              trailing ??
                  const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
