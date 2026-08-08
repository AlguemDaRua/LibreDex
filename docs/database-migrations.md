# Database Migrations and Schema Upgrades

LibreDex uses Drift as its local SQLite-backed ORM wrapper.

## Current Schema Version: 4

The local schema is structured across five tables with corresponding multi-column reverse indices to optimize query response times:

1. `pokemon_table`
2. `move_table`
3. `ability_table`
4. `pokemon_moves_table` (Junction Table)
5. `pokemon_abilities_table` (Junction Table)

## Schema Version History

- **Version 1**: Initial release containing standard species stats, types, and sprite assets.
- **Version 2**: Added full move descriptions (`moveTable.description`).
- **Version 3**: Added support for standard National Dex IDs (`pokemonTable.nationalDexNumber`).
- **Version 4** (Latest):
  - **Pokemon**: Added `generation`, `evolutionStage`, `eggGroups`, `formSource`, `dlcSource`, `isChampions`, and `isLegendsZA`.
  - **Moves**: Added `priority`, `isContact`, `isHealing`, `isSound`, `isPunching`, `isBiting`, `isPowder`, `isPulse`, `isBallistic`, `isSlicing`, `isWind`, `isDance`, `isMultiHit`, `isProtective`, `isSwitching`, `isRecharge`, `isRecoil`, `isDraining`, `isStatusMove`, `isDamagingMove`, `isSignatureMove`, `isDLCMove`, `isChampionsMove`, `isLegendsZAMove`, `generation`, and `introducedIn`.
  - **Abilities**: Added `generation`, `isHiddenAbility`, `isChampionsAbility`, `isLegendsZAAbility`, `introducedIn`, `sourceGames`, `effectTags`, `battleEffectTags`, and `pokemonTypes`.

## Code Example: Migration Path (v3 to v4)
```dart
if (from < 4) {
  // Add columns to pokemonTable
  await m.addColumn(pokemonTable, pokemonTable.generation);
  await m.addColumn(pokemonTable, pokemonTable.evolutionStage);
  await m.addColumn(pokemonTable, pokemonTable.eggGroups);
  await m.addColumn(pokemonTable, pokemonTable.formSource);
  ...
}
```
All upgrades preserve user data, favorites list, and custom team selections.
