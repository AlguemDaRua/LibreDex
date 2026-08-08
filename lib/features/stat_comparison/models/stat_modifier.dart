/// Pure Dart stat modification engine for the Stat Comparison tool.
///
/// Takes a [ComparisonEntry] and a [BattleRuleset] and produces final stat
/// values with an explanation chain of every applied modifier.
///
/// This file must not import Flutter.
library;



import 'package:libredex/core/utils/pokemon_properties.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';

/// A single modifier that was applied to a stat.
class AppliedStatModifier {
  final String label;
  final double multiplier;

  const AppliedStatModifier(this.label, this.multiplier);

  @override
  String toString() => '$label (×${multiplier.toStringAsFixed(2)})';
}

/// The result of computing a single stat, showing both the value before and
/// after modifiers and every modifier in between.
class StatResult {
  /// The stat value using only base + level + IV/EV (or SP) + nature.
  final int rawStat;

  /// The final stat after all applicable modifiers.
  final int effectiveStat;

  /// Every modifier applied in order.
  final List<AppliedStatModifier> modifiers;

  const StatResult({
    required this.rawStat,
    required this.effectiveStat,
    this.modifiers = const [],
  });
}

/// Full computed stats for a single comparison entry.
class ComparisonStats {
  final StatResult hp;
  final StatResult attack;
  final StatResult defense;
  final StatResult spAtk;
  final StatResult spDef;
  final StatResult speed;

  const ComparisonStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAtk,
    required this.spDef,
    required this.speed,
  });

  /// Base Stat Total from the Pokémon's species data.
  int get bst =>
      hp.rawStat + attack.rawStat + defense.rawStat +
      spAtk.rawStat + spDef.rawStat + speed.rawStat;

  /// Physical bulk = HP × Defense (effective).
  int get physicalBulk => hp.effectiveStat * defense.effectiveStat;

  /// Special bulk = HP × Sp. Def (effective).
  int get specialBulk => hp.effectiveStat * spDef.effectiveStat;

  /// Returns the stat result by key.
  StatResult byKey(String key) => switch (key) {
    'hp' => hp,
    'atk' => attack,
    'def' => defense,
    'spa' => spAtk,
    'spd' => spDef,
    'spe' => speed,
    _ => throw ArgumentError('Unknown stat key: $key'),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Modifier Engine
// ─────────────────────────────────────────────────────────────────────────────

class StatModifier {
  StatModifier._();


  /// Compute raw build stats (no stages, weather, status, or temporary effects).
  static ComparisonStats computeRawStats(
    ComparisonEntry entry,
    BattleRuleset ruleset,
  ) {
    final p = entry.pokemon;
    final bases = {
      'hp': p.baseHp, 'atk': p.baseAtk, 'def': p.baseDef,
      'spa': p.baseSpAtk, 'spd': p.baseSpDef, 'spe': p.baseSpd,
    };

    final isChampions = ruleset.isChampions;
    final isShedinja = p.name.toLowerCase() == 'shedinja';

    // HP calculation
    int rawHp;
    if (isChampions) {
      rawHp = StatCalculator.calculateChampionsHp(
        base: bases['hp']!, sp: entry.sps['hp'] ?? 0, isShedinja: isShedinja,
      );
    } else {
      rawHp = StatCalculator.calculateHp(
        base: bases['hp']!, iv: entry.ivs['hp'] ?? 31,
        ev: entry.evs['hp'] ?? 0, level: entry.level, isShedinja: isShedinja,
      );
    }

    // Other stats
    final results = <String, StatResult>{};
    results['hp'] = StatResult(rawStat: rawHp, effectiveStat: rawHp);

    for (final key in ['atk', 'def', 'spa', 'spd', 'spe']) {
      final statLabel = _statKeyToLabel(key);
      final natureMod = CombatUtils.getNatureMultiplier(entry.nature, statLabel);

      int raw;
      if (isChampions) {
        raw = StatCalculator.calculateChampionsStat(
          base: bases[key]!, sp: entry.sps[key] ?? 0, alignmentModifier: natureMod,
        );
      } else {
        raw = StatCalculator.calculateOtherStat(
          base: bases[key]!, iv: entry.ivs[key] ?? 31,
          ev: entry.evs[key] ?? 0, level: entry.level, natureModifier: natureMod,
        );
      }

      // Permanent item effects (raw build includes these)
      final mods = <AppliedStatModifier>[];
      double effectiveValue = raw.toDouble();

      final itemMult = _permanentItemMultiplier(entry, key);
      if (itemMult != 1.0) {
        mods.add(AppliedStatModifier(entry.heldItem, itemMult));
        effectiveValue *= itemMult;
      }

      // Permanent ability effects (raw build includes these)
      final abilityMult = _permanentAbilityMultiplier(entry, key);
      if (abilityMult != 1.0) {
        mods.add(AppliedStatModifier(entry.ability ?? '', abilityMult));
        effectiveValue *= abilityMult;
      }

      results[key] = StatResult(
        rawStat: raw,
        effectiveStat: effectiveValue.floor().clamp(1, 99999),
        modifiers: mods,
      );
    }

    return ComparisonStats(
      hp: results['hp']!,
      attack: results['atk']!,
      defense: results['def']!,
      spAtk: results['spa']!,
      spDef: results['spd']!,
      speed: results['spe']!,
    );
  }

  /// Compute effective battle stats (includes everything in raw build plus
  /// stages, status, weather, terrain, temporary abilities, items, and field).
  static ComparisonStats computeEffectiveStats(
    ComparisonEntry entry,
    BattleRuleset ruleset,
  ) {
    final p = entry.pokemon;
    final bases = {
      'hp': p.baseHp, 'atk': p.baseAtk, 'def': p.baseDef,
      'spa': p.baseSpAtk, 'spd': p.baseSpDef, 'spe': p.baseSpd,
    };

    final isChampions = ruleset.isChampions;
    final isShedinja = p.name.toLowerCase() == 'shedinja';
    final ability = _normalize(entry.ability ?? '');
    final type1 = p.type1.toLowerCase();
    final type2 = p.type2?.toLowerCase();

    // HP calculation (same as raw — HP has no stages)
    int rawHp;
    if (isChampions) {
      rawHp = StatCalculator.calculateChampionsHp(
        base: bases['hp']!, sp: entry.sps['hp'] ?? 0, isShedinja: isShedinja,
      );
    } else {
      rawHp = StatCalculator.calculateHp(
        base: bases['hp']!, iv: entry.ivs['hp'] ?? 31,
        ev: entry.evs['hp'] ?? 0, level: entry.level, isShedinja: isShedinja,
      );
    }

    final results = <String, StatResult>{};
    results['hp'] = StatResult(rawStat: rawHp, effectiveStat: rawHp);

    // First pass: compute raw stats for proto/quark candidate selection
    final rawStats = <String, int>{};
    for (final key in ['atk', 'def', 'spa', 'spd', 'spe']) {
      final statLabel = _statKeyToLabel(key);
      final natureMod = CombatUtils.getNatureMultiplier(entry.nature, statLabel);
      if (isChampions) {
        rawStats[key] = StatCalculator.calculateChampionsStat(
          base: bases[key]!, sp: entry.sps[key] ?? 0, alignmentModifier: natureMod,
        );
      } else {
        rawStats[key] = StatCalculator.calculateOtherStat(
          base: bases[key]!, iv: entry.ivs[key] ?? 31,
          ev: entry.evs[key] ?? 0, level: entry.level, natureModifier: natureMod,
        );
      }
    }

    // Determine protosynthesis / quark drive boosted stat
    String? protoQuarkBoostedStat;
    if (_isProtoQuarkActive(entry)) {
      protoQuarkBoostedStat = _selectProtoQuarkStat(rawStats);
    }

    for (final key in ['atk', 'def', 'spa', 'spd', 'spe']) {
      final raw = rawStats[key]!;
      final mods = <AppliedStatModifier>[];
      double value = raw.toDouble();

      // 1. Permanent item effects
      final itemMult = _permanentItemMultiplier(entry, key);
      if (itemMult != 1.0) {
        mods.add(AppliedStatModifier(entry.heldItem, itemMult));
        value *= itemMult;
      }

      // 2. Permanent ability effects
      final abilityMult = _permanentAbilityMultiplier(entry, key);
      if (abilityMult != 1.0) {
        mods.add(AppliedStatModifier(entry.ability ?? '', abilityMult));
        value *= abilityMult;
      }

      // 3. Stat stages
      final stage = entry.stages[key] ?? 0;
      if (stage != 0) {
        final stageMult = CombatUtils.getStageMultiplier(stage);
        mods.add(AppliedStatModifier(
          '${stage > 0 ? '+' : ''}$stage stage', stageMult,
        ));
        value *= stageMult;
      }

      // 4. Status effects
      _applyStatusEffects(entry, key, ability, mods, value).also((v) => value = v);

      // 5. Weather effects
      _applyWeatherEffects(entry, key, ability, type1, type2, mods, value)
          .also((v) => value = v);

      // 6. Terrain effects
      _applyTerrainEffects(entry, key, ability, mods, value)
          .also((v) => value = v);

      // 7. Slow Start
      if (ability == 'slow start' && entry.turnsOnField < 5) {
        if (key == 'atk' || key == 'spe') {
          mods.add(const AppliedStatModifier('Slow Start', 0.5));
          value *= 0.5;
        }
      }

      // 8. Defeatist
      if (ability == 'defeatist' && entry.hpPercent <= 50.0) {
        if (key == 'atk' || key == 'spa') {
          mods.add(const AppliedStatModifier('Defeatist', 0.5));
          value *= 0.5;
        }
      }

      // 9. Gorilla Tactics
      if (ability == 'gorilla tactics' && key == 'atk') {
        mods.add(const AppliedStatModifier('Gorilla Tactics', 1.5));
        value *= 1.5;
      }

      // 10. Hustle
      if (ability == 'hustle' && key == 'atk') {
        mods.add(const AppliedStatModifier('Hustle', 1.5));
        value *= 1.5;
      }

      // 11. Protosynthesis / Quark Drive
      if (protoQuarkBoostedStat == key) {
        final pqMult = key == 'spe' ? 1.5 : 1.3;
        final pqLabel = ability == 'protosynthesis' ? 'Protosynthesis' : 'Quark Drive';
        mods.add(AppliedStatModifier(pqLabel, pqMult));
        value *= pqMult;
      }

      // 12. Plus / Minus (simplified — assumes pairing condition is active when set)
      if ((ability == 'plus' || ability == 'minus') && key == 'spa') {
        mods.add(AppliedStatModifier(ability == 'plus' ? 'Plus' : 'Minus', 1.5));
        value *= 1.5;
      }

      // 13. Speed-halving items (Iron Ball, Macho Brace, Power items)
      if (key == 'spe') {
        final speedItemMult = _speedItemMultiplier(entry);
        if (speedItemMult != 1.0) {
          mods.add(AppliedStatModifier(entry.heldItem, speedItemMult));
          value *= speedItemMult;
        }
      }

      // 14. Choice Scarf speed
      if (key == 'spe' && _normalize(entry.heldItem) == 'choice scarf') {
        mods.add(const AppliedStatModifier('Choice Scarf', 1.5));
        value *= 1.5;
      }

      // 15. Sandstorm SpDef for Rock types
      if (key == 'spd' && entry.weather == 'sandstorm' &&
          (type1 == 'rock' || type2 == 'rock')) {
        mods.add(const AppliedStatModifier('Sandstorm (Rock)', 1.5));
        value *= 1.5;
      }

      // 16. Snow Defense for Ice types
      if (key == 'def' && entry.weather == 'snow' &&
          (type1 == 'ice' || type2 == 'ice')) {
        mods.add(const AppliedStatModifier('Snow (Ice)', 1.5));
        value *= 1.5;
      }

      results[key] = StatResult(
        rawStat: raw,
        effectiveStat: value.floor().clamp(1, 99999),
        modifiers: mods,
      );
    }

    return ComparisonStats(
      hp: results['hp']!,
      attack: results['atk']!,
      defense: results['def']!,
      spAtk: results['spa']!,
      spDef: results['spd']!,
      speed: results['spe']!,
    );
  }

  // ── Permanent Item Multipliers ──────────────────────────────────────────

  /// Items whose stat effects are part of the "build" (always active,
  /// not turn-dependent). Does NOT include speed items or Choice Scarf
  /// (those are in effective stats only).
  static double _permanentItemMultiplier(ComparisonEntry entry, String statKey) {
    final item = _normalize(entry.heldItem);
    final pokemonName = entry.pokemon.name.toLowerCase();

    // Species-specific items
    if (item == 'light ball' && pokemonName == 'pikachu') {
      if (statKey == 'atk' || statKey == 'spa') return 2.0;
    }
    if (item == 'thick club' &&
        (pokemonName == 'cubone' || pokemonName == 'marowak' ||
         pokemonName.contains('marowak'))) {
      if (statKey == 'atk') return 2.0;
    }
    if (item == 'deep sea tooth' && pokemonName == 'clamperl') {
      if (statKey == 'spa') return 2.0;
    }
    if (item == 'deep sea scale' && pokemonName == 'clamperl') {
      if (statKey == 'spd') return 2.0;
    }
    if (item == 'metal powder' && pokemonName == 'ditto') {
      if (statKey == 'def') return 2.0;
    }
    if (item == 'quick powder' && pokemonName == 'ditto') {
      if (statKey == 'spe') return 2.0;
    }

    // General items
    if (item == 'choice band' && statKey == 'atk') return 1.5;
    if (item == 'choice specs' && statKey == 'spa') return 1.5;
    if (item == 'assault vest' && statKey == 'spd') return 1.5;

    // Eviolite — only on Pokémon that can still evolve (uses the
    // Can Evolve filter's data-driven `canEvolve`, now derived from
    // evolution_chains.json: final evos + isolated singles, plus
    // legendary/mythic/paradox/UB exclusion).
    if (item == 'eviolite' && entry.pokemon.canEvolve) {
      if (statKey == 'def' || statKey == 'spd') return 1.5;
    }

    return 1.0;
  }

  // ── Permanent Ability Multipliers ───────────────────────────────────────

  static double _permanentAbilityMultiplier(ComparisonEntry entry, String statKey) {
    final ability = _normalize(entry.ability ?? '');

    if ((ability == 'huge power' || ability == 'pure power') && statKey == 'atk') {
      return 2.0;
    }
    if (ability == 'fur coat' && statKey == 'def') return 2.0;
    if (ability == 'ice scales' && statKey == 'spd') return 2.0;

    return 1.0;
  }

  // ── Status Effects ──────────────────────────────────────────────────────

  static double _applyStatusEffects(
    ComparisonEntry entry, String key, String ability,
    List<AppliedStatModifier> mods, double value,
  ) {
    if (entry.status == 'none') return value;

    // Paralysis halves speed
    if (entry.status == 'paralysis' && key == 'spe') {
      if (ability == 'quick feet') {
        // Quick Feet ignores paralysis speed drop AND boosts speed
        mods.add(const AppliedStatModifier('Quick Feet', 1.5));
        return value * 1.5;
      }
      mods.add(const AppliedStatModifier('Paralysis', 0.5));
      return value * 0.5;
    }

    // Guts: +50% Attack when statused
    if (ability == 'guts' && key == 'atk') {
      mods.add(const AppliedStatModifier('Guts', 1.5));
      return value * 1.5;
    }

    // Quick Feet: +50% Speed when statused (non-paralysis case)
    if (ability == 'quick feet' && key == 'spe') {
      mods.add(const AppliedStatModifier('Quick Feet', 1.5));
      return value * 1.5;
    }

    // Marvel Scale: +50% Defense when statused
    if (ability == 'marvel scale' && key == 'def') {
      mods.add(const AppliedStatModifier('Marvel Scale', 1.5));
      return value * 1.5;
    }

    return value;
  }

  // ── Weather Effects ─────────────────────────────────────────────────────

  static double _applyWeatherEffects(
    ComparisonEntry entry, String key, String ability,
    String type1, String? type2,
    List<AppliedStatModifier> mods, double value,
  ) {
    if (entry.weather == 'none') return value;

    // Sun + Chlorophyll = Speed ×2
    if (entry.weather == 'sunny' && ability == 'chlorophyll' && key == 'spe') {
      mods.add(const AppliedStatModifier('Chlorophyll (Sun)', 2.0));
      return value * 2.0;
    }

    // Rain + Swift Swim = Speed ×2
    if (entry.weather == 'rainy' && ability == 'swift swim' && key == 'spe') {
      mods.add(const AppliedStatModifier('Swift Swim (Rain)', 2.0));
      return value * 2.0;
    }

    // Sand + Sand Rush = Speed ×2
    if (entry.weather == 'sandstorm' && ability == 'sand rush' && key == 'spe') {
      mods.add(const AppliedStatModifier('Sand Rush (Sandstorm)', 2.0));
      return value * 2.0;
    }

    // Snow + Slush Rush = Speed ×2
    if (entry.weather == 'snow' && ability == 'slush rush' && key == 'spe') {
      mods.add(const AppliedStatModifier('Slush Rush (Snow)', 2.0));
      return value * 2.0;
    }

    return value;
  }

  // ── Terrain Effects ─────────────────────────────────────────────────────

  static double _applyTerrainEffects(
    ComparisonEntry entry, String key, String ability,
    List<AppliedStatModifier> mods, double value,
  ) {
    if (entry.terrain == 'none') return value;

    // Grassy Terrain + Grass Pelt = Defense ×1.5
    if (entry.terrain == 'grassy' && ability == 'grass pelt' && key == 'def') {
      mods.add(const AppliedStatModifier('Grass Pelt (Grassy Terrain)', 1.5));
      return value * 1.5;
    }

    // Electric Terrain + Surge Surfer = Speed ×2
    if (entry.terrain == 'electric' && ability == 'surge surfer' && key == 'spe') {
      mods.add(const AppliedStatModifier('Surge Surfer (Electric Terrain)', 2.0));
      return value * 2.0;
    }

    return value;
  }

  // ── Speed Items ─────────────────────────────────────────────────────────

  static double _speedItemMultiplier(ComparisonEntry entry) {
    final item = _normalize(entry.heldItem);
    if (item == 'iron ball') return 0.5;
    if (item == 'macho brace') return 0.5;
    // Power items
    if (const {
      'power weight', 'power bracer', 'power belt',
      'power lens', 'power band', 'power anklet',
    }.contains(item)) {
      return 0.5;
    }
    return 1.0;
  }

  // ── Protosynthesis / Quark Drive ────────────────────────────────────────

  static bool _isProtoQuarkActive(ComparisonEntry entry) {
    final ability = _normalize(entry.ability ?? '');
    if (ability != 'protosynthesis' && ability != 'quark drive') return false;

    switch (entry.protoQuarkState) {
      case ProtoQuarkState.inactive:
        return false;
      case ProtoQuarkState.forceActive:
        return true;
      case ProtoQuarkState.automatic:
        if (ability == 'protosynthesis') {
          return entry.weather == 'sunny' ||
              _normalize(entry.heldItem) == 'booster energy';
        }
        if (ability == 'quark drive') {
          return entry.terrain == 'electric' ||
              _normalize(entry.heldItem) == 'booster energy';
        }
        return false;
    }
  }

  /// Select the stat boosted by Protosynthesis / Quark Drive.
  /// The highest eligible stat is boosted. Ties use official priority:
  /// Atk > Def > SpA > SpD > Spe.
  static String? _selectProtoQuarkStat(Map<String, int> rawStats) {
    const priority = ['atk', 'def', 'spa', 'spd', 'spe'];
    String? best;
    int bestValue = -1;
    for (final key in priority) {
      final value = rawStats[key] ?? 0;
      if (value > bestValue) {
        bestValue = value;
        best = key;
      }
    }
    return best;
  }

  /// Returns the stat key boosted by Proto/Quark and its multiplier, for UI display.
  static ({String statKey, double multiplier, String label})? getProtoQuarkInfo(
    ComparisonEntry entry,
    BattleRuleset ruleset,
  ) {
    if (!_isProtoQuarkActive(entry)) return null;

    final ability = _normalize(entry.ability ?? '');
    final p = entry.pokemon;
    final isChampions = ruleset.isChampions;

    // Compute raw stats for candidate selection
    final rawStats = <String, int>{};
    for (final key in ['atk', 'def', 'spa', 'spd', 'spe']) {
      final statLabel = _statKeyToLabel(key);
      final natureMod = CombatUtils.getNatureMultiplier(entry.nature, statLabel);
      final bases = {
        'atk': p.baseAtk, 'def': p.baseDef,
        'spa': p.baseSpAtk, 'spd': p.baseSpDef, 'spe': p.baseSpd,
      };
      if (isChampions) {
        rawStats[key] = StatCalculator.calculateChampionsStat(
          base: bases[key]!, sp: entry.sps[key] ?? 0, alignmentModifier: natureMod,
        );
      } else {
        rawStats[key] = StatCalculator.calculateOtherStat(
          base: bases[key]!, iv: entry.ivs[key] ?? 31,
          ev: entry.evs[key] ?? 0, level: entry.level, natureModifier: natureMod,
        );
      }
    }

    final boosted = _selectProtoQuarkStat(rawStats);
    if (boosted == null) return null;

    final mult = boosted == 'spe' ? 1.5 : 1.3;
    final label = ability == 'protosynthesis' ? 'Protosynthesis' : 'Quark Drive';
    return (statKey: boosted, multiplier: mult, label: '$label: ${_statKeyToLabel(boosted)} ×${mult.toStringAsFixed(1)}');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static String _normalize(String s) =>
      s.toLowerCase().replaceAll('-', ' ').replaceAll('_', ' ').trim();

  static String _statKeyToLabel(String key) => switch (key) {
    'hp' => 'HP',
    'atk' => 'Attack',
    'def' => 'Defense',
    'spa' => 'Sp. Atk',
    'spd' => 'Sp. Def',
    'spe' => 'Speed',
    _ => key,
  };
}

// ── Extension for fluent value threading ───────────────────────────────────

extension _Also on double {
  void also(void Function(double) fn) => fn(this);
}
