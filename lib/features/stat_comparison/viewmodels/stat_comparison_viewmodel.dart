/// Riverpod state management for the Stat Comparison feature.
///
/// Manages up to six [ComparisonEntry] slots, the active ruleset, display
/// mode, and sort state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';
import 'package:libredex/features/stat_comparison/models/stat_modifier.dart';

/// Sort column for the comparison table.
enum SortColumn {
  hp, atk, def, spa, spd, spe, bst, physBulk, specBulk, effSpeed,
}

/// Sort direction.
enum SortDirection { descending, ascending }

/// Immutable state for the Stat Comparison feature.
class StatComparisonState {
  /// Up to 6 comparison slots. Null means the slot is empty.
  final List<ComparisonEntry?> entries;

  /// Active ruleset (Mainline or Champions).
  final BattleRuleset ruleset;

  /// Whether to show raw build or effective battle stats.
  final ComparisonDisplayMode displayMode;

  /// Current sort column, or null for original order.
  final SortColumn? sortColumn;

  /// Current sort direction.
  final SortDirection sortDirection;

  const StatComparisonState({
    required this.entries,
    this.ruleset = BattleRuleset.mainline,
    this.displayMode = ComparisonDisplayMode.rawBuild,
    this.sortColumn,
    this.sortDirection = SortDirection.descending,
  });

  StatComparisonState copyWith({
    List<ComparisonEntry?>? entries,
    BattleRuleset? ruleset,
    ComparisonDisplayMode? displayMode,
    Object? sortColumn = const _Sentinel(),
    SortDirection? sortDirection,
  }) {
    return StatComparisonState(
      entries: entries ?? this.entries,
      ruleset: ruleset ?? this.ruleset,
      displayMode: displayMode ?? this.displayMode,
      sortColumn: sortColumn is _Sentinel
          ? this.sortColumn
          : sortColumn as SortColumn?,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }

  /// Number of non-null entries.
  int get count => entries.where((e) => e != null).length;

  /// Whether the comparison is empty.
  bool get isEmpty => count == 0;

  /// Computed stats for all non-null entries, in their current order.
  List<({int index, ComparisonEntry entry, ComparisonStats stats})>
      computedEntries() {
    final result = <({int index, ComparisonEntry entry, ComparisonStats stats})>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry == null) continue;
      final stats = displayMode == ComparisonDisplayMode.rawBuild
          ? StatModifier.computeRawStats(entry, ruleset)
          : StatModifier.computeEffectiveStats(entry, ruleset);
      result.add((index: i, entry: entry, stats: stats));
    }
    return result;
  }

  /// Computed entries, sorted by the active sort column.
  List<({int index, ComparisonEntry entry, ComparisonStats stats})>
      sortedEntries() {
    final computed = computedEntries();
    if (sortColumn == null) return computed;

    final col = sortColumn!;
    computed.sort((a, b) {
      final aVal = _sortValue(a.entry, a.stats, col);
      final bVal = _sortValue(b.entry, b.stats, col);
      int cmp = aVal.compareTo(bVal);
      if (cmp == 0) {
        // Tie: preserve original list order, then alphabetical
        cmp = a.index.compareTo(b.index);
        if (cmp == 0) {
          cmp = a.entry.pokemon.name.compareTo(b.entry.pokemon.name);
        }
      }
      return sortDirection == SortDirection.descending ? -cmp : cmp;
    });
    return computed;
  }

  static int _sortValue(
    ComparisonEntry entry,
    ComparisonStats stats,
    SortColumn col,
  ) {
    return switch (col) {
      SortColumn.hp => stats.hp.effectiveStat,
      SortColumn.atk => stats.attack.effectiveStat,
      SortColumn.def => stats.defense.effectiveStat,
      SortColumn.spa => stats.spAtk.effectiveStat,
      SortColumn.spd => stats.spDef.effectiveStat,
      SortColumn.spe => stats.speed.effectiveStat,
      SortColumn.bst => entry.bst,
      SortColumn.physBulk => stats.physicalBulk,
      SortColumn.specBulk => stats.specialBulk,
      SortColumn.effSpeed => stats.speed.effectiveStat,
    };
  }
}

class _Sentinel {
  const _Sentinel();
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final statComparisonProvider =
    NotifierProvider<StatComparisonNotifier, StatComparisonState>(
  StatComparisonNotifier.new,
);

class StatComparisonNotifier extends Notifier<StatComparisonState> {
  static const int maxSlots = 6;

  @override
  StatComparisonState build() {
    return StatComparisonState(
      entries: List<ComparisonEntry?>.filled(maxSlots, null),
    );
  }

  // ── Ruleset ─────────────────────────────────────────────────────────────

  void setRuleset(BattleRuleset ruleset) {
    if (state.ruleset == ruleset) return;

    // Normalize natures: Champions removes 4 neutral natures
    final updated = state.entries.map((entry) {
      if (entry == null) return null;
      if (ruleset.isChampions && !ChampionsRules.isValidAlignment(entry.nature)) {
        return entry.copyWith(nature: 'serious');
      }
      return entry;
    }).toList();

    state = state.copyWith(ruleset: ruleset, entries: updated);
  }

  // ── Display Mode ────────────────────────────────────────────────────────

  void setDisplayMode(ComparisonDisplayMode mode) {
    state = state.copyWith(displayMode: mode);
  }

  // ── Sort ────────────────────────────────────────────────────────────────

  void toggleSort(SortColumn column) {
    if (state.sortColumn == column) {
      // Same column: flip direction, or clear if already ascending
      if (state.sortDirection == SortDirection.descending) {
        state = state.copyWith(sortDirection: SortDirection.ascending);
      } else {
        state = state.copyWith(sortColumn: null);
      }
    } else {
      state = state.copyWith(
        sortColumn: column,
        sortDirection: SortDirection.descending,
      );
    }
  }

  // ── Entry Management ────────────────────────────────────────────────────

  /// Add a Pokémon to the first available slot.
  void addPokemon(Pokemon pokemon, {String? ability}) {
    final entries = List<ComparisonEntry?>.from(state.entries);
    final slot = entries.indexWhere((e) => e == null);
    if (slot == -1) return; // All slots full
    entries[slot] = ComparisonEntry.defaults(pokemon, ability: ability);
    state = state.copyWith(entries: entries);
  }

  /// Replace the Pokémon in a specific slot.
  void replacePokemon(int index, Pokemon pokemon, {String? ability}) {
    if (index < 0 || index >= maxSlots) return;
    final entries = List<ComparisonEntry?>.from(state.entries);
    entries[index] = ComparisonEntry.defaults(pokemon, ability: ability);
    state = state.copyWith(entries: entries);
  }

  /// Remove a Pokémon from a specific slot.
  void removeEntry(int index) {
    if (index < 0 || index >= maxSlots) return;
    final entries = List<ComparisonEntry?>.from(state.entries);
    entries[index] = null;
    state = state.copyWith(entries: entries);
  }

  /// Duplicate the build at [index] into the next available slot.
  void duplicateEntry(int index) {
    if (index < 0 || index >= maxSlots) return;
    final source = state.entries[index];
    if (source == null) return;
    final entries = List<ComparisonEntry?>.from(state.entries);
    final slot = entries.indexWhere((e) => e == null);
    if (slot == -1) return;
    entries[slot] = source.copyWith();
    state = state.copyWith(entries: entries);
  }

  /// Update the entry at [index].
  void updateEntry(int index, ComparisonEntry entry) {
    if (index < 0 || index >= maxSlots) return;
    final entries = List<ComparisonEntry?>.from(state.entries);
    entries[index] = entry;
    state = state.copyWith(entries: entries);
  }

  /// Clear all entries.
  void clearAll() {
    state = state.copyWith(
      entries: List<ComparisonEntry?>.filled(maxSlots, null),
    );
  }

  /// Load the team from Team Builder into comparison slots.
  void loadFromTeam(List<Pokemon> teamPokemon) {
    final entries = List<ComparisonEntry?>.filled(maxSlots, null);
    for (var i = 0; i < teamPokemon.length && i < maxSlots; i++) {
      entries[i] = ComparisonEntry.defaults(teamPokemon[i]);
    }
    state = state.copyWith(entries: entries);
  }

  /// Reorder: move entry from [oldIndex] to [newIndex].
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final nonNull = state.entries
        .asMap()
        .entries
        .where((e) => e.value != null)
        .toList();
    if (oldIndex >= nonNull.length || newIndex >= nonNull.length) return;
    final item = nonNull.removeAt(oldIndex);
    nonNull.insert(newIndex, item);
    final entries = List<ComparisonEntry?>.filled(maxSlots, null);
    for (var i = 0; i < nonNull.length; i++) {
      entries[i] = nonNull[i].value;
    }
    state = state.copyWith(entries: entries);
  }
}
