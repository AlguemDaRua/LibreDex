# Database schema, migrations, and bundled-data refreshes

LibreDex uses [Drift](https://drift.simonbinder.eu/) over SQLite for its on-device reference database. The schema and bundled JSON assets have separate version numbers: `AppDatabase.schemaVersion` governs SQL migrations, while `SyncRepository.bundledDataVersion` governs when an installed app re-seeds updated reference data.

## Current versions

| Version | Location | Purpose |
| --- | --- | --- |
| **Schema 5** | `lib/core/database/app_database.dart` | SQLite tables and columns; upgraded by Drift. |
| **Bundle 5** | `SyncRepository.bundledDataVersion` | Pokémon, move, ability, learnset, overlay, and metadata assets copied into Drift. |

A schema change and an asset-only update do not necessarily need the same version bump. Increment the schema version when a table or column changes; increment the bundled-data version when seeded asset content or decoding behavior changes. The sync history is documented next to `bundledDataVersion` in `sync_repository.dart`.

## Tables and relationships

1. **`pokemon_table`** — species/form identity, types, base stats, source tags, generation, egg groups, baby/evolution metadata, and sprites.
2. **`move_table`** — move identity, class, power/accuracy/PP, priority, battle traits, generation, and explicit source flags.
3. **`ability_table`** — ability descriptions, generation, source labels, effect tags, and game-specific metadata.
4. **`pokemon_moves_table`** — Pokémon–move junction keyed by `(pokemonId, moveId, learnMethod)` so one move may be available through several methods.
5. **`pokemon_abilities_table`** — Pokémon–ability junction keyed by `(pokemonId, abilityId)`, with `isHidden` stored on this relationship.

Reverse-lookup and common filter indexes are created in `beforeOpen` (Pokémon/move/ability names, forms, types, generation and National Dex number, move class/power/priority, and junction foreign keys). Indexes are single-column; they are not composite indexes.

### Important data ownership rules

- `pokemon_abilities_table.isHidden` is authoritative for whether an ability is hidden **for that Pokémon**. An ability can be hidden for one Pokémon and standard for another. `ability_table.isHiddenAbility` is only a record-level summary and must not replace the junction value in filters or detail pages.
- `move_table.priority` and `move_table.isContact` are persisted move facts. Battle calculations and MoveDex filters read those same fields rather than maintaining a separate hard-coded list.
- Pokémon generation, evolution depth, egg groups, and evolution capability are explicit data fields. UI filters should not reconstruct them from a National Dex number or display-name pattern.
- Regulation membership (for example M-C) comes from its separate ID catalog. It is not a schema-level game-origin flag.

## Schema version history

- **Version 1** — initial Pokémon, move, ability, and junction tables.
- **Version 2** — nullable move descriptions.
- **Version 3** — National Dex number on Pokémon rows.
- **Version 4** — source and battle metadata:
  - Pokémon: generation, evolution stage, egg groups, form/DLC source, Champions and Legends: Z-A source flags.
  - Moves: priority; contact, damage-class, and battle-trait flags; generation and explicit source flags.
  - Abilities: generation, source labels, effect tags, and record-level hidden/game metadata.
- **Version 5** — `pokemon_table.isBaby`, `pokemon_table.hasEvolution`, and `pokemon_table.evolutionMethods`, populated from the bundled species/evolution metadata.

## Upgrade behavior

Drift applies `onUpgrade` steps in order. The `from < N` guards let an older install move through all applicable schema versions without dropping its tables. New non-null columns use documented defaults; nullable metadata remains null when the source does not provide it.

The application separately re-seeds bundled reference rows when `bundledDataVersion` increases. That refresh runs in a transaction: junction rows and the Pokémon/move/ability tables are rebuilt together so old learnsets and obsolete relationships do not remain mixed with new seeded assets. ItemDex currently reads its JSON asset directly rather than storing item rows in Drift. Favorites, teams, settings, and other preferences are outside these seeded tables and are preserved by the refresh.

A user-requested **Rebuild local database** performs the same reference-data reseed. It is safe to run after an asset fix, but it does not delete artwork stored by the offline artwork service.

## Migration maintenance checklist

1. Add or change the Drift table definition.
2. Increment `schemaVersion` and add the matching guarded `onUpgrade` migration; never edit an old migration to assume it has not shipped.
3. Regenerate `app_database.g.dart` with Drift's builder when available.
4. If bundled rows or decoding behavior changed, increment `bundledDataVersion` too.
5. Confirm a fresh database and an older-version upgrade both retain valid Pokémon, move, ability, and junction references.
6. Review the changed data asset and migration together. A schema migration does not refresh bundled rows, and a bundle-version bump does not add SQL columns.

For the generated-asset workflow and provenance policy, see [Data pipeline](data-pipeline.md). For the current Champions catalog, see [Champions support](champions-support.md).
