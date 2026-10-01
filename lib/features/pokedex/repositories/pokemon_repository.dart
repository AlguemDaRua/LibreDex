import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/network/api_client.dart';
import 'package:libredex/core/network/network_preferences.dart';
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

/// Repository for local reference data and online-first evolution lookups.
class PokemonRepository {
  final AppDatabase db;
  Map<String, dynamic>? _localEvolutionChains;
  final Map<int, List<EvolutionStep>> _onlineEvolutionCache = {};

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

  /// Resolves the base-form Pokémon that can lend its learnset/abilities to
  /// a form without direct junction rows (bundle Mega/G-Max forms and the
  /// Z-A Megas whose Champions data is not released yet). Returns null when
  /// [pokemonId] is already the base form or cannot be resolved.
  Future<(int id, String name)?> _baseFormForFallback(int pokemonId) async {
    final self = await (db.select(db.pokemonTable)
          ..where((t) => t.id.equals(pokemonId)))
        .getSingleOrNull();
    if (self == null) return null;
    final dex = self.nationalDexNumber > 0 ? self.nationalDexNumber : self.id;
    final sameDex = await (db.select(db.pokemonTable)
          ..where((t) => t.nationalDexNumber.equals(dex)))
        .get();
    if (sameDex.isEmpty) return null;
    final base = sameDex.firstWhere(
      (p) => p.form == 'normal',
      orElse: () => sameDex.first,
    );
    if (base.id == pokemonId) return null;
    return (base.id, base.name);
  }

  Future<List<Map<String, dynamic>>> _movesAsMaps(int pokemonId) async {
    final rows = await db.getPokemonMoves(pokemonId);
    return rows
        .map((row) => {
              'id': row.move.id,
              'name': row.move.name,
              'type': row.move.type,
              'power': row.move.power,
              'pp': row.move.pp,
              'accuracy': row.move.accuracy,
              'damageClass': row.move.damageClass,
              'description': row.move.description,
              'learnMethod': row.junction.learnMethod,
              'levelLearned': row.junction.levelLearned,
            })
        .toList();
  }

  /// Watches the moves of [pokemonId]; when the form has no direct learnset
  /// rows, the base species learnset is returned instead and every row is
  /// tagged with `learnsetFallbackFrom`, letting the UI show the
  /// "Using base species learnset for this form." note instead of an empty
  /// screen.
  ///
  /// Champions Mega forms are a middle case: their only direct rows are the
  /// Champions "train" selections. Those alone would look like an empty
  /// dex page, so the base species learnset is merged in (tagged) with the
  /// train rows kept on top.
  Stream<List<Map<String, dynamic>>> watchMovesWithFallback(int pokemonId) async* {
    await for (final rows in db.watchPokemonMoves(pokemonId)) {
      final onlyTrainRows = rows.isNotEmpty && rows.every((r) => r['learnMethod'] == 'train');
      if (rows.isNotEmpty && !onlyTrainRows) {
        yield rows;
        continue;
      }
      final base = await _baseFormForFallback(pokemonId);
      if (base == null) {
        yield rows;
        continue;
      }
      final baseRows = await _movesAsMaps(base.$1);
      if (baseRows.isEmpty) {
        yield rows;
        continue;
      }
      yield [
        ...rows,
        for (final row in baseRows) {...row, 'learnsetFallbackFrom': base.$2},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _abilitiesAsMaps(int pokemonId) async {
    final rows = await db.getPokemonAbilities(pokemonId);
    return rows
        .map((row) => {
              'id': row.ability.id,
              'name': row.ability.name,
              'effect': row.ability.description,
              'isHidden': row.junction.isHidden,
            })
        .toList();
  }

  /// Same idea as [watchMovesWithFallback] for abilities — Mega forms with
  /// no released Champions ability still show something meaningful.
  Stream<List<Map<String, dynamic>>> watchAbilitiesWithFallback(int pokemonId) async* {
    await for (final rows in db.watchPokemonAbilities(pokemonId)) {
      if (rows.isNotEmpty) {
        yield rows;
        continue;
      }
      final base = await _baseFormForFallback(pokemonId);
      if (base == null) {
        yield rows;
        continue;
      }
      final baseRows = await _abilitiesAsMaps(base.$1);
      if (baseRows.isEmpty) {
        yield rows;
        continue;
      }
      yield [
        for (final row in baseRows) {...row, 'abilityFallbackFrom': base.$2},
      ];
    }
  }

  /// One-shot abilities fetch with the same base-form fallback; used by the
  /// damage calculator setup sheet.
  Future<List<Map<String, dynamic>>> getAbilitiesWithFallback(int pokemonId) async {
    final rows = await _abilitiesAsMaps(pokemonId);
    if (rows.isNotEmpty) return rows;
    final base = await _baseFormForFallback(pokemonId);
    if (base == null) return rows;
    return _abilitiesAsMaps(base.$1);
  }

  /// Fetches evolution chain steps for a given National Dex ID.
  Future<List<EvolutionStep>> fetchEvolutionSteps(
    int dexNum, {
    bool preferOnline = true,
  }) async {
    if (!preferOnline) return _fetchLocalEvolutionSteps(dexNum);

    final cached = _onlineEvolutionCache[dexNum];
    if (cached != null) return cached;

    final List<EvolutionStep> steps = [];

    try {
      // Prefer the current PokéAPI chain when online, but keep the result for
      // this app session rather than requesting the same resource repeatedly.
      final speciesRes = await ApiClient.get('pokemon-species/$dexNum');
      final evoChainUrl = speciesRes.data['evolution_chain']?['url'] as String?;

      if (evoChainUrl != null) {
        final chainId = evoChainUrl.split('/').where((s) => s.isNotEmpty).last;
        final chainRes = await ApiClient.get('evolution-chain/$chainId');
        final chainData = chainRes.data['chain'];

        await _parseChainNode(chainData, steps);
      }
    } catch (_) {
      // Offline fallback is loaded below.
    }

    if (steps.isNotEmpty) {
      final result = List<EvolutionStep>.unmodifiable(steps);
      _onlineEvolutionCache[dexNum] = result;
      return result;
    }
    return _fetchLocalEvolutionSteps(dexNum);
  }

  Future<List<EvolutionStep>> _fetchLocalEvolutionSteps(int dexNum) async {
    _localEvolutionChains ??= jsonDecode(
      await rootBundle.loadString('assets/data/evolution_chains.json'),
    ) as Map<String, dynamic>;

    final chain = _localEvolutionChains!.entries
        .where((entry) => entry.value is List<dynamic>)
        .map((entry) => entry.value as List<dynamic>)
        .firstWhere(
          (rows) => rows.any((raw) {
            final row = raw as Map<String, dynamic>;
            return row['from'] == dexNum || row['to'] == dexNum;
          }),
          orElse: () => <dynamic>[],
        );
    if (chain.isEmpty) return const [];

    final steps = <EvolutionStep>[];
    for (final raw in chain) {
      final row = raw as Map<String, dynamic>;
      final fromDex = row['from'] as int;
      final toDex = row['to'] as int;
      final fromPokemonId = row['fromPokemon'] as int? ?? fromDex;
      final toPokemonId = row['toPokemon'] as int? ?? toDex;
      final fromPokemon = await _pokemonById(fromPokemonId) ?? await _firstPokemonForDex(fromDex);
      final toPokemon = await _pokemonById(toPokemonId) ?? await _firstPokemonForDex(toDex);
      final fromForm = row['fromForm'] as String? ?? fromPokemon?.form ?? 'normal';
      final toForm = row['toForm'] as String? ?? toPokemon?.form ?? 'normal';

      steps.add(EvolutionStep(
        fromId: fromPokemon?.id ?? fromPokemonId,
        fromName: _formatEvolutionPokemonName(
          fromPokemon?.name ?? 'pokemon-$fromDex',
          fromPokemon?.form ?? fromForm,
        ),
        fromSprite: fromPokemon?.spriteUrl,
        toId: toPokemon?.id ?? toPokemonId,
        toName: _formatEvolutionPokemonName(
          toPokemon?.name ?? 'pokemon-$toDex',
          toPokemon?.form ?? toForm,
        ),
        toSprite: toPokemon?.spriteUrl,
        trigger: row['trigger'] as String? ?? 'Evolves',
        form: row['form'] as String? ?? _evolutionFormLabel(fromForm, toForm),
        fromForm: fromForm,
        toForm: toForm,
      ));
    }
    return steps;
  }

  Future<Pokemon?> _pokemonById(int pokemonId) async {
    final rows = await (db.select(db.pokemonTable)..where((t) => t.id.equals(pokemonId))).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<Pokemon?> _firstPokemonForDex(int dexNum) async {
    final rows = await (db.select(db.pokemonTable)..where((t) => t.nationalDexNumber.equals(dexNum))).get();
    if (rows.isEmpty) return null;
    return rows.firstWhere((p) => p.form == 'normal', orElse: () => rows.first);
  }

  String _evolutionFormLabel(String fromForm, String toForm) {
    final forms = [fromForm, toForm]
        .where((form) => form.toLowerCase() != 'normal')
        .toSet();
    return forms.isEmpty ? 'normal' : forms.join(' → ');
  }

  String _formatEvolutionPokemonName(String rawName, String form) {
    final name = _capitalize(rawName.replaceAll('-', ' '));
    if (form == 'normal') return name;

    final aliases = <String, String>{
      'alolan': 'alola',
      'galarian': 'galar',
      'hisuian': 'hisui',
      'paldean': 'paldea',
    };
    final formWords = form.toLowerCase();
    final formSuffix = aliases[formWords] ?? formWords.replaceAll(' ', '-');
    final rawParts = rawName.toLowerCase().split('-');
    if (rawParts.length > 1 && rawParts.last == formSuffix) {
      return '${_capitalize(rawParts.take(rawParts.length - 1).join(' '))} (${_capitalize(form)})';
    }
    if (name.toLowerCase().contains(formWords)) return name;
    return '$name (${_capitalize(form)})';
  }

  Future<void> _parseChainNode(Map<String, dynamic> node, List<EvolutionStep> steps) async {
    final speciesName = node['species']['name'] as String;
    final speciesUrl = node['species']['url'] as String;
    final fromDexId = int.parse(speciesUrl.split('/').where((part) => part.isNotEmpty).last);
    final evolvesTo = node['evolves_to'] as List<dynamic>? ?? const [];

    for (final rawNext in evolvesTo) {
      final next = rawNext as Map<String, dynamic>;
      final nextSpeciesName = next['species']['name'] as String;
      final nextSpeciesUrl = next['species']['url'] as String;
      final toDexId = int.parse(nextSpeciesUrl.split('/').where((part) => part.isNotEmpty).last);
      final fromPokemon = await _firstPokemonForDex(fromDexId);
      final toPokemon = await _firstPokemonForDex(toDexId);
      final details = (next['evolution_details'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      // A child can have more than one published trigger/condition row; keep
      // every row rather than silently dropping all but the first.
      for (final detail in details.isEmpty ? <Map<String, dynamic>>[{}] : details) {
        final fromForm = fromPokemon?.form ?? 'normal';
        final toForm = toPokemon?.form ?? 'normal';
        final trigger = _formatEvolutionTrigger(detail);
        steps.add(EvolutionStep(
          fromId: fromPokemon?.id ?? fromDexId,
          fromName: _formatEvolutionPokemonName(fromPokemon?.name ?? speciesName, fromForm),
          fromSprite: fromPokemon?.spriteUrl,
          toId: toPokemon?.id ?? toDexId,
          toName: _formatEvolutionPokemonName(toPokemon?.name ?? nextSpeciesName, toForm),
          toSprite: toPokemon?.spriteUrl,
          trigger: trigger,
          form: _evolutionFormLabel(fromForm, toForm),
          fromForm: fromForm,
          toForm: toForm,
        ));
      }

      // Recursion walks every branch from the family root, so a detail view
      // for any member receives the complete chain rather than one adjacent edge.
      await _parseChainNode(next, steps);
    }
  }

  String _formatEvolutionTrigger(Map<String, dynamic> detail) {
    final trigger = detail['trigger']?['name']?.toString() ?? '';
    final minLevel = detail['min_level'];
    final item = detail['item']?['name'];
    final heldItem = detail['held_item']?['name'];
    final knownMove = detail['known_move']?['name'];
    final knownMoveType = detail['known_move_type']?['name'];
    final happiness = detail['min_happiness'];
    final timeOfDay = detail['time_of_day']?.toString() ?? '';
    final location = detail['location']?['name'];
    final gender = detail['gender'];
    final parts = <String>[];

    if (minLevel != null) parts.add('Level $minLevel');
    if (item != null) parts.add('Use ${_capitalize(item.toString().replaceAll('-', ' '))}');
    if (heldItem != null) parts.add('Hold ${_capitalize(heldItem.toString().replaceAll('-', ' '))}');
    if (knownMove != null) parts.add('Know ${_capitalize(knownMove.toString().replaceAll('-', ' '))}');
    if (knownMoveType != null) parts.add('Know a ${_capitalize(knownMoveType.toString())}-type move');
    if (happiness != null) parts.add('High friendship');
    if (gender != null) parts.add(gender == 1 ? 'Female only' : 'Male only');
    if (timeOfDay.isNotEmpty) parts.add(timeOfDay[0].toUpperCase() + timeOfDay.substring(1));
    if (location != null) parts.add('At ${_capitalize(location.toString().replaceAll('-', ' '))}');

    if (parts.isNotEmpty) return parts.join(' · ');
    if (trigger == 'trade') return 'Trade';
    if (trigger == 'shed') return 'Shed shell';
    if (trigger == 'use-item') return 'Use an item';
    return trigger.isEmpty ? 'Evolution condition' : _capitalize(trigger.replaceAll('-', ' '));
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
  return repo.watchAbilitiesWithFallback(pokemonId);
}

@riverpod
Stream<List<Map<String, dynamic>>> pokemonMovesStream(Ref ref, int pokemonId) {
  final repo = ref.watch(pokemonRepositoryProvider);
  return repo.watchMovesWithFallback(pokemonId);
}

final pokemonEvolutionChainProvider =
    FutureProvider.family<List<EvolutionStep>, int>((ref, dexNum) {
  final repo = ref.watch(pokemonRepositoryProvider);
  final preferOnline = ref.watch(liveEvolutionDataProvider);
  return repo.fetchEvolutionSteps(dexNum, preferOnline: preferOnline);
});
