import 'package:libredex/core/database/app_database.dart';

/// Pure Dart utility to parse and export Pokémon teams in Pokémon Showdown text format.
class ShowdownParser {
  /// Converts a list of [Pokemon] objects into standard Pokémon Showdown export text.
  static String exportTeam(List<Pokemon?> team) {
    final buffer = StringBuffer();

    for (final pokemon in team) {
      if (pokemon == null) continue;

      final nameStr = _formatShowdownName(pokemon);
      buffer.writeln(nameStr);

      // Default balanced competitive EVs & Nature hints as export defaults
      buffer.writeln('EVs: 252 HP / 4 Def / 252 Spe');
      buffer.writeln('Serious Nature');
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }

  /// Parses a raw Pokémon Showdown paste block into a list of [Pokemon] database objects.
  static Future<List<Pokemon?>> parseShowdownText(String text, AppDatabase db) async {
    final List<Pokemon?> slots = List<Pokemon?>.filled(6, null);
    if (text.trim().isEmpty) return slots;

    final blocks = text.trim().split(RegExp(r'\n\s*\n'));
    int slotIdx = 0;

    final allPokemons = await db.select(db.pokemonTable).get();

    for (final block in blocks) {
      if (slotIdx >= 6) break;
      final lines = block.trim().split('\n');
      if (lines.isEmpty) continue;

      final headerLine = lines[0].trim();
      if (headerLine.isEmpty) continue;

      final speciesName = _extractSpeciesFromHeader(headerLine);
      final matchedPokemon = _matchPokemon(speciesName, allPokemons);

      if (matchedPokemon != null) {
        slots[slotIdx] = matchedPokemon;
        slotIdx++;
      }
    }

    return slots;
  }

  /// Formats a [Pokemon] object into a Showdown-compatible species string (e.g. "Ninetales-Alola").
  static String _formatShowdownName(Pokemon pokemon) {
    final String rawName = _capitalize(pokemon.name);
    final String form = pokemon.form.toLowerCase();

    if (form == 'normal' || form.isEmpty) {
      return rawName;
    }

    // Capitalize form tag for Showdown parity (e.g. Alola, Galar, Wash, Mega)
    final String formCap = _capitalize(form);
    return '$rawName-$formCap';
  }

  /// Extracts the base species/form name from a Showdown header line:
  /// e.g. "Pikachu @ Light Ball", "Sparky (Pikachu) @ Light Ball", "Rotom-Wash"
  static String _extractSpeciesFromHeader(String header) {
    String line = header;
    if (line.contains('@')) {
      line = line.split('@').first.trim();
    }

    // Handle Nickname (Species)
    final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(line);
    if (parenMatch != null) {
      return parenMatch.group(1)!.trim();
    }

    return line.trim();
  }

  /// Matches a raw parsed Showdown string against database Pokémon entries.
  static Pokemon? _matchPokemon(String query, List<Pokemon> catalog) {
    final cleanQuery = query.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleanQuery.isEmpty) return null;

    // 1. Direct name match
    for (final p in catalog) {
      final pClean = p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final pFormClean = p.form.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

      // Check combined name-form e.g. ninetalesalola
      if ('$pClean$pFormClean' == cleanQuery) {
        return p;
      }
      if (pClean == cleanQuery && (p.form == 'normal' || p.form.isEmpty)) {
        return p;
      }
    }

    // 2. Partial match fallback
    for (final p in catalog) {
      final pClean = p.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (cleanQuery.contains(pClean)) {
        return p;
      }
    }

    return null;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
