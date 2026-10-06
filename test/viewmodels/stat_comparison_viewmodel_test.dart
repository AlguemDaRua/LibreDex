import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';
import 'package:libredex/features/stat_comparison/viewmodels/stat_comparison_viewmodel.dart';

Pokemon mon(int id, String name, {int atk = 50, int spe = 50, int hp = 50}) =>
    Pokemon(
      id: id,
      name: name,
      form: 'normal',
      type1: 'normal',
      type2: null,
      baseHp: hp,
      baseAtk: atk,
      baseDef: 50,
      baseSpAtk: 50,
      baseSpDef: 50,
      baseSpd: spe,
      isLegendary: false,
      isMythical: false,
      isParadox: false,
      isUltraBeast: false,
      spriteUrl: '',
      shinySpriteUrl: '',
      nationalDexNumber: id,
      generation: 1,
      evolutionStage: 1,
      isChampions: false,
      isLegendsZA: false,
    );

final fast = mon(1, 'FastMon', spe: 120);
final slow = mon(2, 'SlowMon', spe: 40);
final mid = mon(3, 'MidMon', spe: 80);

void main() {
  group('StatComparisonState', () {
    test('count ignores empty slots', () {
      final state = StatComparisonState(
        entries: [
          ComparisonEntry.defaults(fast),
          null,
          ComparisonEntry.defaults(slow),
          null,
          null,
          null,
        ],
      );
      expect(state.count, 2);
      expect(state.isEmpty, isFalse);
    });

    test('an all-null list is empty', () {
      final state = StatComparisonState(
        entries: List<ComparisonEntry?>.filled(6, null),
      );
      expect(state.count, 0);
      expect(state.isEmpty, isTrue);
    });

    test('copyWith can clear the sort column through the sentinel', () {
      final state = StatComparisonState(
        entries: const [],
        sortColumn: SortColumn.spe,
      );
      // Omitting sortColumn leaves it alone; passing null clears it. The
      // sentinel is the only way to tell those two apart.
      expect(state.copyWith().sortColumn, SortColumn.spe);
      expect(state.copyWith(sortColumn: null).sortColumn, isNull);
    });

    test('copyWith does not mutate the original', () {
      final state = StatComparisonState(
        entries: List<ComparisonEntry?>.filled(6, null),
      );
      state.copyWith(sortColumn: SortColumn.atk);
      expect(state.sortColumn, isNull);
    });
  });

  group('computedEntries', () {
    test('skips null slots but keeps the original index', () {
      final state = StatComparisonState(
        entries: [
          null,
          ComparisonEntry.defaults(fast),
          null,
          ComparisonEntry.defaults(slow),
          null,
          null,
        ],
      );
      final computed = state.computedEntries();
      expect(computed.length, 2);
      expect(computed.first.index, 1);
      expect(computed.last.index, 3);
    });

    test('preserves slot order when unsorted', () {
      final state = StatComparisonState(
        entries: [
          ComparisonEntry.defaults(slow),
          ComparisonEntry.defaults(fast),
          ComparisonEntry.defaults(mid),
          null,
          null,
          null,
        ],
      );
      expect(state.sortedEntries().map((e) => e.entry.pokemon.name).toList(), [
        'SlowMon',
        'FastMon',
        'MidMon',
      ]);
    });
  });

  group('sortedEntries', () {
    StatComparisonState withThree() => StatComparisonState(
      entries: [
        ComparisonEntry.defaults(slow),
        ComparisonEntry.defaults(fast),
        ComparisonEntry.defaults(mid),
        null,
        null,
        null,
      ],
    );

    test('defaults to descending', () {
      final state = withThree().copyWith(sortColumn: SortColumn.spe);
      expect(state.sortedEntries().map((e) => e.entry.pokemon.name).toList(), [
        'FastMon',
        'MidMon',
        'SlowMon',
      ]);
    });

    test('honours ascending', () {
      final state = withThree().copyWith(
        sortColumn: SortColumn.spe,
        sortDirection: SortDirection.ascending,
      );
      expect(state.sortedEntries().map((e) => e.entry.pokemon.name).toList(), [
        'SlowMon',
        'MidMon',
        'FastMon',
      ]);
    });

    test('ties fall back to slot order, keeping the list stable', () {
      // Three identical Pokémon: the sort must not shuffle them, or rows
      // would jump around every time the user changes a column.
      final state = StatComparisonState(
        entries: [
          ComparisonEntry.defaults(mon(10, 'A', spe: 50)),
          ComparisonEntry.defaults(mon(11, 'B', spe: 50)),
          ComparisonEntry.defaults(mon(12, 'C', spe: 50)),
          null,
          null,
          null,
        ],
        sortColumn: SortColumn.spe,
      );
      expect(state.sortedEntries().map((e) => e.entry.pokemon.name).toList(), [
        'A',
        'B',
        'C',
      ]);
    });

    test('every sort column produces a value without throwing', () {
      final state = withThree();
      for (final col in SortColumn.values) {
        final sorted = state.copyWith(sortColumn: col).sortedEntries();
        expect(sorted.length, 3, reason: '$col dropped entries');
      }
    });
  });

  group('StatComparisonNotifier', () {
    late ProviderContainer container;
    StatComparisonNotifier notifier() =>
        container.read(statComparisonProvider.notifier);
    StatComparisonState current() => container.read(statComparisonProvider);

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('starts with six empty slots', () {
      expect(current().entries.length, 6);
      expect(current().isEmpty, isTrue);
    });

    test('addPokemon fills the first free slot', () {
      notifier().addPokemon(fast);
      expect(current().entries[0]?.pokemon.name, 'FastMon');
      notifier().addPokemon(slow);
      expect(current().entries[1]?.pokemon.name, 'SlowMon');
      expect(current().count, 2);
    });

    test('adding beyond the sixth slot is ignored', () {
      for (var i = 0; i < 10; i++) {
        notifier().addPokemon(mon(i, 'Mon$i'));
      }
      expect(current().count, 6);
    });

    test('removeEntry clears only that slot', () {
      notifier().addPokemon(fast);
      notifier().addPokemon(slow);
      notifier().removeEntry(0);
      expect(current().entries[0], isNull);
      expect(current().entries[1]?.pokemon.name, 'SlowMon');
      expect(current().count, 1);
    });

    test('addPokemon reuses a slot freed by removal', () {
      notifier().addPokemon(fast);
      notifier().addPokemon(slow);
      notifier().removeEntry(0);
      notifier().addPokemon(mid);
      expect(current().entries[0]?.pokemon.name, 'MidMon');
      expect(current().count, 2);
    });

    test('out-of-range indices are ignored rather than throwing', () {
      notifier().addPokemon(fast);
      notifier().removeEntry(99);
      notifier().removeEntry(-1);
      notifier().replacePokemon(99, slow);
      expect(current().count, 1);
    });

    test('duplicateEntry copies into the next free slot', () {
      notifier().addPokemon(fast);
      notifier().duplicateEntry(0);
      expect(current().count, 2);
      expect(current().entries[1]?.pokemon.name, 'FastMon');
    });

    test('duplicating an empty slot does nothing', () {
      notifier().duplicateEntry(0);
      expect(current().count, 0);
    });

    test('duplicating when full does nothing', () {
      for (var i = 0; i < 6; i++) {
        notifier().addPokemon(mon(i, 'Mon$i'));
      }
      notifier().duplicateEntry(0);
      expect(current().count, 6);
    });

    test('clearAll empties every slot', () {
      notifier().addPokemon(fast);
      notifier().addPokemon(slow);
      notifier().clearAll();
      expect(current().isEmpty, isTrue);
    });

    test('loadFromTeam replaces everything and caps at six', () {
      notifier().addPokemon(fast);
      notifier().loadFromTeam([for (var i = 0; i < 9; i++) mon(i, 'Team$i')]);
      expect(current().count, 6);
      expect(current().entries[0]?.pokemon.name, 'Team0');
    });

    test('reorder moves an entry and compacts the slots', () {
      notifier().addPokemon(fast);
      notifier().addPokemon(slow);
      notifier().addPokemon(mid);
      notifier().reorder(2, 0);
      expect(current().entries.map((e) => e?.pokemon.name).take(3).toList(), [
        'MidMon',
        'FastMon',
        'SlowMon',
      ]);
    });

    test('toggleSort cycles descending, ascending, then off', () {
      notifier().addPokemon(fast);
      notifier().addPokemon(slow);

      notifier().toggleSort(SortColumn.spe);
      expect(current().sortColumn, SortColumn.spe);
      expect(current().sortDirection, SortDirection.descending);

      notifier().toggleSort(SortColumn.spe);
      expect(current().sortDirection, SortDirection.ascending);

      notifier().toggleSort(SortColumn.spe);
      expect(current().sortColumn, isNull);
    });

    test('toggleSort on a new column starts descending again', () {
      notifier().addPokemon(fast);
      notifier().toggleSort(SortColumn.spe);
      notifier().toggleSort(SortColumn.spe); // now ascending
      notifier().toggleSort(SortColumn.atk);
      expect(current().sortColumn, SortColumn.atk);
      expect(current().sortDirection, SortDirection.descending);
    });
  });
}
