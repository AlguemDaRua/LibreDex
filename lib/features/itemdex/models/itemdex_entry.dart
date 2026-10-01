class ItemDexEntry {
  final int id;
  final String name;
  final String category;
  final String subcategory;
  final String shortEffect;
  final String description;
  final List<String> tags;
  final int? generation;
  final String? dlcSource;

  /// Upstream occasionally publishes placeholder records under duplicate names.
  /// Keep the row and its curated text, but point the UI at its canonical item.
  final int? aliasOf;

  /// Official PokéAPI item artwork, keyed by the stable item id.
  String get iconUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '')}.png';

  String get spriteUrl => iconUrl;

  String get introducedIn =>
      generation == null ? 'Release unknown' : 'Generation $generation';

  bool get isAlias => aliasOf != null;

  bool get isHeldItem =>
      _hasAnyTag(const {'holdable', 'holdable active', 'holdable passive'}) ||
      _isCategory('held items');

  bool get isBattleItem =>
      _hasTag('usable in battle') ||
      _isCategory('battle items') ||
      _normalized(subcategory) == 'battle items';

  bool get isEvolutionItem =>
      _hasTag('evolution') ||
      _hasTag('mega stone') ||
      _isCategory('evolution') ||
      _isCategory('mega stones');

  /// Release provenance is explicit item metadata; it is never inferred from
  /// the item ID, category, or Regulation M-C eligibility.
  bool get isDLCItem =>
      (dlcSource?.trim().isNotEmpty ?? false) ||
      _hasAnyTag(const {
        'dlc',
        'downloadable content',
        'scarlet violet dlc',
        'scarlet and violet dlc',
        'the teal mask',
        'teal mask',
        'the indigo disk',
        'indigo disk',
      });

  /// Regulation eligibility and game origin are separate facts. Only explicit
  /// provenance tags identify an item as having originated in Champions.
  bool get isChampionsItem => _hasAnyTag(const {
        'champions',
        'pokemon champions',
      });

  bool get isLegendsZAItem => _hasAnyTag(const {
        'legends za',
        'pokemon legends za',
        'pokemon legends z a',
      });

  List<String> get effectTags => tags;
  List<String> get pokemonRestrictions => const [];

  bool _isCategory(String expected) =>
      _normalized(category) == _normalized(expected);

  bool _hasTag(String expected) => _hasAnyTag({expected});

  bool _hasAnyTag(Set<String> expected) => tags.any(
        (tag) => expected.any((value) => _normalized(tag) == _normalized(value)),
      );

  static String _normalized(String value) => value
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();

  const ItemDexEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.shortEffect,
    required this.description,
    required this.tags,
    this.generation,
    this.dlcSource,
    this.aliasOf,
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
      generation: (json['generation'] as num?)?.toInt(),
      dlcSource: json['dlcSource'] as String?,
      aliasOf: (json['aliasOf'] as num?)?.toInt(),
    );
  }
}
