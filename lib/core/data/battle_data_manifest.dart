/// Battle Data & Engine Manifest.
///
/// Tracks the pinned Pokémon Showdown data/engine version, Champions ruleset
/// version, and engine completeness status for offline data auditing.
library;

class BattleDataManifest {
  BattleDataManifest._();

  /// Pinned Pokémon Showdown calculator data version.
  static const String showdownVersionPin = 'Gen IX (v1.0.0-showdown-2024.09)';

  /// Pokémon Champions ruleset specification version.
  static const String championsRulesetVersion = 'Pokémon Champions v1.2';

  /// LibreDex Battle Engine version.
  static const String engineVersion = '1.0.0';

  /// Release date of the pinned data.
  static const String releaseDate = '2026-08-01';

  /// Returns a formatted manifest summary string for debugging and UI display.
  static String get summary =>
      'LibreDex Battle Engine v$engineVersion | Pinned: $showdownVersionPin | $championsRulesetVersion';

  /// Returns full manifest details map.
  static Map<String, String> get details => {
        'Engine Version': engineVersion,
        'Showdown Pin': showdownVersionPin,
        'Champions Version': championsRulesetVersion,
        'Release Date': releaseDate,
        'Offline Capable': 'Yes',
      };
}
