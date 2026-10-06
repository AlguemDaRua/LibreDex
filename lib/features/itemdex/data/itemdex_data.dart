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
  final entries =
      rows
          .map((row) => ItemDexEntry.fromJson(row as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  // Upstream re-issues the same item under a fresh id across game versions, so
  // the bundled data contains rows that share a name - "Bike" twice, "Basement
  // Key" three times, most Z-Crystals twice. Browsing listed every one.
  //
  // Keep the lowest id as canonical and point the rest at it. That reuses the
  // aliasOf mechanism the UI already understands: duplicates disappear from
  // ordinary browsing but stay reachable by id or via the aliases filter.
  final canonicalIdByName = <String, int>{};
  for (final entry in entries) {
    if (entry.isAlias) continue;
    final current = canonicalIdByName[entry.name];
    if (current == null || entry.id < current) {
      canonicalIdByName[entry.name] = entry.id;
    }
  }

  return entries.map((entry) {
    if (entry.isAlias) return entry;
    final canonical = canonicalIdByName[entry.name];
    if (canonical == null || canonical == entry.id) return entry;
    return entry.withAliasOf(canonical);
  }).toList();
}
