import 'package:libredex/core/database/app_database.dart';

extension MovePropertiesExtension on Move {
  int get priority {
    final n = name.toLowerCase();
    if (n == 'protect' ||
        n == 'detect' ||
        n == 'king\'s shield' ||
        n == 'spiky shield' ||
        n == 'baneful bunker' ||
        n == 'obstruct' ||
        n == 'silk trap' ||
        n == 'quick guard' ||
        n == 'wide guard' ||
        n == 'crafty shield' ||
        n == 'mat block' ||
        n == 'max guard' ||
        n == 'shelter') {
      return 4;
    }
    if (n == 'fake out' || n == 'first impression') return 3;
    if (n == 'extreme speed' || n == 'feint' || n == 'rage powder' || n == 'follow me' || n == 'ally switch') return 2;
    if (n == 'quick attack' ||
        n == 'aqua jet' ||
        n == 'ice shard' ||
        n == 'mach punch' ||
        n == 'bullet punch' ||
        n == 'shadow sneak' ||
        n == 'vacuum wave' ||
        n == 'sucker punch' ||
        n == 'water shuriken' ||
        n == 'grassy glide' ||
        n == 'accelerock') {
      return 1;
    }
    if (n == 'vital throw' ||
        n == 'circle throw' ||
        n == 'dragon tail' ||
        n == 'roar' ||
        n == 'whirlwind' ||
        n == 'trick room') {
      return -6;
    }
    return 0;
  }

  bool get isContact {
    if (damageClass.toLowerCase() == 'status' || damageClass.toLowerCase() == 'special') return false;
    final n = name.toLowerCase();
    // Non-contact physical moves
    if (n.contains('earthquake') ||
        n.contains('rock slide') ||
        n.contains('stone edge') ||
        n.contains('icicle crash') ||
        n.contains('bulldoze') ||
        n.contains('bonemerang') ||
        n.contains('bone rush') ||
        n.contains('fission') ||
        n.contains('petal dance') ||
        n.contains('razor leaf') ||
        n.contains('seed bomb') ||
        n.contains('spirit break') ||
        n.contains('drum beating') ||
        n.contains('grav apple')) {
      return false;
    }
    return true;
  }

  bool get isHealing {
    final n = name.toLowerCase();
    return n.contains('heal') ||
        n.contains('recovery') ||
        n.contains('roost') ||
        n.contains('soft-boiled') ||
        n.contains('milk drink') ||
        n.contains('slack off') ||
        n.contains('wish') ||
        (description?.toLowerCase().contains('restores hp') ?? false);
  }

  bool get isSound {
    final n = name.toLowerCase();
    return n.contains('voice') ||
        n.contains('roar') ||
        n.contains('scales') ||
        n.contains('sing') ||
        n.contains('screech') ||
        n.contains('growl') ||
        n.contains('howl') ||
        n.contains('sound') ||
        n.contains('snarl') ||
        n.contains('overdrive') ||
        n.contains('boomburst');
  }

  bool get isPunching {
    final n = name.toLowerCase();
    return n.contains('punch') || n == 'comet punch' || n == 'mach punch' || n == 'hammer arm' || n == 'double iron bash';
  }

  bool get isBiting {
    final n = name.toLowerCase();
    return n.contains('bite') || n.contains('crunch') || n.contains('fang');
  }

  bool get isBite => isBiting;

  bool get isPowder {
    final n = name.toLowerCase();
    return n.contains('powder') || n == 'spore';
  }

  bool get isPulse {
    final n = name.toLowerCase();
    return n.contains('pulse') || n.contains('aura');
  }

  bool get isBallistic {
    final n = name.toLowerCase();
    return n.contains('ball') ||
        n.contains('bomb') ||
        n.contains('seed') ||
        n.contains('shot') ||
        n.contains('blast') ||
        n.contains('barrage') ||
        n == 'pyro ball' ||
        n == 'icicle crash';
  }

  bool get isSlicing {
    final n = name.toLowerCase();
    return n.contains('slash') ||
        n.contains('blade') ||
        n.contains('cutter') ||
        n.contains('scissor') ||
        n.contains('axe') ||
        n.contains('edge') ||
        n == 'sacred sword' ||
        n == 'psycho cut' ||
        n == 'razor shell' ||
        n == 'cross poison';
  }

  bool get isWind {
    final n = name.toLowerCase();
    return n.contains('wind') ||
        n.contains('gust') ||
        n.contains('storm') ||
        n == 'hurricane' ||
        n == 'tailwind' ||
        n == 'blizzard' ||
        n == 'heat wave' ||
        n == 'sandsear storm';
  }

  bool get isDance {
    final n = name.toLowerCase();
    return n.contains('dance');
  }

  bool get isMultiHit {
    final n = name.toLowerCase();
    return n.contains('slap') ||
        n.contains('spike') ||
        n.contains('pin') ||
        n.contains('shuriken') ||
        n.contains('barrage') ||
        n == 'fury swipes' ||
        n == 'bullet seed' ||
        n == 'icicle spear' ||
        n == 'rock blast' ||
        n == 'triple axel' ||
        n == 'surging strikes' ||
        n == 'dual wingbeat' ||
        n == 'bone rush';
  }

  bool get isProtective {
    final n = name.toLowerCase();
    return n == 'protect' ||
        n == 'detect' ||
        n == 'king\'s shield' ||
        n == 'spiky shield' ||
        n == 'baneful bunker' ||
        n == 'obstruct' ||
        n == 'silk trap' ||
        n == 'quick guard' ||
        n == 'wide guard' ||
        n == 'crafty shield' ||
        n == 'shelter';
  }

  bool get isSwitching {
    final n = name.toLowerCase();
    return n == 'u-turn' ||
        n == 'volt switch' ||
        n == 'flip turn' ||
        n == 'parting shot' ||
        n == 'baton pass' ||
        n == 'teleport' ||
        n == 'chilly reception' ||
        n == 'shed tail';
  }

  bool get isRecharge {
    final n = name.toLowerCase();
    return n.contains('beam') ||
        n.contains('impact') ||
        n.contains('plant') ||
        n.contains('burn') ||
        n.contains('cannon') ||
        n == 'meteor assault' ||
        n == 'rock wrecker' ||
        n == 'roar of time' ||
        n == 'prismatic laser' ||
        n == 'fleur cannon';
  }

  bool get isRecoil {
    final n = name.toLowerCase();
    return n.contains('recoil') ||
        n == 'double-edge' ||
        n == 'brave bird' ||
        n == 'flare blitz' ||
        n == 'wood hammer' ||
        n == 'wave crash' ||
        n == 'head smash' ||
        n == 'volt tackle' ||
        n == 'take down' ||
        n == 'wild charge' ||
        n == 'headlong rush' ||
        n == 'chloroblast' ||
        n == 'steel beam' ||
        n == 'mind blown';
  }

  bool get isDraining {
    final n = name.toLowerCase();
    return n.contains('drain') || n.contains('absorb') || n == 'leech life' || n == 'horn leech' || n == 'draining kiss' || n == 'bitter blade' || n == 'dream eater';
  }

  bool get isStatusMove => damageClass.toLowerCase() == 'status';
  bool get isDamagingMove => !isStatusMove;

  bool get isSignatureMove {
    final n = name.toLowerCase();
    return n == 'origin pulse' ||
        n == 'precipice blades' ||
        n == 'dragon ascent' ||
        n == 'roost' ||
        n == 'wicked blow' ||
        n == 'surging strikes' ||
        n == 'dark void' ||
        n == 'judgment' ||
        n == 'roard of time' ||
        n == 'spacial rend' ||
        n == 'shadow force';
  }

  bool get isDLCMove => id >= 800 && id < 900;
  bool get isChampionsMove => name.toLowerCase().contains('champions') || id >= 10000;
  bool get isLegendsZAMove => name.toLowerCase().contains('eternal') || name.toLowerCase().contains('springtide') || name.toLowerCase().contains('bleakwind') || name.toLowerCase().contains('wildbolt') || name.toLowerCase().contains('sandsear');

  int get generation {
    if (id >= 1 && id <= 165) return 1;
    if (id >= 166 && id <= 251) return 2;
    if (id >= 252 && id <= 354) return 3;
    if (id >= 355 && id <= 467) return 4;
    if (id >= 468 && id <= 559) return 5;
    if (id >= 560 && id <= 621) return 6;
    if (id >= 622 && id <= 742) return 7;
    if (id >= 743 && id <= 826) return 8;
    return 9;
  }

  String get introducedIn => 'Generation ${generation.toString()}';
}
