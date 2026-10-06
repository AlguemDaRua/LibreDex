import 'package:flutter_test/flutter_test.dart';

import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/utils/pokemon_search.dart';

Pokemon dexEntry(
  int id,
  String name, {
  String form = 'normal',
  String type1 = 'normal',
  String? type2,
}) =>
    Pokemon(
      id: id,
      name: name,
      form: form,
      type1: type1,
      type2: type2,
      baseHp: 50,
      baseAtk: 50,
      baseDef: 50,
      baseSpAtk: 50,
      baseSpDef: 50,
      baseSpd: 50,
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: id,
      generation: 1,
      evolutionStage: 1,
      isChampions: false,
      isLegendsZA: false,
    );

void main() {
  group('matching', () {
    test('an empty query matches everything', () {
      expect(PokemonSearch.matches(dexEntry(1, 'Bulbasaur'), ''), isTrue);
      expect(PokemonSearch.matches(dexEntry(1, 'Bulbasaur'), '   '), isTrue);
    });

    test('matching is case-insensitive', () {
      expect(PokemonSearch.matches(dexEntry(1, 'Bulbasaur'), 'BULB'), isTrue);
      expect(PokemonSearch.matches(dexEntry(1, 'Bulbasaur'), 'bulb'), isTrue);
    });

    test('matches on name, form, type and dex number', () {
      final p = dexEntry(6, 'Charizard', form: 'mega-x', type1: 'fire');
      expect(PokemonSearch.matches(p, 'chari'), isTrue);
      expect(PokemonSearch.matches(p, 'mega'), isTrue);
      expect(PokemonSearch.matches(p, 'fire'), isTrue);
      expect(PokemonSearch.matches(p, '6'), isTrue);
      expect(PokemonSearch.matches(p, '006'), isTrue);
    });

    test('does not match on an unrelated query', () {
      expect(PokemonSearch.matches(dexEntry(1, 'Bulbasaur'), 'zzzz'), isFalse);
    });

    test('a subsequence hit still matches', () {
      // "gr" appears in order in "Gyarados" but not as a substring.
      expect(PokemonSearch.matches(dexEntry(130, 'Gyarados'), 'grd'), isTrue);
    });

    test('subsequence matching ignores hyphens in names', () {
      expect(
        PokemonSearch.matches(dexEntry(101, 'Ho-Oh'), 'hoh'),
        isTrue,
        reason: '"Ho-Oh" should be searchable as "hoh"',
      );
    });
  });

  group('multi-word queries', () {
    test('tokens are matched in any order', () {
      final p = dexEntry(670, 'Eternal Flower Floette');
      expect(PokemonSearch.matches(p, 'floette eternal'), isTrue);
      expect(PokemonSearch.matches(p, 'eternal floette'), isTrue);
    });

    test('every token must be present', () {
      final p = dexEntry(670, 'Eternal Flower Floette');
      expect(PokemonSearch.matches(p, 'floette zzzz'), isFalse);
    });

    test('a single token does not take the token path', () {
      // Guards the length < 2 check: otherwise every plain substring query
      // would also count as a token match and outrank real name matches.
      expect(PokemonSearch.matchesTokens('gar', 'garchomp', 'normal'), isFalse);
    });
  });

  group('ranking', () {
    test('an exact name match beats everything', () {
      expect(PokemonSearch.rank(dexEntry(445, 'Garchomp'), 'garchomp'), 0);
      expect(PokemonSearch.rank(dexEntry(282, 'Gardevoir'), 'gardevoir'), 0);
    });

    test('a prefix match beats a mid-name match', () {
      // "Bulbagar" contains "gar" but does not start with it.
      // "Magikarp" shares no substring at all, so it falls to the last band.
      expect(PokemonSearch.rank(dexEntry(445, 'Garchomp'), 'gar'), 1);
      expect(PokemonSearch.rank(dexEntry(999, 'Bulbagar'), 'gar'), 3);
      expect(PokemonSearch.rank(dexEntry(129, 'Magikarp'), 'gar'), 8);
    });

    test('a real name match outranks a subsequence hit', () {
      // The bug this ranking exists for: without it, "gar" surfaced
      // Magikarp and Graveler above Garchomp because they share a dex
      // range and every match scored the same.
      final garchomp = PokemonSearch.rank(dexEntry(445, 'Garchomp'), 'gar');
      final magikarp = PokemonSearch.rank(dexEntry(129, 'Magikarp'), 'gar');
      final graveler = PokemonSearch.rank(dexEntry(75, 'Graveler'), 'gar');
      expect(garchomp, lessThan(magikarp));
      expect(garchomp, lessThan(graveler));
    });

    test('every equally-good match lands in the same band', () {
      // Gardevoir, Garchomp, Garbodor and Garganacl are all prefix matches,
      // so dex order inside the band is what separates them. That keeps
      // evolution families adjacent in the results.
      for (final name in ['Gardevoir', 'Garchomp', 'Garbodor', 'Garganacl']) {
        expect(PokemonSearch.rank(dexEntry(1, name), 'gar'), 1,
            reason: '$name should rank as a prefix match');
      }
    });

    test('a form-part match is ranked below a whole-name prefix', () {
      final p = dexEntry(6, 'Charizard', form: 'mega-x');
      expect(PokemonSearch.rank(p, 'charizard'), 0);
      expect(PokemonSearch.rank(p, 'mega'), 4);
    });

    test('a dex-number match is ranked consistently', () {
      expect(PokemonSearch.rank(dexEntry(6, 'Charizard'), '6'), 5);
      expect(PokemonSearch.rank(dexEntry(6, 'Charizard'), '006'), 5);
    });

    test('a type match is ranked below a name match', () {
      final p = dexEntry(6, 'Charizard', type1: 'fire');
      expect(PokemonSearch.rank(p, 'char'), 1);
      expect(PokemonSearch.rank(p, 'fire'), 6);
    });

    test('multi-word token matches beat a bare subsequence', () {
      final p = dexEntry(670, 'Eternal Flower Floette');
      expect(PokemonSearch.rank(p, 'floette eternal'), 7);
    });

    test('an empty query ranks everything equal', () {
      expect(PokemonSearch.rank(dexEntry(1, 'Bulbasaur'), ''), 0);
      expect(PokemonSearch.rank(dexEntry(150, 'Mewtwo'), ''), 0);
    });

    test('rank never exceeds the fallback band', () {
      expect(
        PokemonSearch.rank(dexEntry(1, 'Bulbasaur'), 'zzzzqqq'),
        lessThanOrEqualTo(8),
      );
    });
  });

  group('group ranking across forms', () {
    test('a group is placed by its best-matching form', () {
      final forms = [
        dexEntry(6, 'Charizard'),
        dexEntry(10004, 'Charizard', form: 'mega-x'),
        dexEntry(10005, 'Charizard', form: 'mega-y'),
      ];
      // The base form matches on name; the mega forms only on form.
      expect(PokemonSearch.groupRank(forms, 'charizard'), 0);
    });

    test('an empty form list falls back to the worst band', () {
      expect(PokemonSearch.groupRank([], 'gar'), 8);
    });

    test('the group rank is the minimum across forms', () {
      final forms = [
        dexEntry(10004, 'Charizard', form: 'mega-x'),
        dexEntry(6, 'Charizard'),
      ];
      expect(PokemonSearch.groupRank(forms, 'charizard'), 0);
      expect(PokemonSearch.groupRank(forms, 'mega'), 4);
    });
  });

  group('subsequence guard', () {
    test('queries shorter than three characters never subsequence-match', () {
      // Otherwise "ab" would match a huge share of the dex.
      expect(PokemonSearch.isSubsequence('ab', 'bulbasaur'), isFalse);
      expect(PokemonSearch.isSubsequence('abc', 'bulbasaur'), isFalse);
    });

    test('a real subsequence is detected', () {
      expect(PokemonSearch.isSubsequence('bsr', 'bulbasaur'), isTrue);
    });

    test('characters must appear in order', () {
      expect(PokemonSearch.isSubsequence('rsb', 'bulbasaur'), isFalse);
    });
  });
}
