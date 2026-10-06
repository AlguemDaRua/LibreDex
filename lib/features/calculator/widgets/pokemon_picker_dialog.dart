import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/widgets/debounced_search_field.dart';

/// Bundled pokemon -> ability junctions, loaded once.
///
/// Needed to tell cosmetic forms apart from real ones. A form with a different
/// ability changes damage even when its stats are identical - Meowstic-Female
/// has Prankster, Greninja-Battle-Bond has Battle Bond, Rockruff-Own-Tempo
/// evolves into a different Lycanroc - so ability must be part of the test.
final pokemonAbilityIdsProvider = FutureProvider<Map<int, Set<int>>>((
  ref,
) async {
  final raw = await rootBundle.loadString('assets/data/pokemon_abilities.json');
  final decoded = json.decode(raw) as List<dynamic>;
  final map = <int, Set<int>>{};
  for (final entry in decoded) {
    final row = entry as Map<String, dynamic>;
    final pokemonId = row['pokemonId'] as int;
    map.putIfAbsent(pokemonId, () => <int>{}).add(row['abilityId'] as int);
  }
  return map;
});

bool _sameAbilities(Set<int>? a, Set<int>? b) {
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

/// Ids of forms that can never change a damage result, because they match
/// their species' base form on base stats, typing and abilities alike.
///
/// These are cosmetic variants - Pikachu in eight different caps, the four
/// interchangeable Mimikyu, most Gigantamax forms. They are noise in a
/// calculator: picking one gives the same answer as picking the base form.
/// Forms that actually differ (Megas, regional variants, Rotom, Toxtricity)
/// are kept.
Set<int> cosmeticFormIds(List<Pokemon> all, Map<int, Set<int>> abilities) {
  final byDex = <int, List<Pokemon>>{};
  for (final p in all) {
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
    byDex.putIfAbsent(dex, () => []).add(p);
  }

  final cosmetic = <int>{};
  for (final group in byDex.values) {
    if (group.length < 2) continue;
    final base = group.firstWhere(
      (p) => p.form.toLowerCase() == 'normal',
      orElse: () => group.first,
    );
    for (final p in group) {
      if (p.id == base.id) continue;
      final identical =
          p.baseHp == base.baseHp &&
          p.baseAtk == base.baseAtk &&
          p.baseDef == base.baseDef &&
          p.baseSpAtk == base.baseSpAtk &&
          p.baseSpDef == base.baseSpDef &&
          p.baseSpd == base.baseSpd &&
          p.type1 == base.type1 &&
          p.type2 == base.type2 &&
          _sameAbilities(abilities[p.id], abilities[base.id]);
      if (identical) cosmetic.add(p.id);
    }
  }
  return cosmetic;
}

/// Searchable modal dialog for selecting an attacker or defender Pokémon.
class PokemonPickerDialog extends ConsumerWidget {
  final List<Pokemon> pokemonList;
  final bool isAttacker;
  final DamageCalculatorViewModel viewModel;

  const PokemonPickerDialog({
    super.key,
    required this.pokemonList,
    required this.isAttacker,
    required this.viewModel,
  });

  /// Displays the Pokémon picker dialog.
  static Future<void> show(
    BuildContext context, {
    required List<Pokemon> list,
    required bool isAttacker,
    required DamageCalculatorViewModel vm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PokemonPickerDialog(
        pokemonList: list,
        isAttacker: isAttacker,
        viewModel: vm,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final abilitiesAsync = ref.watch(pokemonAbilityIdsProvider);
    // Until the ability junctions arrive we show everything rather than
    // guessing: hiding a real form would be worse than briefly showing a
    // cosmetic one.
    final cosmetic = abilitiesAsync.maybeWhen(
      data: (abilities) => cosmeticFormIds(pokemonList, abilities),
      orElse: () => const <int>{},
    );
    var query = '';

    return StatefulBuilder(
      builder: (ctx, setState) {
        final filtered = pokemonList.where((p) {
          if (cosmetic.contains(p.id)) return false;
          final q = query.toLowerCase();
          return p.name.toLowerCase().contains(q) ||
              p.id.toString().contains(q) ||
              p.type1.toLowerCase().contains(q) ||
              (p.type2?.toLowerCase().contains(q) ?? false);
        }).toList();

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                        'Select ${isAttacker ? 'Attacker' : 'Defender'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DebouncedSearchField(
                    hintText: 'Search Pokémon by name, ID or type...',
                    initialValue: query,
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      final dexNumber = p.nationalDexNumber > 0
                          ? p.nationalDexNumber
                          : p.id;
                      return ListTile(
                        leading: p.spriteUrl.isNotEmpty
                            ? SizedBox(
                                width: 40,
                                height: 40,
                                child: PokemonSprite(
                                  imageUrl: p.spriteUrl,
                                  fallbackUrl: PokemonSprite.homeArtworkUrl(
                                    dexNumber,
                                  ),
                                  errorIconColor: Colors.grey,
                                  errorIconSize: 24,
                                ),
                              )
                            : const Icon(
                                Icons.catching_pokemon,
                                color: Colors.grey,
                              ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${p.type1.toUpperCase()}${p.type2 != null ? " / ${p.type2!.toUpperCase()}" : ""}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () async {
                          Navigator.pop(ctx);
                          try {
                            final abs = await ref
                                .read(databaseProvider)
                                .getPokemonAbilities(p.id);
                            final defAb = abs.isNotEmpty
                                ? abs.first.ability.name
                                : null;
                            if (isAttacker) {
                              viewModel.setAttacker(p, defaultAbility: defAb);
                            } else {
                              viewModel.setDefender(p, defaultAbility: defAb);
                            }
                          } catch (_) {
                            if (isAttacker) {
                              viewModel.setAttacker(p);
                            } else {
                              viewModel.setDefender(p);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
