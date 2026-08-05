import 'package:flutter/material.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';

/// Interactive visual widget displaying a 6-Pokémon team's combined defensive synergy
/// across all 18 Pokémon elemental types.
class TeamDefenseMatrix extends StatelessWidget {
  final List<Pokemon?> team;

  const TeamDefenseMatrix({
    super.key,
    required this.team,
  });

  Color _getTypeColor(String type) => CombatUtils.typeColors[type.toLowerCase()] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePokemonList = team.whereType<Pokemon>().toList();

    if (activePokemonList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Text(
            'Add Pokémon to your team to inspect defensive type coverage.',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    // Calculate team defense stats for all 18 types
    final allTypes = [
      'normal', 'fire', 'water', 'electric', 'grass', 'ice',
      'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
      'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
    ];

    final Map<String, int> weakCounts = {for (var t in allTypes) t: 0};
    final Map<String, int> resistCounts = {for (var t in allTypes) t: 0};
    final Map<String, int> immuneCounts = {for (var t in allTypes) t: 0};

    for (final pokemon in activePokemonList) {
      final effs = TypeEfficiencyCalculator.getCombinedEffectiveness(pokemon.type1, pokemon.type2);
      effs.forEach((type, mult) {
        final t = type.toLowerCase();
        if (mult > 1.0) {
          weakCounts[t] = (weakCounts[t] ?? 0) + 1;
        } else if (mult == 0.0) {
          immuneCounts[t] = (immuneCounts[t] ?? 0) + 1;
        } else if (mult < 1.0) {
          resistCounts[t] = (resistCounts[t] ?? 0) + 1;
        }
      });
    }

    final vulnerableTypes = weakCounts.entries.where((e) => e.value >= 3).map((e) => e.key).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Team Defense Synergy Matrix',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${activePokemonList.length}/6 Members',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            ],
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),

          if (vulnerableTypes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Shared Vulnerabilities (3+ Members Weak): ${vulnerableTypes.map((t) => t.toUpperCase()).join(", ")}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.red[200] : Colors.red[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allTypes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final type = allTypes[index];
              final color = _getTypeColor(type);
              final weak = weakCounts[type] ?? 0;
              final resist = resistCounts[type] ?? 0;
              final immune = immuneCounts[type] ?? 0;
              final isHighRisk = weak >= 3;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isHighRisk
                      ? Colors.red.withValues(alpha: 0.15)
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isHighRisk ? Colors.redAccent : color.withValues(alpha: 0.4),
                    width: isHighRisk ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      type.toUpperCase(),
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (weak > 0)
                          Text('-$weak ', style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        if (resist > 0)
                          Text('+$resist ', style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        if (immune > 0)
                          Text('🛡$immune', style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        if (weak == 0 && resist == 0 && immune == 0)
                          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
