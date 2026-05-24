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

  static double getTypeEffectiveness(String moveType, String t1, String? t2) {
    double mult = 1.0;
    double getSingleTypeMultiplier(String attacking, String defending) {
      final atk = attacking.toLowerCase();
      final def = defending.toLowerCase();
      final data = effectivenessMap[atk];
      if (data == null) return 1.0;

      if ((data['double'] ?? []).contains(def)) return 2.0;
      if ((data['half'] ?? []).contains(def)) return 0.5;
      if ((data['zero'] ?? []).contains(def)) return 0.0;
      return 1.0;
    }

    mult *= getSingleTypeMultiplier(moveType, t1);
    if (t2 != null) {
      mult *= getSingleTypeMultiplier(moveType, t2);
    }
    return mult;
  }
}
