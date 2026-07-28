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

  /// Calculates the final HP stat under the **Pokémon Champions** ruleset.
  ///
  /// Champions fixes battles at level 50 and treats IVs as perfect (31), so
  /// the level-50 mainline core collapses to `(2 * Base + 31) * 50 ~/ 100 + 60`.
  /// EVs are replaced by Stat Points, and — unlike EVs, which are divided by
  /// 4 *inside* the truncation — each Stat Point adds **exactly +1 at Lv. 50,
  /// applied after the floor**. That is why this does not reuse the EV path:
  /// pretending 1 SP = 4 EV would round half of the points away.
  ///
  /// Formula (community-verified against the Champions stat guide):
  /// `HP = floor((2 * Base + 31) * 50 / 100) + 50 + 10 + SP`
  ///
  /// Special Case: Shedinja's HP is always 1, in every ruleset.
  static int calculateChampionsHp({
    required int base,
    int sp = 0,
    bool isShedinja = false,
  }) {
    if (isShedinja) return 1;
    final int core = ((base * 2 + 31) * 50) ~/ 100; // Lv. 50, 31 IVs
    return core + 50 + 10 + sp;
  }

  /// Calculates any non-HP stat under the **Pokémon Champions** ruleset.
  ///
  /// Same reasoning as [calculateChampionsHp]: Lv. 50 core with perfect IVs,
  /// Stat Point added as a flat +1 after the floor, then the Stat Alignment
  /// modifier (±10%; Serious is the only neutral alignment).
  ///
  /// Formula (community-verified against the Champions stat guide):
  /// `Stat = floor((floor((2 * Base + 31) * 50 / 100) + 5 + SP) * Alignment)`
  static int calculateChampionsStat({
    required int base,
    int sp = 0,
    double alignmentModifier = 1.0,
  }) {
    final int core = ((base * 2 + 31) * 50) ~/ 100; // Lv. 50, 31 IVs
    return ((core + 5 + sp) * alignmentModifier).floor();
  }
}
