import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Semantics(
      label: '$title Filter Panel',
      explicitChildNodes: true,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        backgroundColor: isDark ? const Color(0xFF0C0C0C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.88),
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
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: primaryColor,
                          ),
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
              // Filter Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
