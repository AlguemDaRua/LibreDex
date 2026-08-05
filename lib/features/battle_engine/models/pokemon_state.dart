/// Pure Dart representation of a Pokémon's full battle state.
library;

import 'package:libredex/core/database/app_database.dart';

class PokemonState {
  final int id;
  final String name;
  final String form;
  final List<String> types;
  final Map<String, int> baseStats;

  final int level;
  final String nature;
  final Map<String, int> ivs;
  final Map<String, int> evs;
  final Map<String, int> sps;
  final Map<String, int> stages;

  final String heldItem;
  final String? ability;
  final String status;
  final bool teraActive;
  final String? teraType;
  final double hpPercent;
  final int friendship;
  final int turnsOnField;
  final double weightKg;

  const PokemonState({
    required this.id,
    required this.name,
    this.form = 'normal',
    required this.types,
    required this.baseStats,
    this.level = 50,
    this.nature = 'serious',
    required this.ivs,
    required this.evs,
    required this.sps,
    required this.stages,
    this.heldItem = 'None',
    this.ability,
    this.status = 'none',
    this.teraActive = false,
    this.teraType,
    this.hpPercent = 100.0,
    this.friendship = 255,
    this.turnsOnField = 5,
    this.weightKg = 0.0,
  });

  /// Create a [PokemonState] from a Drift [Pokemon] database model with default build settings.
  factory PokemonState.fromDatabase(Pokemon p, {
    int level = 50,
    String nature = 'serious',
    Map<String, int>? ivs,
    Map<String, int>? evs,
    Map<String, int>? sps,
    Map<String, int>? stages,
    String heldItem = 'None',
    String? ability,
    String status = 'none',
    bool teraActive = false,
    String? teraType,
    double hpPercent = 100.0,
    int friendship = 255,
    int turnsOnField = 5,
    double weightKg = 0.0,
  }) {
    final types = <String>[p.type1];
    if (p.type2 != null && p.type2!.isNotEmpty) {
      types.add(p.type2!);
    }

    return PokemonState(
      id: p.id,
      name: p.name,
      form: p.form,
      types: types,
      baseStats: {
        'hp': p.baseHp,
        'atk': p.baseAtk,
        'def': p.baseDef,
        'spa': p.baseSpAtk,
        'spd': p.baseSpDef,
        'spe': p.baseSpd,
      },
      level: level,
      nature: nature,
      ivs: ivs ?? const {'hp': 31, 'atk': 31, 'def': 31, 'spa': 31, 'spd': 31, 'spe': 31},
      evs: evs ?? const {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      sps: sps ?? const {'hp': 0, 'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      stages: stages ?? const {'atk': 0, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 0},
      heldItem: heldItem,
      ability: ability,
      status: status,
      teraActive: teraActive,
      teraType: teraType,
      hpPercent: hpPercent,
      friendship: friendship,
      turnsOnField: turnsOnField,
      weightKg: weightKg,
    );
  }

  /// Active types considering Tera Transformation.
  List<String> get activeTypes {
    if (teraActive && teraType != null && teraType!.isNotEmpty && teraType!.toLowerCase() != 'stellar') {
      return [teraType!.toLowerCase()];
    }
    return types.map((t) => t.toLowerCase()).toList();
  }

  /// True if the Pokémon is Tera Stellar.
  bool get isTeraStellar => teraActive && teraType?.toLowerCase() == 'stellar';

  PokemonState copyWith({
    int? id,
    String? name,
    String? form,
    List<String>? types,
    Map<String, int>? baseStats,
    int? level,
    String? nature,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    Map<String, int>? sps,
    Map<String, int>? stages,
    String? heldItem,
    Object? ability = const _Sentinel(),
    String? status,
    bool? teraActive,
    Object? teraType = const _Sentinel(),
    double? hpPercent,
    int? friendship,
    int? turnsOnField,
    double? weightKg,
  }) {
    return PokemonState(
      id: id ?? this.id,
      name: name ?? this.name,
      form: form ?? this.form,
      types: types ?? List.from(this.types),
      baseStats: baseStats ?? Map.from(this.baseStats),
      level: level ?? this.level,
      nature: nature ?? this.nature,
      ivs: ivs ?? Map.from(this.ivs),
      evs: evs ?? Map.from(this.evs),
      sps: sps ?? Map.from(this.sps),
      stages: stages ?? Map.from(this.stages),
      heldItem: heldItem ?? this.heldItem,
      ability: ability is _Sentinel ? this.ability : ability as String?,
      status: status ?? this.status,
      teraActive: teraActive ?? this.teraActive,
      teraType: teraType is _Sentinel ? this.teraType : teraType as String?,
      hpPercent: hpPercent ?? this.hpPercent,
      friendship: friendship ?? this.friendship,
      turnsOnField: turnsOnField ?? this.turnsOnField,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}

class _Sentinel {
  const _Sentinel();
}
