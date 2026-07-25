import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Fetching pokemon junctions via GraphQL...');
  final url = Uri.parse('https://beta.pokeapi.co/graphql/v1beta');

  final query = '''
  query {
    pokemon_v2_pokemon {
      id
      pokemon_v2_pokemonabilities {
        is_hidden
        pokemon_v2_ability {
          id
        }
      }
      pokemon_v2_pokemonmoves(where: {pokemon_v2_versiongroup: {name: {_in: ["scarlet-violet", "sword-shield"]}}}) {
        pokemon_v2_move {
          id
        }
        pokemon_v2_movelearnmethod {
          name
        }
        level
      }
    }
  }
  ''';

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'query': query}),
  );

  if (response.statusCode != 200) {
    print('Failed to fetch data: \${response.statusCode}');
    return;
  }

  final data = jsonDecode(response.body)['data'];
  final pokemons = data['pokemon_v2_pokemon'] as List;

  List<Map<String, dynamic>> pokemonAbilities = [];
  List<Map<String, dynamic>> pokemonMoves = [];

  for (final p in pokemons) {
    final int pId = p['id'];
    
    for (final a in p['pokemon_v2_pokemonabilities']) {
      if (a['pokemon_v2_ability'] == null) continue;
      pokemonAbilities.add({
        'pokemonId': pId,
        'abilityId': a['pokemon_v2_ability']['id'],
        'isHidden': a['is_hidden'],
      });
    }

    for (final m in p['pokemon_v2_pokemonmoves']) {
      if (m['pokemon_v2_move'] == null) continue;
      pokemonMoves.add({
        'pokemonId': pId,
        'moveId': m['pokemon_v2_move']['id'],
        'learnMethod': m['pokemon_v2_movelearnmethod']['name'],
        'levelLearned': m['level'],
      });
    }
  }

  File('assets/data/pokemon_abilities.json').writeAsStringSync(jsonEncode(pokemonAbilities));
  File('assets/data/pokemon_moves.json').writeAsStringSync(jsonEncode(pokemonMoves));

  print('Done.');
}
