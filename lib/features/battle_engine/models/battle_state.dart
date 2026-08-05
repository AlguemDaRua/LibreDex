/// Complete snapshot of battle state required for a damage calculation.
library;

import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/battle_engine/models/pokemon_state.dart';
import 'package:libredex/features/battle_engine/models/move_state.dart';
import 'package:libredex/features/battle_engine/models/field_state.dart';

class BattleState {
  final PokemonState attacker;
  final PokemonState defender;
  final MoveState move;
  final FieldState field;
  final BattleRuleset ruleset;

  const BattleState({
    required this.attacker,
    required this.defender,
    required this.move,
    required this.field,
    this.ruleset = BattleRuleset.mainline,
  });

  BattleState copyWith({
    PokemonState? attacker,
    PokemonState? defender,
    MoveState? move,
    FieldState? field,
    BattleRuleset? ruleset,
  }) {
    return BattleState(
      attacker: attacker ?? this.attacker,
      defender: defender ?? this.defender,
      move: move ?? this.move,
      field: field ?? this.field,
      ruleset: ruleset ?? this.ruleset,
    );
  }
}
