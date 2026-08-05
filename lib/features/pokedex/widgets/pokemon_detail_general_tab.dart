import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/abilitydex/views/ability_detail_screen.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/utils/pokemon_data_helpers.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';

import 'package:libredex/core/data/ev_yield_data.dart';
import 'package:libredex/core/data/pokedex_entry_data.dart';
import 'package:libredex/core/data/species_data.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:libredex/features/pokedex/widgets/shiny_slider.dart';

/// General (About) tab for the Pokémon Detail view.
/// Contains artwork slider, type efficiency, Pokédex entry, abilities,
/// evolutions, and biological / breeding data.
class PokemonDetailGeneralTab extends ConsumerWidget {
  final Pokemon activePokemon;
  final List<Pokemon> forms;

  const PokemonDetailGeneralTab({
    super.key,
    required this.activePokemon,
    required this.forms,
  });

  Color _getTypeColor(String type) => CombatUtils.typeColors[type.toLowerCase()] ?? Colors.grey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleEffs = TypeEfficiencyCalculator.getCombinedEffectiveness(
      activePokemon.type1,
      activePokemon.type2,
    );

    final Pokemon baseForm = forms.firstWhere(
      (p) => p.form == 'normal',
      orElse: () => forms.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        top: AppSpacing.topContentGap,
        bottom: AppSpacing.bottomScrollPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShinySlider(
            normalImageUrl: activePokemon.spriteUrl,
            shinyImageUrl: activePokemon.shinySpriteUrl,
            normalFallbackUrl: baseForm.spriteUrl,
            shinyFallbackUrl: baseForm.shinySpriteUrl,
            normalLabel: 'Normal',
            shinyLabel: 'Shiny',
            pokemonId: activePokemon.id,
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeBadge(activePokemon.type1),
              if (activePokemon.type2 != null) ...[
                const SizedBox(width: 12),
                _buildTypeBadge(activePokemon.type2!),
              ],
            ],
          ),
          const SizedBox(height: 24),

          _buildPokedexEntryCard(context, ref),
          const SizedBox(height: 20),

          _buildAbilitiesCard(context, ref),
          const SizedBox(height: 20),

          _buildBiologicalDataCard(context, ref),
          const SizedBox(height: 20),

          _buildEvolutionCard(context, ref),
          const SizedBox(height: 12),

          _buildTypeDexCard(context, doubleEffs),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final color = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeDexCard(BuildContext context, Map<String, double> efficiencies) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weaknesses = efficiencies.entries.where((e) => e.value > 1.0).toList();
    final resistances = efficiencies.entries.where((e) => e.value < 1.0 && e.value > 0.0).toList();
    final immunities = efficiencies.entries.where((e) => e.value == 0.0).toList();

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
          Text(
            'Type Relations (TypeDex)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),

          if (weaknesses.isNotEmpty) ...[
            const Text('Weaknesses (Takes Extra Damage)', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weaknesses.map((e) => _buildMiniTypeEffBadge(context, e.key, e.value)).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (resistances.isNotEmpty) ...[
            const Text('Resistances (Takes Less Damage)', style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resistances.map((e) => _buildMiniTypeEffBadge(context, e.key, e.value)).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (immunities.isNotEmpty) ...[
            const Text('Immunities (Zero Damage)', style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: immunities.map((e) => _buildMiniTypeEffBadge(context, e.key, e.value)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTypeEffBadge(BuildContext context, String type, double multiplier) {
    final color = _getTypeColor(type);
    String label = multiplier % 1 == 0 ? multiplier.toInt().toString() : multiplier.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            'x$label',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokedexEntryCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dexNumber = activePokemon.nationalDexNumber > 0 ? activePokemon.nationalDexNumber : activePokemon.id;
    final entriesAsync = ref.watch(pokedexEntryDatasetProvider);
    final entry = entriesAsync.asData?.value[dexNumber];
    if (entry == null || (entry.genus.isEmpty && entry.flavor.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.genus.isNotEmpty)
            Text(
              entry.genus,
              style: const TextStyle(color: AppTheme.pokemonRed, fontWeight: FontWeight.w900, letterSpacing: 0.3),
            ),
          if (entry.genus.isNotEmpty) const SizedBox(height: 8),
          Text(
            entry.flavor,
            style: TextStyle(
              color: isDark ? Colors.grey[200] : const Color(0xFF1F2937),
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackNote(String message, {required String source, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$message ($source)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.amber[200] : Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final abilitiesAsync = ref.watch(pokemonAbilitiesStreamProvider(activePokemon.id));
    final abilitiesList = abilitiesAsync.asData?.value;
    String? abilityFallbackFrom;
    if (abilitiesList != null) {
      for (final a in abilitiesList) {
        if (a['abilityFallbackFrom'] != null) {
          abilityFallbackFrom = a['abilityFallbackFrom'] as String?;
          break;
        }
      }
    }

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
          Text(
            'Abilities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),
          if (abilityFallbackFrom != null) ...[
            _buildFallbackNote(
              'Using base species abilities for this form.',
              source: abilityFallbackFrom,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          abilitiesAsync.when(
            data: (abilities) {
              if (abilities.isEmpty) {
                return AppEmptyState(
                  icon: Icons.auto_awesome_rounded,
                  title: 'No abilities linked yet',
                  message: 'Rebuild the bundled links now, or open Settings and use “Fix Moves & Abilities Links”.',
                  actionLabel: 'Fix links now',
                  onAction: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
                );
              }
              final sortedAbilities = List<Map<String, dynamic>>.from(abilities)
                ..sort((a, b) {
                  final bool aHidden = a['isHidden'] ?? false;
                  final bool bHidden = b['isHidden'] ?? false;
                  if (aHidden && !bHidden) return 1;
                  if (!aHidden && bHidden) return -1;
                  return 0;
                });

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedAbilities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ability = sortedAbilities[index];
                  final int? abilityId = ability['id'];
                  final String name = ability['name'] ?? '';
                  final String effect = ability['effect'] ?? 'No description available.';
                  final bool isHidden = ability['isHidden'] ?? false;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (abilityId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AbilityDetailScreen(abilityId: abilityId, abilityName: name)),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              if (isHidden) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.purpleAccent, width: 0.8),
                                  ),
                                  child: const Text(
                                    'HIDDEN',
                                    style: TextStyle(color: Colors.purpleAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            effect,
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                ),
              ),
            ),
            error: (err, stack) => Text('Error loading abilities: $err', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _navigateToPokemon(BuildContext context, WidgetRef ref, int targetId) async {
    if (targetId == activePokemon.id) return;

    final db = ref.read(pokemonRepositoryProvider).db;
    final targetPokemon = await (db.select(db.pokemonTable)..where((t) => t.id.equals(targetId))).getSingleOrNull();

    if (targetPokemon != null && context.mounted) {
      final int targetDexNum = targetPokemon.nationalDexNumber > 0 ? targetPokemon.nationalDexNumber : targetPokemon.id;
      final allForms = await (db.select(db.pokemonTable)..where((t) => t.nationalDexNumber.equals(targetDexNum))).get();
      final formsList = allForms.isNotEmpty ? allForms : [targetPokemon];
      final targetIdx = formsList.indexWhere((p) => p.id == targetId);

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PokemonDetailScreen(
            forms: formsList,
            initialFormIndex: targetIdx >= 0 ? targetIdx : 0,
          ),
        ),
      );
    }
  }

  Widget _buildEvolutionCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int dexNum = activePokemon.nationalDexNumber > 0 ? activePokemon.nationalDexNumber : activePokemon.id;
    final evoAsync = ref.watch(pokemonEvolutionChainProvider(dexNum));

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
              Text(
                'Evolutions & Forms',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const Spacer(),
              const Icon(Icons.account_tree_outlined, size: 18, color: AppTheme.pokemonRed),
            ],
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),
          evoAsync.when(
            data: (steps) {
              if (steps.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      'This Pokémon does not evolve.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isFormEvolution = step.form != 'normal';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isFormEvolution
                            ? AppTheme.pokemonRed.withValues(alpha: 0.4)
                            : (isDark ? const Color(0xFF2B2B2B) : const Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (isFormEvolution)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.pokemonRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.pokemonRed, width: 0.8),
                              ),
                              child: Text(
                                step.form.toUpperCase(),
                                style: const TextStyle(color: AppTheme.pokemonRed, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _navigateToPokemon(context, ref, step.fromId),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    children: [
                                      if (step.fromSprite != null && step.fromSprite!.isNotEmpty)
                                        SizedBox(
                                          height: 54,
                                          width: 54,
                                          child: PokemonSprite(
                                            imageUrl: step.fromSprite!,
                                            loadingIndicatorSize: 18,
                                          ),
                                        )
                                      else
                                        const Icon(Icons.catching_pokemon, size: 40, color: Colors.grey),
                                      const SizedBox(height: 4),
                                      Text(
                                        step.fromName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: step.fromId == activePokemon.id ? AppTheme.pokemonRed : (isDark ? Colors.white : Colors.black87),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      step.trigger,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.pokemonRed, size: 20),
                                ],
                              ),
                            ),

                            Expanded(
                              child: InkWell(
                                onTap: () => _navigateToPokemon(context, ref, step.toId),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    children: [
                                      if (step.toSprite != null && step.toSprite!.isNotEmpty)
                                        SizedBox(
                                          height: 54,
                                          width: 54,
                                          child: PokemonSprite(
                                            imageUrl: step.toSprite!,
                                            loadingIndicatorSize: 18,
                                          ),
                                        )
                                      else
                                        const Icon(Icons.catching_pokemon, size: 40, color: Colors.grey),
                                      const SizedBox(height: 4),
                                      Text(
                                        step.toName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: step.toId == activePokemon.id ? AppTheme.pokemonRed : (isDark ? Colors.white : Colors.black87),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                ),
              ),
            ),
            error: (err, stack) => Text('Could not load evolutions: $err', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildBiologicalDataCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final int bst = activePokemon.baseHp +
        activePokemon.baseAtk +
        activePokemon.baseDef +
        activePokemon.baseSpAtk +
        activePokemon.baseSpDef +
        activePokemon.baseSpd;

    final evYieldAsync = ref.watch(evYieldDatasetProvider);
    final realEvYield = evYieldAsync.asData?.value[activePokemon.id];
    final String evYield = realEvYield?.label ?? '${PokemonDataHelpers.getEvYield(activePokemon)} (estimated)';

    final datasetAsync = ref.watch(speciesDatasetProvider);
    final dataset = datasetAsync.asData?.value;
    final int dexNumber = activePokemon.nationalDexNumber > 0
        ? activePokemon.nationalDexNumber
        : activePokemon.id;
    final FormFacts? form = dataset?.formFacts(activePokemon.id, nationalDexNumber: dexNumber);
    final SpeciesFacts? species = dataset?.speciesFacts(dexNumber);

    Color bstColor = Colors.grey;
    String bstLabel = 'Standard BST';
    if (bst >= 600) {
      bstColor = Colors.purpleAccent;
      bstLabel = 'Top Tier / Legend';
    } else if (bst >= 500) {
      bstColor = Colors.tealAccent;
      bstLabel = 'Fully Evolved / High Power';
    } else if (bst >= 400) {
      bstColor = Colors.blueAccent;
      bstLabel = 'Mid Tier';
    }

    final gender = dataset?.genderFor(activePokemon.id, nationalDexNumber: dexNumber) ?? species?.gender;
    final bool isGenderless = gender?.genderless ?? true;
    final double malePct = gender?.malePercent ?? 0;
    final double femalePct = gender?.femalePercent ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Breeding, Training & EV Yields',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bstLabel,
                      style: TextStyle(color: bstColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bstColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bstColor, width: 1.0),
                ),
                child: Text(
                  '$bst BST',
                  style: TextStyle(color: bstColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),

          if (form != null) ...[
            _buildBioRow('Height', form.heightLabel, Icons.height_rounded, isDark),
            const SizedBox(height: 12),
            _buildBioRow('Weight', form.weightLabel, Icons.monitor_weight_rounded, isDark),
            const SizedBox(height: 12),
            _buildBioRow(
              'Base EXP',
              '${form.baseExp} EXP when defeated',
              Icons.military_tech_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
          ],

          _buildBioRow('EV Yield', evYield, Icons.fitness_center_rounded, isDark),
          const SizedBox(height: 12),

          if (species != null) ...[
            _buildBioRow('Egg Groups', species.eggGroupLabel, Icons.egg_rounded, isDark),
            const SizedBox(height: 12),
            if (species.canBreed) ...[
              _buildBioRow(
                'Hatch Time',
                '${species.eggCycles} cycles (~${species.eggSteps} steps)',
                Icons.timelapse_rounded,
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            _buildBioRow(
              'Catch Rate',
              species.captureRateLabel,
              Icons.catching_pokemon_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildBioRow(
              'Growth Rate',
              '${species.growthRate} (${_formatExp(species.growthTotalExp)} EXP to Lv. 100)',
              Icons.trending_up_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildBioRow(
              'Base Friendship',
              '${species.baseHappiness}',
              Icons.favorite_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildBioRow(
              'Generation',
              'Introduced in Gen ${species.generation}',
              Icons.public_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
          ],

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wc_rounded, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Gender Ratio',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isGenderless)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Genderless (100% N/A)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            if (malePct > 0 && (malePct * 10).round() > 0)
                              Expanded(
                                flex: (malePct * 10).round(),
                                child: Container(color: Colors.blueAccent),
                              ),
                            if (femalePct > 0 && (femalePct * 10).round() > 0)
                              Expanded(
                                flex: (femalePct * 10).round(),
                                child: Container(color: Colors.pinkAccent),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '♂ ${GenderRatio.formatPercent(malePct)}% Male',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        Text(
                          '♀ ${GenderRatio.formatPercent(femalePct)}% Female',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatExp(int value) => value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );

  Widget _buildBioRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
