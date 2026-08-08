import 'package:flutter/material.dart';

class ResultCountLabel extends StatelessWidget {
  final int count;
  final String label;

  const ResultCountLabel({
    super.key,
    required this.count,
    this.label = 'results found',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white60 : Colors.grey[600],
    );

    return Semantics(
      liveRegion: true,
      label: '$count $label',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          '$count $label',
          style: textStyle,
        ),
      ),
    );
  }
}
