import 'package:libredex/core/database/app_database.dart';

extension PokemonPropertiesExtension on Pokemon {
  String get generationLabel => 'Generation ${generation.toString()}';

  bool get isBaby {
    const babies = {
      172, 173, 174, 175, 236, 238, 239, 240, 298, 360, 406, 433, 438, 439, 440, 446, 458, 847
    };
    final dexNum = nationalDexNumber > 0 ? nationalDexNumber : id;
    return babies.contains(dexNum);
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
    // Derived from assets/data/evolution_chains.json — final evos (to not in from) + isolated singles.
    // Regenerate via: python3 tools/validate_learnsets.py audit
    const fullyEvolved = {
      3, 6, 9, 12, 15, 18, 20, 22, 24, 26, 28, 31, 34, 36, 38,
      40, 45, 47, 49, 51, 53, 55, 59, 62, 65, 68, 71, 73, 76, 78,
      80, 85, 87, 89, 91, 94, 97, 99, 101, 103, 105, 106, 107, 110, 115,
      119, 121, 124, 127, 128, 130, 131, 132, 134, 135, 136, 139, 141, 142, 143,
      144, 145, 146, 149, 150, 151, 154, 157, 160, 162, 164, 166, 168, 169, 171,
      178, 181, 182, 184, 185, 186, 189, 192, 195, 196, 197, 199, 201, 202, 205,
      208, 210, 212, 213, 214, 219, 224, 225, 226, 227, 229, 230, 232, 235, 237,
      241, 242, 243, 244, 245, 248, 249, 250, 251, 254, 257, 260, 262, 267, 269,
      272, 275, 277, 279, 282, 284, 286, 289, 291, 292, 295, 297, 301, 302, 303,
      306, 308, 310, 311, 312, 313, 314, 317, 319, 321, 323, 324, 326, 327, 330,
      332, 334, 335, 336, 337, 338, 340, 342, 344, 346, 348, 350, 351, 352, 354,
      357, 358, 359, 362, 365, 367, 368, 369, 370, 373, 376, 377, 378, 379, 380,
      381, 382, 383, 384, 385, 386, 389, 392, 395, 398, 400, 402, 405, 407, 409,
      411, 413, 414, 416, 417, 419, 421, 423, 424, 426, 428, 429, 430, 432, 435,
      437, 441, 442, 445, 448, 450, 452, 454, 455, 457, 460, 461, 462, 463, 464,
      465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479,
      480, 481, 482, 483, 484, 485, 486, 487, 488, 490, 491, 492, 493, 494, 497,
      500, 503, 505, 508, 510, 512, 514, 516, 518, 521, 523, 526, 528, 530, 531,
      534, 537, 538, 539, 542, 545, 547, 549, 553, 555, 556, 558, 560, 561, 563,
      565, 567, 569, 571, 573, 576, 579, 581, 584, 586, 587, 589, 591, 593, 594,
      596, 598, 601, 604, 606, 609, 612, 614, 615, 617, 618, 620, 621, 623, 626,
      628, 630, 631, 632, 635, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646,
      647, 648, 649, 652, 655, 658, 660, 663, 666, 668, 671, 673, 675, 676, 678,
      681, 683, 685, 687, 689, 691, 693, 695, 697, 699, 700, 701, 702, 703, 706,
      707, 709, 711, 713, 715, 716, 717, 718, 719, 720, 721, 724, 727, 730, 733,
      735, 738, 740, 741, 743, 745, 746, 748, 750, 752, 754, 756, 758, 760, 763,
      764, 765, 766, 768, 770, 771, 773, 774, 775, 776, 777, 778, 779, 780, 781,
      784, 785, 786, 787, 788, 791, 792, 793, 794, 795, 796, 797, 798, 799, 800,
      801, 802, 804, 805, 806, 807, 808, 809, 812, 815, 818, 820, 823, 826, 828,
      830, 832, 834, 836, 839, 841, 842, 844, 845, 847, 849, 851, 853, 855, 858,
      861, 862, 863, 864, 865, 866, 867, 869, 870, 871, 873, 874, 875, 876, 877,
      879, 880, 881, 882, 883, 887, 888, 889, 890, 892, 893, 894, 895, 896, 897,
      898, 899, 900, 901, 902, 903, 904, 905, 908, 911, 914, 916, 918, 920, 923,
      925, 927, 930, 931, 934, 936, 937, 939, 941, 943, 945, 947, 949, 950, 952,
      954, 956, 959, 961, 962, 964, 966, 967, 968, 970, 972, 973, 975, 976, 977,
      978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992,
      993, 994, 995, 998, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010,
      1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025
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

  /// Parses the comma-separated eggGroups DB field into a list.
  /// Falls back to heuristic-based classification if the DB field is empty.
  List<String> get eggGroupsList {
    if (eggGroups != null && eggGroups!.isNotEmpty) {
      return eggGroups!.split(',').map((e) => e.trim()).toList();
    }

    // Fallback heuristic
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
}
