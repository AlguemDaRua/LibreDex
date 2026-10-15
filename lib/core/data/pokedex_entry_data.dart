import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pokedexEntryDatasetProvider = FutureProvider<Map<int, PokedexEntryFacts>>(
  (ref) async {
    final raw = await rootBundle.loadString('assets/data/pokedex_entries.json');
    return compute(_decodeEntries, raw);
  },
);

Map<int, PokedexEntryFacts> _decodeEntries(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return json.map((key, value) {
    return MapEntry(
      int.parse(key),
      PokedexEntryFacts.fromJson(value as Map<String, dynamic>),
    );
  });
}

/// Short category label only (for example "Seed Pokémon").
///
/// Pokédex description sentences are game text and are deliberately not
/// bundled or displayed; see NOTICE.md.
class PokedexEntryFacts {
  final String genus;

  const PokedexEntryFacts({required this.genus});

  factory PokedexEntryFacts.fromJson(Map<String, dynamic> json) {
    return PokedexEntryFacts(genus: json['genus'] as String? ?? '');
  }
}
