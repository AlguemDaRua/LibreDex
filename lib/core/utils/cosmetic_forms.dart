import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:libredex/core/database/app_database.dart';

/// Bundled pokemon -> ability junctions, loaded once.
///
/// Needed to tell cosmetic forms apart from real ones. A form with a different
/// ability is a different Pokemon in practice even when its stats are
/// identical - Meowstic-Female has Prankster, Greninja-Battle-Bond has Battle
/// Bond, Rockruff-Own-Tempo evolves into a different Lycanroc - so ability
/// has to be part of the test.
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

/// Ids of forms that are interchangeable with their species' base form,
/// because they match it on base stats, typing and abilities alike.
///
/// These are cosmetic variants - Pikachu in eight different caps, the four
/// interchangeable Mimikyu, most Gigantamax forms. Picking one can never
/// change a battle outcome, so pickers hide them. Forms that genuinely differ
/// (Megas, regional variants, Rotom, Toxtricity) are kept.
///
/// Ability is part of the comparison: ten forms have identical stats but a
/// different ability, and those do change outcomes.
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
