import 'package:flutter/material.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/core/widgets/debounced_search_field.dart';

/// Searchable modal dialog for picking a damaging move in the damage calculator.
class MovePickerDialog extends StatefulWidget {
  final List<Move> moves;
  final DamageCalculatorViewModel viewModel;
  final ValueChanged<Move> onMoveSelected;

  const MovePickerDialog({
    super.key,
    required this.moves,
    required this.viewModel,
    required this.onMoveSelected,
  });

  /// Displays the MovePickerDialog.
  static Future<void> show(
    BuildContext context, {
    required List<Move> moves,
    required DamageCalculatorViewModel vm,
    required ValueChanged<Move> onMoveSelected,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MovePickerDialog(
        moves: moves,
        viewModel: vm,
        onMoveSelected: onMoveSelected,
      ),
    );
  }

  @override
  State<MovePickerDialog> createState() => _MovePickerDialogState();
}

class _MovePickerDialogState extends State<MovePickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    final filtered = widget.moves.where((m) {
      final q = _query.toLowerCase();
      return m.name.toLowerCase().contains(q) ||
          m.type.toLowerCase().contains(q) ||
          m.damageClass.toLowerCase().contains(q);
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
                  const Text('Select Move', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                hintText: 'Search moves by name, type, or category...',
                initialValue: _query,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  final typeColor = CombatUtils.typeColors[m.type.toLowerCase()] ?? Colors.grey;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(m.type.toUpperCase(), style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                    subtitle: Text('${m.damageClass.toUpperCase()} \u2022 PP: ${m.pp}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: Text('BP: ${m.power ?? "\u2014"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.pokemonRed)),
                    onTap: () {
                      widget.viewModel.selectMove(m.name, m.type, m.damageClass, m.power?.toDouble() ?? 50.0);
                      widget.onMoveSelected(m);
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
