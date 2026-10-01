# LibreDex release checklist

Use this checklist for a release candidate. A checked item means it was actually performed against the candidate build; do not copy a previous release's checkmarks forward.

## 1. 🗃 Data, provenance, and asset integrity

- [ ] Confirm the data snapshot date/game version and recheck official game/regulation updates.
- [ ] Record upstream PokéAPI CSV commit/retrieval date when refreshing vendored tables; record community source commit and license where applicable.
- [ ] Confirm M-C eligibility remains separate from game-origin/provenance flags and that no numeric-ID inference was introduced.
- [ ] Confirm existing Mega Stone rows were enriched rather than duplicated or dropped; verify explicit item aliases and unknown generations.
- [ ] Run `python3 tools/audit_libredex_data.py`.
- [ ] Run the relevant specialized validators: `validate_champions_data.py`, `validate_forms_catalog.py`, `validate_learnsets.py`, and `validate_move_properties.py`.
- [ ] Review every generated JSON diff; check for duplicate/missing IDs, stale learnsets, move PP changes, ability mappings, form metadata, and false provenance.
- [ ] Check artwork URLs and offline storage behavior; distinguish attempted, succeeded, failed, and unique non-alias artwork counts.

## 2. 🗃 Drift database and migration

- [ ] Increment Drift `schemaVersion` and add guarded migration code if a table/column/index changed.
- [ ] Regenerate `app_database.g.dart` with the compatible Drift builder.
- [ ] Increment `SyncRepository.bundledDataVersion` when seeded reference content/decoding changed.
- [ ] Test fresh install, migration from supported older schema versions, and bundled-data reseed.
- [ ] Confirm transaction rollback behavior and that favorites/team/preferences survive a reference-data rebuild.

## 3. 🧪 Automated tests and code quality

- [ ] Run `dart format lib test` and review any formatting diff.
- [ ] Run `flutter analyze` and resolve relevant new issues.
- [ ] Run `flutter test` and all focused tests listed in [Testing](testing.md).
- [ ] Retain logs/results for the release record; do not describe unrun checks as passed.

## 4. 📱 UI, accessibility, and responsive behavior

- [ ] Test phones below **700 logical pixels** and tablet/wide layouts at and above **700 logical pixels**.
- [ ] Confirm navigation destinations, overflow FeatureHub targets, back-stack behavior, and selected-section metadata are consistent.
- [ ] Confirm Pokédex result count is unique species-by-National-Dex, while MoveDex/AbilityDex/ItemDex counts describe filtered record rows.
- [ ] Test active filter chips and reset behavior, including hidden ability without a text query and all MoveDex property switches.
- [ ] Test randomizer pool modes, criteria, empty-state behavior, instant roll, and long-press customization.
- [ ] Confirm form groups/branches and both evolution directions are navigable online and offline.
- [ ] Verify screen-reader result announcements, minimum **44 × 44 logical-pixel** touch targets, contrast, and keyboard behavior where applicable.

## 5. ⚔️ Battle behavior

- [ ] Confirm mainline and Champions rulesets remain isolated where required.
- [ ] Confirm persisted priority/contact flags reach the picker and engine consistently.
- [ ] Exercise critical hit stage handling, Body Press, Foul Play, Aura Guard, and M-C PP overrides.
- [ ] Confirm the duel summary renders the existing `DamageResult` without a duplicate engine calculation; keep the raw sandbox explicitly separate.
- [ ] Compare selected cases against trusted mechanics references and record the cases/versions used.

## 6. 📦 Release documentation

- [ ] Update [Champions support](champions-support.md), [Legends: Z-A support](legends-za-support.md), and [Data pipeline](data-pipeline.md) when sources or game support change.
- [ ] Update [Database migrations](database-migrations.md) whenever the schema or seed behavior changes.
- [ ] Update the data snapshot date and source attribution; distinguish official sources from community corroboration.
- [ ] Check [`NOTICE.md`](../NOTICE.md), README, and build metadata.

## Current branch status

The current implementation work intentionally has no claim of passing Flutter tests, formatting, or analysis; those remain unchecked until the requested review/verification is performed. See [Testing](testing.md).
