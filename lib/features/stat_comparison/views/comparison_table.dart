/// Sortable stat comparison table for the Stat Comparison feature.
///
/// Renders a horizontal-scrolling table with one row per Pokémon and columns
/// for each stat, BST, bulk products, and effective speed. Every column
/// header is tappable to toggle sort.
library;

import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';
import 'package:libredex/features/stat_comparison/models/stat_modifier.dart';
import 'package:libredex/features/stat_comparison/viewmodels/stat_comparison_viewmodel.dart';

class ComparisonTable extends StatelessWidget {
  final List<({int index, ComparisonEntry entry, ComparisonStats stats})> rows;
  final SortColumn? sortColumn;
  final SortDirection sortDirection;
  final ComparisonDisplayMode displayMode;
  final ValueChanged<SortColumn> onSort;

  const ComparisonTable({
    super.key,
    required this.rows,
    required this.sortColumn,
    required this.sortDirection,
    required this.displayMode,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (rows.isEmpty) return const SizedBox.shrink();

    // Compute min/max for color grading
    final allStats = <SortColumn, List<int>>{};
    for (final col in _columns) {
      allStats[col.key] = rows.map((r) => _getValue(r.stats, r.entry, col.key)).toList();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 46,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 68,
        columnSpacing: 14,
        horizontalMargin: 12,
        headingRowColor: WidgetStateProperty.all(
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF1F5F9),
        ),
        border: TableBorder(
          horizontalInside: BorderSide(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
        columns: [
          const DataColumn(label: Text('Pokémon', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11))),
          for (final col in _columns)
            DataColumn(
              numeric: true,
              label: _SortableHeader(
                label: col.label,
                isActive: sortColumn == col.key,
                direction: sortDirection,
                onTap: () => onSort(col.key),
              ),
            ),
        ],
        rows: rows.map((row) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 100,
                  child: Text(
                    row.entry.pokemon.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              for (final col in _columns)
                DataCell(
                  _StatCell(
                    value: _getValue(row.stats, row.entry, col.key),
                    rawValue: _getRawValue(row.stats, row.entry, col.key),
                    showDelta: displayMode == ComparisonDisplayMode.effectiveBattle &&
                        col.key != SortColumn.bst &&
                        col.key != SortColumn.physBulk &&
                        col.key != SortColumn.specBulk,
                    colorFraction: _colorFraction(
                      _getValue(row.stats, row.entry, col.key),
                      allStats[col.key] ?? [],
                    ),
                    modifiers: _getModifiers(row.stats, col.key),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  static int _getValue(ComparisonStats stats, ComparisonEntry entry, SortColumn col) {
    return switch (col) {
      SortColumn.hp => stats.hp.effectiveStat,
      SortColumn.atk => stats.attack.effectiveStat,
      SortColumn.def => stats.defense.effectiveStat,
      SortColumn.spa => stats.spAtk.effectiveStat,
      SortColumn.spd => stats.spDef.effectiveStat,
      SortColumn.spe => stats.speed.effectiveStat,
      SortColumn.bst => entry.bst,
      SortColumn.physBulk => stats.physicalBulk,
      SortColumn.specBulk => stats.specialBulk,
      SortColumn.effSpeed => stats.speed.effectiveStat,
    };
  }

  static int _getRawValue(ComparisonStats stats, ComparisonEntry entry, SortColumn col) {
    return switch (col) {
      SortColumn.hp => stats.hp.rawStat,
      SortColumn.atk => stats.attack.rawStat,
      SortColumn.def => stats.defense.rawStat,
      SortColumn.spa => stats.spAtk.rawStat,
      SortColumn.spd => stats.spDef.rawStat,
      SortColumn.spe => stats.speed.rawStat,
      SortColumn.bst => entry.bst,
      SortColumn.physBulk => stats.physicalBulk,
      SortColumn.specBulk => stats.specialBulk,
      SortColumn.effSpeed => stats.speed.rawStat,
    };
  }

  static List<AppliedStatModifier> _getModifiers(ComparisonStats stats, SortColumn col) {
    return switch (col) {
      SortColumn.hp => stats.hp.modifiers,
      SortColumn.atk => stats.attack.modifiers,
      SortColumn.def => stats.defense.modifiers,
      SortColumn.spa => stats.spAtk.modifiers,
      SortColumn.spd => stats.spDef.modifiers,
      SortColumn.spe => stats.speed.modifiers,
      _ => const [],
    };
  }

  static double _colorFraction(int value, List<int> allValues) {
    if (allValues.length <= 1) return 0.5;
    final minV = allValues.reduce((a, b) => a < b ? a : b);
    final maxV = allValues.reduce((a, b) => a > b ? a : b);
    if (maxV == minV) return 0.5;
    return (value - minV) / (maxV - minV);
  }
}

class _ColumnDef {
  final SortColumn key;
  final String label;
  const _ColumnDef(this.key, this.label);
}

const _columns = [
  _ColumnDef(SortColumn.hp, 'HP'),
  _ColumnDef(SortColumn.atk, 'Atk'),
  _ColumnDef(SortColumn.def, 'Def'),
  _ColumnDef(SortColumn.spa, 'SpA'),
  _ColumnDef(SortColumn.spd, 'SpD'),
  _ColumnDef(SortColumn.spe, 'Spe'),
  _ColumnDef(SortColumn.bst, 'BST'),
  _ColumnDef(SortColumn.physBulk, 'P.Bulk'),
  _ColumnDef(SortColumn.specBulk, 'S.Bulk'),
];

class _SortableHeader extends StatelessWidget {
  final String label;
  final bool isActive;
  final SortDirection direction;
  final VoidCallback onTap;

  const _SortableHeader({
    required this.label,
    required this.isActive,
    required this.direction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: isActive ? AppTheme.pokemonRed : null,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 2),
            Icon(
              direction == SortDirection.descending
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 12,
              color: AppTheme.pokemonRed,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final int value;
  final int rawValue;
  final bool showDelta;
  final double colorFraction;
  final List<AppliedStatModifier> modifiers;

  const _StatCell({
    required this.value,
    required this.rawValue,
    required this.showDelta,
    required this.colorFraction,
    required this.modifiers,
  });

  @override
  Widget build(BuildContext context) {

    final color = Color.lerp(
      Colors.red.shade300,
      Colors.green.shade400,
      colorFraction,
    )!;

    final delta = value - rawValue;
    final hasDelta = showDelta && delta != 0;

    return Tooltip(
      message: modifiers.isEmpty
          ? '$value'
          : modifiers.map((m) => m.toString()).join('\n'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: color,
            ),
          ),
          if (hasDelta)
            Text(
              '${delta > 0 ? '+' : ''}$delta',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: delta > 0
                    ? Colors.green.shade400
                    : Colors.red.shade400,
              ),
            ),
        ],
      ),
    );
  }
}
