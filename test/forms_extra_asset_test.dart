import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/data/champions_catalog.dart';

void main() {
  late Map<String, dynamic> overlay;
  late List<dynamic> forms;
  late Set<int> bundledIds;
  late Map<int, String> bundledNames;

  setUpAll(() {
    overlay = jsonDecode(File('assets/data/forms_extra.json').readAsStringSync())
        as Map<String, dynamic>;
    forms = overlay['pokemon'] as List<dynamic>;
    final bundled = jsonDecode(File('assets/data/pokemon.json').readAsStringSync())
        as List<dynamic>;
    bundledIds = {for (final p in bundled) p['id'] as int};
    bundledNames = {for (final p in bundled) p['id'] as int: p['name'] as String};
  });

  group('forms_extra.json overlay integrity', () {
    test('contains the 49 Legends Z-A / Champions Mega forms', () {
      expect(forms.length, 49);
    });

    test('uses the official, collision-free 10278..10326 id namespace', () {
      final ids = forms.map((f) => f['id'] as int).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate overlay id');
      for (final id in ids) {
        expect(id, inInclusiveRange(10278, 10326));
        expect(bundledIds.contains(id), isFalse, reason: 'id $id collides with the base bundle');
      }
    });

    test('includes the showcase forms with readable display names', () {
      final names = forms.map((f) => f['name'] as String).toSet();
      for (final required in <String>[
        'Mega Raichu X',
        'Mega Raichu Y',
        'Mega Meganium',
        'Mega Staraptor',
        'Mega Floette',
      ]) {
        expect(names, contains(required));
      }
    });

    test('every form has stats, types and its base species national dex', () {
      final dexBySpecies = <String, int>{
        'Mega Raichu X': 26,
        'Mega Meganium': 154,
        'Mega Staraptor': 398,
        'Mega Floette': 670,
        'Mega Starmie': 121,
      };
      for (final raw in forms) {
        final form = raw as Map<String, dynamic>;
        for (final key in <String>['baseHp', 'baseAtk', 'baseDef', 'baseSpAtk', 'baseSpDef', 'baseSpd']) {
          expect(form[key], isA<int>(), reason: '${form['name']} missing $key');
        }
        expect(form['type1'], isA<String>());
        expect(form['nationalDexNumber'], isA<int>());
        expect(form['flags'], contains('mega'));
        final bst = <String>['baseHp', 'baseAtk', 'baseDef', 'baseSpAtk', 'baseSpDef', 'baseSpd']
            .map((k) => form[k] as int)
            .fold<int>(0, (a, b) => a + b);
        expect(bst, inInclusiveRange(555, 780), reason: '${form['name']} BST $bst not mega-like');
        final expectedDex = dexBySpecies[form['name']];
        if (expectedDex != null) {
          expect(form['nationalDexNumber'], expectedDex,
              reason: '${form['name']} must share its base species dex number');
        }
      }
    });

    test('Champions-flagged forms carry a released Champions ability; the rest explicitly do not', () {
      var championsCount = 0;
      for (final raw in forms) {
        final form = raw as Map<String, dynamic>;
        final flags = (form['flags'] as List).cast<String>();
        final abilities = form['abilities'] as List;
        if (flags.contains('champions')) {
          championsCount++;
          expect(abilities, isNotEmpty, reason: '${form['name']} needs its Champions ability');
          expect(form['championsAbility'], isTrue);
        } else {
          // Mega Dimension wave: confirmed for Z-A, waiting on Champions data.
          expect(flags, contains('legendsZA'), reason: '${form['name']} flags');
          expect(form['championsAbility'], isFalse);
        }
      }
      expect(championsCount, 35);
    });

    test('new Champions abilities are bundled in extraAbilities', () {
      final extra = (overlay['extraAbilities'] as List)
          .map((a) => (a as Map<String, dynamic>)['name'] as String)
          .toSet();
      for (final ability in <String>[
        'Piercing Drill',
        'Dragonize',
        'Mega Sol',
        'Spicy Spray',
        'Eelevate',
        'Fire Mane',
      ]) {
        expect(extra, contains(ability));
      }
    });

    test('Eternal Flower Floette override: readable name, broken shiny intentionally hidden', () {
      final overrides = (overlay['pokemonOverrides'] as List).cast<Map<String, dynamic>>();
      final floette = overrides.firstWhere((o) => o['id'] == 10061);
      expect(floette['name'], 'Eternal Flower Floette');
      expect(floette['shinySpriteUrl'], isEmpty,
          reason: 'the upstream shiny/10061.png render is upside-down/broken and must stay blank');
      // And the base bundle still ships the row the override patches.
      expect(bundledIds, contains(10061));
      expect(bundledNames[10061], isNot('Eternal Flower Floette'),
          reason: 'the readable name comes from the override, keeping the base asset untouched');
    });
  });

  group('pokemon_moves.json Champions learnsets', () {
    late List<dynamic> rows;

    setUpAll(() {
      rows = jsonDecode(File('assets/data/pokemon_moves.json').readAsStringSync()) as List<dynamic>;
    });

    test('Champions "train" rows are merged without dropping mainline rows', () {
      final train = rows.where((r) => r[2] == 'train').toList();
      expect(train.length, 19810);
      // Champions forms learn moves via Victory Points…
      expect(train.any((r) => r[0] == 10304), isTrue, reason: 'Mega Raichu X needs Champions train rows');
      expect(train.any((r) => r[0] == 10278), isTrue, reason: 'Mega Clefable needs Champions train rows');
      // …and the classic mainline learnsets stay untouched.
      expect(rows.any((r) => r[2] == 'level-up' && r[0] == 6), isTrue,
          reason: 'Charizard level-up rows must survive the merge');
    });

    test('previously missing base species keep non-empty learnsets', () {
      for (final dex in <int>[16, 18, 201, 351, 676]) {
        expect(rows.any((r) => r[0] == dex), isTrue, reason: 'National Dex $dex lost its learnset');
      }
    });
  });

  group('ChampionsCatalog search aliases', () {
    ChampionsFormInfo form(Map<String, dynamic> json) => ChampionsFormInfo.fromJson(json);

    ChampionsFormInfo byName(String name) =>
        form(forms.cast<Map<String, dynamic>>().firstWhere((f) => f['name'] == name));

    test('"mega raichu x", "raichu x" and aliases resolve Mega Raichu X', () {
      final raichu = byName('Mega Raichu X');
      expect(raichu.matchesQuery('mega raichu x'), isTrue);
      expect(raichu.matchesQuery('raichu x'), isTrue);
      expect(raichu.matchesQuery('champions'), isTrue);
      expect(raichu.matchesQuery('legends za'), isTrue);
      expect(raichu.matchesQuery('electric surge'), isTrue,
          reason: 'Champions ability names must resolve');
      expect(raichu.matchesQuery('blastoise'), isFalse);
    });

    test('token order does not matter ("x raichu mega" still matches)', () {
      expect(byName('Mega Raichu X').matchesQuery('x raichu mega'), isTrue);
    });

    test('Champions flags and Legends Z-A flags are distinct', () {
      // Mega Zygarde is Z-A confirmed but has no Champions data yet.
      final zygarde = byName('Mega Zygarde');
      expect(zygarde.isLegendsZa, isTrue);
      expect(zygarde.isChampions, isFalse);
      expect(zygarde.matchesQuery('champions'), isFalse);

      final raichu = byName('Mega Raichu X');
      expect(raichu.isLegendsZa, isTrue);
      expect(raichu.isChampions, isTrue);
    });

    test('an empty catalog matches nothing (graceful overlay-missing mode)', () {
      final catalog = ChampionsCatalog.empty();
      expect(catalog.isChampionsForm(10304), isFalse);
      expect(catalog.matchesSearch(10304, 'champions'), isFalse);
    });
  });
}
