import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _versionGroupsNewestFirst = [
  'scarlet-violet',
  'sword-shield',
  'ultra-sun-ultra-moon',
  'sun-moon',
  'omega-ruby-alpha-sapphire',
  'x-y',
  'black-2-white-2',
  'black-white',
  'heartgold-soulsilver',
  'platinum',
];

const _mustHaveBaseDexNumbers = {
  16,
  18,
  201,
  351,
  676,
};

Future<void> main() async {
  stdout.writeln('Fetching Pokémon junctions via GraphQL...');
  final url = Uri.parse('https://beta.pokeapi.co/graphql/v1beta');

  final query = '''
  query Junctions(\$versionGroups: [String!]) {
    pokemon_v2_pokemon {
      id
      pokemon_species_id
      pokemon_v2_pokemonabilities {
        is_hidden
        pokemon_v2_ability { id }
      }
      pokemon_v2_pokemonmoves(
        where: {pokemon_v2_versiongroup: {name: {_in: \$versionGroups}}}
      ) {
        pokemon_v2_versiongroup { name }
        pokemon_v2_move { id }
        pokemon_v2_movelearnmethod { name }
        level
      }
    }
  }
  ''';

  Map<String, dynamic> payload;
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'variables': {'versionGroups': _versionGroupsNewestFirst},
      }),
    );

    if (response.statusCode != 200) {
      stderr.writeln('Failed to fetch data: ${response.statusCode}');
      exitCode = 1;
      return;
    }
    payload = jsonDecode(response.body) as Map<String, dynamic>;
  } on Object catch (error) {
    stderr.writeln('Could not reach PokéAPI GraphQL: $error');
    stderr.writeln('Existing assets were left untouched. Re-run this tool when network access is available.');
    exitCode = 1;
    return;
  }

  if (payload['errors'] != null) {
    stderr.writeln('GraphQL returned errors: ${jsonEncode(payload['errors'])}');
    exitCode = 1;
    return;
  }

  final data = payload['data'] as Map<String, dynamic>?;
  final pokemons = data?['pokemon_v2_pokemon'] as List<dynamic>?;
  if (pokemons == null || pokemons.isEmpty) {
    stderr.writeln('GraphQL returned no Pokémon; existing assets were left untouched.');
    exitCode = 1;
    return;
  }

  final pokemonAbilities = <Map<String, dynamic>>[];
  final abilityKeys = <String>{};
  final bestMoves = <String, _MoveChoice>{};
  final speciesWithMoves = <int>{};
  final versionRank = {
    for (var i = 0; i < _versionGroupsNewestFirst.length; i++)
      _versionGroupsNewestFirst[i]: i,
  };

  for (final rawPokemon in pokemons) {
    final p = rawPokemon as Map<String, dynamic>;
    final pId = p['id'] as int;
    final speciesId = p['pokemon_species_id'] as int? ?? pId;

    for (final rawAbility in p['pokemon_v2_pokemonabilities'] as List<dynamic>) {
      final a = rawAbility as Map<String, dynamic>;
      final ability = a['pokemon_v2_ability'] as Map<String, dynamic>?;
      if (ability == null) continue;
      final abilityId = ability['id'] as int;
      final isHidden = a['is_hidden'] as bool? ?? false;
      final key = '$pId/$abilityId/$isHidden';
      if (!abilityKeys.add(key)) continue;
      pokemonAbilities.add({
        'pokemonId': pId,
        'abilityId': abilityId,
        'isHidden': isHidden,
      });
    }

    for (final rawMove in p['pokemon_v2_pokemonmoves'] as List<dynamic>) {
      final m = rawMove as Map<String, dynamic>;
      final move = m['pokemon_v2_move'] as Map<String, dynamic>?;
      final method = m['pokemon_v2_movelearnmethod'] as Map<String, dynamic>?;
      final group = m['pokemon_v2_versiongroup'] as Map<String, dynamic>?;
      if (move == null || method == null || group == null) continue;

      final moveId = move['id'] as int;
      final methodName = method['name'] as String;
      final groupName = group['name'] as String;
      final rank = versionRank[groupName];
      if (rank == null) continue;

      final key = '$pId/$moveId/$methodName';
      final candidate = _MoveChoice(
        pokemonId: pId,
        speciesId: speciesId,
        moveId: moveId,
        method: methodName,
        level: m['level'] as int?,
        versionRank: rank,
      );
      final existing = bestMoves[key];
      if (existing == null || candidate.isNewerThan(existing)) {
        bestMoves[key] = candidate;
      }
    }
  }

  final pokemonMoves = bestMoves.values.toList()
    ..sort((a, b) {
      final byPokemon = a.pokemonId.compareTo(b.pokemonId);
      if (byPokemon != 0) return byPokemon;
      final byMethod = a.method.compareTo(b.method);
      if (byMethod != 0) return byMethod;
      final byLevel = (a.level ?? -1).compareTo(b.level ?? -1);
      if (byLevel != 0) return byLevel;
      return a.moveId.compareTo(b.moveId);
    });

  for (final move in pokemonMoves) {
    speciesWithMoves.add(move.speciesId);
  }

  final missingMustHave = _mustHaveBaseDexNumbers.difference(speciesWithMoves);
  if (missingMustHave.isNotEmpty) {
    stderr.writeln('Validation failed. Still missing learnsets for: ${missingMustHave.join(', ')}');
    stderr.writeln('Existing assets were left untouched. Add an older fallback version group and re-run.');
    exitCode = 1;
    return;
  }

  File('assets/data/pokemon_abilities.json').writeAsStringSync(jsonEncode(pokemonAbilities));
  File('assets/data/pokemon_moves.json').writeAsStringSync(jsonEncode(pokemonMoves.map((m) => m.toCompactJson()).toList()));

  stdout.writeln('Done. Abilities: ${pokemonAbilities.length}; moves: ${pokemonMoves.length}.');
  stdout.writeln('pokemon_moves.json now uses compact [pokemonId, moveId, method, level] rows.');
}

class _MoveChoice {
  final int pokemonId;
  final int speciesId;
  final int moveId;
  final String method;
  final int? level;
  final int versionRank;

  const _MoveChoice({
    required this.pokemonId,
    required this.speciesId,
    required this.moveId,
    required this.method,
    required this.level,
    required this.versionRank,
  });

  bool isNewerThan(_MoveChoice other) {
    if (versionRank != other.versionRank) return versionRank < other.versionRank;
    // Same version/method duplicates are rare; lower levels are more helpful to show.
    return (level ?? 999) < (other.level ?? 999);
  }

  List<Object?> toCompactJson() => [pokemonId, moveId, method, level];
}
