import 'package:flutter_test/flutter_test.dart';
import 'package:libredex/core/navigation/section_back_stack.dart';

void main() {
  group('SectionBackStack', () {
    test('starts at the Pokédex root with an empty stack', () {
      final backStack = SectionBackStack();
      expect(backStack.current, SectionBackStack.rootIndex);
      expect(backStack.stack, isEmpty);
      expect(backStack.goBack(), isNull, reason: 'back at root must exit');
    });

    test('drawer navigation chains back in reverse order', () {
      final backStack = SectionBackStack();
      backStack
        ..record(4) // Pokédex → ItemDex
        ..record(2) // ItemDex → MoveDex
        ..record(6); // MoveDex → Type Chart

      expect(backStack.goBack(), 2);
      expect(backStack.goBack(), 4);
      expect(backStack.goBack(), isNull, reason: 'root reached, history drained');
      expect(backStack.current, SectionBackStack.rootIndex);
    });

    test('the Team Builder → Calculator shortcut back-tracks to Team Builder', () {
      final backStack = SectionBackStack();
      backStack
        ..record(1) // Pokédex → Team Builder
        ..record(7); // "Open in calculator" shortcut

      expect(backStack.goBack(), 1, reason: 'back from the calculator must return to the team');
      expect(backStack.goBack(), isNull);
    });

    test('recording the same section twice is a no-op', () {
      final backStack = SectionBackStack();
      backStack
        ..record(7)
        ..record(7)
        ..record(7);
      expect(backStack.stack.length, 1);
      expect(backStack.goBack(), isNull);
    });

    test('reaching the root through normal navigation clears the history', () {
      final backStack = SectionBackStack();
      backStack
        ..record(1)
        ..record(7)
        ..record(SectionBackStack.rootIndex); // user tapped "Pokédex" in the drawer

      expect(backStack.current, SectionBackStack.rootIndex);
      expect(backStack.stack, isEmpty, reason: 'back from home exits, never teleports');
      expect(backStack.goBack(), isNull);
    });

    test('going back to a duplicated section does not re-record loops', () {
      final backStack = SectionBackStack();
      backStack
        ..record(1)
        ..record(7);
      backStack.goBack(); // → 1, stack already consistent
      expect(backStack.stack, isEmpty);
      expect(backStack.goBack(), isNull);
    });

    test('restored sections can still back out to the root', () {
      final backStack = SectionBackStack();
      // Mirrors the persisted last-index restore on a cold start.
      backStack.record(8);
      expect(backStack.goBack(), SectionBackStack.rootIndex);
      expect(backStack.goBack(), isNull);
    });
  });
}
