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

  /// Every move whose base power depends on battle context rather than a
  /// fixed database value. Used to decide which low/no-power moves the duel
  /// move picker must still offer (Low Kick & co. have no `power` in
  /// moves.json, but the calculator resolves them).
  static const Set<String> dynamicBasePowerMoves = {
    'return', 'frustration', 'eruption', 'water spout', 'facade',
    'acrobatics', 'knock off', 'hex', 'bitter malice', 'rage fist', 'brine',
    // Weight-based gimmicks.
    'low kick', 'grass knot', 'heavy slam', 'heat crash',
    // Speed-based gimmicks.
    'gyro ball', 'electro ball',
    // Status / HP-based gimmicks.
    'venoshock', 'crush grip', 'wring out', 'flail', 'reversal', 'hard press',
    // Environment gimmicks (also change the move's type).
    'weather ball', 'terrain pulse',
  };

  static String _normalizeName(String moveName) =>
      moveName.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim();

  /// Whether [moveName] scales on battle context (weight, speed, status,
  /// item, HP, ...) instead of a fixed database power.
  static bool supportsDynamicBasePower(String moveName) =>
      dynamicBasePowerMoves.contains(_normalizeName(moveName));

  /// Effective attacking type of moves that transform with the battlefield.
  ///
  /// * Weather Ball becomes Fire/Water/Rock/Ice in sun/rain/sandstorm/snow.
  /// * Terrain Pulse becomes Electric/Grass/Psychic/Fairy on the matching
  ///   terrain.
  ///
  /// Returns [moveType] unchanged for everything else.
  static String effectiveMoveType({
    required String moveName,
    required String moveType,
    String weather = 'none',
    String terrain = 'none',
    String? attackerAbility,
  }) {
    final mName = _normalizeName(moveName);
    final ability = _normalizeName(attackerAbility ?? '');
    var type = moveType.toLowerCase();
    if (mName == 'weather ball') {
      type = switch (weather) {
        'sunny' => 'fire', 'rainy' => 'water', 'sandstorm' => 'rock',
        'snow' => 'ice', _ => type,
      };
    } else if (mName == 'terrain pulse') {
      type = switch (terrain) {
        'electric' => 'electric', 'grassy' => 'grass', 'psychic' => 'psychic',
        'misty' => 'fairy', _ => type,
      };
    }

    // Generation IX "-ate" abilities change Normal attacking moves before
    // STAB and type effectiveness. Normalize converts every attacking move.
    // (Status moves are never sent to this damage path.)
    if (ability == 'pixilate' && type == 'normal') return 'fairy';
    if (ability == 'aerilate' && type == 'normal') return 'flying';
    if (ability == 'refrigerate' && type == 'normal') return 'ice';
    if (ability == 'galvanize' && type == 'normal') return 'electric';
    if (ability == 'normalize') return 'normal';
    return type;
  }

  /// Protection interaction used by the current one-turn calculator.
  /// Moves that explicitly bypass/break protection deal normal damage; Unseen
  /// Fist only applies to contact moves and deals the protected 1/4 damage.
  static bool breaksProtect(String moveName) => const {
    'phantom force', 'shadow force', 'hyperspace fury', 'hyperspace hole',
    'feint', 'g max one blow', 'g max rapid flow',
  }.contains(_normalizeName(moveName));

  static bool isContactMove(String moveName) => const {
    'surging strikes', 'wicked blow', 'close combat', 'drain punch', 'body slam',
    'triple axel', 'dual wingbeat', 'double iron bash', 'flower trick',
    'knock off', 'u turn', 'flip turn', 'jet punch', 'aqua jet', 'fake out',
  }.contains(_normalizeName(moveName));

  static bool isUnseenFistProtectionHit(String moveName, String? ability) =>
      _normalizeName(ability ?? '') == 'unseen fist' && isContactMove(moveName);

  /// Whether a move is guaranteed to land as a critical hit in Gen IX.
  /// This is not a user toggle: Flower Trick and the listed high-crit moves
  /// must still be critical when the checkbox is off.
  static bool alwaysCriticalHit(String moveName) => const {
    'flower trick', 'wicked blow', 'surging strikes', 'frost breath', 'storm throw',
  }.contains(_normalizeName(moveName));

  /// Base power for each guaranteed strike. Variable-hit moves deliberately
  /// remain one hit until the calculator has an explicit hit-count control.
  /// Triple Axel is intentionally [20, 40, 60], not three 20 BP attacks.
  static List<int> guaranteedHitBasePowers(String moveName, int basePower) {
    final bp = basePower < 1 ? 1 : basePower;
    return switch (_normalizeName(moveName)) {
      'surging strikes' => const [25, 25, 25],
      'triple axel' => const [20, 40, 60],
      'dual wingbeat' || 'double iron bash' || 'double kick' || 'twineedle' => [bp, bp],
      _ => [bp],
    };
  }

  static int guaranteedHitCount(String moveName) =>
      guaranteedHitBasePowers(moveName, 1).length;

  /// Gen IX -ate/Normalize power bonus (20%) after a Normal move is changed.
  static double typeChangingAbilityPowerMultiplier(String? attackerAbility, String originalMoveType) {
    final ability = _normalizeName(attackerAbility ?? '');
    final original = originalMoveType.toLowerCase();
    if (original == 'normal' && const {'pixilate', 'aerilate', 'refrigerate', 'galvanize'}.contains(ability)) {
      return 1.2;
    }
    return ability == 'normalize' ? 1.2 : 1.0;
  }

  /// Effective base power for gimmick moves (Return, Frustration, Eruption,
  /// Water Spout, Facade, Acrobatics, Knock Off, Hex, Low Kick & co.).
  /// Thin wrapper over [resolveDynamicBasePower] for callers that only need
  /// the number and not the explanation note.
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
    double attackerWeightKg = 0,
    double defenderWeightKg = 0,
    double attackerSpeedStat = 0,
    double defenderSpeedStat = 0,
    String weather = 'none',
    String terrain = 'none',
    bool championsRules = false,
  }) {
    return resolveDynamicBasePower(
      moveName: moveName,
      basePower: basePower,
      friendship: friendship,
      attackerHpPercent: attackerHpPercent,
      defenderHpPercent: defenderHpPercent,
      attackerStatus: attackerStatus,
      defenderStatus: defenderStatus,
      attackerHeldItem: attackerHeldItem,
      defenderHeldItem: defenderHeldItem,
      rageFistHits: rageFistHits,
      attackerWeightKg: attackerWeightKg,
      defenderWeightKg: defenderWeightKg,
      attackerSpeedStat: attackerSpeedStat,
      defenderSpeedStat: defenderSpeedStat,
      weather: weather,
      terrain: terrain,
      championsRules: championsRules,
    ).basePower;
  }

  /// Full version of [calculateDynamicBasePower] that also explains the
  /// gimmick it applied. When no contextual rule matches, [note] is `null`
  /// and the plain [basePower] passes through.
  static ({double basePower, String? note}) resolveDynamicBasePower({
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
    double attackerWeightKg = 0,
    double defenderWeightKg = 0,
    double attackerSpeedStat = 0,
    double defenderSpeedStat = 0,
    String weather = 'none',
    String terrain = 'none',
    bool championsRules = false,
  }) {
    final mName = _normalizeName(moveName);

    if (mName == 'return') {
      final bp = (friendship * 2 / 5).floorToDouble().clamp(1.0, 102.0);
      return (basePower: bp, note: 'Friendship $friendship → ${bp.toInt()} BP');
    }
    if (mName == 'frustration') {
      final bp = ((255 - friendship) * 2 / 5).floorToDouble().clamp(1.0, 102.0);
      return (basePower: bp, note: 'Friendship $friendship → ${bp.toInt()} BP');
    }
    if (mName == 'eruption' || mName == 'water spout') {
      final bp = (150.0 * (attackerHpPercent / 100.0)).floorToDouble().clamp(1.0, 150.0);
      return (basePower: bp, note: 'Attacker at ${attackerHpPercent.toInt()}% HP → ${bp.toInt()} BP');
    }
    if (mName == 'facade') {
      final boosted = attackerStatus != 'none' && attackerStatus != 'freeze' && attackerStatus != 'sleep';
      return (basePower: boosted ? 140.0 : 70.0, note: boosted ? 'Attacker is statused → 140 BP' : null);
    }
    if (mName == 'acrobatics') {
      final boosted = attackerHeldItem == 'None';
      return (basePower: boosted ? 110.0 : 55.0, note: boosted ? 'No held item → 110 BP' : null);
    }
    if (mName == 'knock off') {
      final boosted = defenderHeldItem != 'None';
      return (basePower: boosted ? (basePower * 1.5) : basePower, note: boosted ? 'Target holds an item → ×1.5 BP' : null);
    }
    if (mName == 'hex' || mName == 'bitter malice') {
      final boosted = defenderStatus != 'none';
      return (basePower: boosted ? 130.0 : 65.0, note: boosted ? 'Target is statused → 130 BP' : null);
    }
    if (mName == 'rage fist') {
      // Champions deliberately removes Rage Fist's "hits taken" scaling;
      // Pokémon Showdown's Champions ruleset keeps it at its printed 50 BP.
      if (championsRules) return (basePower: 50.0, note: 'Champions: fixed at 50 BP');
      final hits = rageFistHits.clamp(0, 6).toInt();
      final bp = 50.0 + (hits * 50.0);
      return (basePower: bp, note: '$hits hits taken → ${bp.toInt()} BP');
    }
    if (mName == 'brine') {
      final boosted = defenderHpPercent <= 50.0;
      return (basePower: boosted ? 130.0 : 65.0, note: boosted ? 'Target below half HP → 130 BP' : null);
    }

    // ── Weight-based gimmicks (the defender feeds Low Kick / Grass Knot;
    // Heavy Slam / Heat Crash compare both weights) ──────────────────────
    if (mName == 'low kick' || mName == 'grass knot') {
      if (defenderWeightKg > 0) {
        final bp = lowKickPowerFor(defenderWeightKg).toDouble();
        return (basePower: bp, note: 'Target weighs ${_fmtKg(defenderWeightKg)} → ${bp.toInt()} BP');
      }
      return (basePower: basePower, note: null);
    }
    if (mName == 'heavy slam' || mName == 'heat crash') {
      if (attackerWeightKg > 0 && defenderWeightKg > 0) {
        final bp = heavySlamPowerFor(attackerWeightKg, defenderWeightKg).toDouble();
        final ratio = attackerWeightKg / defenderWeightKg;
        return (
          basePower: bp,
          note: '${_fmtKg(attackerWeightKg)} vs ${_fmtKg(defenderWeightKg)} '
              '(${ratio.toStringAsFixed(1)}×) → ${bp.toInt()} BP',
        );
      }
      return (basePower: basePower, note: null);
    }

    // ── Speed-based gimmicks ────────────────────────────────────────────
    if (mName == 'gyro ball') {
      if (attackerSpeedStat > 0 && defenderSpeedStat > 0) {
        final bp = (25.0 * defenderSpeedStat / attackerSpeedStat).floorToDouble().clamp(1.0, 150.0);
        return (
          basePower: bp,
          note: '25× (Spd ${defenderSpeedStat.round()} / ${attackerSpeedStat.round()}) → ${bp.toInt()} BP',
        );
      }
      return (basePower: basePower, note: null);
    }
    if (mName == 'electro ball') {
      if (attackerSpeedStat > 0 && defenderSpeedStat > 0) {
        final ratio = attackerSpeedStat / defenderSpeedStat;
        final double bp = ratio >= 4 ? 150 : ratio >= 3 ? 120 : ratio >= 2 ? 80 : ratio >= 1 ? 60 : 40;
        return (basePower: bp, note: 'Speed ratio ${ratio.toStringAsFixed(1)}× → ${bp.toInt()} BP');
      }
      return (basePower: basePower, note: null);
    }

    // ── Status / HP-based gimmicks ──────────────────────────────────────
    if (mName == 'venoshock') {
      final boosted = defenderStatus == 'poison' || defenderStatus == 'toxic';
      return (basePower: boosted ? 130.0 : 65.0, note: boosted ? 'Target is poisoned → 130 BP' : null);
    }
    if (mName == 'crush grip' || mName == 'wring out') {
      final bp = (120.0 * (defenderHpPercent / 100.0)).floorToDouble().clamp(1.0, 120.0);
      return (basePower: bp, note: 'Target at ${defenderHpPercent.toInt()}% HP → ${bp.toInt()} BP');
    }
    if (mName == 'flail' || mName == 'reversal') {
      final pct = attackerHpPercent;
      final double bp = pct < 4.167 ? 200 : pct < 10.417 ? 150 : pct < 20.833 ? 100 : pct < 35.417 ? 80 : pct < 68.75 ? 40 : 20;
      return (basePower: bp, note: 'Attacker at ${pct.toInt()}% HP → ${bp.toInt()} BP');
    }
    if (mName == 'hard press') {
      final bp = (100.0 * (defenderHpPercent / 100.0)).floorToDouble().clamp(1.0, 100.0);
      return (basePower: bp, note: 'Target at ${defenderHpPercent.toInt()}% HP → ${bp.toInt()} BP');
    }

    // ── Environment gimmicks (type changes handled by [effectiveMoveType]) ──
    if (mName == 'weather ball') {
      final effective = effectiveMoveType(moveName: moveName, moveType: 'normal', weather: weather);
      final boosted = effective != 'normal';
      if (boosted) {
        return (basePower: 100.0, note: 'Weather turns it ${effective.toUpperCase()} → 100 BP');
      }
      return (basePower: basePower, note: null);
    }
    if (mName == 'terrain pulse') {
      final effective = effectiveMoveType(moveName: moveName, moveType: 'normal', weather: weather, terrain: terrain);
      final boosted = effective != 'normal';
      if (boosted) {
        return (basePower: 100.0, note: 'Terrain turns it ${effective.toUpperCase()} → 100 BP');
      }
      return (basePower: basePower, note: null);
    }

    return (basePower: basePower, note: null);
  }

  /// Base power of Low Kick / Grass Knot against a target of [weightKg].
  static int lowKickPowerFor(double weightKg) {
    if (weightKg >= 200) return 120;
    if (weightKg >= 100) return 100;
    if (weightKg >= 50) return 80;
    if (weightKg >= 25) return 60;
    if (weightKg >= 10) return 40;
    return 20;
  }

  /// Base power of Heavy Slam / Heat Crash for an attacker of
  /// [attackerWeightKg] against a target of [defenderWeightKg].
  static int heavySlamPowerFor(double attackerWeightKg, double defenderWeightKg) {
    if (defenderWeightKg <= 0) return 0;
    final ratio = attackerWeightKg / defenderWeightKg;
    if (ratio >= 5) return 120;
    if (ratio >= 4) return 100;
    if (ratio >= 3) return 80;
    if (ratio >= 2) return 60;
    return 40;
  }

  static String _fmtKg(double kg) =>
      '${kg.toStringAsFixed(1)} kg';

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
    var defAbility = defenderAbility?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';
    final mName = moveName?.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim() ?? '';
    // These abilities suppress defender abilities for damage purposes, but
    // never erase a defender's actual typing/immunity.
    if (const {'mold breaker', 'turboblaze', 'teravolt'}.contains(atkAbility)) {
      defAbility = '';
    }

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
