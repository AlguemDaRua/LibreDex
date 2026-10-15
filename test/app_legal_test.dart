import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/legal/app_legal.dart';

void main() {
  test('in-app version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('version: ${AppLegal.version}+'));
  });

  test('disclaimer states non-affiliation and the trademark owner', () {
    expect(AppLegal.disclaimer, contains('not'));
    expect(AppLegal.disclaimer, contains('affiliated'));
    expect(AppLegal.disclaimer, contains('Nintendo'));
  });

  test('credits name every external source and its licence', () {
    for (final source in [
      'PokéAPI',
      'BSD 3-Clause',
      'The Pokémon Company',
      'pokemon-champions-data',
      'CC BY 4.0',
      'Pokémon Showdown',
      'smogon/damage-calc',
      'MIT License',
    ]) {
      expect(AppLegal.credits, contains(source), reason: source);
    }
  });
}
