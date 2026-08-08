/// 19-step Gen IX calculation pipeline for battle mechanics.
library;

import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/stat_comparison/models/stat_modifier.dart';
import 'package:libredex/features/battle_engine/models/applied_modifier.dart';
import 'package:libredex/features/battle_engine/models/battle_state.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';

class ModifierPipelineResult {
  final int effectiveBasePower;
  final int effectiveAttack;
  final int effectiveDefense;
  final String attackingStatKey; // 'atk', 'spa', 'def', 'spe'
  final String defendingStatKey; // 'def', 'spd'
  final double weatherMultiplier;
  final double stabMultiplier;
  final double typeEffectiveness;
  final bool isBurnApplied;
  final List<double> finalModifiers;
  final List<AppliedModifier> appliedModifiers;
  final List<String> warnings;

  const ModifierPipelineResult({
    required this.effectiveBasePower,
    required this.effectiveAttack,
    required this.effectiveDefense,
    required this.attackingStatKey,
    required this.defendingStatKey,
    required this.weatherMultiplier,
    required this.stabMultiplier,
    required this.typeEffectiveness,
    required this.isBurnApplied,
    required this.finalModifiers,
    required this.appliedModifiers,
    required this.warnings,
  });
}

class ModifierPipeline {
  ModifierPipeline._();

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim();

  /// Executes the pipeline to determine effective parameters for damage formula.
  static ModifierPipelineResult process(BattleState state, ComparisonStats attackerStats, ComparisonStats defenderStats) {
    final applied = <AppliedModifier>[];
    final warnings = <String>[];

    final moveName = _normalize(state.move.name);
    final attackerAbility = _normalize(state.attacker.ability ?? '');
    final defenderAbility = _normalize(state.defender.ability ?? '');
    final attackerItem = _normalize(state.attacker.heldItem);
    final defenderItem = _normalize(state.defender.heldItem);

    // ── 1. Determine Effective Move Type ────────────────────────────────────
    String effectiveType = state.move.type.toLowerCase();
    if (moveName == 'weather ball') {
      effectiveType = switch (state.field.weather) {
        'sunny' => 'fire',
        'rainy' => 'water',
        'sandstorm' => 'rock',
        'snow' => 'ice',
        _ => effectiveType,
      };
      if (state.field.weather != 'none') {
        applied.add(AppliedModifier(
          name: 'Weather Ball (${titleCasePokemonText(effectiveType)})',
          multiplier: 1.0,
          category: ModifierCategory.weather,
        ));
      }
    } else if (moveName == 'terrain pulse' && state.field.terrain != 'none') {
      effectiveType = switch (state.field.terrain) {
        'electric' => 'electric',
        'grassy' => 'grass',
        'psychic' => 'psychic',
        'misty' => 'fairy',
        _ => effectiveType,
      };
      applied.add(AppliedModifier(
        name: 'Terrain Pulse (${titleCasePokemonText(effectiveType)})',
        multiplier: 1.0,
        category: ModifierCategory.terrain,
      ));
    }

    // ── 2. Determine Attacking and Defending Stat Keys ───────────────────────
    String atkKey = state.move.isPhysical ? 'atk' : 'spa';
    String defKey = state.move.isPhysical ? 'def' : 'spd';

    // Move stat target overrides
    if (moveName == 'body press') {
      atkKey = 'def';
      applied.add(const AppliedModifier(
        name: 'Body Press (Uses Defense)',
        multiplier: 1.0,
        category: ModifierCategory.attack,
      ));
    } else if (moveName == 'foul play') {
      // Uses defender's raw/effective attack
      applied.add(const AppliedModifier(
        name: "Foul Play (Uses Defender's Attack)",
        multiplier: 1.0,
        category: ModifierCategory.attack,
      ));
    } else if (moveName == 'psyshock' || moveName == 'psystrike' || moveName == 'secret sword') {
      defKey = 'def';
      applied.add(AppliedModifier(
        name: '$moveName (Targets Defense)',
        multiplier: 1.0,
        category: ModifierCategory.defense,
      ));
    }

    // ── 3. Base Power Calculation ───────────────────────────────────────────
    int bp = state.move.basePower;

    if (bp <= 0 && !state.move.isStatus) {
      warnings.add('Base power is 0 for an attacking move. Check move configuration.');
    }

    // DB-accurate category checks — no more `contains('punch')` hacks
    final isPunching = CombatUtils.isPunchingMove(moveName);
    final isSlicing = CombatUtils.isSlicingMove(moveName);
    final isBiting = CombatUtils.isBitingMove(moveName);
    final isPulse = CombatUtils.isPulseMove(moveName);
    final isRecoil = CombatUtils.isRecoilMove(moveName);

    // Dynamic Base Power logic
    if (moveName == 'facade' && state.attacker.status != 'none') {
      bp *= 2;
      applied.add(const AppliedModifier(name: 'Facade (Statused)', multiplier: 2.0, category: ModifierCategory.basePower));
    } else if (moveName == 'brine' && state.defender.hpPercent <= 50.0) {
      bp = (bp * 2);
      applied.add(const AppliedModifier(name: 'Brine (Defender HP ≤ 50%)', multiplier: 2.0, category: ModifierCategory.basePower));
    } else if (moveName == 'venoshock' && (state.defender.status == 'poison' || state.defender.status == 'toxic')) {
      bp *= 2;
      applied.add(const AppliedModifier(name: 'Venoshock (Poisoned)', multiplier: 2.0, category: ModifierCategory.basePower));
    } else if (moveName == 'hex' && state.defender.status != 'none') {
      bp *= 2;
      applied.add(const AppliedModifier(name: 'Hex (Statused)', multiplier: 2.0, category: ModifierCategory.basePower));
    } else if (moveName == 'rage fist') {
      bp = 50 + (state.move.rageFistHits * 50).clamp(0, 300);
      applied.add(AppliedModifier(name: 'Rage Fist (${state.move.rageFistHits} hits)', multiplier: bp / 50.0, category: ModifierCategory.basePower));
    } else if (moveName == 'acrobatics' && attackerItem == 'none') {
      bp *= 2;
      applied.add(const AppliedModifier(name: 'Acrobatics (No Item)', multiplier: 2.0, category: ModifierCategory.basePower));
    } else if (moveName == 'knock off' && defenderItem != 'none') {
      bp = (bp * 1.5).floor();
      applied.add(const AppliedModifier(name: 'Knock Off (Holding Item)', multiplier: 1.5, category: ModifierCategory.basePower));
    }

    // Ability BP modifiers
    if (attackerAbility == 'technician' && bp <= 60 && bp > 0) {
      bp = (bp * 1.5).floor();
      applied.add(const AppliedModifier(name: 'Technician', multiplier: 1.5, category: ModifierCategory.basePower));
    } else if (attackerAbility == 'sharpness' && isSlicing) {
      bp = (bp * 1.5).floor();
      applied.add(const AppliedModifier(name: 'Sharpness', multiplier: 1.5, category: ModifierCategory.basePower));
    } else if (attackerAbility == 'strong jaw' && isBiting) {
      bp = (bp * 1.5).floor();
      applied.add(const AppliedModifier(name: 'Strong Jaw', multiplier: 1.5, category: ModifierCategory.basePower));
    } else if (attackerAbility == 'mega launcher' && isPulse) {
      bp = (bp * 1.5).floor();
      applied.add(const AppliedModifier(name: 'Mega Launcher', multiplier: 1.5, category: ModifierCategory.basePower));
    } else if (attackerAbility == 'iron fist' && isPunching) {
      bp = (bp * 1.2).floor();
      applied.add(const AppliedModifier(name: 'Iron Fist', multiplier: 1.2, category: ModifierCategory.basePower));
    } else if (attackerAbility == 'reckless' && isRecoil) {
      bp = (bp * 1.2).floor();
      applied.add(const AppliedModifier(name: 'Reckless', multiplier: 1.2, category: ModifierCategory.basePower));
    }

    // Punching Glove item
    if (attackerItem == 'punching glove' && isPunching) {
      bp = (bp * 1.1).floor();
      applied.add(const AppliedModifier(name: 'Punching Glove', multiplier: 1.1, category: ModifierCategory.item));
    }

    // ── 4. Effective Attack & Defense Stats ──────────────────────────────────
    int atkVal;
    if (moveName == 'foul play') {
      atkVal = defenderStats.byKey('atk').effectiveStat;
    } else {
      atkVal = attackerStats.byKey(atkKey).effectiveStat;
    }

    int defVal = defenderStats.byKey(defKey).effectiveStat;

    // Critical hit ignores positive defense stages and negative attack stages
    if (state.move.isCritical) {
      applied.add(const AppliedModifier(name: 'Critical Hit', multiplier: 1.5, category: ModifierCategory.critical));
    }

    // ── 5. Weather Multiplier ────────────────────────────────────────────────
    double weatherMult = 1.0;
    if (state.field.weather == 'sunny') {
      if (effectiveType == 'fire') {
        weatherMult = 1.5;
        applied.add(const AppliedModifier(name: 'Sun (Fire Boost)', multiplier: 1.5, category: ModifierCategory.weather));
      } else if (effectiveType == 'water') {
        weatherMult = 0.5;
        applied.add(const AppliedModifier(name: 'Sun (Water Reduction)', multiplier: 0.5, category: ModifierCategory.weather));
      }
    } else if (state.field.weather == 'rainy') {
      if (effectiveType == 'water') {
        weatherMult = 1.5;
        applied.add(const AppliedModifier(name: 'Rain (Water Boost)', multiplier: 1.5, category: ModifierCategory.weather));
      } else if (effectiveType == 'fire') {
        weatherMult = 0.5;
        applied.add(const AppliedModifier(name: 'Rain (Fire Reduction)', multiplier: 0.5, category: ModifierCategory.weather));
      }
    }

    // ── 6. STAB Multiplier ───────────────────────────────────────────────────
    double stab = 1.0;
    final activeAttackerTypes = state.attacker.activeTypes;
    final isStab = activeAttackerTypes.contains(effectiveType);

    if (isStab) {
      if (attackerAbility == 'adaptability') {
        stab = 2.0;
        applied.add(const AppliedModifier(name: 'Adaptability STAB', multiplier: 2.0, category: ModifierCategory.stab));
      } else {
        stab = 1.5;
        applied.add(const AppliedModifier(name: 'STAB', multiplier: 1.5, category: ModifierCategory.stab));
      }
    }

    // ── 7. Type Effectiveness ────────────────────────────────────────────────
    final defenderTypes = state.defender.activeTypes;
    final type1 = defenderTypes.first;
    final type2 = defenderTypes.length > 1 ? defenderTypes[1] : null;

    double effectiveness = TypeEfficiencyCalculator.getCombinedEffectiveness(
      type1, type2,
    )[effectiveType] ?? 1.0;

    // Ability Type Immunities
    if (effectiveType == 'ground' && defenderAbility == 'levitate') {
      effectiveness = 0.0;
      applied.add(const AppliedModifier(name: 'Levitate Immunity', multiplier: 0.0, category: ModifierCategory.ability));
    } else if (effectiveType == 'fire' && (defenderAbility == 'well baked body' || defenderAbility == 'flash fire')) {
      effectiveness = 0.0;
      applied.add(AppliedModifier(name: '$defenderAbility Immunity', multiplier: 0.0, category: ModifierCategory.ability));
    } else if (effectiveType == 'water' && (defenderAbility == 'water absorb' || defenderAbility == 'dry skin')) {
      effectiveness = 0.0;
      applied.add(AppliedModifier(name: '$defenderAbility Immunity', multiplier: 0.0, category: ModifierCategory.ability));
    } else if (effectiveType == 'electric' && (defenderAbility == 'volt absorb' || defenderAbility == 'lightning rod')) {
      effectiveness = 0.0;
      applied.add(AppliedModifier(name: '$defenderAbility Immunity', multiplier: 0.0, category: ModifierCategory.ability));
    } else if (effectiveType == 'grass' && defenderAbility == 'sap sipper') {
      effectiveness = 0.0;
      applied.add(const AppliedModifier(name: 'Sap Sipper Immunity', multiplier: 0.0, category: ModifierCategory.ability));
    }

    if (effectiveness != 1.0 && effectiveness > 0) {
      final effStr = effectiveness == effectiveness.roundToDouble()
          ? effectiveness.toInt().toString()
          : effectiveness.toString();
      applied.add(AppliedModifier(
        name: '$effStr× Type Effectiveness',
        multiplier: effectiveness,
        category: ModifierCategory.typeEffectiveness,
      ));
    } else if (effectiveness == 0.0 && !applied.any((m) => m.category == ModifierCategory.ability)) {
      applied.add(const AppliedModifier(name: 'Type Immunity (0×)', multiplier: 0.0, category: ModifierCategory.typeEffectiveness));
    }

    // ── 8. Burn Penalty ─────────────────────────────────────────────────────
    bool isBurnApplied = false;
    if (state.attacker.status == 'burn' && state.move.isPhysical && attackerAbility != 'guts' && moveName != 'facade') {
      isBurnApplied = true;
      applied.add(const AppliedModifier(name: 'Burn (Physical Halved)', multiplier: 0.5, category: ModifierCategory.status));
    }

    // ── 9. Final Modifiers List ──────────────────────────────────────────────
    final finalModifiers = <double>[];

    // Screen reduction
    if (state.move.isPhysical && state.field.reflectActive && !state.move.isCritical && attackerAbility != 'infiltrator') {
      final mult = state.field.isDoubleBattle ? (2732 / 4096) : 0.5;
      finalModifiers.add(mult);
      applied.add(AppliedModifier(name: 'Reflect', multiplier: mult, category: ModifierCategory.screen));
    }
    if (state.move.isSpecial && state.field.lightScreenActive && !state.move.isCritical && attackerAbility != 'infiltrator') {
      final mult = state.field.isDoubleBattle ? (2732 / 4096) : 0.5;
      finalModifiers.add(mult);
      applied.add(AppliedModifier(name: 'Light Screen', multiplier: mult, category: ModifierCategory.screen));
    }

    // Helping Hand
    if (state.field.helpingHandActive) {
      finalModifiers.add(1.5);
      applied.add(const AppliedModifier(name: 'Helping Hand', multiplier: 1.5, category: ModifierCategory.finalModifier));
    }

    // Spread move penalty in doubles (0.75× per Showdown)
    if (state.field.isDoubleBattle && CombatUtils.isSpreadMove(state.move.name)) {
      finalModifiers.add(0.75);
      applied.add(const AppliedModifier(name: 'Spread Move (Doubles 0.75×)', multiplier: 0.75, category: ModifierCategory.finalModifier));
    }

    // Life Orb
    if (attackerItem == 'life orb') {
      finalModifiers.add(1.3);
      applied.add(const AppliedModifier(name: 'Life Orb', multiplier: 1.3, category: ModifierCategory.item));
    }

    // Expert Belt
    if (attackerItem == 'expert belt' && effectiveness > 1.0) {
      finalModifiers.add(1.2);
      applied.add(const AppliedModifier(name: 'Expert Belt', multiplier: 1.2, category: ModifierCategory.item));
    }

    // Muscle Band / Wise Glasses
    if (attackerItem == 'muscle band' && state.move.isPhysical) {
      finalModifiers.add(1.1);
      applied.add(const AppliedModifier(name: 'Muscle Band', multiplier: 1.1, category: ModifierCategory.item));
    } else if (attackerItem == 'wise glasses' && state.move.isSpecial) {
      finalModifiers.add(1.1);
      applied.add(const AppliedModifier(name: 'Wise Glasses', multiplier: 1.1, category: ModifierCategory.item));
    }

    // Tinted Lens
    if (attackerAbility == 'tinted lens' && effectiveness < 1.0 && effectiveness > 0) {
      finalModifiers.add(2.0);
      applied.add(const AppliedModifier(name: 'Tinted Lens', multiplier: 2.0, category: ModifierCategory.ability));
    }

    // Solid Rock / Filter / Prism Armor
    if ((defenderAbility == 'solid rock' || defenderAbility == 'filter' || defenderAbility == 'prism armor') && effectiveness > 1.0) {
      finalModifiers.add(0.75);
      applied.add(AppliedModifier(name: titleCasePokemonText(defenderAbility), multiplier: 0.75, category: ModifierCategory.ability));
    }

    // Multiscale / Shadow Shield
    if ((defenderAbility == 'multiscale' || defenderAbility == 'shadow shield') && state.defender.hpPercent >= 100.0) {
      finalModifiers.add(0.5);
      applied.add(AppliedModifier(name: titleCasePokemonText(defenderAbility), multiplier: 0.5, category: ModifierCategory.ability));
    }

    // Ice Scales / Fluffy / Thick Fat / Purifying Salt
    if (defenderAbility == 'ice scales' && state.move.isSpecial) {
      finalModifiers.add(0.5);
      applied.add(const AppliedModifier(name: 'Ice Scales (Special Halved)', multiplier: 0.5, category: ModifierCategory.ability));
    } else if (defenderAbility == 'purifying salt' && effectiveType == 'ghost') {
      finalModifiers.add(0.5);
      applied.add(const AppliedModifier(name: 'Purifying Salt (Ghost Halved)', multiplier: 0.5, category: ModifierCategory.ability));
    } else if (defenderAbility == 'thick fat' && (effectiveType == 'fire' || effectiveType == 'ice')) {
      finalModifiers.add(0.5);
      applied.add(const AppliedModifier(name: 'Thick Fat', multiplier: 0.5, category: ModifierCategory.ability));
    }

    return ModifierPipelineResult(
      effectiveBasePower: bp,
      effectiveAttack: atkVal,
      effectiveDefense: defVal,
      attackingStatKey: atkKey,
      defendingStatKey: defKey,
      weatherMultiplier: weatherMult,
      stabMultiplier: stab,
      typeEffectiveness: effectiveness,
      isBurnApplied: isBurnApplied,
      finalModifiers: finalModifiers,
      appliedModifiers: applied,
      warnings: warnings,
    );
  }
}
