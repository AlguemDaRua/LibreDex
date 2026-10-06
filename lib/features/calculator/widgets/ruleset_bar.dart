import 'package:flutter/material.dart';
import 'package:libredex/core/data/battle_data_manifest.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';

/// Single adaptive ruleset selector — Champions (66 SP) vs Mainline.
/// Extracted from the 3.8k-line DamageCalculatorScreen for instant load
/// and zero redundant storytelling (icon + two pills + ⓘ suffices).
class RulesetBar extends StatelessWidget {
  final bool isDark;
  final DamageCalculatorState state;
  final DamageCalculatorViewModel vm;
  const RulesetBar({
    super.key,
    required this.isDark,
    required this.state,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final isChampions = state.ruleset.isChampions;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChampions
              ? Colors.deepPurpleAccent.withValues(alpha: 0.45)
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final ruleset in BattleRuleset.values) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => vm.setRuleset(ruleset),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: state.ruleset == ruleset
                            ? (ruleset.isChampions
                                  ? Colors.deepPurpleAccent
                                  : AppTheme.pokemonRed)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            ruleset.isChampions
                                ? Icons.emoji_events_rounded
                                : Icons.videogame_asset_rounded,
                            size: 14,
                            color: state.ruleset == ruleset
                                ? Colors.white
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ruleset.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: state.ruleset == ruleset
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.verified_outlined,
                  size: 18,
                  color: Colors.blueAccent,
                ),
                tooltip: 'Engine Parity & Data Manifest',
                onPressed: () => _showManifestDialog(context),
              ),
            ],
          ),
          if (isChampions) ...[
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Champions uses 66 Stat Points instead of EVs and its own fixed stat formula.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.35,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showManifestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Battle Engine Manifest',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in BattleDataManifest.details.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
