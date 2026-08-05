/// Pure Dart representation of battlefield environment and side conditions.
library;

class FieldState {
  final String weather; // 'none', 'sunny', 'rainy', 'sandstorm', 'snow'
  final String terrain; // 'none', 'electric', 'grassy', 'psychic', 'misty'
  final bool reflectActive;
  final bool lightScreenActive;
  final bool auroraVeilActive;
  final bool helpingHandActive;
  final bool trickRoomActive;
  final bool defenderProtected;
  final bool isDoubleBattle;
  final Set<String> activeRuinAbilities; // 'Tablets of Ruin', 'Sword of Ruin', etc.

  const FieldState({
    this.weather = 'none',
    this.terrain = 'none',
    this.reflectActive = false,
    this.lightScreenActive = false,
    this.auroraVeilActive = false,
    this.helpingHandActive = false,
    this.trickRoomActive = false,
    this.defenderProtected = false,
    this.isDoubleBattle = false,
    this.activeRuinAbilities = const {},
  });

  FieldState copyWith({
    String? weather,
    String? terrain,
    bool? reflectActive,
    bool? lightScreenActive,
    bool? auroraVeilActive,
    bool? helpingHandActive,
    bool? trickRoomActive,
    bool? defenderProtected,
    bool? isDoubleBattle,
    Set<String>? activeRuinAbilities,
  }) {
    return FieldState(
      weather: weather ?? this.weather,
      terrain: terrain ?? this.terrain,
      reflectActive: reflectActive ?? this.reflectActive,
      lightScreenActive: lightScreenActive ?? this.lightScreenActive,
      auroraVeilActive: auroraVeilActive ?? this.auroraVeilActive,
      helpingHandActive: helpingHandActive ?? this.helpingHandActive,
      trickRoomActive: trickRoomActive ?? this.trickRoomActive,
      defenderProtected: defenderProtected ?? this.defenderProtected,
      isDoubleBattle: isDoubleBattle ?? this.isDoubleBattle,
      activeRuinAbilities: activeRuinAbilities ?? Set.from(this.activeRuinAbilities),
    );
  }
}
