/// A single Pokémon build entry in the Stat Comparison tool.
///
/// Each entry holds a Pokémon reference plus all the build knobs that affect
/// its final stats: level, nature/alignment, IVs/EVs/SPs, item, ability,
/// status, stat stages, and field conditions. The entry itself is pure data;
/// actual stat math is delegated to [StatModifier].
library;

import 'package:libredex/core/database/app_database.dart';


/// Whether the comparison table shows base-level build stats or fully
/// modified effective battle stats.
enum ComparisonDisplayMode {
  /// Includes base stats, level, IVs/EVs or SPs, nature/alignment, and
  /// permanent item/ability effects. No stages, weather, status, etc.
  rawBuild,

  /// Everything from [rawBuild] plus stat stages, status effects, weather,
  /// terrain, temporary ability effects, field effects, and relevant items.
  effectiveBattle,
}

/// Activation state for Protosynthesis / Quark Drive.
enum ProtoQuarkState {
  /// Not active — ability does nothing.
  inactive,

  /// Activate automatically when the matching weather/terrain or Booster
  /// Energy is present.
  automatic,

  /// Force the boost regardless of weather/terrain.
  forceActive,
}

/// A single build configuration for the Stat Comparison tool.
class ComparisonEntry {
  /// The Pokémon this entry represents.
  final Pokemon pokemon;

  // ── Mainline Build ──────────────────────────────────────────────────────

  /// Level 1–100 (mainline only; Champions always uses 50).
  final int level;

  /// Nature name (lowercase), e.g. 'adamant'. In Champions, doubles as
  /// the Stat Alignment.
  final String nature;

  /// Individual values per stat (mainline only).
  final Map<String, int> ivs;

  /// Effort values per stat (mainline only).
  final Map<String, int> evs;

  // ── Champions Build ─────────────────────────────────────────────────────

  /// Stat Points per stat (Champions only, 0–32 each, 66 total).
  final Map<String, int> sps;

  // ── Shared Build ────────────────────────────────────────────────────────

  /// The Pokémon's ability (lowercase or null for unset).
  final String? ability;

  /// Held item name, or 'None'.
  final String heldItem;

  /// Status condition: 'none', 'burn', 'paralysis', 'poison', 'toxic',
  /// 'sleep', 'freeze'.
  final String status;

  /// Stat stages -6 to +6 for each battle stat.
  final Map<String, int> stages;

  // ── Field Conditions (only affect Effective Battle display) ─────────────

  /// Active weather: 'none', 'sunny', 'rainy', 'sandstorm', 'snow'.
  final String weather;

  /// Active terrain: 'none', 'electric', 'grassy', 'psychic', 'misty'.
  final String terrain;

  /// Whether Trick Room is active (inverts speed ordering, not speed stat).
  final bool trickRoom;

  /// Completed turns on the field, 0–5 (relevant for Slow Start).
  final int turnsOnField;

  /// Protosynthesis / Quark Drive activation.
  final ProtoQuarkState protoQuarkState;

  /// Current HP percentage (for Defeatist, 1–100).
  final double hpPercent;

  const ComparisonEntry({
    required this.pokemon,
    this.level = 50,
    this.nature = 'serious',
    required this.ivs,
    required this.evs,
    required this.sps,
    this.ability,
    this.heldItem = 'None',
    this.status = 'none',
    required this.stages,
    this.weather = 'none',
    this.terrain = 'none',
    this.trickRoom = false,
    this.turnsOnField = 5,
    this.protoQuarkState = ProtoQuarkState.inactive,
    this.hpPercent = 100.0,
  });

  /// Convenient factory for a new entry with sensible defaults.
  factory ComparisonEntry.defaults(Pokemon pokemon, {String? ability}) {
    return ComparisonEntry(
      pokemon: pokemon,
      ability: ability,
      ivs: {for (final k in _statKeys) k: 31},
      evs: {for (final k in _statKeys) k: 0},
      sps: {for (final k in _statKeys) k: 0},
      stages: {for (final k in _battleStatKeys) k: 0},
    );
  }

  ComparisonEntry copyWith({
    Pokemon? pokemon,
    int? level,
    String? nature,
    Map<String, int>? ivs,
    Map<String, int>? evs,
    Map<String, int>? sps,
    Object? ability = const _Sentinel(),
    String? heldItem,
    String? status,
    Map<String, int>? stages,
    String? weather,
    String? terrain,
    bool? trickRoom,
    int? turnsOnField,
    ProtoQuarkState? protoQuarkState,
    double? hpPercent,
  }) {
    return ComparisonEntry(
      pokemon: pokemon ?? this.pokemon,
      level: level ?? this.level,
      nature: nature ?? this.nature,
      ivs: ivs ?? Map<String, int>.from(this.ivs),
      evs: evs ?? Map<String, int>.from(this.evs),
      sps: sps ?? Map<String, int>.from(this.sps),
      ability: ability is _Sentinel ? this.ability : ability as String?,
      heldItem: heldItem ?? this.heldItem,
      status: status ?? this.status,
      stages: stages ?? Map<String, int>.from(this.stages),
      weather: weather ?? this.weather,
      terrain: terrain ?? this.terrain,
      trickRoom: trickRoom ?? this.trickRoom,
      turnsOnField: turnsOnField ?? this.turnsOnField,
      protoQuarkState: protoQuarkState ?? this.protoQuarkState,
      hpPercent: hpPercent ?? this.hpPercent,
    );
  }

  /// Base Stat Total.
  int get bst =>
      pokemon.baseHp +
      pokemon.baseAtk +
      pokemon.baseDef +
      pokemon.baseSpAtk +
      pokemon.baseSpDef +
      pokemon.baseSpd;

  static const List<String> _statKeys = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];
  static const List<String> _battleStatKeys = ['atk', 'def', 'spa', 'spd', 'spe'];
}

class _Sentinel {
  const _Sentinel();
}
