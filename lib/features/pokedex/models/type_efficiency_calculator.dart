/// Utility class to calculate type effectiveness, weaknesses, and resistances for Pokémon.
/// Supports dual-typing logic and returns combined multipliers.
class TypeEfficiencyCalculator {
  TypeEfficiencyCalculator._();

  static const List<String> allTypes = [
    'normal', 'fire', 'water', 'grass', 'electric', 'ice', 'fighting', 'poison',
    'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark',
    'steel', 'fairy'
  ];

  /// Mapping from a defending type to a map of attacking types and their multipliers.
  /// Standard Generation VI+ type effectiveness chart.
  static const Map<String, Map<String, double>> _typeChart = {
    'normal': {
      'fighting': 2.0,
      'ghost': 0.0,
    },
    'fire': {
      'water': 2.0,
      'ground': 2.0,
      'rock': 2.0,
      'fire': 0.5,
      'grass': 0.5,
      'ice': 0.5,
      'bug': 0.5,
      'steel': 0.5,
      'fairy': 0.5,
    },
    'water': {
      'grass': 2.0,
      'electric': 2.0,
      'fire': 0.5,
      'water': 0.5,
      'ice': 0.5,
      'steel': 0.5,
    },
    'grass': {
      'fire': 2.0,
      'ice': 2.0,
      'poison': 2.0,
      'flying': 2.0,
      'bug': 2.0,
      'water': 0.5,
      'grass': 0.5,
      'electric': 0.5,
      'ground': 0.5,
    },
    'electric': {
      'ground': 2.0,
      'electric': 0.5,
      'flying': 0.5,
      'steel': 0.5,
    },
    'ice': {
      'fire': 2.0,
      'fighting': 2.0,
      'rock': 2.0,
      'steel': 2.0,
      'ice': 0.5,
    },
    'fighting': {
      'flying': 2.0,
      'psychic': 2.0,
      'fairy': 2.0,
      'bug': 0.5,
      'rock': 0.5,
      'dark': 0.5,
    },
    'poison': {
      'ground': 2.0,
      'psychic': 2.0,
      'grass': 0.5,
      'fighting': 0.5,
      'poison': 0.5,
      'bug': 0.5,
      'fairy': 0.5,
    },
    'ground': {
      'water': 2.0,
      'grass': 2.0,
      'ice': 2.0,
      'poison': 0.5,
      'rock': 0.5,
      'electric': 0.0,
    },
    'flying': {
      'electric': 2.0,
      'ice': 2.0,
      'rock': 2.0,
      'grass': 0.5,
      'fighting': 0.5,
      'bug': 0.5,
      'ground': 0.0,
    },
    'psychic': {
      'bug': 2.0,
      'ghost': 2.0,
      'dark': 2.0,
      'fighting': 0.5,
      'psychic': 0.5,
    },
    'bug': {
      'fire': 2.0,
      'flying': 2.0,
      'rock': 2.0,
      'grass': 0.5,
      'fighting': 0.5,
      'ground': 0.5,
    },
    'rock': {
      'water': 2.0,
      'grass': 2.0,
      'fighting': 2.0,
      'ground': 2.0,
      'steel': 2.0,
      'normal': 0.5,
      'fire': 0.5,
      'poison': 0.5,
      'flying': 0.5,
    },
    'ghost': {
      'ghost': 2.0,
      'dark': 2.0,
      'poison': 0.5,
      'bug': 0.5,
      'normal': 0.0,
      'fighting': 0.0,
    },
    'dragon': {
      'ice': 2.0,
      'dragon': 2.0,
      'fairy': 2.0,
      'fire': 0.5,
      'water': 0.5,
      'grass': 0.5,
      'electric': 0.5,
    },
    'dark': {
      'fighting': 2.0,
      'bug': 2.0,
      'fairy': 2.0,
      'ghost': 0.5,
      'dark': 0.5,
      'psychic': 0.0,
    },
    'steel': {
      'fire': 2.0,
      'fighting': 2.0,
      'ground': 2.0,
      'normal': 0.5,
      'grass': 0.5,
      'ice': 0.5,
      'flying': 0.5,
      'psychic': 0.5,
      'bug': 0.5,
      'rock': 0.5,
      'dragon': 0.5,
      'steel': 0.5,
      'fairy': 0.5,
      'poison': 0.0,
    },
    'fairy': {
      'poison': 2.0,
      'steel': 2.0,
      'fighting': 0.5,
      'bug': 0.5,
      'dark': 0.5,
      'dragon': 0.0,
    },
  };

  /// Calculates defensive effectiveness multipliers for all types against the given dual tipagem.
  /// Returns a map of: Attacking Type -> Combined Multiplier (e.g. 'fire' -> 2.0, 'electric' -> 0.0).
  static Map<String, double> getCombinedEffectiveness(String type1, String? type2) {
    final Map<String, double> effectiveness = {};

    final t1 = type1.trim().toLowerCase();
    final t2 = type2?.trim().toLowerCase();

    for (final attackingType in allTypes) {
      double mult1 = 1.0;
      double mult2 = 1.0;

      // 1. Get multiplier against type1
      if (_typeChart[t1]?.containsKey(attackingType) ?? false) {
        mult1 = _typeChart[t1]![attackingType]!;
      }

      // 2. Get multiplier against type2
      if (t2 != null && (_typeChart[t2]?.containsKey(attackingType) ?? false)) {
        mult2 = _typeChart[t2]![attackingType]!;
      }

      final combined = mult1 * mult2;
      // We only store if it modifies normal damage (not equal to 1.0)
      if (combined != 1.0) {
        effectiveness[attackingType] = combined;
      }
    }

    return effectiveness;
  }
}
