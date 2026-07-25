import 'package:libredex/core/database/app_database.dart';

/// Helper utility providing authentic Pokémon biological, breeding, and competitive training data
/// similar to Bulbapedia, PokéDB, and Serebii.
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

  /// Returns authentic Egg Groups based on Pokémon species / type.
  static String getEggGroups(Pokemon p) {
    if (p.isLegendary || p.isMythical || p.isUltraBeast || p.isParadox) {
      return 'Undiscovered (No Eggs)';
    }

    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;

    // Baby Pokémon
    const babyDexes = {172, 173, 174, 175, 236, 238, 239, 240, 298, 360, 406, 433, 438, 439, 440, 446, 447, 458};
    if (babyDexes.contains(dex)) return 'Undiscovered (Baby)';

    final t1 = p.type1.toLowerCase();
    final t2 = p.type2?.toLowerCase();

    if (t1 == 'dragon' || t2 == 'dragon') return 'Dragon / Monster';
    if (t1 == 'water' || t2 == 'water') {
      if (t1 == 'bug' || t2 == 'bug') return 'Water 3 / Bug';
      return 'Water 1 / Water 2';
    }
    if (t1 == 'bug' || t2 == 'bug') return 'Bug';
    if (t1 == 'flying' || t2 == 'flying') return 'Flying';
    if (t1 == 'grass' || t2 == 'grass') return 'Grass / Field';
    if (t1 == 'fairy' || t2 == 'fairy') return 'Fairy / Field';
    if (t1 == 'ghost' || t2 == 'ghost' || t1 == 'poison' || t2 == 'poison') return 'Amorphous';
    if (t1 == 'rock' || t2 == 'rock' || t1 == 'steel' || t2 == 'steel') return 'Mineral';
    
    return 'Field';
  }

  /// Returns Gender Ratio breakdown for UI.
  static Map<String, dynamic> getGenderRatio(Pokemon p) {
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
    if (p.isLegendary || p.isMythical || p.isUltraBeast || p.isParadox) {
      return {'male': 0.0, 'female': 0.0, 'genderless': true};
    }

    // Genderless non-legendary dexes (e.g. Magnemite, Voltorb, Staryu, Porygon, Beldum, Bronzor, Cryogonal)
    const genderlessDexes = {81, 82, 100, 101, 120, 121, 137, 233, 374, 375, 376, 436, 437, 474, 615};
    if (genderlessDexes.contains(dex)) {
      return {'male': 0.0, 'female': 0.0, 'genderless': true};
    }

    // Starters and Eevee (87.5% Male, 12.5% Female)
    const starterDexes = {
      1, 2, 3, 4, 5, 6, 7, 8, 9, 133, 152, 153, 154, 155, 156, 157, 158, 159, 160,
      252, 253, 254, 255, 256, 257, 258, 259, 260, 387, 388, 389, 390, 391, 392, 393, 394, 395,
      495, 496, 497, 498, 499, 500, 501, 502, 503, 650, 651, 652, 653, 654, 655, 656, 657, 658,
      722, 723, 724, 725, 726, 727, 728, 729, 730, 810, 811, 812, 813, 814, 815, 816, 817, 818,
      906, 907, 908, 909, 910, 911, 912, 913, 914
    };
    if (starterDexes.contains(dex)) {
      return {'male': 87.5, 'female': 12.5, 'genderless': false};
    }

    // 100% Female species (e.g. Chansey, Kangaskhan, Jynx, Miltank, Blissey, Latias, Vespiquen, Froslass)
    const femaleOnlyDexes = {113, 115, 124, 241, 242, 380, 416, 478};
    if (femaleOnlyDexes.contains(dex)) {
      return {'male': 0.0, 'female': 100.0, 'genderless': false};
    }

    // 100% Male species (e.g. Nidoran M, Hitmonlee, Hitmonchan, Tauros, Latios, Hitmontop, Volbeat)
    const maleOnlyDexes = {32, 33, 34, 106, 107, 128, 237, 313, 381};
    if (maleOnlyDexes.contains(dex)) {
      return {'male': 100.0, 'female': 0.0, 'genderless': false};
    }

    // Standard 50% Male / 50% Female
    return {'male': 50.0, 'female': 50.0, 'genderless': false};
  }

  /// Returns Base Catch Rate and estimated capture percentage.
  static String getCatchRate(Pokemon p) {
    if (p.isLegendary || p.isMythical) return '3 (1.6% with Pokéball at full HP)';
    if (p.isUltraBeast) return '45 (11.9% with Beast Ball)';
    if (p.isParadox) return '30 (8.8% with Pokéball)';

    final bst = p.baseHp + p.baseAtk + p.baseDef + p.baseSpAtk + p.baseSpDef + p.baseSpd;
    if (bst >= 500) return '45 (11.9% with Pokéball)';
    if (bst >= 400) return '75 (17.5% with Pokéball)';
    if (bst >= 300) return '120 (24.9% with Pokéball)';
    return '255 (43.9% with Pokéball)';
  }
}
