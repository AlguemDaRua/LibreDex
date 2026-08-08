import 'package:libredex/core/database/app_database.dart';

extension AbilityPropertiesExtension on Ability {
  int get generation {
    if (id >= 1 && id <= 76) return 3;
    if (id >= 77 && id <= 123) return 4;
    if (id >= 124 && id <= 164) return 5;
    if (id >= 165 && id <= 191) return 6;
    if (id >= 192 && id <= 233) return 7;
    if (id >= 234 && id <= 267) return 8;
    if (id >= 268 && id <= 307) return 9;
    return 9; // default/latest
  }

  String get introducedIn => 'Generation ${generation.toString()}';

  bool get isHiddenAbility => false; // Usually context-specific, default false
  bool get isChampionsAbility => id >= 10000;
  bool get isLegendsZAAbility => name.toLowerCase().contains('legends') || name.toLowerCase().contains('za') || name.toLowerCase().contains('mega');

  String get sourceGames {
    if (isChampionsAbility) return 'Pokémon Champions';
    if (isLegendsZAAbility) return 'Pokémon Legends: Z-A';
    return 'Mainline Games';
  }

  List<String> get effectTags {
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

  List<String> get battleEffectTags => effectTags;
  List<String> get pokemonTypes => []; // Contextual or general types using this ability
}
