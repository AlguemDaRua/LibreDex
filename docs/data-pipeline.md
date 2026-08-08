# LibreDex Data Pipeline

LibreDex is fully offline-capable, which means all Pokemon species, moves, abilities, and item data are bundled as offline assets and parsed upon first launching the application.

## Bundled Data Sources
Reference data is sourced from:
1. **PokéAPI**: Standard stats, types, generations, descriptions, and learning methods.
2. **Pokémon Showdown**: Current move priorities, contact flags, and battle mechanics.
3. **Curated Overlays**: Custom rulesets, stats alignments, and Legends: Z-A Effort Level rules.

## Synchronization Pipeline
The pipeline runs on Python scripts under `tools/` and a Dart seeding repository:
- `tools/generate_seed.dart`: Pulls moves and abilities via GraphQL from PokeAPI.
- `tools/audit_libredex_data.py`: Validates references and checks for duplicate IDs.
- `lib/features/pokedex/repositories/sync_repository.dart`: Erases old database tables and feeds raw JSONs into Drift tables during cold boots or version upgrades.

## Updating Reference Datasets
To update the offline datasets:
1. Re-run `tools/generate_seed.dart` to fetch newer moves and abilities.
2. Run `tools/audit_libredex_data.py` to confirm alignment and link safety.
3. Increment `bundledDataVersion` inside `sync_repository.dart` to trigger an automatic database rebuild upon the next app startup.
