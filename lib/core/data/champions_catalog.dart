import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads the bundled Pokémon Champions / Legends Z-A forms overlay
/// (`assets/data/forms_extra.json`) once and exposes fast lookups so the UI
/// can flag Champions content without growing the database schema.
final championsCatalogProvider = FutureProvider<ChampionsCatalog>((ref) async {
  try {
    final raw = await rootBundle.loadString('assets/data/forms_extra.json');
    return compute(_decodeCatalog, raw);
  } catch (_) {
    // The overlay is additive: without it the app behaves exactly as before.
    return ChampionsCatalog.empty();
  }
});

ChampionsCatalog _decodeCatalog(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final forms = <ChampionsFormInfo>[];
  for (final entry in (json['pokemon'] as List<dynamic>? ?? const [])) {
    final map = entry as Map<String, dynamic>;
    forms.add(ChampionsFormInfo.fromJson(map));
  }
  return ChampionsCatalog(forms);
}

/// One overlay form (Mega Evolutions introduced in Legends Z-A / Champions).
class ChampionsFormInfo {
  final int id;
  final String name;
  final int nationalDexNumber;
  final Set<String> flags;
  final List<String> abilityNames;

  /// Lowercase haystack used for token-substring search matching.
  final String searchText;

  const ChampionsFormInfo._({
    required this.id,
    required this.name,
    required this.nationalDexNumber,
    required this.flags,
    required this.abilityNames,
    required this.searchText,
  });

  factory ChampionsFormInfo.fromJson(Map<String, dynamic> json) {
    final flags = <String>{
      for (final f in (json['flags'] as List<dynamic>? ?? const [])) '$f'.toLowerCase(),
    };
    // Ability *ids* are seeded into the database; the catalog only keeps a
    // readable echo for search. Bundled abilities resolve by id, the six new
    // Champions abilities resolve through the overlay's extraAbilities too.
    final abilityNames = <String>[
      for (final a in (json['abilityNames'] as List<dynamic>? ?? const [])) '$a',
    ];

    final aliases = <String>[
      json['name'] as String? ?? '',
      (json['pokedexIdentifier'] as String? ?? '').replaceAll('-', ' '),
      if (flags.contains('mega')) 'mega',
      if (flags.contains('champions')) 'pokemon champions champions',
      if (flags.contains('legendsZA') || flags.contains('legendsza'))
        'legends z-a legends za z-a za',
      ...abilityNames,
    ];
    return ChampionsFormInfo._(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nationalDexNumber: json['nationalDexNumber'] as int? ?? 0,
      flags: flags,
      abilityNames: abilityNames,
      searchText: aliases.join(' | ').toLowerCase(),
    );
  }

  bool get isMega => flags.contains('mega');
  bool get isChampions => flags.contains('champions');
  bool get isLegendsZa => flags.contains('legendsza') || flags.contains('legendsz-a');
  bool get isProvisional => flags.contains('provisional');

  /// True when every token of [query] appears somewhere in this form's
  /// aliases, so "mega raichu x", "raichu x", "floette eternal" and ability
  /// names like "huge power" all resolve. Token matching is order-free but
  /// still cheap — the catalog holds ~50 forms, nothing fuzzy.
  bool matchesQuery(String query) {
    final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return false;
    return tokens.every(searchText.contains);
  }
}

/// Read-only view over the overlay, with O(1) flag lookups for filters.
class ChampionsCatalog {
  final List<ChampionsFormInfo> forms;
  late final Map<int, ChampionsFormInfo> _byId = {for (final f in forms) f.id: f};

  ChampionsCatalog(this.forms);

  factory ChampionsCatalog.empty() => ChampionsCatalog(const []);

  ChampionsFormInfo? byId(int id) => _byId[id];

  bool isChampionsForm(int pokemonId) => _byId[pokemonId]?.isChampions ?? false;
  bool isLegendsZaForm(int pokemonId) => _byId[pokemonId]?.isLegendsZa ?? false;
  bool isOverlayMega(int pokemonId) => _byId[pokemonId]?.isMega ?? false;
  bool isProvisional(int pokemonId) => _byId[pokemonId]?.isProvisional ?? false;

  /// Display name from the overlay asset (already human-readable, e.g.
  /// "Mega Raichu X"); falls back to the database name everywhere else.
  String? displayName(int pokemonId) => _byId[pokemonId]?.name;

  /// Matches Champions overlay forms against a free-text search query
  /// ("champions", "mega", "mega raichu x", "raichu x", "legends za",
  /// "eternal", "floette eternal", or any Champions ability name).
  bool matchesSearch(int pokemonId, String query) {
    final form = _byId[pokemonId];
    if (form == null) return false;
    return form.matchesQuery(query.trim().toLowerCase());
  }

  /// Ability names as bundled in the overlay (Champions-specific overrides).
  List<String> abilityNamesFor(int pokemonId) =>
      _byId[pokemonId]?.abilityNames ?? const [];
}
