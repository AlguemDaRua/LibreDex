import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';

const garchomp = Pokemon(
  id: 445,
  name: 'Garchomp',
  form: 'normal',
  type1: 'dragon',
  type2: 'ground',
  baseHp: 108,
  baseAtk: 130,
  baseDef: 95,
  baseSpAtk: 80,
  baseSpDef: 85,
  baseSpd: 102,
  isLegendary: false,
  isMythical: false,
  isParadox: false,
  isUltraBeast: false,
  spriteUrl: '',
  shinySpriteUrl: '',
  nationalDexNumber: 445,
  generation: 4,
  evolutionStage: 3,
  isChampions: false,
  isLegendsZA: false,
);

void main() {
  group('StatCalculator', () {
    test('HP at level 100 with perfect IVs and no EVs', () {
      // Garchomp, base 108: (108*2 + 31) + 100 + 10
      expect(
        StatCalculator.calculateHp(base: 108, iv: 31, ev: 0, level: 100),
        357,
      );
    });

    test('HP at level 50 with 252 EVs', () {
      // floor((216 + 31 + 63) * 50 / 100) + 50 + 10
      expect(
        StatCalculator.calculateHp(base: 108, iv: 31, ev: 252, level: 50),
        215,
      );
    });

    test('non-HP stat at level 50 with 252 EVs, neutral nature', () {
      // floor((260 + 31 + 63) * 50 / 100) + 5
      expect(
        StatCalculator.calculateOtherStat(
          base: 130,
          iv: 31,
          ev: 252,
          level: 50,
        ),
        182,
      );
    });

    test('a beneficial nature is applied after the +5, then floored', () {
      // floor(182 * 1.1) = floor(200.2)
      expect(
        StatCalculator.calculateOtherStat(
          base: 130,
          iv: 31,
          ev: 252,
          level: 50,
          natureModifier: 1.1,
        ),
        200,
      );
    });

    test('a hindering nature floors downwards', () {
      // floor(182 * 0.9) = floor(163.8)
      expect(
        StatCalculator.calculateOtherStat(
          base: 130,
          iv: 31,
          ev: 252,
          level: 50,
          natureModifier: 0.9,
        ),
        163,
      );
    });

    test('Shedinja always has 1 HP', () {
      expect(
        StatCalculator.calculateHp(base: 1, iv: 31, ev: 252, level: 100,
            isShedinja: true),
        1,
      );
    });

    test('EVs only count in multiples of 4', () {
      // 3 EVs contribute nothing, exactly as 0 do.
      expect(
        StatCalculator.calculateOtherStat(base: 100, iv: 31, ev: 3, level: 50),
        StatCalculator.calculateOtherStat(base: 100, iv: 31, ev: 0, level: 50),
      );
      expect(
        StatCalculator.calculateOtherStat(base: 100, iv: 31, ev: 4, level: 50),
        greaterThan(
          StatCalculator.calculateOtherStat(
            base: 100,
            iv: 31,
            ev: 3,
            level: 50,
          ),
        ),
      );
    });
  });

  group('StatsCalculatorState', () {
    final base = StatsCalculatorState(
      level: 50,
      ivs: const {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
      evs: const {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      nature: 'serious',
    );

    test('totalEvs sums every stat', () {
      expect(base.totalEvs, 0);
      expect(
        base.copyWith(evs: const {
          'hp': 252, 'atk': 252, 'def': 4, 'spa': 0, 'spd': 0, 'spe': 0,
        }).totalEvs,
        508,
      );
    });

    test('copyWith leaves unspecified fields alone', () {
      final updated = base.copyWith(level: 100);
      expect(updated.level, 100);
      expect(updated.nature, base.nature);
      expect(updated.ivs, base.ivs);
      expect(updated.evs, base.evs);
    });

    test('copyWith does not mutate the original', () {
      base.copyWith(level: 1);
      expect(base.level, 50);
    });
  });

  group('StatsCalculator notifier', () {
    late ProviderContainer container;

    StatsCalculator notifier() =>
        container.read(statsCalculatorProvider.notifier);
    StatsCalculatorState current() => container.read(statsCalculatorProvider);

    setUp(() {
      container = ProviderContainer();
    });
    tearDown(() => container.dispose());

    test('starts at level 100 with perfect IVs and no EVs', () {
      expect(current().level, 100);
      expect(current().totalEvs, 0);
      expect(current().nature, 'serious');
    });

    test('IVs clamp to 0..31', () {
      notifier().updateIv('atk', 99);
      expect(current().ivs['atk'], 31);
      notifier().updateIv('atk', -5);
      expect(current().ivs['atk'], 0);
    });

    test('a single EV caps at 252', () {
      notifier().updateEv('atk', 999);
      expect(current().evs['atk'], 252);
    });

    test('total EVs across stats cap at 508', () {
      notifier().updateEv('atk', 252);
      notifier().updateEv('spe', 252);
      expect(current().evs['atk'], 252);
      expect(current().evs['spe'], 252);
      // Only 4 left, so a third stat cannot take the full 252.
      notifier().updateEv('def', 252);
      expect(current().evs['def'], 4);
      expect(current().totalEvs, 508);
    });

    test('lowering one EV frees budget for another', () {
      notifier().updateEv('atk', 252);
      notifier().updateEv('spe', 252);
      notifier().updateEv('atk', 0);
      notifier().updateEv('def', 252);
      expect(current().evs['def'], 252);
      expect(current().totalEvs, 504);
    });

    test('reset returns to the initial state', () {
      notifier().updateLevel(50);
      notifier().updateEv('atk', 252);
      notifier().updateNature('jolly');
      notifier().reset();
      expect(current().level, 100);
      expect(current().totalEvs, 0);
      expect(current().nature, 'serious');
    });
  });

  group('nature multipliers', () {
    late ProviderContainer container;
    late StatsCalculator calc;
    setUp(() {
      container = ProviderContainer();
      calc = container.read(statsCalculatorProvider.notifier);
    });
    tearDown(() => container.dispose());

    test('neutral natures leave every stat alone', () {
      for (final nature in ['serious', 'hardy', 'docile', 'bashful', 'quirky']) {
        for (final stat in ['Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed']) {
          expect(calc.getNatureMultiplier(nature, stat), 1.0,
              reason: '$nature should not change $stat');
        }
      }
    });

    test('HP is never modified by nature', () {
      expect(calc.getNatureMultiplier('adamant', 'HP'), 1.0);
      expect(calc.getNatureMultiplier('timid', 'HP'), 1.0);
    });

    test('each non-neutral nature boosts exactly one and cuts exactly one', () {
      const natures = [
        'adamant', 'bold', 'brave', 'calm', 'careful', 'gentle', 'hasty',
        'impish', 'jolly', 'lax', 'lonely', 'mild', 'modest', 'naive',
        'naughty', 'quiet', 'rash', 'relaxed', 'sassy', 'timid',
      ];
      const stats = ['Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'];

      for (final nature in natures) {
        final boosted = stats
            .where((s) => calc.getNatureMultiplier(nature, s) > 1.0)
            .toList();
        final hindered = stats
            .where((s) => calc.getNatureMultiplier(nature, s) < 1.0)
            .toList();
        final neutral = stats
            .where((s) => calc.getNatureMultiplier(nature, s) == 1.0)
            .toList();

        expect(boosted.length, 1, reason: '$nature should boost one stat');
        expect(hindered.length, 1, reason: '$nature should hinder one stat');
        expect(neutral.length, 3, reason: '$nature should leave three alone');
        expect(boosted.single, isNot(hindered.single),
            reason: '$nature boosts and hinders the same stat');
      }
    });

    test('the 20 listed natures cover every boosting/hindering pair', () {
      // 20 non-neutral natures, each a distinct (boosted, hindered) pair.
      // Missing one would silently make that nature neutral in the UI.
      const natures = [
        'adamant', 'bold', 'brave', 'calm', 'careful', 'gentle', 'hasty',
        'impish', 'jolly', 'lax', 'lonely', 'mild', 'modest', 'naive',
        'naughty', 'quiet', 'rash', 'relaxed', 'sassy', 'timid',
      ];
      const stats = ['Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'];
      final pairs = <String>{};
      for (final nature in natures) {
        final boosted = stats
            .singleWhere((s) => calc.getNatureMultiplier(nature, s) > 1.0);
        final hindered = stats
            .singleWhere((s) => calc.getNatureMultiplier(nature, s) < 1.0);
        pairs.add('$boosted>$hindered');
      }
      expect(pairs.length, 20, reason: 'a duplicate pair means a wrong nature');
    });

    test('every nature name the UI offers is recognised', () {
      const natures = [
        'serious', 'hardy', 'docile', 'bashful', 'quirky',
        'adamant', 'bold', 'brave', 'calm', 'careful', 'gentle', 'hasty',
        'impish', 'jolly', 'lax', 'lonely', 'mild', 'modest', 'naive',
        'naughty', 'quiet', 'rash', 'relaxed', 'sassy', 'timid',
      ];
      for (final nature in natures) {
        final values = ['Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed']
            .map((s) => calc.getNatureMultiplier(nature, s))
            .toList();
        expect(values.any((v) => v != 1.0) || nature == 'serious' ||
            nature == 'hardy' || nature == 'docile' || nature == 'bashful' ||
            nature == 'quirky', isTrue,
            reason: '$nature is recognised as neutral but is not in the '
                'neutral list - it is probably misspelled');
      }
    });
  });

  group('getCalculatedStats', () {
    test('applies EVs, IVs, nature and item to the right stats', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final calc = container.read(statsCalculatorProvider.notifier);

      calc.updateLevel(50);
      calc.updateEv('atk', 252);
      // Adamant is +Attack / -Sp. Atk. Jolly would boost Speed instead.
      calc.updateNature('adamant');

      final stats = calc.getCalculatedStats(garchomp);
      // floor((130*2 + 31 + 63) * 50/100) + 5 = 182, then * 1.1
      expect(stats['atk'], 200);
      // Adamant cuts Sp. Atk: floor((80*2 + 31) * 50/100) + 5 = 100, * 0.9
      expect(stats['spa'], 90);
      // Speed is untouched by Adamant: floor((102*2 + 31) * 50/100) + 5
      expect(stats['spe'], 122);
      // HP ignores nature entirely, and only the Attack EV was set, so HP
      // is still at its 0-EV value.
      expect(stats['hp'], 183);

      // Adding an HP EV moves HP only - and still ignores the nature.
      calc.updateEv('hp', 252);
      expect(calc.getCalculatedStats(garchomp)['hp'], 215);
      expect(calc.getCalculatedStats(garchomp)['atk'], 200);
    });
  });
}
