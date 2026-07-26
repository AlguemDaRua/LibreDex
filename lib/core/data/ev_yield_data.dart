import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final evYieldDatasetProvider = FutureProvider<Map<int, EvYieldFacts>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/pokemon_ev_yields.json');
  return compute(_decodeEvYields, raw);
});

Map<int, EvYieldFacts> _decodeEvYields(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return json.map((key, value) {
    return MapEntry(int.parse(key), EvYieldFacts.fromJson(value as Map<String, dynamic>));
  });
}

class EvYieldFacts {
  final Map<String, int> values;

  const EvYieldFacts(this.values);

  factory EvYieldFacts.fromJson(Map<String, dynamic> json) {
    return EvYieldFacts(json.map((key, value) => MapEntry(key, value as int)));
  }

  String get label {
    if (values.isEmpty) return 'Unknown';
    const names = {
      'hp': 'HP',
      'atk': 'Attack',
      'def': 'Defense',
      'spatk': 'Sp. Atk',
      'spdef': 'Sp. Def',
      'spd': 'Speed',
    };
    return values.entries
        .where((entry) => entry.value > 0)
        .map((entry) => '+${entry.value} ${names[entry.key] ?? entry.key}')
        .join(', ');
  }

  List<String> get statKeys => values.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toList();
}
