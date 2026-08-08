import 'package:libredex/core/database/app_database.dart';

extension PokemonPropertiesExtension on Pokemon {
  int get generation {
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    if (dexNum >= 1 && dexNum <= 151) return 1;
    if (dexNum >= 152 && dexNum <= 251) return 2;
    if (dexNum >= 252 && dexNum <= 386) return 3;
    if (dexNum >= 387 && dexNum <= 493) return 4;
    if (dexNum >= 494 && dexNum <= 649) return 5;
    if (dexNum >= 650 && dexNum <= 721) return 6;
    if (dexNum >= 722 && dexNum <= 809) return 7;
    if (dexNum >= 810 && dexNum <= 898) return 8;
    if (dexNum >= 899 && dexNum <= 1025) return 9;
    return 9;
  }

  String get generationLabel => 'Generation ${generation.toString()}';

  bool get isBaby {
    const babies = {
      172, 173, 174, 175, 236, 238, 239, 240, 298, 360, 406, 433, 438, 439, 440, 446, 458, 847
    };
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    return babies.contains(dexNum);
  }

  int get evolutionStage {
    final n = name.toLowerCase();
    final f = form.toLowerCase();
    if (n.contains('mega') || f.contains('mega') || f.contains('gigantamax')) return 3; // Special
    if (isBaby) return 0; // Baby

    const stage2 = {
      3, 6, 9, 12, 15, 18, 26, 31, 34, 36, 38, 45, 62, 65, 68, 71, 76, 89, 94, 130, 143, 149,
      154, 157, 160, 181, 189, 248, 254, 257, 260, 267, 272, 275, 282, 289, 295, 306, 330, 373, 376,
      389, 392, 395, 405, 407, 430, 445, 448, 462, 464, 466, 467, 474, 475, 477, 497, 500, 503, 526,
      534, 537, 542, 545, 553, 576, 579, 604, 609, 612, 635, 652, 655, 658, 663, 666, 671, 681, 706,
      711, 724, 727, 730, 733, 738, 743, 784, 791, 792, 812, 815, 818, 823, 826, 858, 861, 887, 908,
      911, 914, 923, 930, 934, 959, 998
    };

    const stage1 = {
      2, 5, 8, 11, 14, 17, 25, 30, 33, 35, 37, 44, 61, 64, 67, 70, 75, 88, 93, 129, 142, 148,
      153, 156, 159, 180, 188, 247, 253, 256, 259, 266, 271, 274, 281, 288, 294, 305, 329, 372, 375,
      388, 391, 394, 404, 444, 461, 496, 499, 502, 525, 533, 536, 541, 544, 552, 575, 578, 603, 608,
      611, 634, 651, 654, 657, 662, 665, 670, 680, 705, 710, 723, 726, 729, 732, 737, 742, 783, 790,
      811, 814, 817, 822, 825, 857, 860, 886, 907, 910, 913, 922, 929, 933, 958, 997
    };

    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    if (stage2.contains(dexNum)) return 2; // Stage 2
    if (stage1.contains(dexNum)) return 1; // Stage 1
    return 0; // Basic / Single Stage
  }

  String get evolutionStageLabel {
    if (isBaby) return 'Baby Pokémon';
    switch (evolutionStage) {
      case 0: return 'Basic Pokémon';
      case 1: return 'Stage 1';
      case 2: return 'Stage 2';
      default: return 'Special Form';
    }
  }

  bool get canEvolve {
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    // Common fully evolved species or single stage with no evolution
    const fullyEvolved = {
      3, 6, 9, 12, 15, 18, 20, 22, 24, 26, 28, 31, 34, 36, 38, 40, 45, 47, 49, 51, 53, 55, 57, 59,
      62, 65, 68, 71, 73, 76, 78, 80, 82, 83, 85, 87, 89, 91, 94, 95, 97, 99, 101, 103, 105, 106,
      107, 110, 112, 113, 114, 115, 117, 119, 121, 122, 123, 124, 125, 126, 127, 128, 130, 131, 132,
      134, 135, 136, 139, 141, 142, 143, 144, 145, 146, 149, 150, 151, 154, 157, 160, 162, 164, 166,
      168, 169, 171, 178, 181, 182, 184, 185, 186, 189, 192, 195, 196, 197, 199, 201, 202, 203, 205,
      208, 210, 211, 212, 213, 214, 217, 219, 221, 222, 224, 225, 226, 227, 229, 230, 232, 233, 235,
      237, 241, 242, 243, 244, 245, 248, 249, 250, 251, 254, 257, 260, 262, 264, 267, 269, 272, 275,
      277, 279, 282, 284, 286, 289, 291, 292, 295, 297, 301, 302, 303, 306, 308, 310, 311, 312, 313,
      314, 317, 319, 321, 323, 324, 326, 327, 330, 332, 334, 335, 336, 337, 338, 340, 342, 344, 346,
      348, 350, 351, 352, 354, 356, 357, 358, 359, 362, 365, 368, 369, 373, 376, 377, 378, 379, 380,
      381, 382, 383, 384, 385, 386
    };
    if (fullyEvolved.contains(dexNum)) return false;
    if (isLegendary || isMythical || isParadox || isUltraBeast) return false;
    return true;
  }

  bool get hasNoEvolution => !canEvolve && evolutionStage == 0;

  String get evolutionMethod {
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;

    // Stone / Item evolutions
    const stones = {
      26, 31, 34, 36, 38, 45, 59, 91, 103, 121, 134, 135, 136, 182, 272, 275, 350, 407, 429, 430, 468, 475, 754, 936, 937
    };
    if (stones.contains(dexNum)) return 'Item/Stone';

    // Friendship evolutions
    const friendship = {
      25, 40, 113, 143, 172, 173, 174, 175, 196, 197, 242, 440, 446, 528, 542, 700, 773, 873
    };
    if (friendship.contains(dexNum)) return 'Friendship';

    // Trade evolutions
    const trade = {
      65, 68, 94, 186, 199, 208, 212, 230, 233, 368, 369, 464, 466, 467, 474, 526, 534, 589, 617, 709, 711
    };
    if (trade.contains(dexNum)) return 'Trade';

    // Move evolution (knows a specific move)
    const moves = {
      114, 122, 185, 190, 193, 203, 206, 221, 424, 439, 463, 465, 469, 473, 763, 865, 866, 981, 982
    };
    if (moves.contains(dexNum)) return 'Move';

    if (canEvolve || evolutionStage > 0) return 'Level';
    return 'None';
  }

  List<String> get eggGroups {
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    if (isLegendary || isMythical || isParadox || isUltraBeast) {
      return ['Undiscovered'];
    }
    
    final t1 = type1.toLowerCase();
    final t2 = type2?.toLowerCase();
    final n = name.toLowerCase();

    final groups = <String>[];

    // Starter groups
    if (dexNum <= 9 || (dexNum >= 152 && dexNum <= 160) || (dexNum >= 252 && dexNum <= 260) ||
        (dexNum >= 387 && dexNum <= 395) || (dexNum >= 495 && dexNum <= 503) || (dexNum >= 650 && dexNum <= 658) ||
        (dexNum >= 722 && dexNum <= 730) || (dexNum >= 810 && dexNum <= 818) || (dexNum >= 906 && dexNum <= 914)) {
      if (t1 == 'grass' || t2 == 'grass') groups.add('Monster');
      if (t1 == 'fire' || t2 == 'fire') groups.add('Field');
      if (t1 == 'water' || t2 == 'water') groups.add('Water 1');
      if (groups.isEmpty) groups.add('Field');
      return groups;
    }

    // Ditto
    if (dexNum == 132) return ['Ditto'];

    // Rule-based classification
    if (t1 == 'bug' || t2 == 'bug') groups.add('Bug');
    if (t1 == 'flying' || t2 == 'flying') groups.add('Flying');
    if (t1 == 'dragon' || t2 == 'dragon') groups.add('Dragon');
    if (t1 == 'fairy' || t2 == 'fairy') groups.add('Fairy');
    if (t1 == 'grass' || t2 == 'grass') groups.add('Grass');
    
    if (t1 == 'water' || t2 == 'water') {
      if (n.contains('fish') || n.contains('carp') || n.contains('remoraid') || n.contains('octillery')) {
        groups.add('Water 2');
      } else if (n.contains('tentacool') || n.contains('jelly') || n.contains('shellder') || n.contains('clam')) {
        groups.add('Water 3');
      } else {
        groups.add('Water 1');
      }
    }

    if (t1 == 'rock' || t1 == 'steel' || t2 == 'rock' || t2 == 'steel') {
      groups.add('Mineral');
    }

    if (t1 == 'ghost' || t1 == 'poison' || t2 == 'ghost' || t2 == 'poison') {
      groups.add('Amorphous');
    }

    if (t1 == 'fighting' || t1 == 'psychic' || t2 == 'fighting' || t2 == 'psychic') {
      groups.add('Human-Like');
    }

    if (groups.isEmpty) {
      groups.add('Field');
    }

    return groups;
  }

  bool get isChampions => name.toLowerCase().contains('champions') || id >= 10000;
  bool get isLegendsZA => form.toLowerCase().contains('eternal') || form.toLowerCase().contains('legends') || form.toLowerCase().contains('mega-raichu') || name.toLowerCase().contains('floette eternal') || form.toLowerCase() == 'legends-za';

  String? get formSource {
    if (isChampions) return 'champions';
    if (isLegendsZA) return 'legends_za';
    final f = form.toLowerCase();
    if (f.contains('mega')) return 'mega';
    if (f.contains('alolan')) return 'alola';
    if (f.contains('galarian')) return 'galar';
    if (f.contains('hisuian')) return 'hisui';
    if (f.contains('paldean')) return 'paldea';
    return 'mainline';
  }

  String? get dlcSource {
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    if (dexNum >= 1010 && dexNum <= 1017) return 'The Teal Mask';
    if (dexNum >= 1018 && dexNum <= 1025) return 'The Indigo Disk';
    if (isChampions) return 'Mega Dimension DLC';
    return null;
  }
}
