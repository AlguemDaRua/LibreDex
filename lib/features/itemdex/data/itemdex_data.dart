import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/features/itemdex/models/itemdex_entry.dart';

final itemDexProvider = FutureProvider<List<ItemDexEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/items.json');
  return compute(_decodeItems, raw);
});

List<ItemDexEntry> _decodeItems(String raw) {
  final rows = jsonDecode(raw) as List<dynamic>;
  return rows
      .map((row) => ItemDexEntry.fromJson(row as Map<String, dynamic>))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));
}
