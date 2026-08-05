import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Champions stat formulas', () {
    // Canonical formula verified against Pokémon Showdown Champions mode:
    //   HP    = Base + SP + 75
    //   Other = floor((Base + SP + 20) * Alignment)
    test('HP core matches the official formula', () {
      expect(StatCalculator.calculateChampionsHp(base: 60, sp: 2), 137);
      expect(StatCalculator.calculateChampionsHp(base: 100, sp: 0), 175);
      // Mega Zygarde: (463 * 50) ~/ 100 = 231, plus 60, plus 32 SP.
      expect(StatCalculator.calculateChampionsHp(base: 216, sp: 32), 323);
    });

    test('non-HP stats match the official formula incl. alignment', () {
      // Mega Raichu X Attack: base 135, 32 SP, Adamant (+10%).
      expect(
        StatCalculator.calculateChampionsStat(base: 135, sp: 32, alignmentModifier: 1.1),
        205,
      );
      // Same stat neutral.
      expect(StatCalculator.calculateChampionsStat(base: 135, sp: 32), 187);
      // Hindering alignment floors after the 0.9 multiplier.
      expect(
        StatCalculator.calculateChampionsStat(base: 135, sp: 32, alignmentModifier: 0.9),
        168,
      );
      // Speed example: base 110, 32 SP, Timid.
      expect(
        StatCalculator.calculateChampionsStat(base: 110, sp: 32, alignmentModifier: 1.1),
        178,
      );
    });

    test('at zero SP the Champions formula equals mainline Lv. 50 / 31 IVs', () {
      for (final base in <int>[1, 25, 48, 60, 100, 135, 150, 216, 255]) {
        expect(
          StatCalculator.calculateChampionsHp(base: base),
          StatCalculator.calculateHp(base: base, level: 50),
          reason: 'HP differs for base $base',
        );
        expect(
          StatCalculator.calculateChampionsStat(base: base),
          StatCalculator.calculateOtherStat(base: base, level: 50),
          reason: 'stat differs for base $base',
        );
      }
    });

    test('every Stat Point adds exactly one point (no EV-style rounding)', () {
      for (final base in <int>[45, 100, 135, 216]) {
        for (var sp = 0; sp < ChampionsRules.maxStatPointsPerStat; sp++) {
          expect(
            StatCalculator.calculateChampionsStat(base: base, sp: sp + 1) -
                StatCalculator.calculateChampionsStat(base: base, sp: sp),
            1,
            reason: 'base $base sp $sp',
          );
          expect(
            StatCalculator.calculateChampionsHp(base: base, sp: sp + 1) -
                StatCalculator.calculateChampionsHp(base: base, sp: sp),
            1,
            reason: 'HP base $base sp $sp',
          );
        }
      }
    });

    test('Shedinja HP stays 1 under Champions rules', () {
      expect(StatCalculator.calculateChampionsHp(base: 1, sp: 32, isShedinja: true), 1);
    });

    test('championsFinalStats builds the full six-stat spread for Mega Raichu X', () {
      final stats = championsFinalStats(
        base: const {'hp': 60, 'atk': 135, 'def': 95, 'spa': 90, 'spd': 95, 'spe': 110},
        spread: const {'hp': 1, 'atk': 32, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 32},
        alignment: 'adamant',
        alignmentModifierFor: (label) => CombatUtils.getNatureMultiplier('adamant', label),
      );
      expect(stats['hp'], 136);
      expect(stats['atk'], 205); // Adamant (+10% Attack)
      expect(stats['spe'], 162, reason: 'Adamant does not touch Speed: (125 + 5 + 32) = 162');
      expect(stats['atk']!, greaterThan(stats['spa']!),
          reason: 'physical attacker alignment beats its Sp. Atk');
    });
  });

  group('Champions rules constants & alignments', () {
    test('damage level is fixed at 50 and SP budget is canonical', () {
      expect(ChampionsRules.level, 50);
      expect(ChampionsRules.fixedIv, 31);
      expect(ChampionsRules.totalStatPoints, 65);
      expect(ChampionsRules.maxStatPointsPerStat, 32);
    });

    test('21 alignments; Serious is the only neutral; filler naturals dropped', () {
      expect(ChampionsRules.alignments.length, 21);
      expect(ChampionsRules.alignments, contains('serious'));
      for (final removed in <String>['hardy', 'docile', 'bashful', 'quirky']) {
        expect(ChampionsRules.alignments, isNot(contains(removed)));
      }
      // Every alignment is still a proper nature with a ±10% modifier except
      // the neutral Serious.
      for (final alignment in ChampionsRules.alignments) {
        final mods = <double>[
          for (final stat in <String>['Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'])
            CombatUtils.getNatureMultiplier(alignment, stat),
        ];
        if (alignment == 'serious') {
          expect(mods, everyElement(1.0), reason: 'Serious must be neutral');
        } else {
          expect(mods.where((m) => m == 1.1).length, 1, reason: '$alignment needs exactly one +10%');
          expect(mods.where((m) => m == 0.9).length, 1, reason: '$alignment needs exactly one -10%');
        }
      }
    });

    test('SP edits respect the 32 per-stat cap and the 65 total budget', () {
      final spread = ChampionsRules.emptySpread();
      expect(ChampionsRules.clampStatPoint(spread, 'atk', 40), 32);
      expect(ChampionsRules.clampStatPoint(spread, 'atk', -5), 0);

      final almostFull = ChampionsRules.emptySpread()
        ..['atk'] = 32
        ..['spe'] = 32;
      expect(ChampionsRules.remainingStatPoints(almostFull), 1);
      expect(ChampionsRules.clampStatPoint(almostFull, 'hp', 32), 1);
    });

    test('built-in presets spend the budget sensibly', () {
      for (final preset in ChampionsStatPreset.presets) {
        final used = ChampionsRules.usedStatPoints(preset.spread);
        expect(used, lessThanOrEqualTo(ChampionsRules.totalStatPoints),
            reason: '${preset.label} overspends');
        for (final entry in preset.spread.entries) {
          expect(entry.value, lessThanOrEqualTo(ChampionsRules.maxStatPointsPerStat),
              reason: '${preset.label} ${entry.key}');
        }
      }
      // Trick Room preset invests nothing in Speed.
      final trickRoom = ChampionsStatPreset.presets.firstWhere((p) => p.label == 'Trick Room Attacker');
      expect(trickRoom.spread['spe'], 0);
      // Physical preset mirrors the documented 32/32/2 spread.
      final physical = ChampionsStatPreset.presets.first;
      expect(physical.spread['atk'], 32);
      expect(physical.spread['spe'], 32);
      expect(physical.spread['hp'], 1);
    });
  });

  group('DamageCalculatorViewModel Champions mode', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    ProviderContainer liveContainer() {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Keep the auto-dispose notifier alive for the whole test.
      final sub = container.listen(damageCalculatorViewModelProvider, (_, _) {});
      addTearDown(sub.close);
      return container;
    }

    test('switching rulesets preserves the mainline EV/IV setup', () async {
      final container = liveContainer();
      final vm = container.read(damageCalculatorViewModelProvider.notifier);

      vm.updateAttackerEv('atk', 128);
      vm.updateAttackerIv('atk', 17);
      final evsBefore = Map<String, int>.from(container.read(damageCalculatorViewModelProvider).attackerEvs);
      final ivsBefore = Map<String, int>.from(container.read(damageCalculatorViewModelProvider).attackerIvs);

      await vm.setRuleset(BattleRuleset.champions);
      var state = container.read(damageCalculatorViewModelProvider);
      expect(state.ruleset, BattleRuleset.champions);
      expect(state.attackerEvs, evsBefore);
      expect(state.attackerIvs, ivsBefore);

      await vm.setRuleset(BattleRuleset.mainline);
      state = container.read(damageCalculatorViewModelProvider);
      expect(state.attackerEvs, evsBefore);
      expect(state.attackerIvs, ivsBefore);
    });

    test('natures that are not alignments normalize to Serious in Champions', () async {
      final container = liveContainer();
      final vm = container.read(damageCalculatorViewModelProvider.notifier);

      vm.updateAttackerNature('hardy'); // dropped in Champions
      await vm.setRuleset(BattleRuleset.champions);
      final state = container.read(damageCalculatorViewModelProvider);
      expect(state.attackerNature, 'serious');
    });

    test('SP edits clamp per-stat and total budget', () {
      final container = liveContainer();
      final vm = container.read(damageCalculatorViewModelProvider.notifier);

      vm.applyChampionsPreset(
        isAttacker: true,
        preset: const ChampionsStatPreset('Custom', {
          'hp': 0, 'atk': 32, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 32,
        }),
      );
      vm.updateAttackerSp('def', 32);
      final state = container.read(damageCalculatorViewModelProvider);
      // Only 1 point remains (65 - 32 - 32), so Def caps at 1.
      expect(state.attackerSps['def'], 1);
      expect(ChampionsRules.usedStatPoints(state.attackerSps), 65);
    });

    test('ruleset choice persists via SharedPreferences', () async {
      final container = liveContainer();
      final vm = container.read(damageCalculatorViewModelProvider.notifier);
      await vm.setRuleset(BattleRuleset.champions);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('damage_calculator_ruleset'), 'champions');
    });
  });
}
