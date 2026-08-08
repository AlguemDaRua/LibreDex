import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/core/widgets/debounced_search_field.dart';

/// Searchable modal dialog for picking held items in the damage calculator.
class ItemPickerDialog extends StatefulWidget {
  final bool isAttacker;
  final DamageCalculatorViewModel viewModel;

  const ItemPickerDialog({
    super.key,
    required this.isAttacker,
    required this.viewModel,
  });

  /// Displays the ItemPickerDialog.
  static Future<void> show(
    BuildContext context, {
    required bool isAttacker,
    required DamageCalculatorViewModel vm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ItemPickerDialog(
        isAttacker: isAttacker,
        viewModel: vm,
      ),
    );
  }

  @override
  State<ItemPickerDialog> createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState extends State<ItemPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    final items = HeldItemsData.allItems.where((item) {
      final q = _query.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isAttacker ? 'Attacker Held Item' : 'Defender Held Item',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DebouncedSearchField(
                hintText: 'Search held items (Choice, Berry, Vest, Boots...)...',
                initialValue: _query,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return ListTile(
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.pokemonRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(item.category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.pokemonRed)),
                    ),
                    onTap: () {
                      if (widget.isAttacker) {
                        widget.viewModel.setAttackerHeldItem(item.name);
                      } else {
                        widget.viewModel.setDefenderHeldItem(item.name);
                      }
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
