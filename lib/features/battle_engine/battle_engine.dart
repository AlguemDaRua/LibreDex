/// Pure Dart Battle Engine facade for LibreDex.
///
/// Provides single entry point for battle damage calculations, stat math,
/// and modifier calculations without any dependency on Flutter UI widgets.
library;

export 'models/applied_modifier.dart';
export 'models/pokemon_state.dart';
export 'models/move_state.dart';
export 'models/field_state.dart';
export 'models/battle_state.dart';
export 'models/damage_result.dart';
export 'package:libredex/features/calculator/models/battle_ruleset.dart';

export 'services/stat_engine.dart';
export 'services/modifier_pipeline.dart';
export 'services/mainline_damage_engine.dart';
export 'services/champions_damage_engine.dart';

import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'models/battle_state.dart';
import 'models/damage_result.dart';
import 'services/mainline_damage_engine.dart';
import 'services/champions_damage_engine.dart';

class BattleEngine {
  BattleEngine._();

  /// Calculate battle damage using the state's active ruleset (Mainline or Champions).
  static DamageResult calculate(BattleState state) {
    if (state.ruleset == BattleRuleset.champions) {
      return ChampionsDamageEngine.calculate(state);
    }
    return MainlineDamageEngine.calculate(state);
  }
}
