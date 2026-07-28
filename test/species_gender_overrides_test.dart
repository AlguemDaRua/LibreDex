import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/data/species_data.dart';

/// Pins the form-level gender overrides: PokéAPI reports a single gender
/// ratio per species, which is wrong for gender-morph forms (Indeedee-Female
/// reads 50/50 at the species level but is 100% female in the games) and for
/// event-locked forms (cap Pikachu always male, Cosplay Pikachu always
/// female).
void main() {
  group('SpeciesDataset.genderFor', () {
    test('applies the form override before any species data', () {
      final ratio = SpeciesDataset.empty.genderFor(10186, nationalDexNumber: 876);
      expect(ratio, same(SpeciesDataset.femaleLocked));
      expect(ratio!.femalePercent, 100);
      expect(ratio.malePercent, 0);
    });

    test('male morph base rows resolve to 100% male', () {
      for (final id in [678, 876, 902]) {
        expect(
          SpeciesDataset.empty.genderFor(id),
          same(SpeciesDataset.maleLocked),
          reason: 'form id $id is the male morph row',
        );
      }
    });

    test('female morph rows resolve to 100% female', () {
      for (final id in [10025, 10186, 10248, 10254]) {
        expect(
          SpeciesDataset.empty.genderFor(id),
          same(SpeciesDataset.femaleLocked),
          reason: 'form id $id is the female morph row',
        );
      }
    });

    test('forms without an override fall back to the species ratio (or null)', () {
      expect(SpeciesDataset.empty.genderFor(6, nationalDexNumber: 6), isNull);
    });

    test('overrides only cover forms that exist in the bundled pokemon.json', () {
      final bundle = jsonDecode(File('assets/data/pokemon.json').readAsStringSync()) as List<dynamic>;
      final byId = {for (final p in bundle) p['id'] as int: p as Map<String, dynamic>};
      for (final id in SpeciesDataset.formGenderOverrides.keys) {
        final row = byId[id];
        expect(row, isNotNull, reason: 'gender override for unknown form id $id');
        final name = (row!['name'] as String).toLowerCase();
        final locked = SpeciesDataset.formGenderOverrides[id]!;
        if (locked.malePercent == 100 && id != 678 && id != 876 && id != 902) {
          // Event-locked male forms (caps, Battle Bond) — name sanity only.
          expect(name, isNot(contains('female')));
        }
        if (locked.femalePercent == 100) {
          expect(
            name.contains('female') || name.contains('pikachu'),
            isTrue,
            reason: 'a 100%-female override must sit on the female visual: $name',
          );
        }
      }
    });

    test('the specific case the user reported: Indeedee-Female is 100% female', () {
      final indeedeeFemale = SpeciesDataset.empty.genderFor(10186, nationalDexNumber: 876)!;
      expect(indeedeeFemale.genderless, isFalse);
      expect(indeedeeFemale.femalePercent, 100);
      // ...and its male counterpart is 100% male, not the species 50/50.
      final indeedeeMale = SpeciesDataset.empty.genderFor(876, nationalDexNumber: 876)!;
      expect(indeedeeMale.malePercent, 100);
    });
  });
}
