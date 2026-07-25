import 'package:flutter/material.dart';

class CombatUtils {
  static final Map<String, Color> typeColors = {
    'normal': const Color(0xFFA8A77A),
    'fire': const Color(0xFFEE8130),
    'water': const Color(0xFF6390F0),
    'electric': const Color(0xFFF7D02C),
    'grass': const Color(0xFF7AC74C),
    'ice': const Color(0xFF96D9D6),
    'fighting': const Color(0xFFC22E28),
    'poison': const Color(0xFFA33EA1),
    'ground': const Color(0xFFE2BF65),
    'flying': const Color(0xFFA98FEE),
    'psychic': const Color(0xFFF95587),
    'bug': const Color(0xFFA6B91A),
    'rock': const Color(0xFFB6A136),
    'ghost': const Color(0xFF735797),
    'dragon': const Color(0xFF6F35FC),
    'dark': const Color(0xFF705746),
    'steel': const Color(0xFFB7B7CE),
    'fairy': const Color(0xFFD685AD),
  };

  static final List<String> allTypes = typeColors.keys.toList();

  static final Map<String, Map<String, List<String>>> effectivenessMap = {
    'normal': {
      'double': [],
      'half': ['rock', 'steel'],
      'zero': ['ghost'],
    },
    'fire': {
      'double': ['grass', 'ice', 'bug', 'steel'],
      'half': ['fire', 'water', 'rock', 'dragon'],
      'zero': [],
    },
    'water': {
      'double': ['fire', 'ground', 'rock'],
      'half': ['water', 'grass', 'dragon'],
      'zero': [],
    },
    'electric': {
      'double': ['water', 'flying'],
      'half': ['electric', 'grass', 'dragon'],
      'zero': ['ground'],
    },
    'grass': {
      'double': ['water', 'ground', 'rock'],
      'half': ['fire', 'grass', 'poison', 'flying', 'bug', 'dragon', 'steel'],
      'zero': [],
    },
    'ice': {
      'double': ['grass', 'ground', 'flying', 'dragon'],
      'half': ['fire', 'water', 'ice', 'steel'],
      'zero': [],
    },
    'fighting': {
      'double': ['normal', 'ice', 'rock', 'dark', 'steel'],
      'half': ['poison', 'flying', 'psychic', 'bug', 'fairy'],
      'zero': ['ghost'],
    },
    'poison': {
      'double': ['grass', 'fairy'],
      'half': ['poison', 'ground', 'rock', 'ghost'],
      'zero': ['steel'],
    },
    'ground': {
      'double': ['fire', 'electric', 'poison', 'rock', 'steel'],
      'half': ['grass', 'bug'],
      'zero': ['flying'],
    },
    'flying': {
      'double': ['grass', 'fighting', 'bug'],
      'half': ['electric', 'rock', 'steel'],
      'zero': [],
    },
    'psychic': {
      'double': ['fighting', 'poison'],
      'half': ['psychic', 'steel'],
      'zero': ['dark'],
    },
    'bug': {
      'double': ['grass', 'psychic', 'dark'],
      'half': ['fire', 'fighting', 'poison', 'flying', 'ghost', 'steel', 'fairy'],
      'zero': [],
    },
    'rock': {
      'double': ['fire', 'ice', 'flying', 'bug'],
      'half': ['fighting', 'ground', 'steel'],
      'zero': [],
    },
    'ghost': {
      'double': ['psychic', 'ghost'],
      'half': ['dark'],
      'zero': ['normal'],
    },
    'dragon': {
      'double': ['dragon'],
      'half': ['steel'],
      'zero': ['fairy'],
    },
    'dark': {
      'double': ['psychic', 'ghost'],
      'half': ['fighting', 'dark', 'fairy'],
      'zero': [],
    },
    'steel': {
      'double': ['ice', 'rock', 'fairy'],
      'half': ['fire', 'water', 'electric', 'steel'],
      'zero': [],
    },
    'fairy': {
      'double': ['fighting', 'dragon', 'dark'],
      'half': ['fire', 'poison', 'steel'],
      'zero': [],
    },
  };

  static double getStageMultiplier(int stage) {
    if (stage > 0) {
      return (2 + stage) / 2;
    } else if (stage < 0) {
      return 2 / (2 - stage);
    }
    return 1.0;
  }

  static double getNatureMultiplier(String nature, String stat) {
    final n = nature.toLowerCase();
    if (stat == 'Attack') {
      if (['adamant', 'brave', 'lonely', 'naughty'].contains(n)) return 1.1;
      if (['bold', 'calm', 'modest', 'timid'].contains(n)) return 0.9;
    }
    if (stat == 'Defense') {
      if (['bold', 'impish', 'lax', 'relaxed'].contains(n)) return 1.1;
      if (['gentle', 'hasty', 'lonely', 'mild'].contains(n)) return 0.9;
    }
    if (stat == 'Sp. Atk') {
      if (['modest', 'mild', 'quiet', 'rash'].contains(n)) return 1.1;
      if (['adamant', 'careful', 'impish', 'jolly'].contains(n)) return 0.9;
    }
    if (stat == 'Sp. Def') {
      if (['calm', 'careful', 'gentle', 'sassy'].contains(n)) return 1.1;
      if (['lax', 'naive', 'naughty', 'rash'].contains(n)) return 0.9;
    }
    if (stat == 'Speed') {
      if (['timid', 'jolly', 'hasty', 'naive'].contains(n)) return 1.1;
      if (['brave', 'quiet', 'relaxed', 'sassy'].contains(n)) return 0.9;
    }
    return 1.0;
  }

  /// Calculate dynamic base power for special moves (Return, Frustration, Eruption, Water Spout, Facade, Acrobatics, Knock Off, Hex, Foul Play, etc.)
  static double calculateDynamicBasePower({
    required String moveName,
    required double basePower,
    int friendship = 255,
    double attackerHpPercent = 100.0,
    double defenderHpPercent = 100.0,
    String attackerStatus = 'none',
    String defenderStatus = 'none',
    String attackerHeldItem = 'None',
    String defenderHeldItem = 'None',
    int rageFistHits = 0,
  }) {
    final mName = moveName.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim();

    if (mName == 'return') {
      return (friendship * 2 / 5).floorToDouble().clamp(1.0, 102.0);
    }
    if (mName == 'frustration') {
      return ((255 - friendship) * 2 / 5).floorToDouble().clamp(1.0, 102.0);
    }
    if (mName == 'eruption' || mName == 'water spout') {
      return (150.0 * (attackerHpPercent / 100.0)).floorToDouble().clamp(1.0, 150.0);
    }
    if (mName == 'facade') {
      return (attackerStatus != 'none' && attackerStatus != 'freeze' && attackerStatus != 'sleep') ? 140.0 : 70.0;
    }
    if (mName == 'acrobatics') {
      return (attackerHeldItem == 'None') ? 110.0 : 55.0;
    }
    if (mName == 'knock off') {
      return (defenderHeldItem != 'None') ? (basePower * 1.5) : basePower;
    }
    if (mName == 'hex' || mName == 'bitter malice') {
      return (defenderStatus != 'none') ? 130.0 : 65.0;
    }
    if (mName == 'rage fist') {
      return 50.0 + (rageFistHits.clamp(0, 6) * 50.0);
    }
    if (mName == 'brine') {
      return (defenderHpPercent <= 50.0) ? 130.0 : 65.0;
    }
    return basePower;
  }

  static double getTypeEffectiveness(
    String moveType,
    String t1,
    String? t2, {
    String? attackerAbility,
    String? defenderAbility,
    String? moveName,
    bool defenderTeraActive = false,
    String? defenderTeraType,
  }) {
    final move = moveType.toLowerCase();
    // Tera defense overrides defender types to single Tera type
    final type1 = (defenderTeraActive && defenderTeraType != null && defenderTeraType.isNotEmpty)
        ? defenderTeraType.toLowerCase()
        : t1.toLowerCase();
    final type2 = (defenderTeraActive && defenderTeraType != null && defenderTeraType.isNotEmpty)
        ? null
        : t2?.toLowerCase();

    final atkAbility = attackerAbility?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';
    final defAbility = defenderAbility?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';
    final mName = moveName?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';

    // Check Mind's Eye or Scrappy bypass against Ghost types
    final hasGhostBypass = atkAbility == 'minds eye' || atkAbility == 'mind\'s eye' || atkAbility == 'scrappy';

    double getSingleTypeMultiplier(String attacking, String defending) {
      final data = effectivenessMap[attacking];
      if (data == null) return 1.0;

      if ((data['double'] ?? []).contains(defending)) return 2.0;
      if ((data['half'] ?? []).contains(defending)) return 0.5;
      if ((data['zero'] ?? []).contains(defending)) {
        if (hasGhostBypass && (attacking == 'normal' || attacking == 'fighting') && defending == 'ghost') {
          return 1.0; // Bypasses Ghost immunity
        }
        return 0.0;
      }
      return 1.0;
    }

    double mult = getSingleTypeMultiplier(move, type1);
    if (type2 != null) {
      mult *= getSingleTypeMultiplier(move, type2);
    }

    // ── Defender Ability Immunities ──
    if (defAbility == 'well baked body' || defAbility == 'flash fire') {
      if (move == 'fire') return 0.0;
    }
    if (defAbility == 'levitate' || defAbility == 'earth eater') {
      if (move == 'ground') return 0.0;
    }
    if (defAbility == 'volt absorb' || defAbility == 'motor drive' || defAbility == 'lightning rod') {
      if (move == 'electric') return 0.0;
    }
    if (defAbility == 'water absorb' || defAbility == 'storm drain' || defAbility == 'dry skin') {
      if (move == 'water') return 0.0;
    }
    if (defAbility == 'sap sipper') {
      if (move == 'grass') return 0.0;
    }
    if (defAbility == 'wonder guard') {
      if (mult <= 1.0) return 0.0;
    }

    // Soundproof immunity
    if (defAbility == 'soundproof') {
      const soundMoves = {
        'hyper voice', 'boomburst', 'bug buzz', 'torch song', 'snarl',
        'clanging scales', 'roar', 'sing', 'overdrive', 'alluring voice',
        'relic song', 'disarming voice', 'metal sound', 'screech', 'uproar'
      };
      if (soundMoves.contains(mName)) return 0.0;
    }

    // Bulletproof immunity
    if (defAbility == 'bulletproof') {
      const bulletMoves = {
        'shadow ball', 'sludge bomb', 'gyro ball', 'energy ball', 'focus blast',
        'weather ball', 'electro ball', 'beak blast', 'rock wrecker', 'magnet bomb',
        'mud bomb', 'pyro ball', 'seed bomb', 'zap cannon', 'acid spray'
      };
      if (bulletMoves.contains(mName)) return 0.0;
    }

    // ── Defender Ability Damage Modifiers ──
    if (defAbility == 'thick fat') {
      if (move == 'fire' || move == 'ice') mult *= 0.5;
    }
    if (defAbility == 'heatproof') {
      if (move == 'fire') mult *= 0.5;
    }
    if (defAbility == 'purifying salt') {
      if (move == 'ghost') mult *= 0.5;
    }
    if (defAbility == 'dry skin') {
      if (move == 'fire') mult *= 1.25;
    }
    if (defAbility == 'fluffy') {
      if (move == 'fire') mult *= 2.0;
    }
    if (defAbility == 'filter' || defAbility == 'solid rock' || defAbility == 'prism armor') {
      if (mult > 1.0) mult *= 0.75;
    }

    // ── Attacker Ability Modifiers ──
    if (atkAbility == 'tinted lens') {
      if (mult < 1.0 && mult > 0.0) mult *= 2.0;
    }

    return mult;
  }

  /// Helper to return a human-readable badge summary when an ability alters effectiveness.
  static String? getAbilityContextBadge({
    required String moveType,
    required String t1,
    String? t2,
    String? attackerAbility,
    String? defenderAbility,
    String? moveName,
    bool defenderTeraActive = false,
    String? defenderTeraType,
  }) {
    final move = moveType.toLowerCase();
    final atkAbility = attackerAbility?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';
    final defAbility = defenderAbility?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';

    if ((atkAbility == 'minds eye' || atkAbility == 'mind\'s eye' || atkAbility == 'scrappy') &&
        (move == 'normal' || move == 'fighting') &&
        (t1.toLowerCase() == 'ghost' || t2?.toLowerCase() == 'ghost')) {
      return '👁️ Mind\'s Eye / Scrappy: Hits Ghost (1.0x)';
    }
    if (atkAbility == 'tinted lens') {
      final baseMult = getTypeEffectiveness(moveType, t1, t2, defenderAbility: defenderAbility, moveName: moveName, defenderTeraActive: defenderTeraActive, defenderTeraType: defenderTeraType);
      if (baseMult < 1.0 && baseMult > 0.0) {
        return '👓 Tinted Lens: Doubled Effectiveness';
      }
    }

    if ((defAbility == 'well baked body' || defAbility == 'flash fire') && move == 'fire') {
      return '🔥 Well-Baked Body / Flash Fire: IMMUNE (0x)';
    }
    if ((defAbility == 'levitate' || defAbility == 'earth eater') && move == 'ground') {
      return '🌪️ Levitate / Earth Eater: IMMUNE (0x)';
    }
    if ((defAbility == 'volt absorb' || defAbility == 'motor drive' || defAbility == 'lightning rod') && move == 'electric') {
      return '⚡ Volt Absorb / Motor Drive: IMMUNE (0x)';
    }
    if ((defAbility == 'water absorb' || defAbility == 'storm drain' || defAbility == 'dry skin') && move == 'water') {
      return '💧 Water Absorb / Dry Skin: IMMUNE (0x)';
    }
    if (defAbility == 'sap sipper' && move == 'grass') {
      return '🌿 Sap Sipper: IMMUNE (0x)';
    }
    if (defAbility == 'wonder guard') {
      final baseMult = getTypeEffectiveness(moveType, t1, t2, defenderTeraActive: defenderTeraActive, defenderTeraType: defenderTeraType);
      if (baseMult <= 1.0) {
        return '🛡️ Wonder Guard: IMMUNE (0x)';
      }
    }
    if (defAbility == 'soundproof') {
      const soundMoves = {'hyper voice', 'boomburst', 'bug buzz', 'torch song', 'snarl', 'overdrive'};
      if (soundMoves.contains(moveName?.toLowerCase())) return '🔊 Soundproof: IMMUNE (0x)';
    }
    if (defAbility == 'bulletproof') {
      const bulletMoves = {'shadow ball', 'sludge bomb', 'energy ball', 'focus blast', 'seed bomb'};
      if (bulletMoves.contains(moveName?.toLowerCase())) return '💣 Bulletproof: IMMUNE (0x)';
    }
    if (defAbility == 'thick fat' && (move == 'fire' || move == 'ice')) {
      return '🛡️ Thick Fat: RESIST (0.5x)';
    }
    if (defAbility == 'purifying salt' && move == 'ghost') {
      return '🧂 Purifying Salt: RESIST (0.5x)';
    }
    if (defAbility == 'heatproof' && move == 'fire') {
      return '🔥 Heatproof: RESIST (0.5x)';
    }
    if (defAbility == 'filter' || defAbility == 'solid rock' || defAbility == 'prism armor') {
      final baseMult = getTypeEffectiveness(moveType, t1, t2, defenderTeraActive: defenderTeraActive, defenderTeraType: defenderTeraType);
      if (baseMult > 1.0) {
        return '🛡️ Solid Rock / Filter: Reduced (0.75x)';
      }
    }
    return null;
  }
}
