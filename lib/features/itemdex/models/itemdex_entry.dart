class ItemDexEntry {
  final int id;
  final String name;
  final String category;
  final String subcategory;
  final String shortEffect;
  final String description;
  final List<String> tags;

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
