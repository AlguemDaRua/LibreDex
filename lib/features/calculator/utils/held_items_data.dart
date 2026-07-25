/// Comprehensive held items database for competitive Pokémon damage calculations.
/// Each item defines its effect on attacker or defender stats.
class HeldItemsData {
  static const String noItem = 'None';

  static List<HeldItem> get offensiveItems {
    return allItems.where((item) => 
      item.name == 'None' ||
      item.atkMultiplier != 1.0 || 
      item.spAtkMultiplier != 1.0 || 
      item.universalDamageMultiplier != 1.0 || 
      item.typeBoostMultiplier != 1.0
    ).toList();
  }

  /// All available items for the picker, grouped by category.
  static const List<HeldItem> allItems = [
    HeldItem(name: 'None', category: 'None', description: 'No held item.'),

    // ── Speed modifiers ──────────────────────────────────────────────────────
    HeldItem(
      name: 'Choice Scarf',
      category: 'Speed',
      description: '+50% Speed, locked to first move.',
      speedMultiplier: 1.5,
    ),
    HeldItem(
      name: 'Iron Ball',
      category: 'Speed',
      description: '-50% Speed.',
      speedMultiplier: 0.5,
    ),
    HeldItem(
      name: 'Lagging Tail',
      category: 'Speed',
      description: 'Always moves last.',
      speedMultiplier: 0.5,
    ),
    HeldItem(
      name: 'Quick Powder',
      category: 'Speed',
      description: '+100% Speed (Ditto only in competitive context).',
      speedMultiplier: 2.0,
    ),

    // ── Attack multipliers (attacker) ────────────────────────────────────────
    HeldItem(
      name: 'Choice Band',
      category: 'Attack',
      description: '+50% Attack, locked to first move.',
      atkMultiplier: 1.5,
    ),
    HeldItem(
      name: 'Choice Specs',
      category: 'Special Attack',
      description: '+50% Sp. Atk, locked to first move.',
      spAtkMultiplier: 1.5,
    ),
    HeldItem(
      name: 'Life Orb',
      category: 'Universal Damage',
      description: '+30% damage dealt, user loses 1/10 HP per hit.',
      universalDamageMultiplier: 1.3,
    ),
    HeldItem(
      name: 'Eviolite',
      category: 'Defense',
      description: '+50% Def & Sp. Def for non fully-evolved Pokémon.',
      defMultiplier: 1.5,
      spDefMultiplier: 1.5,
    ),
    HeldItem(
      name: 'Assault Vest',
      category: 'Special Defense',
      description: '+50% Sp. Def, cannot use status moves.',
      spDefMultiplier: 1.5,
    ),
    HeldItem(
      name: 'Thick Club',
      category: 'Attack',
      description: '+100% Attack for Cubone/Marowak.',
      atkMultiplier: 2.0,
    ),
    HeldItem(
      name: 'Deep Sea Tooth',
      category: 'Special Attack',
      description: '+100% Sp. Atk for Clamperl.',
      spAtkMultiplier: 2.0,
    ),

    // ── Type-boosting items (+20% to specific type) ─────────────────────────
    HeldItem(name: 'Black Glasses', category: 'Type Boost', description: '+20% Dark moves.', typeBoostType: 'dark', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Silk Scarf', category: 'Type Boost', description: '+20% Normal moves.', typeBoostType: 'normal', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Charcoal', category: 'Type Boost', description: '+20% Fire moves.', typeBoostType: 'fire', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Mystic Water', category: 'Type Boost', description: '+20% Water moves.', typeBoostType: 'water', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Miracle Seed', category: 'Type Boost', description: '+20% Grass moves.', typeBoostType: 'grass', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Magnet', category: 'Type Boost', description: '+20% Electric moves.', typeBoostType: 'electric', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Never-Melt Ice', category: 'Type Boost', description: '+20% Ice moves.', typeBoostType: 'ice', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Black Belt', category: 'Type Boost', description: '+20% Fighting moves.', typeBoostType: 'fighting', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Poison Barb', category: 'Type Boost', description: '+20% Poison moves.', typeBoostType: 'poison', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Soft Sand', category: 'Type Boost', description: '+20% Ground moves.', typeBoostType: 'ground', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Sharp Beak', category: 'Type Boost', description: '+20% Flying moves.', typeBoostType: 'flying', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Twisted Spoon', category: 'Type Boost', description: '+20% Psychic moves.', typeBoostType: 'psychic', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Silver Powder', category: 'Type Boost', description: '+20% Bug moves.', typeBoostType: 'bug', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Hard Stone', category: 'Type Boost', description: '+20% Rock moves.', typeBoostType: 'rock', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Spell Tag', category: 'Type Boost', description: '+20% Ghost moves.', typeBoostType: 'ghost', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Dragon Fang', category: 'Type Boost', description: '+20% Dragon moves.', typeBoostType: 'dragon', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Metal Coat', category: 'Type Boost', description: '+20% Steel moves.', typeBoostType: 'steel', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Fairy Feather', category: 'Type Boost', description: '+20% Fairy moves.', typeBoostType: 'fairy', typeBoostMultiplier: 1.2),

    // ── Plates (+20% to specific type, like type gems) ───────────────────────
    HeldItem(name: 'Flame Plate', category: 'Type Boost', description: '+20% Fire moves.', typeBoostType: 'fire', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Splash Plate', category: 'Type Boost', description: '+20% Water moves.', typeBoostType: 'water', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Zap Plate', category: 'Type Boost', description: '+20% Electric moves.', typeBoostType: 'electric', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Meadow Plate', category: 'Type Boost', description: '+20% Grass moves.', typeBoostType: 'grass', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Icicle Plate', category: 'Type Boost', description: '+20% Ice moves.', typeBoostType: 'ice', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Fist Plate', category: 'Type Boost', description: '+20% Fighting moves.', typeBoostType: 'fighting', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Toxic Plate', category: 'Type Boost', description: '+20% Poison moves.', typeBoostType: 'poison', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Earth Plate', category: 'Type Boost', description: '+20% Ground moves.', typeBoostType: 'ground', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Sky Plate', category: 'Type Boost', description: '+20% Flying moves.', typeBoostType: 'flying', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Mind Plate', category: 'Type Boost', description: '+20% Psychic moves.', typeBoostType: 'psychic', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Insect Plate', category: 'Type Boost', description: '+20% Bug moves.', typeBoostType: 'bug', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Stone Plate', category: 'Type Boost', description: '+20% Rock moves.', typeBoostType: 'rock', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Spooky Plate', category: 'Type Boost', description: '+20% Ghost moves.', typeBoostType: 'ghost', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Draco Plate', category: 'Type Boost', description: '+20% Dragon moves.', typeBoostType: 'dragon', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Dread Plate', category: 'Type Boost', description: '+20% Dark moves.', typeBoostType: 'dark', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Iron Plate', category: 'Type Boost', description: '+20% Steel moves.', typeBoostType: 'steel', typeBoostMultiplier: 1.2),
    HeldItem(name: 'Pixie Plate', category: 'Type Boost', description: '+20% Fairy moves.', typeBoostType: 'fairy', typeBoostMultiplier: 1.2),

    // ── Type Gems (+30%, single use — treated as one-time here) ─────────────
    HeldItem(name: 'Fire Gem', category: 'Type Gem', description: '+30% Fire move once.', typeBoostType: 'fire', typeBoostMultiplier: 1.3),
    HeldItem(name: 'Water Gem', category: 'Type Gem', description: '+30% Water move once.', typeBoostType: 'water', typeBoostMultiplier: 1.3),
    HeldItem(name: 'Normal Gem', category: 'Type Gem', description: '+30% Normal move once.', typeBoostType: 'normal', typeBoostMultiplier: 1.3),

    // ── Defender damage-reduction Berries (halve super-effective hits) ───────
    HeldItem(name: 'Occa Berry', category: 'Resist Berry', description: 'Halves Fire damage when super-effective.', resistType: 'fire', resistMultiplier: 0.5),
    HeldItem(name: 'Passho Berry', category: 'Resist Berry', description: 'Halves Water damage when super-effective.', resistType: 'water', resistMultiplier: 0.5),
    HeldItem(name: 'Wacan Berry', category: 'Resist Berry', description: 'Halves Electric damage when super-effective.', resistType: 'electric', resistMultiplier: 0.5),
    HeldItem(name: 'Rindo Berry', category: 'Resist Berry', description: 'Halves Grass damage when super-effective.', resistType: 'grass', resistMultiplier: 0.5),
    HeldItem(name: 'Yache Berry', category: 'Resist Berry', description: 'Halves Ice damage when super-effective.', resistType: 'ice', resistMultiplier: 0.5),
    HeldItem(name: 'Chople Berry', category: 'Resist Berry', description: 'Halves Fighting damage when super-effective.', resistType: 'fighting', resistMultiplier: 0.5),
    HeldItem(name: 'Kebia Berry', category: 'Resist Berry', description: 'Halves Poison damage when super-effective.', resistType: 'poison', resistMultiplier: 0.5),
    HeldItem(name: 'Shuca Berry', category: 'Resist Berry', description: 'Halves Ground damage when super-effective.', resistType: 'ground', resistMultiplier: 0.5),
    HeldItem(name: 'Coba Berry', category: 'Resist Berry', description: 'Halves Flying damage when super-effective.', resistType: 'flying', resistMultiplier: 0.5),
    HeldItem(name: 'Payapa Berry', category: 'Resist Berry', description: 'Halves Psychic damage when super-effective.', resistType: 'psychic', resistMultiplier: 0.5),
    HeldItem(name: 'Tanga Berry', category: 'Resist Berry', description: 'Halves Bug damage when super-effective.', resistType: 'bug', resistMultiplier: 0.5),
    HeldItem(name: 'Charti Berry', category: 'Resist Berry', description: 'Halves Rock damage when super-effective.', resistType: 'rock', resistMultiplier: 0.5),
    HeldItem(name: 'Kasib Berry', category: 'Resist Berry', description: 'Halves Ghost damage when super-effective.', resistType: 'ghost', resistMultiplier: 0.5),
    HeldItem(name: 'Haban Berry', category: 'Resist Berry', description: 'Halves Dragon damage when super-effective.', resistType: 'dragon', resistMultiplier: 0.5),
    HeldItem(name: 'Colbur Berry', category: 'Resist Berry', description: 'Halves Dark damage when super-effective.', resistType: 'dark', resistMultiplier: 0.5),
    HeldItem(name: 'Babiri Berry', category: 'Resist Berry', description: 'Halves Steel damage when super-effective.', resistType: 'steel', resistMultiplier: 0.5),
    HeldItem(name: 'Roseli Berry', category: 'Resist Berry', description: 'Halves Fairy damage when super-effective.', resistType: 'fairy', resistMultiplier: 0.5),
    HeldItem(name: 'Chilan Berry', category: 'Resist Berry', description: 'Halves Normal damage.', resistType: 'normal', resistMultiplier: 0.5),
  ];

  /// Look up an item by name (returns null item if not found).
  static HeldItem? findByName(String name) {
    try {
      return allItems.firstWhere((i) => i.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Calculate the speed multiplier for an attacker's held item.
  static double getSpeedMultiplier(String itemName) {
    return findByName(itemName)?.speedMultiplier ?? 1.0;
  }

  /// Calculate the attack multiplier from a held item for a given move type and isSpecial.
  static double getAttackMultiplier(String itemName, String moveType, bool isSpecial) {
    final item = findByName(itemName);
    if (item == null) return 1.0;

    double mult = 1.0;

    if (isSpecial) {
      mult *= item.spAtkMultiplier;
    } else {
      mult *= item.atkMultiplier;
    }

    // Universal damage (Life Orb, etc.)
    mult *= item.universalDamageMultiplier;

    // Type-boosting items
    if (item.typeBoostType != null &&
        item.typeBoostType!.toLowerCase() == moveType.toLowerCase()) {
      mult *= item.typeBoostMultiplier;
    }

    return mult;
  }

  /// Calculate resistance multiplier from defender's held item.
  /// Resist berries apply only when the move is super-effective (mult > 1.0).
  static double getDefenderResistMultiplier(
      String itemName, String moveType, double typeEffectiveness) {
    final item = findByName(itemName);
    if (item == null) return 1.0;

    if (item.resistType != null &&
        item.resistType!.toLowerCase() == moveType.toLowerCase()) {
      // Berries apply when super-effective, Chilan applies always
      if (typeEffectiveness > 1.0 || item.resistType == 'normal') {
        return item.resistMultiplier;
      }
    }
    return 1.0;
  }

  /// Get defense multipliers (Eviolite, Assault Vest) for a given stat.
  /// statKey: 'def' or 'spd'
  static double getDefenseMultiplier(String itemName, bool isSpecial) {
    final item = findByName(itemName);
    if (item == null) return 1.0;
    return isSpecial ? item.spDefMultiplier : item.defMultiplier;
  }
}

/// A competitive held item definition.
class HeldItem {
  final String name;
  final String category;
  final String description;

  // Stat multipliers applied to the holder
  final double speedMultiplier;
  final double atkMultiplier;
  final double spAtkMultiplier;
  final double defMultiplier;
  final double spDefMultiplier;
  final double universalDamageMultiplier;

  // Type-specific damage boost (attacker)
  final String? typeBoostType;
  final double typeBoostMultiplier;

  // Type-specific damage reduction (defender berry)
  final String? resistType;
  final double resistMultiplier;

  const HeldItem({
    required this.name,
    required this.category,
    required this.description,
    this.speedMultiplier = 1.0,
    this.atkMultiplier = 1.0,
    this.spAtkMultiplier = 1.0,
    this.defMultiplier = 1.0,
    this.spDefMultiplier = 1.0,
    this.universalDamageMultiplier = 1.0,
    this.typeBoostType,
    this.typeBoostMultiplier = 1.0,
    this.resistType,
    this.resistMultiplier = 1.0,
  });
}
