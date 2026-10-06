import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/data/champions_regulation.dart';

void main() {
  late Map<String, dynamic> raw;
  late ChampionsRegulationCatalog catalog;

  setUpAll(() {
    raw =
        jsonDecode(
              File(
                'assets/data/champions_regulation_mc.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    catalog = ChampionsRegulationCatalog.fromJson(raw);
  });

  test(
    'M-C catalog keeps roster entries separate from official species count',
    () {
      expect(catalog.regulationCode, 'M-C');
      expect(catalog.gameVersion, '1.2.0');
      expect(catalog.asOf, '2026-10-01');
      expect(catalog.rosterEntryCount, 345);
      expect(catalog.newPokemonIds, hasLength(29));
      expect(catalog.newMegaFormIds, hasLength(6));
      expect(catalog.newRosterPokemonIds, hasLength(35));
      expect(catalog.officialNewPokemonCount, 24);
      expect(catalog.patchSummary, contains('Wish and Strength Sap'));
      expect(catalog.sourcePokemonIds.length, 345);
      expect(catalog.sourcePokemonIds.values.toSet(), hasLength(345));
    },
  );

  test('current and newly eligible IDs are independently queryable', () {
    expect(catalog.isPokemonEligible(6), isTrue);
    expect(catalog.isPokemonEligible(10307), isTrue);
    expect(catalog.isPokemonEligible(99999), isFalse);
    expect(catalog.isNewPokemon(930), isTrue);
    expect(catalog.isNewPokemon(10307), isTrue);
    expect(catalog.isNewPokemon(6), isFalse);
    expect(catalog.matchesPokemonSearch(930, 'new m-c'), isTrue);
    expect(
      catalog.matchesPokemonSearch(
        930,
        'newly eligible',
        aliases: 'gogoat normal',
      ),
      isTrue,
    );
    expect(catalog.matchesPokemonSearch(6, 'new m-c'), isFalse);
    expect(
      catalog.matchesPokemonSearch(
        25,
        'm-c pikachu',
        aliases: 'pikachu normal electric 25',
      ),
      isTrue,
    );
    expect(
      catalog.matchesPokemonSearch(25, 'new m-c', aliases: 'pikachu'),
      isFalse,
    );
  });

  test('high-ID Shadow moves are not implicitly Champions-origin moves', () {
    final rows =
        jsonDecode(File('assets/data/moves.json').readAsStringSync())
            as List<dynamic>;
    final shadowMoves = rows
        .where((row) => row['id'] >= 10001 && row['id'] <= 10018)
        .toList();

    expect(shadowMoves, hasLength(18));
    expect(
      shadowMoves.every((row) => row['name'].startsWith('Shadow ')),
      isTrue,
    );
    expect(shadowMoves.every((row) => row['isChampionsMove'] != true), isTrue);
  });

  test('M-C move, ability and item pools retain the researched deltas', () {
    expect(catalog.moveIds, hasLength(510));
    expect(catalog.newMoveIds, hasLength(14));
    expect(catalog.abilityIds, hasLength(216));
    expect(catalog.newAbilityIds, hasLength(15));
    expect(catalog.itemIds, hasLength(151));
    expect(catalog.newItemIds, hasLength(18));

    expect(catalog.isMoveAvailable(756), isTrue); // Court Change
    expect(catalog.isNewMove(892), isTrue); // Double Shock
    expect(catalog.isAbilityAvailable(314), isTrue); // Aura Guard
    expect(catalog.isNewAbility(314), isTrue);
    expect(catalog.isItemAvailable(2265), isTrue); // Absolite Z
    expect(catalog.isNewItem(2265), isTrue);
    expect(
      catalog.isItemAvailable(236),
      isTrue,
    ); // Leek: newly eligible, not new to the series
    expect(catalog.isNewItem(236), isTrue);
    expect(catalog.newAbilityDescriptionFor(314), contains('contact moves'));
  });

  test('official M-C balance changes stay regulation-specific', () {
    expect(catalog.newlyUsableMoveIds, contains(163)); // Slash
    expect(catalog.movePpFor(273), 8); // Wish
    expect(catalog.previousMovePpFor(273), 12);
    expect(catalog.movePpFor(668), 8); // Strength Sap
    expect(catalog.removedMoves, hasLength(3));
    expect(
      catalog.removedMoves.map((change) => change.moveName).toSet(),
      containsAll(['Pound', 'Mirror Coat', 'Metal Burst']),
    );
    final removedPairs = catalog.removedMoves
        .map((change) => '${change.pokemonId}:${change.moveId}')
        .toSet();
    expect(removedPairs, containsAll(['186:1', '1018:243', '1018:368']));
  });

  test('bundled M-C learnsets apply removals and keep Slash available', () {
    final rows =
        jsonDecode(File('assets/data/pokemon_moves.json').readAsStringSync())
            as List<dynamic>;
    final train = rows.where((row) => row[2] == 'train').toList();
    final pairs = train.map((row) => '${row[0]}:${row[1]}').toSet();

    expect(train, hasLength(21488));
    expect(pairs, isNot(contains('186:1')));
    expect(pairs, isNot(contains('1018:243')));
    expect(pairs, isNot(contains('1018:368')));
    expect(train.any((row) => row[1] == 163), isTrue);
    expect(train.map((row) => row[0]).toSet(), hasLength(345));
  });
}
