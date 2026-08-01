/// Battle rulesets supported by the LibreDex damage calculator.
///
/// The mainline ruleset models the classic Nintendo / Switch games
/// ( Scarlet & Violet and earlier): levels 1–100, IVs 0–31 and EVs up to
/// 252 per stat / 510 total.
///
/// Pokémon Champions replaces effort values with **Stat Points (SP)** and
/// uses its own stat formula. Damage calculations use level 50. The constants
/// and formulas below are verified against Pokémon Showdown's Champions mode.
library;

import 'package:libredex/features/pokedex/models/stat_calculator.dart';

/// Which game's stat system the damage calculator should use.
enum BattleRuleset {
  /// Classic mainline games (default; keeps the classic calculator intact).
  mainline,

  /// Pokémon Champions: its own fixed stat formula, 65 Stat Points total
  /// (max 32 per stat) and Stat Alignments.
  champions,
}

extension BattleRulesetX on BattleRuleset {
  /// Human-readable selector label.
  String get label => switch (this) {
        BattleRuleset.mainline => 'Mainline',
        BattleRuleset.champions => 'Pokémon Champions',
      };

  bool get isChampions => this == BattleRuleset.champions;
}

/// Constants and helpers for the Pokémon Champions ruleset.
class ChampionsRules {
  ChampionsRules._();

  /// Damage calculations use level 50.
  static const int level = 50;

  /// Kept for UI compatibility; Champions stats do not use mainline IVs.
  static const int fixedIv = 31;

  /// Total Stat Points that can be distributed across the six stats.
  /// The official Champions calculator shows a 65-point budget.
  static const int totalStatPoints = 65;

  /// Maximum Stat Points allowed in a single stat (each point is +1 stat).
  static const int maxStatPointsPerStat = 32;

  /// Champions drops the four filler neutral natures (Hardy, Docile,
  /// Bashful, Quirky); Serious remains the only neutral Stat Alignment.
  /// All remaining 21 alignments keep the classic ±10% modification.
  static const List<String> alignments = [
    'lonely', 'brave', 'adamant', 'naughty',
    'bold', 'relaxed', 'impish', 'lax',
    'timid', 'hasty', 'jolly', 'naive',
    'serious',
    'modest', 'mild', 'quiet', 'rash',
    'calm', 'gentle', 'sassy', 'careful',
  ];

  /// Stat keys in display order (matches the calculator state maps).
  static const List<String> statKeys = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];

  /// Returns true when [nature] exists in Champions as a Stat Alignment.
  static bool isValidAlignment(String nature) => alignments.contains(nature.toLowerCase());

  /// Zeroed Stat Point map used as the default Champions spread.
  static Map<String, int> emptySpread() => {for (final key in statKeys) key: 0};

  /// SP already invested in [spread].
  static int usedStatPoints(Map<String, int> spread) =>
      spread.values.fold(0, (sum, val) => sum + val);

  /// Remaining Stat Points for [spread], matching the in-game budget readout.
  static int remainingStatPoints(Map<String, int> spread) =>
      totalStatPoints - usedStatPoints(spread);

  /// Clamps a Stat Point edit so it respects both the 32 per-stat cap and
  /// the 65 point total budget. Returns the effective value for [key].
  static int clampStatPoint(Map<String, int> spread, String key, int requested) {
    final otherStats = usedStatPoints(spread) - (spread[key] ?? 0);
    final budgetLeft = totalStatPoints - otherStats;
    final upper = requested < 0 ? 0 : requested;
    final perStatCap = upper > maxStatPointsPerStat ? maxStatPointsPerStat : upper;
    return perStatCap > budgetLeft ? budgetLeft : perStatCap;
  }

  /// Final HP for a Champions-rules Pokémon (see [StatCalculator] docs).
  static int hp({required int base, int sp = 0, bool isShedinja = false}) =>
      StatCalculator.calculateChampionsHp(base: base, sp: sp, isShedinja: isShedinja);

  /// Final non-HP stat for a Champions-rules Pokémon, alignment applied.
  static int stat({required int base, int sp = 0, double alignmentModifier = 1.0}) =>
      StatCalculator.calculateChampionsStat(base: base, sp: sp, alignmentModifier: alignmentModifier);
}

/// A named Stat Point spread matching the common Champions archetypes.
class ChampionsStatPreset {
  final String label;
  final Map<String, int> spread;

  const ChampionsStatPreset(this.label, this.spread);

  static const List<ChampionsStatPreset> presets = [
    ChampionsStatPreset('Physical Attacker', {
      'hp': 1, 'atk': 32, 'def': 0, 'spa': 0, 'spd': 0, 'spe': 32,
    }),
    ChampionsStatPreset('Special Attacker', {
      'hp': 1, 'atk': 0, 'def': 0, 'spa': 32, 'spd': 0, 'spe': 32,
    }),
    ChampionsStatPreset('Bulky Physical', {
      'hp': 32, 'atk': 32, 'def': 1, 'spa': 0, 'spd': 0, 'spe': 0,
    }),
    ChampionsStatPreset('Bulky Special', {
      'hp': 32, 'atk': 0, 'def': 0, 'spa': 32, 'spd': 1, 'spe': 0,
    }),
    ChampionsStatPreset('Trick Room Attacker', {
      'hp': 32, 'atk': 32, 'def': 1, 'spa': 0, 'spd': 0, 'spe': 0,
    }),
  ];
}

/// Computes a Champions final stat map for the given base stats — shared by
/// the calculator, tests and any future Champions surface so formulas stay
/// in one place.
Map<String, int> championsFinalStats({
  required Map<String, int> base,
  required Map<String, int> spread,
  required String alignment,
  required double Function(String statLabel) alignmentModifierFor,
  bool isShedinja = false,
}) {
  return {
    'hp': ChampionsRules.hp(base: base['hp'] ?? 1, sp: spread['hp'] ?? 0, isShedinja: isShedinja),
    'atk': ChampionsRules.stat(base: base['atk'] ?? 1, sp: spread['atk'] ?? 0, alignmentModifier: alignmentModifierFor('Attack')),
    'def': ChampionsRules.stat(base: base['def'] ?? 1, sp: spread['def'] ?? 0, alignmentModifier: alignmentModifierFor('Defense')),
    'spa': ChampionsRules.stat(base: base['spa'] ?? 1, sp: spread['spa'] ?? 0, alignmentModifier: alignmentModifierFor('Sp. Atk')),
    'spd': ChampionsRules.stat(base: base['spd'] ?? 1, sp: spread['spd'] ?? 0, alignmentModifier: alignmentModifierFor('Sp. Def')),
    'spe': ChampionsRules.stat(base: base['spe'] ?? 1, sp: spread['spe'] ?? 0, alignmentModifier: alignmentModifierFor('Speed')),
  };
}
