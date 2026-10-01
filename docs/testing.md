# Testing LibreDex

This guide separates **structural asset validators** (Python scripts that check selected JSON/data invariants) from **Flutter tests** (Dart unit/widget behavior) and from the final device/release checks. A validator or a test passing does not prove every source claim or every in-game mechanic.

## 🧪 Flutter test inventory

Focused suites include:

| File | Main coverage |
| --- | --- |
| `test/battle_engine_test.dart` | Battle-engine damage results, critical stat-stage behavior, Body Press/Foul Play stat source cases, and data-backed move effects. |
| `test/damage_math_test.dart`, `test/showdown_parity_test.dart`, `test/showdown_parser_test.dart`, `test/move_gimmicks_test.dart` | Integer damage math, selected Showdown comparisons/parsing, and move-specific gimmicks. |
| `test/champions_ruleset_test.dart`, `test/champions_regulation_test.dart` | Champions rules and the ID-based M-C catalog/delta. |
| `test/itemdex_entry_test.dart` | Mega Stone records/provenance, the Roseli Berry alias, and separation of M-C eligibility from origin. |
| `test/forms_extra_asset_test.dart`, `test/sprite_urls_asset_test.dart`, `test/species_gender_overrides_test.dart` | Curated overlay fields, known sprite URL exceptions, and species-level gender data. |
| `test/randomizer_settings_test.dart`, `test/random_roll_overlay_test.dart` | Randomizer settings persistence/criteria and the roll overlay. |
| `test/pokemon_detail_render_test.dart`, `test/section_back_stack_test.dart`, `test/widget_test.dart` | Selected detail rendering, navigation back-stack behavior, and app widget behavior. |
| `test/complete_improvement_plan_test.dart` | Existing MoveDex/AbilityDex/Pokédex metadata checks; consult the source for the current assertions rather than relying on historical counts in older notes. |

Run the full suite from the repository root:

```bash
flutter test
```

Run one focused suite while debugging:

```bash
flutter test test/battle_engine_test.dart
flutter test test/itemdex_entry_test.dart
flutter test test/champions_regulation_test.dart
```

## 🗃 Asset validators

The source and scope of each Python validator are documented in [Data pipeline and provenance](data-pipeline.md). Run the relevant scripts after changing JSON/source assets:

```bash
python3 tools/audit_libredex_data.py
python3 tools/validate_champions_data.py
python3 tools/validate_forms_catalog.py
python3 tools/validate_learnsets.py
python3 tools/validate_move_properties.py
```

These scripts are intentionally not treated as complete semantic proofs. For example, `validate_move_properties.py` checks names/types/damage classes, not whether every move trait is correct in every game.

## 🧰 Formatting and static analysis

Before release, format the changed Dart code and run analysis:

```bash
dart format lib test
flutter analyze
```

To check that formatting would not change tracked Dart files without writing them, use:

```bash
dart format --set-exit-if-changed lib test
```

Use the project's Flutter/Dart SDK version from `pubspec.yaml`/CI; do not regenerate Drift output with a different incompatible version.

## 📱 Device and manual checks

- Test narrow phone layout and wide/tablet layout at the actual **700 logical-pixel** adaptive-navigation threshold.
- Confirm the Pokédex count is species-based while detail navigation retains all matching forms; result-count announcements should be available to assistive technology.
- Exercise every filter's individual chip removal and **Clear all**, especially the no-query `Hidden Ability Only` filter and all MoveDex property switches.
- Check M-C availability versus origin labels independently in Pokédex, MoveDex, AbilityDex, and ItemDex.
- Verify item alias visibility/search, unknown-generation sorting, Mega Stone categories, and bulk download totals against unique non-alias artwork URLs.
- Test randomizer `Everything`, `Active Dex Search & Filters`, and `Custom Criteria Rules`, including empty pools, persisted settings, instant tap, and long-press customization.
- Test online evolution lookup, offline fallback, complete branches in both directions, and form-specific navigation.
- Confirm the main battle view uses one engine result for the summary; verify the raw sandbox remains a separate surface.
- Test real device sizing, screen readers, touch targets, network failure, cached artwork, and user-requested offline artwork.

## ⚠️ Current verification status

The implementation pass documented in [`audit-implementation.md`](audit-implementation.md) intentionally did **not** run Flutter tests, `dart format`, or `flutter analyze`, in keeping with the request to leave that verification for later review. The new/updated regression tests are present but are not claimed as passing. Run the commands above before treating the branch as release-verified.
