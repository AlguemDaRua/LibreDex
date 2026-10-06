import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/battle_engine/battle_engine.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';

/// The raw-sandbox panel of the damage calculator used to re-implement the
/// damage formula inside a `build()` method. It silently diverged from the duel
/// view — no Aurora Veil, no Multiscale, no Filter/Solid Rock, no Expert Belt,
/// no Tinted Lens, and Helping Hand folded into base power instead of applied as
/// a final modifier.
///
/// These tests lock in the fix: the sandbox now runs the shared
/// [ModifierPipeline], so it is the duel view with four hand-typed inputs.
void main() {
  const attacker = Pokemon(
    id: 6,
    name: 'Charizard',
    form: 'normal',
    type1: 'fire',
    type2: 'flying',
    baseHp: 78,
    baseAtk: 84,
    baseDef: 78,
    baseSpAtk: 109,
    baseSpDef: 85,
    baseSpd: 100,
    isLegendary: false,
    isMythical: false,
    isParadox: false,
    isUltraBeast: false,
    spriteUrl: '',
    shinySpriteUrl: '',
    nationalDexNumber: 6,
    generation: 1,
    evolutionStage: 2,
    isChampions: false,
    isLegendsZA: false,
  );

  const defender = Pokemon(
    id: 9,
    name: 'Blastoise',
    form: 'normal',
    type1: 'water',
    type2: null,
    baseHp: 79,
    baseAtk: 83,
    baseDef: 100,
    baseSpAtk: 85,
    baseSpDef: 105,
    baseSpd: 78,
    isLegendary: false,
    isMythical: false,
    isParadox: false,
    isUltraBeast: false,
    spriteUrl: '',
    shinySpriteUrl: '',
    nationalDexNumber: 9,
    generation: 1,
    evolutionStage: 3,
    isChampions: false,
    isLegendsZA: false,
  );

  /// Fails loudly when a scenario names an item the dataset does not contain.
  ///
  /// [HeldItemsData.findByName] returns null for unknown names and every
  /// multiplier then falls back to 1.0, so a scenario built with a
  /// non-existent item compares two identical no-op results and passes without
  /// testing anything. Two scenarios here were doing exactly that: 'Expert
  /// Belt' and 'Muscle Band' are not in the dataset.
  String checkItem(String name) {
    if (name != 'None' && HeldItemsData.findByName(name) == null) {
      throw StateError(
        'Held item "$name" is not in HeldItemsData. Unknown items silently '
        'resolve to a 1.0 multiplier, so this scenario would be a no-op.',
      );
    }
    return name;
  }

  PokemonState attackerState({String? ability, String heldItem = 'None'}) =>
      PokemonState.fromDatabase(
        attacker,
        level: 50,
        nature: 'adamant',
        ability: ability,
        heldItem: checkItem(heldItem),
      );

  PokemonState defenderState({
    String? ability,
    String heldItem = 'None',
    double hpPercent = 100.0,
  }) => PokemonState.fromDatabase(
    defender,
    level: 50,
    nature: 'bold',
    ability: ability,
    heldItem: checkItem(heldItem),
    hpPercent: hpPercent,
  );

  /// A single-strike physical hit — keeps both engines on the same branch.
  BattleState stateFor({
    FieldState field = const FieldState(),
    String? attackerAbility,
    String? defenderAbility,
    String attackerItem = 'None',
    String defenderItem = 'None',
    double defenderHpPercent = 100.0,
    bool critical = false,
    String moveName = 'Flare Blitz',
    String moveType = 'fire',
    String damageClass = 'physical',
    int basePower = 120,
  }) => BattleState(
    attacker: attackerState(ability: attackerAbility, heldItem: attackerItem),
    defender: defenderState(
      ability: defenderAbility,
      heldItem: defenderItem,
      hpPercent: defenderHpPercent,
    ),
    move: MoveState(
      name: moveName,
      type: moveType,
      basePower: basePower,
      damageClass: damageClass,
      hits: 1,
      isCritical: critical,
      isContact: true,
    ),
    field: field,
  );

  /// Feed the duel view's own derived values into the sandbox. If there is
  /// exactly one damage implementation, the rolls must come back identical.
  SandboxOverrides overridesFor(BattleState state) {
    final attackerStats = StatEngine.computeEffectiveStats(
      state.attacker,
      state.ruleset,
      isCriticalAttacker: state.move.isCritical,
      weather: state.field.weather,
      terrain: state.field.terrain,
    );
    final defenderStats = StatEngine.computeEffectiveStats(
      state.defender,
      state.ruleset,
      isCriticalDefender: state.move.isCritical,
      weather: state.field.weather,
      terrain: state.field.terrain,
    );
    final pipe = ModifierPipeline.process(state, attackerStats, defenderStats);
    return SandboxOverrides(
      attack: pipe.effectiveAttack,
      defense: pipe.effectiveDefense,
      stab: pipe.stabMultiplier,
      effectiveness: pipe.typeEffectiveness,
    );
  }

  int effectiveAttackFor(BattleState state) {
    final attackerStats = StatEngine.computeEffectiveStats(
      state.attacker,
      state.ruleset,
      isCriticalAttacker: state.move.isCritical,
      weather: state.field.weather,
      terrain: state.field.terrain,
    );
    final defenderStats = StatEngine.computeEffectiveStats(
      state.defender,
      state.ruleset,
      isCriticalDefender: state.move.isCritical,
      weather: state.field.weather,
      terrain: state.field.terrain,
    );
    return ModifierPipeline.process(
      state,
      attackerStats,
      defenderStats,
    ).effectiveAttack;
  }

  group('sandbox resolves through the shared engine', () {
    test('produces identical rolls to the duel view for the same inputs', () {
      final state = stateFor();
      final duel = BattleEngine.calculate(state);
      final sandboxed = SandboxDamageEngine.calculate(
        state,
        overridesFor(state),
      );

      expect(sandboxed.rolls, equals(duel.rolls));
      expect(sandboxed.minDamage, equals(duel.minDamage));
      expect(sandboxed.maxDamage, equals(duel.maxDamage));
      expect(sandboxed.effectiveBasePower, equals(duel.effectiveBasePower));
      expect(sandboxed.effectiveAttack, equals(duel.effectiveAttack));
      expect(sandboxed.effectiveDefense, equals(duel.effectiveDefense));
    });

    test('holds across a matrix of field conditions', () {
      for (final weather in ['none', 'sunny', 'rainy', 'sandstorm', 'snow']) {
        for (final terrain in [
          'none',
          'electric',
          'grassy',
          'psychic',
          'misty',
        ]) {
          for (final reflect in [false, true]) {
            for (final critical in [false, true]) {
              final state = stateFor(
                field: FieldState(
                  weather: weather,
                  terrain: terrain,
                  reflectActive: reflect,
                ),
                critical: critical,
              );
              final duel = BattleEngine.calculate(state);
              final sandboxed = SandboxDamageEngine.calculate(
                state,
                overridesFor(state),
              );

              expect(
                sandboxed.rolls,
                equals(duel.rolls),
                reason:
                    'diverged at weather=$weather terrain=$terrain '
                    'reflect=$reflect critical=$critical',
              );
            }
          }
        }
      }
    });

    test('holds for items, abilities and doubles', () {
      final scenarios = <BattleState>[
        stateFor(attackerItem: 'Life Orb'),
        stateFor(attackerItem: 'Choice Band'),
        // Fire boost, matching Flare Blitz - covers the typeBoost path.
        stateFor(attackerItem: 'Charcoal'),
        stateFor(defenderAbility: 'Filter'),
        stateFor(defenderAbility: 'Solid Rock'),
        stateFor(defenderAbility: 'Multiscale'),
        stateFor(defenderAbility: 'Thick Fat'),
        stateFor(attackerAbility: 'Tinted Lens', defenderItem: 'Chilan Berry'),
        stateFor(field: const FieldState(helpingHandActive: true)),
        stateFor(field: const FieldState(auroraVeilActive: true)),
        stateFor(
          field: const FieldState(isDoubleBattle: true, reflectActive: true),
        ),
        stateFor(attackerAbility: 'Sniper', critical: true),
      ];

      for (final state in scenarios) {
        final duel = BattleEngine.calculate(state);
        final sandboxed = SandboxDamageEngine.calculate(
          state,
          overridesFor(state),
        );
        expect(sandboxed.rolls, equals(duel.rolls));
      }
    });
  });

  group('sandbox resolves mechanics the old formula ignored', () {
    int maxDamageFor(BattleState state) => SandboxDamageEngine.calculate(
      state,
      const SandboxOverrides(
        attack: 300,
        defense: 150,
        stab: 1.5,
        effectiveness: 1.0,
      ),
    ).maxDamage;

    test('held item damage multipliers are applied exactly once', () {
      // Regression: the sandbox path built its Attack stat from
      // HeldItemsData.getAttackMultiplier, which folded Life Orb and
      // type-boosting items into the stat. ModifierPipeline applies those
      // again as final modifiers, so they counted twice - but only on the
      // sandbox path, which is why parity never caught it.
      final withOrb = stateFor(attackerItem: 'Life Orb');
      final bare = stateFor(attackerItem: 'None');

      expect(
        effectiveAttackFor(withOrb),
        equals(effectiveAttackFor(bare)),
        reason:
            'Life Orb is a final damage modifier, not an Attack stat '
            'modifier, so holding it must not change the Attack stat',
      );

      final duel = BattleEngine.calculate(withOrb);
      final sandboxed = SandboxDamageEngine.calculate(
        withOrb,
        overridesFor(withOrb),
      );
      expect(sandboxed.rolls, equals(duel.rolls));
    });

    test('Aurora Veil halves damage', () {
      final plain = maxDamageFor(stateFor());
      final veiled = maxDamageFor(
        stateFor(field: const FieldState(auroraVeilActive: true)),
      );
      expect(veiled, lessThan(plain));
    });

    test('Life Orb boosts damage', () {
      final plain = maxDamageFor(stateFor());
      const orb = 'Life Orb';
      final boosted = maxDamageFor(stateFor(attackerItem: orb));
      expect(boosted, greaterThan(plain));
    });

    test('Multiscale halves damage at full HP only', () {
      final fullHp = maxDamageFor(stateFor(defenderAbility: 'Multiscale'));
      final hurt = maxDamageFor(
        stateFor(defenderAbility: 'Multiscale', defenderHpPercent: 50.0),
      );
      expect(fullHp, lessThan(hurt));
    });

    test('critical hits ignore screens', () {
      final screened = maxDamageFor(
        stateFor(field: const FieldState(reflectActive: true)),
      );
      final screenedCrit = maxDamageFor(
        stateFor(field: const FieldState(reflectActive: true), critical: true),
      );
      // The crit multiplier outweighs the restored screen reduction.
      expect(screenedCrit, greaterThan(screened));
    });

    test('hand-typed effectiveness reaches the formula', () {
      final neutral = SandboxDamageEngine.calculate(
        stateFor(),
        const SandboxOverrides(
          attack: 300,
          defense: 150,
          stab: 1.0,
          effectiveness: 1.0,
        ),
      ).maxDamage;
      final superEffective = SandboxDamageEngine.calculate(
        stateFor(),
        const SandboxOverrides(
          attack: 300,
          defense: 150,
          stab: 1.0,
          effectiveness: 2.0,
        ),
      ).maxDamage;

      expect(superEffective, greaterThan(neutral));

      final immune = SandboxDamageEngine.calculate(
        stateFor(),
        const SandboxOverrides(
          attack: 300,
          defense: 150,
          stab: 1.0,
          effectiveness: 0.0,
        ),
      );
      expect(immune.maxDamage, equals(0));
    });

    test('hand-typed stats are used verbatim', () {
      final result = SandboxDamageEngine.calculate(
        stateFor(),
        const SandboxOverrides(
          attack: 300,
          defense: 150,
          stab: 1.0,
          effectiveness: 1.0,
        ),
      );
      expect(result.effectiveAttack, equals(300));
      expect(result.effectiveDefense, equals(150));
    });

    test('reports no HP context, because no Pokémon is selected', () {
      final result = SandboxDamageEngine.calculate(
        stateFor(),
        const SandboxOverrides(
          attack: 300,
          defense: 150,
          stab: 1.0,
          effectiveness: 1.0,
        ),
      );
      expect(result.defenderMaxHp, equals(0));
      expect(result.maxDamage, greaterThan(0));
    });
  });

  group('no second damage implementation', () {
    test('the calculator screen no longer does its own damage math', () {
      final source = File(
        'lib/features/calculator/views/damage_calculator_screen.dart',
      ).readAsStringSync();

      expect(
        source.contains('DamageMath.calculate'),
        isFalse,
        reason:
            'The raw sandbox must resolve through SandboxDamageEngine, '
            'not a hand-rolled DamageMath call that can drift from the '
            'duel view.',
      );
    });

    test('the sandbox engine is the only sandbox entry point', () {
      final source = File(
        'lib/features/calculator/views/damage_calculator_screen.dart',
      ).readAsStringSync();

      expect(source.contains('calculateSandboxDamage'), isTrue);
    });
  });
}
