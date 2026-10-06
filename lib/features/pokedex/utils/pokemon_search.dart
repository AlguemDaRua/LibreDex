import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/data/champions_catalog.dart';
import 'package:libredex/core/data/champions_regulation.dart';

/// Pokédex search matching and ranking, kept free of any widget state so it
/// can be exercised directly in tests.
///
/// This logic used to live inside the Pokédex screen's State object. That
/// made it impossible to test without building the whole screen, which is
/// how the ranking bug survived: every match was ranked equal, so dex order
/// decided what the user saw and typing "gar" surfaced Magikarp and Graveler
/// above Garchomp.
class PokemonSearch {
  PokemonSearch._();

  /// Whether [pokemon] matches [query] at all.
  static bool matches(
    Pokemon pokemon,
    String query, {
    ChampionsCatalog? champions,
    ChampionsRegulationCatalog? regulation,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    final name = pokemon.name.toLowerCase();
    final form = pokemon.form.toLowerCase();
    final type1 = pokemon.type1.toLowerCase();
    final type2 = pokemon.type2?.toLowerCase() ?? '';
    final dex = '${pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id}';

    return name.contains(q) ||
        form.contains(q) ||
        type1.contains(q) ||
        type2.contains(q) ||
        dex.contains(q) ||
        dex.padLeft(3, '0').contains(q) ||
        // Champions / Legends Z-A forms also answer to alias searches such
        // as "champions", "mega raichu x", "raichu x", "legends za",
        // "eternal", "floette eternal" or a Champions ability name.
        (champions?.matchesSearch(pokemon.id, q) ?? false) ||
        (regulation?.matchesPokemonSearch(
              pokemon.id,
              q,
              aliases: '$name $form $type1 $type2 $dex',
            ) ??
            false) ||
        // Order-free token search, so "floette eternal" still finds the
        // "Eternal Flower Floette" display name (and "raichu x" the Mega).
        matchesTokens(q, name, form) ||
        isSubsequence(q, name.replaceAll('-', ''));
  }

  /// True when every whitespace-separated token of [query] appears somewhere
  /// in the name or form, in any order. Only applies to multi-word queries.
  static bool matchesTokens(String query, String name, String form) {
    final tokens =
        query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.length < 2) return false;
    final haystack = '$name $form';
    return tokens.every(haystack.contains);
  }

  /// True when [query]'s characters appear in [text] in order, with gaps.
  /// Short queries are rejected because they match almost everything.
  static bool isSubsequence(String query, String text) {
    if (query.length < 3) return false;
    var index = 0;
    for (final codeUnit in text.codeUnits) {
      if (codeUnit == query.codeUnitAt(index)) index++;
      if (index == query.length) return true;
    }
    return false;
  }

  /// How well [pokemon] matches [query]. Lower is better.
  ///
  /// Without ranking every match is equal and dex order decides what the user
  /// sees first, which reads as "search only works once you have typed the
  /// whole name".
  static int rank(Pokemon pokemon, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return 0;

    final name = pokemon.name.toLowerCase();
    final form = pokemon.form.toLowerCase();
    final type1 = pokemon.type1.toLowerCase();
    final type2 = pokemon.type2?.toLowerCase() ?? '';
    final dexNum = pokemon.nationalDexNumber > 0
        ? pokemon.nationalDexNumber
        : pokemon.id;
    final dex = dexNum.toString();

    if (name == q) return 0;
    if (name.startsWith(q)) return 1;
    if (name.split('-').any((part) => part.startsWith(q))) return 2;
    if (name.contains(q)) return 3;
    if (form.contains(q)) return 4;
    if (q == dex || q == dex.padLeft(3, '0')) return 5;
    if (type1.contains(q) || type2.contains(q)) return 6;

    // Order-free tokens ("floette eternal") still beat a bare subsequence.
    final tokens =
        q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.length >= 2 && tokens.every('$name $form'.contains)) return 7;

    // Everything else - subsequence hits, Champions aliases, regulation
    // aliases - shares the last band and falls back to dex order. It can
    // therefore never outrank a real name match.
    return 8;
  }

  /// Best rank across a species' forms, so a group is placed by its strongest
  /// match rather than whichever form happens to be first.
  static int groupRank(List<Pokemon> forms, String query) {
    if (forms.isEmpty) return 8;
    var best = 8;
    for (final form in forms) {
      final r = rank(form, query);
      if (r < best) best = r;
    }
    return best;
  }
}
