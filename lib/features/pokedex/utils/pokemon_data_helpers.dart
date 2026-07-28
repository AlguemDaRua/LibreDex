import 'package:libredex/core/database/app_database.dart';

/// Derived training data that is computed from base stats.
///
/// Breeding, catching and physical facts are *not* guessed here — they come from
/// the bundled PokeAPI dataset in `core/data/species_data.dart`.
class PokemonDataHelpers {
  /// Calculates the primary EV Yield provided upon defeating this Pokémon.
  /// Standard formula based on base stat distribution and stage/legendary status.
  static String getEvYield(Pokemon p) {
    final Map<String, int> stats = {
      'HP': p.baseHp,
      'Attack': p.baseAtk,
      'Defense': p.baseDef,
      'Sp. Atk': p.baseSpAtk,
      'Sp. Def': p.baseSpDef,
      'Speed': p.baseSpd,
    };

    final bst = p.baseHp + p.baseAtk + p.baseDef + p.baseSpAtk + p.baseSpDef + p.baseSpd;
    int points = 1;
    if (bst >= 600 || p.isLegendary || p.isMythical) {
      points = 3;
    } else if (bst >= 450) {
      points = 2;
    }

    // Find stat with highest base value
    final sorted = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topStat = sorted.first;

    // Check if second stat is very close (dual EV yield)
    if (sorted[1].value >= topStat.value * 0.95 && points >= 2) {
      return '+1 ${topStat.key}, +1 ${sorted[1].key}';
    }

    return '+$points ${topStat.key}';
  }

  /// Returns stat keys ('hp', 'atk', 'def', 'spatk', 'spdef', 'spd') that this Pokémon yields EVs for.
  static List<String> getEvYieldStatKeys(Pokemon p) {
    final Map<String, int> stats = {
      'hp': p.baseHp,
      'atk': p.baseAtk,
      'def': p.baseDef,
      'spatk': p.baseSpAtk,
      'spdef': p.baseSpDef,
      'spd': p.baseSpd,
    };

    final sorted = stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topKey = sorted.first.key;
    final keys = [topKey];

    if (sorted[1].value >= sorted.first.value * 0.95) {
      keys.add(sorted[1].key);
    }

    return keys;
  }
}
