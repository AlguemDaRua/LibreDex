import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/features/itemdex/models/itemdex_entry.dart';

void main() {
  late List<ItemDexEntry> items;

  setUpAll(() {
    final rows =
        jsonDecode(File('assets/data/items.json').readAsStringSync())
            as List<dynamic>;
    items = rows
        .map((row) => ItemDexEntry.fromJson(row as Map<String, dynamic>))
        .toList();
  });

  test(
    'Mega Stone rows keep Legends: Z-A provenance separate from Champions',
    () {
      final absolite = items.singleWhere((item) => item.id == 2265);
      expect(absolite.isChampionsItem, isFalse);
      expect(absolite.isEvolutionItem, isTrue);
      expect(absolite.isHeldItem, isTrue);
      expect(absolite.isLegendsZAItem, isTrue);
      expect(absolite.shortEffect, contains('Mega Evolve'));
    },
  );

  test(
    'Roseli Berry stub is retained as a generation-aware canonical alias',
    () {
      final canonical = items.singleWhere((item) => item.id == 723);
      final alias = items.singleWhere((item) => item.id == 2279);

      expect(canonical.generation, 6);
      expect(alias.aliasOf, 723);
      expect(alias.isAlias, isTrue);
      expect(alias.generation, canonical.generation);
      expect(alias.isHeldItem, isTrue);
      expect(alias.shortEffect, contains('Fairy-type'));
    },
  );

  test('Champions item provenance comes from tags, not numeric IDs', () {
    final highIdWithoutOrigin = ItemDexEntry(
      id: 10000,
      name: 'Unclassified item',
      category: 'Held Items',
      subcategory: 'Held Items',
      shortEffect: '',
      description: '',
      tags: const [],
    );
    final explicitlyTagged = ItemDexEntry(
      id: 42,
      name: 'Champions item',
      category: 'Held Items',
      subcategory: 'Held Items',
      shortEffect: '',
      description: '',
      tags: const ['Champions'],
    );

    expect(highIdWithoutOrigin.isChampionsItem, isFalse);
    expect(explicitlyTagged.isChampionsItem, isTrue);
  });

  test('M-C-eligible existing items stay a separate regulation lookup', () {
    final leek = items.singleWhere((item) => item.id == 236);
    final salamencite = items.singleWhere((item) => item.id == 810);
    expect(leek.isChampionsItem, isFalse);
    expect(salamencite.isChampionsItem, isFalse);
    expect(leek.shortEffect, isNot(contains('No effect text')));
    expect(salamencite.shortEffect, isNot(contains('No effect text')));
  });
}
