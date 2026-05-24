/// Pure utility class to calculate official Pokémon stats based on main-series formulas.
/// All formulas are correct from Generation III onwards.
class StatCalculator {
  StatCalculator._();

  /// Calculates the final HP stat for a Pokémon.
  ///
  /// Formula:
  /// HP = floor(((Base * 2 + IV + floor(EV / 4)) * Level) / 100) + Level + 10
  ///
  /// Special Case: Shedinja's HP is always 1 regardless of Level, IVs, EVs, or Base Stat.
  ///
  /// [base]: Base HP stat of the Pokémon.
  /// [iv]: Individual Value (0 to 31). Defaults to 31.
  /// [ev]: Effort Value (0 to 252). Defaults to 0.
  /// [level]: Pokémon Level (1 to 100). Defaults to 100.
  /// [isShedinja]: Set to true if calculating for Shedinja.
  static int calculateHp({
    required int base,
    int iv = 31,
    int ev = 0,
    int level = 100,
    bool isShedinja = false,
  }) {
    if (isShedinja) return 1;

    final int evPart = ev ~/ 4; // Integer division: floor(EV / 4)
    final int mainCalculation = (((base * 2 + iv + evPart) * level) ~/ 100);
    return mainCalculation + level + 10;
  }

  /// Calculates the final value of any stat other than HP (Attack, Defense, Sp. Atk, Sp. Def, Speed).
  ///
  /// Formula:
  /// Stat = floor((floor(((Base * 2 + IV + floor(EV / 4)) * Level) / 100) + 5) * NatureModifier)
  ///
  /// [base]: Base value of the stat.
  /// [iv]: Individual Value (0 to 31). Defaults to 31.
  /// [ev]: Effort Value (0 to 252). Defaults to 0.
  /// [level]: Pokémon Level (1 to 100). Defaults to 100.
  /// [natureModifier]: Nature modifier multiplier. Typically 0.9 (hindering), 1.0 (neutral), or 1.1 (beneficial).
  static int calculateOtherStat({
    required int base,
    int iv = 31,
    int ev = 0,
    int level = 100,
    double natureModifier = 1.0,
  }) {
    final int evPart = ev ~/ 4; // Integer division: floor(EV / 4)
    final int mainCalculation = (((base * 2 + iv + evPart) * level) ~/ 100);
    final double finalValue = (mainCalculation + 5) * natureModifier;
    return finalValue.floor();
  }
}
