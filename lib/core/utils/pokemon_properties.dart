import 'package:libredex/core/database/app_database.dart';

extension PokemonPropertiesExtension on Pokemon {
  String get generationLabel => 'Generation $generation';

  String get evolutionStageLabel {
    if (isBaby) return 'Baby Pokémon';
    return switch (evolutionStage) {
      0 => 'Basic Pokémon',
      1 => 'Stage 1',
      2 => 'Stage 2',
      final stage => 'Stage $stage',
    };
  }

  /// Whether this exact Pokémon/form has at least one outgoing evolution edge.
  bool get canEvolve => hasEvolution;

  /// A single-stage species has no incoming or outgoing stage in its family.
  bool get hasNoEvolution => !hasEvolution && evolutionStage == 0;

  List<String> get evolutionMethodsList => (evolutionMethods ?? '')
      .split('|')
      .map((method) => method.trim())
      .where((method) => method.isNotEmpty)
      .toList(growable: false);

  /// The first available method is kept for compact labels in older UI.
  String get evolutionMethod =>
      evolutionMethodsList.isEmpty ? 'None' : evolutionMethodsList.first;

  bool hasEvolutionMethod(String method) => evolutionMethodsList.any(
    (candidate) => candidate.toLowerCase() == method.toLowerCase(),
  );

  /// Parses the source-backed, comma-separated egg groups without guessing.
  List<String> get eggGroupsList => (eggGroups ?? '')
      .split(',')
      .map((group) => group.trim())
      .where((group) => group.isNotEmpty)
      .toList(growable: false);
}
