/// Card displaying 16-roll breakdown, KO chance, and applied modifiers breakdown.
library;

import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/battle_engine/battle_engine.dart';

class DamageSummaryCard extends StatelessWidget {
  final DamageResult result;
  final String moveName;

  const DamageSummaryCard({
    super.key,
    required this.result,
    required this.moveName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF8FAFC),
                  ],
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: KO Chance Badge + Damage Percentage Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moveName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${result.minDamage} – ${result.maxDamage} HP (${result.minPercentage.toStringAsFixed(1)}% – ${result.maxPercentage.toStringAsFixed(1)}%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: result.maxPercentage >= 100
                                  ? Colors.red
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getKoColor(result.maxPercentage).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getKoColor(result.maxPercentage),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    result.koChance,
                    style: TextStyle(
                      color: _getKoColor(result.maxPercentage),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // HP Health Bar Visualizer
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                  FractionallySizedBox(
                    widthFactor: (result.maxPercentage / 100.0).clamp(0.0, 1.0),
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getKoColor(result.maxPercentage),
                            _getKoColor(result.minPercentage),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Step 19 Applied Modifiers Chips
            if (result.modifiers.isNotEmpty) ...[
              Text(
                'Applied Modifiers Breakdown',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: result.modifiers.map((mod) {
                  return Chip(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: _getCategoryColor(mod.category, isDark),
                    label: Text(
                      '${mod.name} (×${mod.multiplier.toStringAsFixed(mod.multiplier == mod.multiplier.roundToDouble() ? 0 : 2)})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // 16 Exact Rolls Grid
            Text(
              '16 Damage Rolls (85% – 100%)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: result.rolls.map((roll) {
                final pct = (roll / result.defenderMaxHp) * 100.0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    '$roll (${pct.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              }).toList(),
            ),

            // Warnings section if present
            if (result.hasWarnings) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.warnings.join('\n'),
                        style: const TextStyle(fontSize: 11, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _getKoColor(double maxPct) {
    if (maxPct >= 100) return AppTheme.pokemonRed;
    if (maxPct >= 50) return Colors.orange;
    return Colors.blue;
  }

  static Color _getCategoryColor(ModifierCategory cat, bool isDark) {
    final alphaVal = isDark ? 0.25 : 0.15;
    return switch (cat) {
      ModifierCategory.basePower => Colors.purple.withValues(alpha: alphaVal),
      ModifierCategory.attack => Colors.red.withValues(alpha: alphaVal),
      ModifierCategory.defense => Colors.blue.withValues(alpha: alphaVal),
      ModifierCategory.statStage => Colors.orange.withValues(alpha: alphaVal),
      ModifierCategory.weather => Colors.cyan.withValues(alpha: alphaVal),
      ModifierCategory.terrain => Colors.green.withValues(alpha: alphaVal),
      ModifierCategory.stab => Colors.amber.withValues(alpha: alphaVal),
      ModifierCategory.typeEffectiveness => Colors.deepOrange.withValues(alpha: alphaVal),
      ModifierCategory.critical => Colors.yellow.withValues(alpha: alphaVal),
      ModifierCategory.status => Colors.purpleAccent.withValues(alpha: alphaVal),
      ModifierCategory.screen => Colors.indigo.withValues(alpha: alphaVal),
      ModifierCategory.ability => Colors.teal.withValues(alpha: alphaVal),
      ModifierCategory.item => Colors.brown.withValues(alpha: alphaVal),
      ModifierCategory.rule => Colors.purpleAccent.withValues(alpha: alphaVal),
      ModifierCategory.finalModifier => Colors.grey.withValues(alpha: alphaVal),
    };
  }
}
