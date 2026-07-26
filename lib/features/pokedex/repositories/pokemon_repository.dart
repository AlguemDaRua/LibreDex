import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/network/api_client.dart';
import 'package:libredex/features/pokedex/models/evolution_chain_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pokemon_repository.g.dart';

/// Single shared database instance, closed when the app scope is disposed.
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
}

/// Repository provider injected with Drift Database.
@Riverpod(keepAlive: true)
PokemonRepository pokemonRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  return PokemonRepository(db: db);
}

/// Repository responsible for syncing and retrieving offline-first Pokémon data.
class PokemonRepository {
  final AppDatabase db;

  PokemonRepository({required this.db});

  /// Watch all Pokémon reactively (updates in real time).
  Stream<List<Pokemon>> watchAllPokemon() {
    return db.select(db.pokemonTable).watch();
  }


  /// Watch abilities with full details for a given Pokémon using JOIN
  Stream<List<PokemonAbilityWithDetails>> watchAbilitiesForPokemon(int pokemonId) {
    final query = db.select(db.pokemonAbilitiesTable).join([
      innerJoin(db.abilityTable, db.abilityTable.id.equalsExp(db.pokemonAbilitiesTable.abilityId)),
    ])..where(db.pokemonAbilitiesTable.pokemonId.equals(pokemonId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final junction = row.readTable(db.pokemonAbilitiesTable);
        final ability = row.readTable(db.abilityTable);
        return PokemonAbilityWithDetails(junction: junction, ability: ability);
      }).toList();
    });
  }

  /// Watch moves with full details for a given Pokémon using JOIN
  Stream<List<PokemonMoveWithDetails>> watchMovesForPokemon(int pokemonId) {
    final query = db.select(db.pokemonMovesTable).join([
      innerJoin(db.moveTable, db.moveTable.id.equalsExp(db.pokemonMovesTable.moveId)),
    ])..where(db.pokemonMovesTable.pokemonId.equals(pokemonId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final junction = row.readTable(db.pokemonMovesTable);
        final move = row.readTable(db.moveTable);
        return PokemonMoveWithDetails(junction: junction, move: move);
      }).toList();
    });
  }

  /// Fetches evolution chain steps for a given National Dex ID and available forms.
  Future<List<EvolutionStep>> fetchEvolutionSteps(int dexNum, List<Pokemon> forms) async {
    final List<EvolutionStep> steps = [];

    try {
      // 1. Fetch species data from PokeAPI to get evolution chain URL
      final speciesRes = await ApiClient.get('pokemon-species/$dexNum');
      final evoChainUrl = speciesRes.data['evolution_chain']?['url'] as String?;

      if (evoChainUrl != null) {
        final chainId = evoChainUrl.split('/').where((s) => s.isNotEmpty).last;
        final chainRes = await ApiClient.get('evolution-chain/$chainId');
        final chainData = chainRes.data['chain'];

        await _parseChainNode(chainData, steps);
      }
    } catch (_) {
      // Fallback: If network is offline, attempt local species lookup
    }

    return steps;
  }

  Future<void> _parseChainNode(Map<String, dynamic> node, List<EvolutionStep> steps) async {
    final speciesName = node['species']['name'] as String;
    final speciesUrl = node['species']['url'] as String;
    final fromDexId = int.parse(speciesUrl.split('/').where((s) => s.isNotEmpty).last);

    final evolvesTo = node['evolves_to'] as List<dynamic>?;
    if (evolvesTo == null || evolvesTo.isEmpty) return;

    for (final next in evolvesTo) {
      final nextSpeciesName = next['species']['name'] as String;
      final nextSpeciesUrl = next['species']['url'] as String;
      final toDexId = int.parse(nextSpeciesUrl.split('/').where((s) => s.isNotEmpty).last);

      final evoDetailsList = next['evolution_details'] as List<dynamic>?;
      String triggerText = 'Level Up';

      if (evoDetailsList != null && evoDetailsList.isNotEmpty) {
        triggerText = _formatEvolutionTrigger(evoDetailsList.first);
      }

      // Fetch all forms for fromDexId and toDexId to resolve regional form branches
      final allFromForms = await (db.select(db.pokemonTable)..where((t) => t.nationalDexNumber.equals(fromDexId))).get();
      final allToForms = await (db.select(db.pokemonTable)..where((t) => t.nationalDexNumber.equals(toDexId))).get();

      Pokemon? fromPokemon;
      Pokemon? toPokemon;

      if (allToForms.isNotEmpty) {
        toPokemon = allToForms.first;
      }
      if (allFromForms.isNotEmpty) {
        fromPokemon = allFromForms.first;
      }

      // Determine regional form matching
      final evoDetail = (evoDetailsList != null && evoDetailsList.isNotEmpty) ? evoDetailsList.first : null;
      final String? reqForm = evoDetail?['gender'] != null
          ? (evoDetail!['gender'] == 1 ? 'Female' : 'Male')
          : null;

      // If toPokemon is a regional evolution or form (e.g., Sneasler, Sirfetch'd, Perrserker, Clodsire)
      if (toPokemon != null && toPokemon.form != 'normal') {
        final formName = toPokemon.form.toLowerCase();
        final matchFrom = allFromForms.firstWhere(
          (f) => f.form.toLowerCase() == formName || formName.contains(f.form.toLowerCase()),
          orElse: () => allFromForms.first,
        );
        fromPokemon = matchFrom;
      } else if (allFromForms.length > 1) {
        // If fromPokemon has regional variants (e.g. Sneasel Hisui vs Sneasel Normal)
        // Check if evoDetail has specific conditions or if toPokemon is an exclusive evolution
        if (nextSpeciesName == 'sneasler' || nextSpeciesName == 'overqwil' || nextSpeciesName == 'basculegion' || nextSpeciesName == 'wyrdeer' || nextSpeciesName == 'ursaluna' || nextSpeciesName == 'kleavor') {
          fromPokemon = allFromForms.firstWhere(
            (f) => f.form.toLowerCase().contains('hisui'),
            orElse: () => allFromForms.first,
          );
        } else if (nextSpeciesName == 'perrserker' || nextSpeciesName == 'sirfetchd' || nextSpeciesName == 'mr-rime' || nextSpeciesName == 'runerigus' || nextSpeciesName == 'obstagoon') {
          fromPokemon = allFromForms.firstWhere(
            (f) => f.form.toLowerCase().contains('galar'),
            orElse: () => allFromForms.first,
          );
        } else if (nextSpeciesName == 'clodsire') {
          fromPokemon = allFromForms.firstWhere(
            (f) => f.form.toLowerCase().contains('paldea'),
            orElse: () => allFromForms.first,
          );
        } else if (nextSpeciesName == 'alolan-raichu' || nextSpeciesName == 'marowak-alola' || nextSpeciesName == 'exeggutor-alola') {
          // Regional form evolutions from normal base species
        }
      }

      steps.add(EvolutionStep(
        fromId: fromPokemon?.id ?? fromDexId,
        fromName: _formatDisplayName(fromPokemon?.name ?? speciesName, fromPokemon?.form ?? 'normal'),
        fromSprite: fromPokemon?.spriteUrl,
        toId: toPokemon?.id ?? toDexId,
        toName: _formatDisplayName(toPokemon?.name ?? nextSpeciesName, toPokemon?.form ?? 'normal'),
        toSprite: toPokemon?.spriteUrl,
        trigger: reqForm != null ? '$triggerText ($reqForm)' : triggerText,
        form: fromPokemon?.form ?? 'normal',
      ));

      // Recurse down the tree
      await _parseChainNode(next, steps);
    }
  }

  String _formatDisplayName(String rawName, String form) {
    final capName = _capitalize(rawName.replaceAll('-', ' '));
    if (form != 'normal' && !capName.toLowerCase().contains(form.toLowerCase())) {
      return '$capName (${_capitalize(form)})';
    }
    return capName;
  }

  String _formatEvolutionTrigger(Map<String, dynamic> detail) {
    final trigger = detail['trigger']?['name'] ?? '';
    final minLevel = detail['min_level'];
    final item = detail['item']?['name'];
    final heldItem = detail['held_item']?['name'];
    final knownMove = detail['known_move']?['name'];
    final knownMoveType = detail['known_move_type']?['name'];
    final happiness = detail['min_happiness'];
    final timeOfDay = detail['time_of_day'] ?? '';
    final location = detail['location']?['name'];

    List<String> parts = [];

    if (minLevel != null) parts.add('Lvl $minLevel');
    if (item != null) parts.add(_capitalize(item.replaceAll('-', ' ')));
    if (heldItem != null) parts.add('Hold ${_capitalize(heldItem.replaceAll('-', ' '))}');
    if (knownMove != null) parts.add('Know ${_capitalize(knownMove.replaceAll('-', ' '))}');
    if (knownMoveType != null) parts.add('Know ${_capitalize(knownMoveType.replaceAll('-', ' '))} move');
    if (happiness != null) parts.add('High Friendship');
    if (timeOfDay.toString().isNotEmpty) parts.add('(${_capitalize(timeOfDay)})');
    if (location != null) parts.add('at ${_capitalize(location.replaceAll('-', ' '))}');

    if (parts.isEmpty) {
      if (trigger == 'trade') {
        parts.add('Trade');
      } else if (trigger == 'shed') {
        parts.add('Empty PokeBall in party');
      } else {
        parts.add('Level Up');
      }
    }

    return parts.join(' ');
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

@riverpod
Stream<List<PokemonAbilityWithDetails>> pokemonAbilities(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchAbilitiesForPokemon(pokemonId);
}

@riverpod
Stream<List<PokemonMoveWithDetails>> pokemonMoves(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchMovesForPokemon(pokemonId);
}

@riverpod
Stream<List<Map<String, dynamic>>> pokemonAbilitiesStream(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.db.watchPokemonAbilities(pokemonId);
}

@riverpod
Stream<List<Map<String, dynamic>>> pokemonMovesStream(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.db.watchPokemonMoves(pokemonId);
}

final pokemonEvolutionChainProvider = FutureProvider.family<List<EvolutionStep>, ({int dexNum, List<Pokemon> forms})>((ref, arg) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.fetchEvolutionSteps(arg.dexNum, arg.forms);
});
