import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Fetching abilities and moves via GraphQL...');
  final url = Uri.parse('https://beta.pokeapi.co/graphql/v1beta');

  final query = '''
  query {
    pokemon_v2_move {
      id
      name
      power
      accuracy
      pp
      pokemon_v2_type {
        name
      }
      pokemon_v2_movedamageclass {
        name
      }
      pokemon_v2_moveflavortexts(where: {language_id: {_eq: 9}}, limit: 1) {
        flavor_text
      }
    }
    pokemon_v2_ability {
      id
      name
      pokemon_v2_abilityflavortexts(where: {language_id: {_eq: 9}}, limit: 1) {
        flavor_text
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
  final moves = data['pokemon_v2_move'] as List;
  final abilities = data['pokemon_v2_ability'] as List;

  final processedMoves = moves.map((m) {
    String desc = 'No description available.';
    final flavorTexts = m['pokemon_v2_moveflavortexts'] as List;
    if (flavorTexts.isNotEmpty) {
      desc = flavorTexts.first['flavor_text'].toString().replaceAll('\n', ' ');
    }
    return {
      'id': m['id'],
      'name': m['name'].toString().replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' '),
      'type': m['pokemon_v2_type'] != null ? m['pokemon_v2_type']['name'] : 'normal',
      'power': m['power'],
      'accuracy': m['accuracy'],
      'pp': m['pp'] ?? 10,
      'damageClass': m['pokemon_v2_movedamageclass'] != null ? m['pokemon_v2_movedamageclass']['name'] : 'status',
      'description': desc,
    };
  }).toList();

  final processedAbilities = abilities.map((a) {
    String desc = 'No description available.';
    final flavorTexts = a['pokemon_v2_abilityflavortexts'] as List;
    if (flavorTexts.isNotEmpty) {
      desc = flavorTexts.first['flavor_text'].toString().replaceAll('\n', ' ');
    }
    return {
      'id': a['id'],
      'name': a['name'].toString().replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' '),
      'description': desc,
    };
  }).toList();

  final dir = Directory('assets/data');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  File('assets/data/moves.json').writeAsStringSync(jsonEncode(processedMoves));
  File('assets/data/abilities.json').writeAsStringSync(jsonEncode(processedAbilities));

  print('Successfully saved \${processedMoves.length} moves and \${processedAbilities.length} abilities.');
}
