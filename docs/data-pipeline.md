# Data pipeline and provenance

LibreDex bundles reference data for offline browsing. JSON assets are the reviewable source of truth for a release; `SyncRepository` copies their relevant rows into Drift on first launch and when the bundled-data version changes. Online lookups and remote artwork are separate optional services.

## 🗂 Asset map — where data lives

| Asset | Purpose | How the app uses it |
| --- | --- | --- |
| `assets/data/pokemon.json` | Base Pokémon records and generated species metadata. | Seeded into `pokemon_table`. |
| `assets/data/forms_extra.json` | Curated/additive Mega and other overlay forms, explicit form/source flags, extra abilities, and reviewed base-row overrides. | Added to the same Pokémon/ability tables during seeding. |
| `assets/data/moves.json` | Move facts, source flags, descriptions, and persisted battle properties. | Seeded into `move_table`; MoveDex and the calculator read the same flags. |
| `assets/data/abilities.json` | Ability facts, generation, source labels, and effect metadata. | Seeded into `ability_table`; hidden status still comes from its Pokémon junction. |
| `assets/data/items.json` | Item display records, categories, tags, generation/provenance, and explicit aliases. | Loaded by ItemDex; item artwork may be downloaded separately. |
| `assets/data/pokemon_moves.json` | Pokémon–move pairs and learning methods. | Seeded into `pokemon_moves_table`; M-C refresh replaces only `train` rows. |
| `assets/data/pokemon_abilities.json` | Pokémon–ability pairs, including each Pokémon's hidden-slot flag. | Seeded into `pokemon_abilities_table`; authoritative for per-Pokémon hidden filtering. |
| `assets/data/evolution_chains.json` | Family-rooted, form-aware directed evolution edges and trigger labels. | Used when online evolution data is disabled or unavailable. |
| `assets/data/champions_regulation_mc.json` | ID-based Regulation Set M-C catalog, delta, descriptions, move PP changes, learnset removals, and attribution. | Loaded by the regulation provider; not merged into global game-origin fields. |
| `tools/data/` | Vendored source CSV extracts and reviewed JSON override manifests. | Inputs to the deterministic/local asset builders. |

## 📚 Source policy — what is official, upstream, or curated

- **PokéAPI REST/CSV** supplies standard reference records and identifiers, including Pokémon species/forms, generations, evolution/evolution triggers, egg groups, moves, move priority/contact/flags, abilities, items, learnsets, and item game indices. The [PokéAPI repository CSV directory](https://github.com/PokeAPI/pokeapi/tree/master/data/v2/csv) is the upstream table reference.
- **PokéAPI sprites** is the source for linked artwork. Sprite existence can change upstream; known broken HOME render paths are handled explicitly by `tools/fix_sprite_urls.py` rather than by altering species identity.
- **Official Pokémon and Nintendo pages** establish game/regulation claims and published patch changes. The Champions references and the distinction between official and community-reported details are listed in [Champions support](champions-support.md); Legends: Z-A references are in [Legends: Z-A support](legends-za-support.md).
- **Pokémon Showdown's damage calculator** is a mechanics cross-check, not the source for the app's PokéAPI move flags or Champions roster. The review target for Gen 7–9 mechanics is [its `gen789.ts` implementation](https://github.com/smogon/damage-calc/blob/master/calc/src/mechanics/gen789.ts).
- **Community Champions data** is used as a pinned, attributed M-C roster/learnset cross-check: [`vbbjandrade/pokemon-champions-data`](https://github.com/vbbjandrade/pokemon-champions-data), branch `data`, commit [`df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4`](https://github.com/vbbjandrade/pokemon-champions-data/commit/df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4), CC BY 4.0. It is not an official Pokémon source.
- **Curated local overrides** are for values upstream does not carry or values requiring source review: Mega/overlay display names and flags, the published Champions ability, reviewed move traits missing from source tables, item category/tag corrections, source-specific provenance, duplicate aliases, and known sprite corrections. Keep each override exact and auditable. Not every current override row carries its own source URL/review date: in particular, move-trait classifications and item tags are local curation, not a separate official Pokémon taxonomy. When changing one, record the evidence and date in the relevant support guide or manifest; do not imply that every custom label is an official game term.

### Provenance invariants

1. **M-C eligibility is not game origin.** Store roster membership in `champions_regulation_mc.json`; store origin only in reviewed `isChampions*`, `isLegendsZA*`, `formSource`, `dlcSource`, or item tags/fields.
2. **Never infer provenance from numeric IDs.** For example, local move IDs `10001–10018` are Shadow moves, and Legends: Z-A provenance is attached to particular Mega Stone records. Item `2279` is a Roseli Berry alias, not a Mega Stone. The data itself wins over a numeric pattern.
3. **Preserve canonical records.** Enrich existing Mega Stone rows in place. Keep source aliases with an explicit `aliasOf` link and curated text; do not silently delete or duplicate them.
4. **Unknown stays unknown.** Item generation is the earliest source game-index generation when available; missing source metadata stays null and is displayed/sorted as unknown, not guessed from an ID.
5. **Hidden ability is relational.** `pokemon_abilities_table.isHidden` is the Pokémon-specific fact. Ability-level hidden metadata is not a replacement for that relationship.
6. **Move properties are data-backed.** PokéAPI supplies priority/contact and published flags; exact-name overrides are limited to traits absent from the source tables. Showdown is a cross-check for mechanics, not a source for the persisted PokéAPI fields.

### Snapshot caveat

The checked-in `tools/data/*.csv` files make local regeneration reviewable, but this branch does not yet record one upstream PokéAPI commit SHA and retrieval date for the full CSV collection. Treat their current contents as the repository snapshot, not as proof of a pinned upstream revision. Before refreshing them, record the exact PokéAPI revision/date in the same change and review the resulting JSON diffs. Some scripts (`build_items_asset.py`, `build_pokedex_lore_asset.py`, and artwork URL checks) query live services; they are not fully deterministic from the vendored CSVs alone.

## 🛠 Builder inventory — inputs, outputs, and safety behavior

Run commands from the repository root unless the command takes an explicit source directory.

| Command | Main inputs → outputs | Notes / guardrails |
| --- | --- | --- |
| `python3 tools/build_species_asset.py` | `tools/data/species.csv` and other local PokéAPI extracts → species reference asset. | Uses the checked-in data snapshot; inspect generated rows before replacing related content. |
| `python3 tools/build_champions_forms_asset.py --csv-dir /path/to/pokeapi-master/data/v2/csv` | PokéAPI CSV source plus reviewed `CURATED_FORMS` → `forms_extra.json`. | Fails without required CSVs; builds into a temporary file and leaves the old asset untouched on input failure. `python3 tools/build_forms_asset.py --csv-dir ...` is the compatibility wrapper. |
| `python3 tools/build_pokemon_metadata.py` | Local species/form/evolution/egg-group CSVs + current base/overlay assets → updated `pokemon.json`, `forms_extra.json`, and `evolution_chains.json`. | Checks IDs, cycles, source edge coverage, and inputs before replacing generated files. Review all three outputs together. |
| `python3 tools/build_moves_asset.py` | `moves.json`, `moves.csv`, move flags/meta CSVs, and `move_trait_overrides.json` → enriched `moves.json`. | Rejects missing source IDs, ambiguous names, or unknown overrides and leaves the current asset untouched on those failures. Does not infer M-C/game-origin flags from IDs. |
| `python3 tools/build_abilities_asset.py` | `abilities.json`, `abilities.csv`, `ability_provenance_overrides.json` → enriched `abilities.json`. | Ability generation is record metadata; hidden status remains on Pokémon–ability junction rows. Unknown override identifiers fail without replacing the asset. |
| `python3 tools/build_items_asset.py` | Current PokéAPI item REST endpoint + `item_game_indices.csv`, existing `items.json`, and `item_metadata_overrides.json` → enriched `items.json`. | Requires a network connection. Preserves useful local copy/tags/rows, adds explicit aliases and Mega Stone roles, uses atomic replace after a successful fetch, and leaves the current asset untouched on read/fetch/validation failure. |
| `python3 tools/build_pokedex_lore_asset.py` | Live PokéAPI species/flavor-text responses → lore asset. | Network-backed; review language, version and text diffs. |
| `python3 tools/apply_champions_regulation_learnsets.py --source /path/to/pokemon-champions-data/m-c/learnsets.json` | Pinned regulation source + `sourcePokemonIds`, move catalog, and current junctions → `pokemon_moves.json`. | Requires exact source-roster key equality, validates every move/ID and removed pair, preserves every non-`train` method, and atomically writes the result. Use only with the reviewed source commit. |
| `python3 tools/apply_pokeapi_csv_junctions.py --csv-dir /path/to/pokeapi-master/data/v2/csv` | Legacy PokéAPI learnset CSV → junction rows. | Guarded against overwriting the pinned M-C `train` learnset. Do not use it as the M-C learnset builder. |
| `python3 tools/build_dlc_overlay.py` | `tools/data/dlc_provenance_overrides.json` → explicit DLC provenance overlay. | The current manifest is intentionally empty; the builder rejects an empty manifest rather than reporting a false successful provenance build. Populate it only after source review. |
| `python3 tools/fix_sprite_urls.py` | Audited URL exceptions → corrected base Pokémon sprite URLs. | Keeps known 404/fallback choices explicit; run its validator after changing the map. |
| `python3 tools/build_ev_yields_asset.py` | Live PokéAPI `/pokemon` index and per-Pokémon records → `assets/data/pokemon_ev_yields.json`. | Network-backed. Fetch failures leave the old asset untouched, but the final successful write is direct rather than temp-file replacement; review the output promptly. Run from the repository root. |

Builders that write JSON use temporary files where implemented, but multi-file outputs are not a single filesystem-wide transaction. Keep a working-tree diff or backup, and review every output if a process is interrupted during final replacement.

## 🔁 Safe refresh workflow

1. **Research first.** Start from official game news/patch notes. Record URLs, update date/version, and exact third-party repository commit/license where community data is used. Never promote a community claim to “official.”
2. **Pin the input snapshot.** Check out/download PokéAPI CSVs at a known revision. Record its commit and retrieval date with the source update; do not refresh only some related tables from different revisions without documenting that choice.
3. **Update source tables and reviewed overrides.** Change only the intended records. Keep provenance, M-C eligibility, alias mapping, and generation data separate.
4. **Regenerate the base/form assets.** Run the applicable builders above. For evolution/generation/egg metadata, run `build_pokemon_metadata.py` after both base Pokémon and overlay rows are current.
5. **Apply the M-C learnset last.** Validate the M-C catalog and source mapping before the learnset command. Confirm it preserves non-`train` rows and that no legacy importer runs afterward.
6. **Review the diff and validate.** Compare IDs, counts, source tags, PP/learnset differences, aliases, form flags, sprite URLs, and the exact field changed. A source script's success message is not a substitute for this review.
7. **Version the right layer.** Increment `SyncRepository.bundledDataVersion` when seeded asset content changes. Increment Drift `schemaVersion` and add a migration only when a table/column/index shape changes. See [Database migrations](database-migrations.md).
8. **Run release verification.** Execute the asset validators listed below and, with Flutter installed, format/analyze/tests and device checks in [Testing](testing.md) and [Release checklist](release-checklist.md).

### Structural validator commands

```bash
python3 tools/audit_libredex_data.py
python3 tools/validate_champions_data.py
python3 tools/validate_forms_catalog.py
python3 tools/validate_learnsets.py
python3 tools/validate_move_properties.py
```

These checks have intentionally different scopes:

- `audit_libredex_data.py` checks required IDs/fields, junction references, required move priority/contact booleans, item alias targets, and basic item generation values.
- `validate_champions_data.py` checks overlay form data/IDs, ability references, learnset fallback, required forms, selected sprite exceptions, and a few known learnset cases.
- `validate_forms_catalog.py` checks the overlay's IDs/names and warns on unknown flags.
- `validate_learnsets.py` checks Pokémon/move junction references.
- `validate_move_properties.py` checks move names, types, and damage classes; it does **not** prove every priority/contact/trait classification matches a game.

## 🧾 Runtime data refresh

`SyncRepository.bundledDataVersion` is currently **5**. On an installed app, increasing it triggers a transactional re-seed of reference tables so stale learnsets and metadata do not coexist with new rows. Favorites/team/settings remain outside those tables. The M-C catalog is read directly from its asset through a provider and is not a substitute for seeded move/ability/item data.

Item artwork is downloaded only when the user requests it; a bulk ItemDex run counts unique stored artwork URLs and verifies that artwork exists after each request. The normal image cache, persistent offline artwork library, and reference database have separate storage lifetimes; see the [README](../README.md).

## ✅ Current review status

The M-C snapshot metadata and source commit are recorded; general PokéAPI CSV commit/date are not yet recorded as one source manifest. The implementation pass documented in [Audit implementation](audit-implementation.md) intentionally did **not** run Flutter tests, `dart format`, or `flutter analyze`.
