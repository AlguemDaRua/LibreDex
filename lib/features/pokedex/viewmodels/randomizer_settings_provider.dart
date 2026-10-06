import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RandomPoolMode { all, activeFilters, custom }

class RandomizerSettings {
  final RandomPoolMode poolMode;
  final Set<String> selectedTypes;
  final Set<int> selectedGens;
  final int minBst;
  final int maxBst;
  final bool fullyEvolvedOnly;
  final bool instantRollOnTap;

  /// How many Pokémon a roll returns: 1 for a single pick, 6 for a team.
  final int rollCount;

  const RandomizerSettings({
    this.poolMode = RandomPoolMode.all,
    this.selectedTypes = const <String>{},
    this.selectedGens = const <int>{},
    this.minBst = 180,
    this.maxBst = 780,
    this.fullyEvolvedOnly = false,
    this.instantRollOnTap = false,
    this.rollCount = 1,
  });

  bool get isCustomActive =>
      poolMode == RandomPoolMode.custom ||
      poolMode == RandomPoolMode.activeFilters;

  RandomizerSettings copyWith({
    RandomPoolMode? poolMode,
    Set<String>? selectedTypes,
    Set<int>? selectedGens,
    int? minBst,
    int? maxBst,
    bool? fullyEvolvedOnly,
    bool? instantRollOnTap,
    int? rollCount,
  }) {
    return RandomizerSettings(
      poolMode: poolMode ?? this.poolMode,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedGens: selectedGens ?? this.selectedGens,
      minBst: minBst ?? this.minBst,
      maxBst: maxBst ?? this.maxBst,
      fullyEvolvedOnly: fullyEvolvedOnly ?? this.fullyEvolvedOnly,
      instantRollOnTap: instantRollOnTap ?? this.instantRollOnTap,
      rollCount: rollCount ?? this.rollCount,
    );
  }

  /// Evaluates whether a Pokémon meets the custom criteria.
  bool matchesCustomCriteria(Pokemon p) {
    if (selectedTypes.isNotEmpty) {
      final t1 = p.type1.toLowerCase();
      final t2 = p.type2?.toLowerCase();
      final matchesType = selectedTypes.any((t) {
        final target = t.toLowerCase();
        return t1 == target || t2 == target;
      });
      if (!matchesType) return false;
    }

    if (selectedGens.isNotEmpty) {
      if (!selectedGens.contains(p.generation)) return false;
    }

    final bst =
        p.baseHp +
        p.baseAtk +
        p.baseDef +
        p.baseSpAtk +
        p.baseSpDef +
        p.baseSpd;
    if (bst < minBst || bst > maxBst) return false;

    // Include final evolutions and genuine single-stage Pokémon, but exclude
    // every form that has a real outgoing evolution edge.
    if (fullyEvolvedOnly && p.hasEvolution) return false;

    return true;
  }

  Map<String, dynamic> toJson() => {
    'poolMode': poolMode.name,
    'selectedTypes': selectedTypes.toList(),
    'selectedGens': selectedGens.toList(),
    'minBst': minBst,
    'maxBst': maxBst,
    'fullyEvolvedOnly': fullyEvolvedOnly,
    'instantRollOnTap': instantRollOnTap,
    'rollCount': rollCount,
  };

  factory RandomizerSettings.fromJson(Map<String, dynamic> json) {
    return RandomizerSettings(
      poolMode: RandomPoolMode.values.firstWhere(
        (e) => e.name == json['poolMode'],
        orElse: () => RandomPoolMode.all,
      ),
      selectedTypes:
          (json['selectedTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          const {},
      selectedGens:
          (json['selectedGens'] as List<dynamic>?)
              ?.map((e) => int.tryParse(e.toString()))
              .whereType<int>()
              .toSet() ??
          const {},
      minBst: (json['minBst'] as num?)?.toInt() ?? 180,
      maxBst: (json['maxBst'] as num?)?.toInt() ?? 780,
      fullyEvolvedOnly: json['fullyEvolvedOnly'] as bool? ?? false,
      instantRollOnTap: json['instantRollOnTap'] as bool? ?? false,
      // Clamped: a stored value above the pool size would otherwise ask for
      // more Pokémon than exist, and 0 would roll an empty team.
      // clamp() returns num, hence the trailing toInt().
      rollCount:
          ((json['rollCount'] as num?)?.toInt() ?? 1).clamp(1, 6).toInt(),
    );
  }
}

class RandomizerSettingsNotifier extends Notifier<RandomizerSettings> {
  static const _prefsKey = 'randomizer_settings_v1';

  @override
  RandomizerSettings build() {
    _load();
    return const RandomizerSettings();
  }

  void updateSettings(RandomizerSettings settings) {
    state = settings;
    _save(settings);
  }

  void reset() {
    state = const RandomizerSettings();
    _save(state);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = json.decode(jsonString) as Map<String, dynamic>;
        state = RandomizerSettings.fromJson(decoded);
      } catch (_) {}
    }
  }

  Future<void> _save(RandomizerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(settings.toJson());
    await prefs.setString(_prefsKey, jsonString);
  }
}

final randomizerSettingsProvider =
    NotifierProvider<RandomizerSettingsNotifier, RandomizerSettings>(
      RandomizerSettingsNotifier.new,
    );
