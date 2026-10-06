import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libredex/core/theme/responsive.dart';

class DexFilterSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onReset;
  final bool hasActiveFilters;

  const DexFilterSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onReset,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final isTablet = Responsive.isTablet(context);
    final maxW = isTablet ? 720.0 : 560.0;
    final maxH = MediaQuery.of(context).size.height * (isTablet ? 0.88 : 0.92);

    return Semantics(
      label: '$title Filter Panel',
      explicitChildNodes: true,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 8,
          vertical: isTablet ? 24 : 16,
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE3350D,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: Color(0xFFE3350D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: primaryColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onReset();
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(context),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Close filter panel',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Filter Content — scrollable, with bottom handle on tablet
              Flexible(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
