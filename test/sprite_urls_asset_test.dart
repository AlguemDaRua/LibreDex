import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the sprite audit behind tools/fix_sprite_urls.py.
///
/// The tool patched the bundled URLs so they no longer 404 against the
/// PokeAPI/sprites repository (audited via the GitHub trees API on
/// 2026-07-27). These tests pin the outcome so regenerated data cannot
/// silently reintroduce the broken form pictures (Koraidon builds, Miraidon
/// modes, cosplay/cap Pikachus, Let's Go starters).
void main() {
  const homeBase =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home';

  // Keep in sync with tools/fix_sprite_urls.py.
  const brokenNormalFallbackDex = <int, int>{
    10080: 25, 10081: 25, 10082: 25, 10083: 25, 10084: 25, 10085: 25,
    10158: 25, 10159: 133,
    10264: 1007, 10265: 1007, 10266: 1007, 10267: 1007,
    10268: 1008, 10269: 1008, 10270: 1008, 10271: 1008,
  };
  final brokenShinyIds = <int>{
    ...brokenNormalFallbackDex.keys,
    10094, 10095, 10096, 10097, 10098, 10099, 10160,
  };

  late List<dynamic> bundle;
  late Map<int, Map<String, dynamic>> byId;

  setUpAll(() {
    bundle = jsonDecode(File('assets/data/pokemon.json').readAsStringSync()) as List<dynamic>;
    byId = {for (final p in bundle) p['id'] as int: p as Map<String, dynamic>};
  });

  group('assets/data/pokemon.json sprite audit', () {
    test('every URL follows the HOME render URL shape (or is a blank shiny)', () {
      final normal = RegExp('^$homeBase/\\d+\\.png\$');
      final shiny = RegExp('^$homeBase/shiny/\\d+\\.png\$');
      for (final p in byId.values) {
        final id = p['id'] as int;
        final sprite = p['spriteUrl'] as String;
        final shinySprite = p['shinySpriteUrl'] as String;
        expect(normal.hasMatch(sprite), isTrue, reason: 'weird spriteUrl for #$id: $sprite');
        expect(
          shinySprite.isEmpty || shiny.hasMatch(shinySprite),
          isTrue,
          reason: 'weird shinySpriteUrl for #$id: $shinySprite',
        );
      }
    });

    test('forms without an upstream render reuse their base species artwork', () {
      for (final entry in brokenNormalFallbackDex.entries) {
        final p = byId[entry.key];
        expect(p, isNotNull, reason: 'form ${entry.key} missing from bundle');
        expect(
          p!['spriteUrl'],
          '$homeBase/${entry.value}.png',
          reason: '#${entry.key} (${p['name']}) must reuse dex ${entry.value} art',
        );
      }
    });

    test('forms with no upstream shiny render ship a blank shiny URL', () {
      for (final id in brokenShinyIds) {
        final p = byId[id]!;
        expect(
          p['shinySpriteUrl'],
          '',
          reason: '#$id (${p['name']}) has no shiny render upstream; '
              'the UI shows the graceful "no shiny sprite bundled" note for blanks',
        );
      }
    });

    test('base species keep their own renders', () {
      for (final dex in <int>[25, 649, 1007, 1008]) {
        final p = byId[dex]!;
        expect(p['spriteUrl'], '$homeBase/$dex.png');
        expect(p['shinySpriteUrl'], '$homeBase/shiny/$dex.png');
      }
    });

    test('forms that genuinely have shiny renders keep them', () {
      // Mimikyu's forms are the canary: they exist upstream (normal + shiny),
      // so blanking them would be a regression in the other direction.
      for (final id in <int>[10143, 10144, 10145]) {
        final p = byId[id];
        expect(p, isNotNull, reason: 'Mimikyu form $id missing from bundle');
        expect(p!['shinySpriteUrl'], '$homeBase/shiny/$id.png');
      }
      // Cap Pikachus keep their (real) normal renders.
      for (final id in <int>[10094, 10160]) {
        expect(byId[id]!['spriteUrl'], '$homeBase/$id.png');
      }
    });
  });
}
