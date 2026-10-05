import 'package:flutter/material.dart';
import 'package:libredex/core/data/champions_regulation.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/core/widgets/debounced_search_field.dart';

/// Searchable modal dialog for picking a damaging move in the damage calculator.
class MovePickerDialog extends StatefulWidget {
  final List<Move> moves;
  final DamageCalculatorViewModel viewModel;
  final ChampionsRegulationCatalog? regulation;
  final bool useRegulationPp;

  const MovePickerDialog({
    super.key,
    required this.moves,
    required this.viewModel,
    this.regulation,
    this.useRegulationPp = false,
  });

  /// Displays the MovePickerDialog.
  static Future<void> show(
    BuildContext context, {
    required List<Move> moves,
    required DamageCalculatorViewModel vm,
    ChampionsRegulationCatalog? regulation,
    bool useRegulationPp = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MovePickerDialog(
        moves: moves,
        viewModel: vm,
        regulation: regulation,
        useRegulationPp: useRegulationPp,
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
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
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
                  const Text(
                    'Select Move',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  final typeColor =
                      CombatUtils.typeColors[m.type.toLowerCase()] ??
                      Colors.grey;
                  final mCPp = widget.regulation?.movePpFor(m.id);
                  final previousMCPp = widget.regulation?.previousMovePpFor(
                    m.id,
                  );
                  final previousPpLabel = previousMCPp == null
                      ? ''
                      : ', was $previousMCPp';
                  final ppLabel = widget.useRegulationPp && mCPp != null
                      ? 'PP: $mCPp (M-C$previousPpLabel)'
                      : 'PP: ${m.pp}';
                  final priorityLabel = m.priority == 0
                      ? null
                      : 'Priority ${m.priority > 0 ? '+' : ''}${m.priority}';
                  final moveFacts = [
                    m.damageClass.toUpperCase(),
                    ppLabel,
                    ?priorityLabel,
                    m.isContact ? 'Contact' : 'Non-contact',
                  ].join(' · ');
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m.type.toUpperCase(),
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      m.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      moveFacts,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: Text(
                      'BP: ${m.power ?? "\u2014"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.pokemonRed,
                      ),
                    ),
                    onTap: () {
                      widget.viewModel.selectDatabaseMove(m);
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
