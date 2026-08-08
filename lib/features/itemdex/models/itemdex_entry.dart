class ItemDexEntry {
  final int id;
  final String name;
  final String category;
  final String subcategory;
  final String shortEffect;
  final String description;
  final List<String> tags;

  /// Official PokéAPI item artwork, keyed by the stable item id.
  String get iconUrl => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '')}.png';

  String get spriteUrl => iconUrl;

  int get generation {
    if (id >= 10000) return 9;
    if (id > 1000) return 9;
    if (id > 800) return 8;
    if (id > 600) return 7;
    if (id > 400) return 6;
    if (id > 300) return 5;
    if (id > 200) return 4;
    if (id > 150) return 3;
    if (id > 100) return 2;
    return 1;
  }

  String get introducedIn => 'Generation ${generation.toString()}';

  bool get isHeldItem => category.toLowerCase() == 'held item' || tags.contains('held');
  bool get isBattleItem => tags.contains('battle') || subcategory.toLowerCase().contains('battle') || category.toLowerCase() == 'battle-item';
  bool get isEvolutionItem => tags.contains('evolution') || subcategory.toLowerCase().contains('evolution') || name.toLowerCase().contains('stone');
  bool get isDLCItem => name.toLowerCase().contains('terastal') || name.toLowerCase().contains('booster') || id > 1000;
  bool get isChampionsItem => id >= 10000;
  bool get isLegendsZAItem => name.toLowerCase().contains('mega stone') || name.toLowerCase().contains('z-crystal') || name.toLowerCase().contains('mega');

  List<String> get effectTags => tags;
  List<String> get pokemonRestrictions => [];

  const ItemDexEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.shortEffect,
    required this.description,
    required this.tags,
  });

  factory ItemDexEntry.fromJson(Map<String, dynamic> json) {
    return ItemDexEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      shortEffect: json['shortEffect'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[]).cast<String>(),
    );
  }
}
