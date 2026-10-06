/// 19-step Gen IX calculation pipeline for battle mechanics.
library;

import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';
import 'package:libredex/features/stat_comparison/models/stat_modifier.dart';
import 'package:libredex/features/battle_engine/services/stat_engine.dart';
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
  static ModifierPipelineResult process(
    BattleState state,
    ComparisonStats attackerStats,
    ComparisonStats defenderStats,
  ) {
    final applied = <AppliedModifier>[];
    final warnings = <String>[];

    final moveName = _normalize(state.move.name);
    final attackerAbility = _normalize(state.attacker.ability ?? '');
    final defenderAbility = _normalize(state.defender.ability ?? '');
    final attackerItem = _normalize(state.attacker.heldItem);
    final defenderItem = _normalize(state.defender.heldItem);

    // ── 1. Determine Effective Move Type ────────────────────────────────────
    final effectiveType = CombatUtils.effectiveMoveType(
      moveName: state.move.name,
      moveType: state.move.type,
      weather: state.field.weather,
      terrain: state.field.terrain,
      attackerAbility: state.attacker.ability,
    );
    if (effectiveType != state.move.type.toLowerCase()) {
      final category = moveName == 'weather ball'
          ? ModifierCategory.weather
          : moveName == 'terrain pulse'
          ? ModifierCategory.terrain
          : ModifierCategory.ability;
      applied.add(
        AppliedModifier(
          name: '$moveName (${titleCasePokemonText(effectiveType)})',
          multiplier: 1.0,
          category: category,
        ),
      );
    }

    // ── 2. Determine Attacking and Defending Stat Keys ───────────────────────
    String atkKey = state.move.isPhysical ? 'atk' : 'spa';
    String defKey = state.move.isPhysical ? 'def' : 'spd';

    // Move stat target overrides
    if (moveName == 'body press') {
      atkKey = 'def';
      applied.add(
        const AppliedModifier(
          name: 'Body Press (Uses Defense)',
          multiplier: 1.0,
          category: ModifierCategory.attack,
        ),
      );
    } else if (moveName == 'foul play') {
      // Uses defender's raw/effective attack
      applied.add(
        const AppliedModifier(
          name: "Foul Play (Uses Defender's Attack)",
          multiplier: 1.0,
          category: ModifierCategory.attack,
        ),
      );
    } else if (moveName == 'psyshock' ||
        moveName == 'psystrike' ||
        moveName == 'secret sword') {
      defKey = 'def';
      applied.add(
        AppliedModifier(
          name: '$moveName (Targets Defense)',
          multiplier: 1.0,
          category: ModifierCategory.defense,
        ),
      );
    }

    // ── 3. Base Power Calculation ───────────────────────────────────────────
    final dynamicPower = CombatUtils.resolveDynamicBasePower(
      moveName: state.move.name,
      basePower: state.move.basePower.toDouble(),
      friendship: state.attacker.friendship,
      attackerHpPercent: state.attacker.hpPercent,
      defenderHpPercent: state.defender.hpPercent,
      attackerStatus: state.attacker.status,
      defenderStatus: state.defender.status,
      attackerHeldItem: state.attacker.heldItem,
      defenderHeldItem: state.defender.heldItem,
      rageFistHits: state.move.rageFistHits,
      attackerWeightKg: state.attacker.weightKg,
      defenderWeightKg: state.defender.weightKg,
      attackerSpeedStat: attackerStats.speed.effectiveStat.toDouble(),
      defenderSpeedStat: defenderStats.speed.effectiveStat.toDouble(),
      weather: state.field.weather,
      terrain: state.field.terrain,
      championsRules: state.ruleset.isChampions,
    );
    int bp = dynamicPower.basePower.round();
    if (dynamicPower.note != null) {
      final bpMultiplier = state.move.basePower > 0
          ? dynamicPower.basePower / state.move.basePower
          : dynamicPower.basePower;
      applied.add(
        AppliedModifier(
          name: dynamicPower.note!,
          multiplier: bpMultiplier,
          category: ModifierCategory.basePower,
        ),
      );
    }
    if (bp <= 0 && !state.move.isStatus) {
      warnings.add(
        'Base power is 0 for an attacking move. Check move configuration.',
      );
    }

    // These traits come from the same move record shown in the calculator;
    // keep ability/item modifiers independent of fragile name matching.
    final isPunching = state.move.isPunching;
    final isSlicing = state.move.isSlicing;
    final isBiting = state.move.isBiting;
    final isPulse = state.move.isPulse;
    final isRecoil = state.move.isRecoil;

    final typeAbilityBpMultiplier =
        CombatUtils.typeChangingAbilityPowerMultiplier(
          state.attacker.ability,
          state.move.type,
        );
    if (typeAbilityBpMultiplier != 1.0) {
      bp = (bp * typeAbilityBpMultiplier).round();
      applied.add(
        AppliedModifier(
          name: '${titleCasePokemonText(attackerAbility)} (Type Power)',
          multiplier: typeAbilityBpMultiplier,
          category: ModifierCategory.ability,
        ),
      );
    }
    final terrainBpMultiplier = switch ((state.field.terrain, effectiveType)) {
      ('electric', 'electric') ||
      ('grassy', 'grass') ||
      ('psychic', 'psychic') => 1.3,
      _ => 1.0,
    };
    if (terrainBpMultiplier != 1.0) {
      bp = (bp * terrainBpMultiplier).round();
      applied.add(
        AppliedModifier(
          name: '${titleCasePokemonText(state.field.terrain)} Terrain',
          multiplier: terrainBpMultiplier,
          category: ModifierCategory.terrain,
        ),
      );
    }

    // Ability BP modifiers
    if (attackerAbility == 'technician' && bp <= 60 && bp > 0) {
      bp = (bp * 1.5).floor();
      applied.add(
        const AppliedModifier(
          name: 'Technician',
          multiplier: 1.5,
          category: ModifierCategory.basePower,
        ),
      );
    } else if (attackerAbility == 'sharpness' && isSlicing) {
      bp = (bp * 1.5).floor();
      applied.add(
        const AppliedModifier(
          name: 'Sharpness',
          multiplier: 1.5,
          category: ModifierCategory.basePower,
        ),
      );
    } else if (attackerAbility == 'strong jaw' && isBiting) {
      bp = (bp * 1.5).floor();
      applied.add(
        const AppliedModifier(
          name: 'Strong Jaw',
          multiplier: 1.5,
          category: ModifierCategory.basePower,
        ),
      );
    } else if (attackerAbility == 'mega launcher' && isPulse) {
      bp = (bp * 1.5).floor();
      applied.add(
        const AppliedModifier(
          name: 'Mega Launcher',
          multiplier: 1.5,
          category: ModifierCategory.basePower,
        ),
      );
    } else if (attackerAbility == 'iron fist' && isPunching) {
      bp = (bp * 1.2).floor();
      applied.add(
        const AppliedModifier(
          name: 'Iron Fist',
          multiplier: 1.2,
          category: ModifierCategory.basePower,
        ),
      );
    } else if (attackerAbility == 'reckless' && isRecoil) {
      bp = (bp * 1.2).floor();
      applied.add(
        const AppliedModifier(
          name: 'Reckless',
          multiplier: 1.2,
          category: ModifierCategory.basePower,
        ),
      );
    }

    // Punching Glove item
    if (attackerItem == 'punching glove' && isPunching) {
      bp = (bp * 1.1).floor();
      applied.add(
        const AppliedModifier(
          name: 'Punching Glove',
          multiplier: 1.1,
          category: ModifierCategory.item,
        ),
      );
    }

    // ── 4. Effective Attack & Defense Stats ──────────────────────────────────
    int atkVal;
    if (moveName == 'foul play') {
      // Foul Play uses the target's base Attack and Attack stage, but the
      // user's item, ability and status modifiers. On a critical hit, the
      // target's negative Attack stage is ignored as the move's attack source.
      final userWithTargetAttack = state.attacker.copyWith(
        level: state.defender.level,
        nature: state.defender.nature,
        baseStats: {
          ...state.attacker.baseStats,
          'atk': state.defender.baseStats['atk'] ?? 50,
        },
        ivs: {...state.attacker.ivs, 'atk': state.defender.ivs['atk'] ?? 31},
        evs: {...state.attacker.evs, 'atk': state.defender.evs['atk'] ?? 0},
        sps: {...state.attacker.sps, 'atk': state.defender.sps['atk'] ?? 0},
        stages: {
          ...state.attacker.stages,
          'atk': state.defender.stages['atk'] ?? 0,
        },
      );
      atkVal = StatEngine.computeEffectiveStats(
        userWithTargetAttack,
        state.ruleset,
        isCriticalAttacker: state.move.isCritical,
        weather: state.field.weather,
        terrain: state.field.terrain,
      ).attack.effectiveStat;
    } else {
      atkVal = attackerStats.byKey(atkKey).effectiveStat;
    }

    int defVal = defenderStats.byKey(defKey).effectiveStat;

    // Critical hit ignores positive defense stages and negative attack stages
    if (state.move.isCritical) {
      applied.add(
        const AppliedModifier(
          name: 'Critical Hit',
          multiplier: 1.5,
          category: ModifierCategory.critical,
        ),
      );
    }

    // ── 5. Weather Multiplier ────────────────────────────────────────────────
    double weatherMult = 1.0;
    if (state.field.weather == 'sunny') {
      if (effectiveType == 'fire') {
        weatherMult = 1.5;
        applied.add(
          const AppliedModifier(
            name: 'Sun (Fire Boost)',
            multiplier: 1.5,
            category: ModifierCategory.weather,
          ),
        );
      } else if (effectiveType == 'water') {
        weatherMult = 0.5;
        applied.add(
          const AppliedModifier(
            name: 'Sun (Water Reduction)',
            multiplier: 0.5,
            category: ModifierCategory.weather,
          ),
        );
      }
    } else if (state.field.weather == 'rainy') {
      if (effectiveType == 'water') {
        weatherMult = 1.5;
        applied.add(
          const AppliedModifier(
            name: 'Rain (Water Boost)',
            multiplier: 1.5,
            category: ModifierCategory.weather,
          ),
        );
      } else if (effectiveType == 'fire') {
        weatherMult = 0.5;
        applied.add(
          const AppliedModifier(
            name: 'Rain (Fire Reduction)',
            multiplier: 0.5,
            category: ModifierCategory.weather,
          ),
        );
      }
    }

    // ── 6. STAB Multiplier ───────────────────────────────────────────────────
    double stab = 1.0;
    final originalTypes = state.attacker.types
        .map((type) => type.toLowerCase())
        .toSet();
    final hasOriginalStab = originalTypes.contains(effectiveType);
    final hasAdaptability = attackerAbility == 'adaptability';
    final teraActive =
        !state.ruleset.isChampions &&
        state.attacker.teraActive &&
        state.attacker.teraType != null;
    final teraType = state.attacker.teraType?.toLowerCase();

    if (teraActive && state.attacker.isTeraStellar) {
      stab = hasOriginalStab ? (hasAdaptability ? 2.25 : 2.0) : 1.2;
    } else if (teraActive && teraType == effectiveType) {
      stab = hasOriginalStab
          ? (hasAdaptability ? 2.25 : 2.0)
          : (hasAdaptability ? 2.0 : 1.5);
    } else if (hasOriginalStab) {
      stab = hasAdaptability ? 2.0 : 1.5;
    }
    if (stab != 1.0) {
      applied.add(
        AppliedModifier(
          name: hasAdaptability ? 'Adaptability STAB' : 'STAB',
          multiplier: stab,
          category: ModifierCategory.stab,
        ),
      );
    }

    // ── 7. Type Effectiveness ────────────────────────────────────────────────
    final type1 = state.defender.types.first;
    final type2 = state.defender.types.length > 1
        ? state.defender.types[1]
        : null;
    double effectiveness = CombatUtils.getTypeEffectiveness(
      effectiveType,
      type1,
      type2,
      attackerAbility: state.attacker.ability,
      defenderAbility: state.defender.ability,
      moveName: state.move.name,
      defenderTeraActive:
          !state.ruleset.isChampions && state.defender.teraActive,
      defenderTeraType: state.defender.teraType,
    );

    final breaksProtection = CombatUtils.breaksProtect(state.move.name);
    final unseenFistProtectionHit =
        attackerAbility == 'unseen fist' && state.move.isContact;
    final priorityBlockReason = CombatUtils.priorityMoveBlockReason(
      priority: state.move.priority,
      attackerAbility: state.attacker.ability,
      defenderAbility: state.defender.ability,
      defenderHeldItem: state.defender.heldItem,
      terrain: state.field.terrain,
      defenderGrounded: CombatUtils.isGrounded(
        types: state.defender.types,
        ability: state.defender.ability,
        heldItem: state.defender.heldItem,
      ),
    );
    if (priorityBlockReason != null) {
      effectiveness = 0.0;
      applied.add(
        AppliedModifier(
          name: '$priorityBlockReason (Priority Move Blocked)',
          multiplier: 0.0,
          category: priorityBlockReason == 'Psychic Terrain'
              ? ModifierCategory.terrain
              : ModifierCategory.ability,
        ),
      );
    } else if (state.field.defenderProtected &&
        !breaksProtection &&
        !unseenFistProtectionHit) {
      effectiveness = 0.0;
      applied.add(
        const AppliedModifier(
          name: 'Protect (Move Blocked)',
          multiplier: 0.0,
          category: ModifierCategory.rule,
        ),
      );
    }

    if (effectiveness != 1.0 && effectiveness > 0) {
      final effStr = effectiveness == effectiveness.roundToDouble()
          ? effectiveness.toInt().toString()
          : effectiveness.toString();
      applied.add(
        AppliedModifier(
          name: '$effStr× Type Effectiveness',
          multiplier: effectiveness,
          category: ModifierCategory.typeEffectiveness,
        ),
      );
    } else if (effectiveness == 0.0 &&
        !applied.any(
          (modifier) =>
              modifier.category == ModifierCategory.ability ||
              modifier.category == ModifierCategory.rule ||
              modifier.category == ModifierCategory.terrain,
        )) {
      applied.add(
        const AppliedModifier(
          name: 'Type Immunity (0×)',
          multiplier: 0.0,
          category: ModifierCategory.typeEffectiveness,
        ),
      );
    }
    if (state.field.defenderProtected && breaksProtection) {
      applied.add(
        const AppliedModifier(
          name: 'Move Breaks Protect',
          multiplier: 1.0,
          category: ModifierCategory.rule,
        ),
      );
    }

    // ── 8. Burn Penalty ─────────────────────────────────────────────────────
    // Facade bypasses burn's physical halving (like Guts) — its doubled BP
    // already accounts for the status. Showdown's pipeline excludes it.
    bool isBurnApplied = false;
    if (state.attacker.status == 'burn' &&
        state.move.isPhysical &&
        attackerAbility != 'guts' &&
        moveName != 'facade') {
      isBurnApplied = true;
      applied.add(
        const AppliedModifier(
          name: 'Burn (Physical Halved)',
          multiplier: 0.5,
          category: ModifierCategory.status,
        ),
      );
    }

    // ── 9. Final Modifiers List ──────────────────────────────────────────────
    final finalModifiers = <double>[];

    // Unseen Fist allows contact damage through Protect, but at one quarter.
    if (state.field.defenderProtected &&
        unseenFistProtectionHit &&
        !breaksProtection) {
      finalModifiers.add(0.25);
      applied.add(
        const AppliedModifier(
          name: 'Unseen Fist (¼ through Protect)',
          multiplier: 0.25,
          category: ModifierCategory.ability,
        ),
      );
    }

    // Resist berries reduce matching super-effective hits (Chilan Berry is
    // the exception and also activates against neutral Normal damage).
    final defenderResistMultiplier = HeldItemsData.getDefenderResistMultiplier(
      state.defender.heldItem,
      effectiveType,
      effectiveness,
    );
    if (defenderResistMultiplier != 1.0) {
      finalModifiers.add(defenderResistMultiplier);
      applied.add(
        AppliedModifier(
          name: '${titleCasePokemonText(defenderItem)} (Damage Reduction)',
          multiplier: defenderResistMultiplier,
          category: ModifierCategory.item,
        ),
      );
    }

    // Aura Guard (Pokémon Champions): halve damage from contact moves.
    if (CombatUtils.auraGuardReducesDamage(
      championsRuleset: state.ruleset.isChampions,
      defenderAbility: defenderAbility,
      contactMove: state.move.isContact,
    )) {
      finalModifiers.add(0.5);
      applied.add(
        const AppliedModifier(
          name: 'Aura Guard (Contact Damage Halved)',
          multiplier: 0.5,
          category: ModifierCategory.ability,
          description:
              'Aura Guard halves damage from contact moves in Pokémon Champions.',
        ),
      );
    }

    // Screen reduction — Reflect / Light Screen / Aurora Veil (combined).
    // Aurora Veil is mutually exclusive with the individual screens in-game;
    // if it is active we apply one reduction for either damage class and skip
    // the individual screen to avoid double 0.5× stacking.
    final bool hasAuroraVeil = state.field.auroraVeilActive;
    if (hasAuroraVeil &&
        !state.move.isCritical &&
        attackerAbility != 'infiltrator') {
      final mult = state.field.isDoubleBattle ? (2732 / 4096) : 0.5;
      finalModifiers.add(mult);
      applied.add(
        AppliedModifier(
          name: 'Aurora Veil',
          multiplier: mult,
          category: ModifierCategory.screen,
        ),
      );
    } else {
      if (state.move.isPhysical &&
          state.field.reflectActive &&
          !state.move.isCritical &&
          attackerAbility != 'infiltrator') {
        final mult = state.field.isDoubleBattle ? (2732 / 4096) : 0.5;
        finalModifiers.add(mult);
        applied.add(
          AppliedModifier(
            name: 'Reflect',
            multiplier: mult,
            category: ModifierCategory.screen,
          ),
        );
      }
      if (state.move.isSpecial &&
          state.field.lightScreenActive &&
          !state.move.isCritical &&
          attackerAbility != 'infiltrator') {
        final mult = state.field.isDoubleBattle ? (2732 / 4096) : 0.5;
        finalModifiers.add(mult);
        applied.add(
          AppliedModifier(
            name: 'Light Screen',
            multiplier: mult,
            category: ModifierCategory.screen,
          ),
        );
      }
    }

    // Helping Hand
    if (state.field.helpingHandActive) {
      finalModifiers.add(1.5);
      applied.add(
        const AppliedModifier(
          name: 'Helping Hand',
          multiplier: 1.5,
          category: ModifierCategory.finalModifier,
        ),
      );
    }

    // Spread move penalty in doubles (0.75× per Showdown)
    if (state.field.isDoubleBattle &&
        CombatUtils.isSpreadMove(state.move.name)) {
      finalModifiers.add(0.75);
      applied.add(
        const AppliedModifier(
          name: 'Spread Move (Doubles 0.75×)',
          multiplier: 0.75,
          category: ModifierCategory.finalModifier,
        ),
      );
    }

    // Universal and type-boosting held items (stat items are already applied
    // by the shared StatModifier engine).
    final attackerHeldItemData = HeldItemsData.findByName(
      state.attacker.heldItem,
    );
    final itemDamageMultiplier =
        attackerHeldItemData?.universalDamageMultiplier ?? 1.0;
    if (itemDamageMultiplier != 1.0) {
      finalModifiers.add(itemDamageMultiplier);
      applied.add(
        AppliedModifier(
          name: titleCasePokemonText(attackerItem),
          multiplier: itemDamageMultiplier,
          category: ModifierCategory.item,
        ),
      );
    }
    if (attackerHeldItemData?.typeBoostType?.toLowerCase() == effectiveType) {
      final typeBoostMultiplier = attackerHeldItemData!.typeBoostMultiplier;
      finalModifiers.add(typeBoostMultiplier);
      applied.add(
        AppliedModifier(
          name: titleCasePokemonText(attackerItem),
          multiplier: typeBoostMultiplier,
          category: ModifierCategory.item,
        ),
      );
    }

    // Expert Belt
    if (attackerItem == 'expert belt' && effectiveness > 1.0) {
      finalModifiers.add(1.2);
      applied.add(
        const AppliedModifier(
          name: 'Expert Belt',
          multiplier: 1.2,
          category: ModifierCategory.item,
        ),
      );
    }

    // Muscle Band / Wise Glasses
    if (attackerItem == 'muscle band' && state.move.isPhysical) {
      finalModifiers.add(1.1);
      applied.add(
        const AppliedModifier(
          name: 'Muscle Band',
          multiplier: 1.1,
          category: ModifierCategory.item,
        ),
      );
    } else if (attackerItem == 'wise glasses' && state.move.isSpecial) {
      finalModifiers.add(1.1);
      applied.add(
        const AppliedModifier(
          name: 'Wise Glasses',
          multiplier: 1.1,
          category: ModifierCategory.item,
        ),
      );
    }

    // Tinted Lens
    if (attackerAbility == 'tinted lens' &&
        effectiveness < 1.0 &&
        effectiveness > 0) {
      finalModifiers.add(2.0);
      applied.add(
        const AppliedModifier(
          name: 'Tinted Lens',
          multiplier: 2.0,
          category: ModifierCategory.ability,
        ),
      );
    }

    // Sniper: 1.5× extra on a critical hit (total 2.25× with the base 1.5×).
    if (attackerAbility == 'sniper' && state.move.isCritical) {
      finalModifiers.add(1.5);
      applied.add(
        const AppliedModifier(
          name: 'Sniper (Crit ×2.25)',
          multiplier: 1.5,
          category: ModifierCategory.ability,
        ),
      );
    }

    // Solid Rock / Filter / Prism Armor
    if ((defenderAbility == 'solid rock' ||
            defenderAbility == 'filter' ||
            defenderAbility == 'prism armor') &&
        effectiveness > 1.0) {
      finalModifiers.add(0.75);
      applied.add(
        AppliedModifier(
          name: titleCasePokemonText(defenderAbility),
          multiplier: 0.75,
          category: ModifierCategory.ability,
        ),
      );
    }

    // Multiscale / Shadow Shield
    if ((defenderAbility == 'multiscale' ||
            defenderAbility == 'shadow shield') &&
        state.defender.hpPercent >= 100.0) {
      finalModifiers.add(0.5);
      applied.add(
        AppliedModifier(
          name: titleCasePokemonText(defenderAbility),
          multiplier: 0.5,
          category: ModifierCategory.ability,
        ),
      );
    }

    // Ice Scales / Fluffy / Thick Fat / Purifying Salt
    if (defenderAbility == 'ice scales' && state.move.isSpecial) {
      finalModifiers.add(0.5);
      applied.add(
        const AppliedModifier(
          name: 'Ice Scales (Special Halved)',
          multiplier: 0.5,
          category: ModifierCategory.ability,
        ),
      );
    } else if (defenderAbility == 'purifying salt' &&
        effectiveType == 'ghost') {
      finalModifiers.add(0.5);
      applied.add(
        const AppliedModifier(
          name: 'Purifying Salt (Ghost Halved)',
          multiplier: 0.5,
          category: ModifierCategory.ability,
        ),
      );
    } else if (defenderAbility == 'thick fat' &&
        (effectiveType == 'fire' || effectiveType == 'ice')) {
      finalModifiers.add(0.5);
      applied.add(
        const AppliedModifier(
          name: 'Thick Fat',
          multiplier: 0.5,
          category: ModifierCategory.ability,
        ),
      );
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
