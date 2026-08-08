import 'package:libredex/core/database/app_database.dart';

extension AbilityPropertiesExtension on Ability {
  String get generationLabel => 'Generation ${generation.toString()}';

  String get introducedInLabel => introducedIn ?? 'Generation ${generation.toString()}';

  String get sourceGamesLabel {
    if (sourceGames != null && sourceGames!.isNotEmpty) return sourceGames!;
    if (isChampionsAbility) return 'Pokémon Champions';
    if (isLegendsZAAbility) return 'Pokémon Legends: Z-A';
    return 'Mainline Games';
  }

  /// Parses the comma-separated effectTags DB field into a list.
  /// Falls back to description-based heuristic classification.
  List<String> get effectTagsList {
    if (effectTags != null && effectTags!.isNotEmpty) {
      return effectTags!.split(',').map((e) => e.trim()).toList();
    }

    // Fallback heuristic from description
    final desc = description.toLowerCase();
    final tags = <String>[];
    if (desc.contains('weather') || desc.contains('rain') || desc.contains('sun') || desc.contains('sandstorm') || desc.contains('hail')) tags.add('Weather');
    if (desc.contains('terrain') || desc.contains('electric terrain') || desc.contains('grassy terrain') || desc.contains('misty terrain') || desc.contains('psychic terrain')) tags.add('Terrain');
    if (desc.contains('stat') || desc.contains('attack') || desc.contains('defense') || desc.contains('speed') || desc.contains('sp. atk') || desc.contains('sp. def')) tags.add('Stats');
    if (desc.contains('status') || desc.contains('poison') || desc.contains('paralyze') || desc.contains('burn') || desc.contains('sleep') || desc.contains('freeze') || desc.contains('confusion')) tags.add('Status');
    if (desc.contains('damage') || desc.contains('power') || desc.contains('weakens') || desc.contains('boosts')) tags.add('Damage');
    if (desc.contains('immune') || desc.contains('immunity') || desc.contains('prevents') || desc.contains('negates')) tags.add('Immunity');
    if (desc.contains('type') || desc.contains('changes type')) tags.add('Type');
    if (desc.contains('speed') || desc.contains('first')) tags.add('Speed');
    if (desc.contains('item') || desc.contains('berry') || desc.contains('held item')) tags.add('Items');
    if (desc.contains('switch') || desc.contains('flee') || desc.contains('escape')) tags.add('Switching');
    if (desc.contains('hazard') || desc.contains('spikes')) tags.add('Hazards');
    if (desc.contains('restore') || desc.contains('hp') || desc.contains('heal')) tags.add('Healing');
    if (desc.contains('critical') || desc.contains('critical-hit')) tags.add('Critical Hits');
    if (desc.contains('accuracy') || desc.contains('evasiveness')) tags.add('Accuracy');
    if (desc.contains('priority') || desc.contains('always goes first')) tags.add('Priority');
    return tags;
  }

  List<String> get battleEffectTagsList => effectTagsList;
  List<String> get pokemonTypesList => (pokemonTypes != null && pokemonTypes!.isNotEmpty) ? pokemonTypes!.split(',').map((e) => e.trim()).toList() : [];
}
