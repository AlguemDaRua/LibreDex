# Testing LibreDex

LibreDex has automated test coverage across unit, widget, and asset validation layers.

## Test Directory Structure
- `test/complete_improvement_plan_test.dart`: Verifies the 27 move properties, 7 Pokémon properties, and ability classifications.
- `test/battle_engine_test.dart`: Tests mainline damage calculation.
- `test/champions_ruleset_test.dart`: Verifies custom Champions mechanics.
- `test/forms_extra_asset_test.dart`: Ensures overlay assets have correct formats.

## Running Tests
Run the standard Flutter test runner:
```bash
flutter test
```

Or execute specific tests:
```bash
flutter test test/complete_improvement_plan_test.dart
```
