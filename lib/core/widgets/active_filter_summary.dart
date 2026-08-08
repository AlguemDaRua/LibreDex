import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActiveFilterItem {
  final String label;
  final VoidCallback onDeleted;
  final Color? color;

  const ActiveFilterItem({
    required this.label,
    required this.onDeleted,
    this.color,
  });
}

class ActiveFilterSummary extends StatelessWidget {
  final List<ActiveFilterItem> items;
  final VoidCallback onClearAll;

  const ActiveFilterSummary({
    super.key,
    required this.items,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final chips = items.map((item) {
      final chipColor = item.color ?? Colors.orangeAccent;
      return Container(
        padding: const EdgeInsets.only(left: 10, right: 4, top: 3, bottom: 3),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: chipColor.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: chipColor),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                item.onDeleted();
              },
              child: Icon(Icons.cancel_rounded, size: 16, color: chipColor.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }).toList();

    // Append Clear All button at the end
    chips.add(
      GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onClearAll();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.clear_all_rounded, size: 14, color: Colors.redAccent),
              SizedBox(width: 4),
              Text(
                'Clear All',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) => chips[index],
      ),
    );
  }
}
