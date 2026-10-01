# Implementation guide: architecture, behavior, and verification

**Data snapshot:** 1 October 2026 · **Pokémon Champions:** Version 1.2.0 / Regulation Set M-C · **Database:** Drift schema 5, bundled-data version 5.

This guide explains where audited behavior lives, what the counts and filters mean to users, and which claims still need Flutter validation. It complements rather than replaces the focused [data-pipeline](data-pipeline.md), [Champions](champions-support.md), [Legends: Z-A](legends-za-support.md), and [migration](database-migrations.md) guides.

## 🧭 Architecture — how the pieces fit

1. **Bundled JSON** under `assets/data/` is the offline source for Pokémon/forms, moves, abilities, items, learnsets, EV yields, and evolution edges.
2. **`StartupGate`** calls `SyncRepository.ensureSeeded()` before showing the app. `SyncRepository` decodes the selected database-seed JSON assets and transactionally seeds the local Drift tables. ItemDex reads `items.json` directly rather than from Drift; the regulation provider reads its catalog asset directly rather than seeding it. The app does not need a network connection to build its reference database.
3. **Drift** (`lib/core/database/app_database.dart`) stores Pokémon, move, ability, and junction rows. The hidden-ability fact belongs to the Pokémon–ability junction, not solely to the ability row. Schema upgrades and bundled-data refreshes have independent version numbers; see [Database migrations](database-migrations.md).
4. **Riverpod repositories/providers** expose database streams, regulation catalogs, favorites, teams, and settings to screens.
5. **`champions_regulation_mc.json`** is a separate ID-based regulation snapshot. It provides eligibility and the M-C delta; it does not rewrite general-game origin metadata or universal move PP.
6. **The battle engine** consumes immutable battle state built from database move properties and user-selected combat state. The duel view calculates one `DamageResult` and passes that result to the summary card. The raw sandbox remains a separate, deliberately simpler calculation surface.

Settings such as the randomizer mode and calculator ruleset are stored in preferences. Favorites and team slots are also outside the bundled reference tables and survive a reference-data reseed.

## 🗃 Data and provenance — what the labels mean

### Source roles

| Source | Used for | Important boundary |
| --- | --- | --- |
| [PokéAPI](https://pokeapi.co/) and its [CSV data](https://github.com/PokeAPI/pokeapi/tree/master/data/v2/csv) | Standard Pokémon, move, ability and item records; generation, egg-group, form, evolution, learnset, move-flag, priority/contact and item-game-index metadata. | The checked-in CSVs are source snapshots; see the snapshot/revision caveat in [Data pipeline](data-pipeline.md). Some builders also fetch current REST data. |
| [PokéAPI sprites](https://github.com/PokeAPI/sprites) | Remote and optionally downloaded artwork. | Artwork is separate from the local facts database; see [`NOTICE.md`](../NOTICE.md). |
| Official Pokémon/Nintendo news and update notes | Champions regulation window, published patch changes, announced roster/abilities, and Legends: Z-A announcements/rewards. | Official statements are distinguished from third-party cross-checks in the game-specific guides. |
| [`pokemon-champions-data`](https://github.com/vbbjandrade/pokemon-champions-data), branch `data`, commit [`df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4`](https://github.com/vbbjandrade/pokemon-champions-data/commit/df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4), CC BY 4.0 | ID roster and M-C learnset cross-check. | Community-maintained, not an official Pokémon source; attribution is retained in the regulation asset. |
| [Pokémon Showdown damage calculator](https://github.com/smogon/damage-calc/blob/master/calc/src/mechanics/gen789.ts) | Independent cross-check for battle mechanics and damage behavior. | Mechanics cross-check only; it is not the source of PokéAPI move priority/contact fields or the Champions roster. |
| Local reviewed overrides/manifests | Labels and facts absent from upstream data, researched game-specific ability metadata, explicit aliases, known asset corrections, and game-origin tags. | Overrides must be tied to a reviewed source; they must not be inferred from an ID range or from M-C eligibility. |

### Regulation eligibility is not game origin

- **Available in M-C** means the ID appears in the regulation catalog.
- **New in M-C** means the ID is in the catalog's M-C-versus-M-B delta.
- **Champions-origin** or **Legends: Z-A-origin** means explicit provenance metadata identifies that origin.
- A move or item can become M-C-eligible without being new to Champions. Conversely, a Champions form/ability does not imply eligibility in every regulation.
- Numeric IDs are identifiers, not provenance. The local dataset includes non-Champions content in ranges that might look like game-specific blocks; examples and rules are in [Champions support](champions-support.md).
- Keep existing Mega Stone records and enrich them in place. Item aliases are explicit relationships (`aliasOf`), not a reason to delete a source row.

## 🔎 User-facing filters and counts — exact semantics

Filters within a screen are combined as constraints; a Pokémon that fails any active constraint is excluded. Search text is managed by its search field, independently of the removable filter chips.

### Pokédex

- **Types:** one selected type matches either slot. Two selected types require the exact dual-type pair, in either order. Multiple selected generations are alternatives (any selected generation may match).
- **Classifications and collections:** Legendary, Mythical, Ultra Beast, and Paradox selections are alternatives within that classification group. Favorites, team membership, shiny-art availability, and M-C eligibility/newness are separate constraints. `Shiny display` changes the displayed artwork; `Has Shiny Form` filters out records with no shiny URL.
- **Roster metadata:** generation, egg group, evolution stage, outgoing-evolution/single-stage flags, and incoming evolution-method category use stored metadata; the UI does not infer them from an ID threshold.
- **Ability compatibility:** the query is matched against ability name/description on the Pokémon's own junction rows. `Hidden Ability Only` reads `pokemon_abilities_table.isHidden` for that Pokémon, so a hidden slot on one Pokémon does not make the same ability hidden for every species. The toggle works without an ability-name query.
- **Stats:** BST range, minimum per-stat thresholds, and EV-yield selection can be combined.
- **Result count:** `species found` counts unique National Dex numbers that have at least one form surviving all filters. Cards group matching forms by National Dex number and open the complete local form group. It is not the number of form rows.
- **Active chips:** type, generation, classification, collection, M-C, format, egg-group, evolution, ability, stat, EV, shiny-display, and sort state can be cleared individually; **Clear all** resets the filter state.

### MoveDex

- Search, type, damage class, generation, power/accuracy/PP ranges, description-effect keyword, and source/rules filters can be combined.
- The **22 battle-property switches** share one definition for label, state, predicate, reset, and active chip: positive priority, negative priority, contact, non-contact, status, damaging, multi-hit, recoil, draining, healing, switching, protective, recharge, sound, punching, biting, powder, pulse/aura, ballistic, slicing, wind, and dance.
- Contact and priority predicates use the persisted `Move` record. An enabled property requires that property to be true; enabling both sides of a mutually exclusive pair (for example contact and non-contact) naturally gives no results.
- **Available in M-C**, **New to M-C**, **Champions-origin**, **Legends: Z-A**, **DLC**, and **signature** are distinct filters.
- **Result count:** `moves found` counts filtered move records/IDs, not Pokémon learnset pairs. Active property chips use the same definition as the switches and their clearing behavior.

### AbilityDex

- Filters cover generation, effect tags, Champions origin, M-C availability/newness, Legends: Z-A provenance, and hidden status.
- AbilityDex's hidden-status list means **at least one** Pokémon–ability junction marks that ability hidden. The detail view then marks the specific Pokémon rows whose junction says it is hidden.
- **Result count:** `abilities found` counts ability records. It is not the number of Pokémon that use those abilities.

### ItemDex

- Filters cover source category/subcategory/tag, held/battle/evolution roles, DLC provenance, M-C availability/newness, explicit Champions/Legends: Z-A origin, effect keyword, and whether to show upstream aliases.
- Mega Stones are retained as item records and classified as held evolution items even when the upstream holdable attribute is absent. Introduction generation uses the earliest source game-index generation when available; unknown remains unknown and sorts after known generations.
- The Roseli Berry source alias is hidden during ordinary browsing, but exact-ID search can still find it and the alias toggle reveals it. The alias points to the canonical item rather than being merged away.
- **Result count:** `items found` counts visible item rows; if aliases are shown, an alias is a separately visible row. Bulk artwork reports unique, non-alias artwork URLs and counts verified stored downloads, not item rows or attempted requests.

### Random Pokémon

The settings sheet offers three pool sources:

1. **Everything** — any bundled Pokémon/form, independent of the current Pokédex filter.
2. **Active Dex Search & Filters** — the current filtered Pokédex rows.
3. **Custom Criteria Rules** — selected type(s), generation(s), BST range, and optionally final-evolution-or-single-stage entries.

`Instant Roll on Tap` skips the sheet on a normal tap; long-press still opens customization. Custom settings persist in preferences. The fully-evolved option excludes exact Pokémon rows with a stored outgoing evolution edge; genuine single-stage records remain eligible.

## ⚔️ Battle calculations — shared data, explicit scope

- Move priority and contact flags are persisted in `move_table`. The move picker displays them, `MoveState` carries them into the battle engine, and the engine uses the same fields for priority/contact-dependent effects such as Psychic Terrain, Unseen Fist, and Champions-only Aura Guard.
- Both mainline and Champions engines use `StatEngine` for critical-stage handling. Critical hits ignore the relevant negative attacking stages and positive defending stages; the Body Press and Foul Play stat sources receive their move-specific handling (Body Press uses the user's Defense; Foul Play uses the target's Attack source).
- Aura Guard is conditional on Champions rules and contact metadata. The general move record remains valid outside Champions.
- The full duel view creates one engine result per render pass and sends that result to `DamageSummaryCard`; avoid adding a second identical `BattleEngine.calculate` call in the summary. The **RAW SANDBOX** intentionally remains separate and should not be described as the full engine.
- These are implementation statements, not claims of exhaustive simulator parity. The target regression cases exist in `test/battle_engine_test.dart` but were not run in this implementation pass; see [Testing](testing.md).

## 🧬 Evolution, generation, and form coverage

`tools/build_pokemon_metadata.py` derives species generation, egg groups, evolution depth, baby status, per-form outgoing-evolution capability, incoming evolution-method categories, and form-aware edges from the local source tables. It writes `pokemon.json`, `forms_extra.json`, and `evolution_chains.json` only after it has parsed inputs and checked source edge coverage.

- The stored graph is grouped by evolution-family root and includes all evolution edges retained from the builder's selected default-species PokéAPI rows, including their branches—not just the selected Pokémon's immediate parent or child. It can carry form constraints present on those rows, but it does not claim complete coverage of every non-default/form-specific source edge.
- The detail view renders all edges in the selected family, from predecessor to successor, and each endpoint is navigable. Online PokéAPI results are preferred when enabled; the bundled graph is the offline/error fallback and can be selected in Settings.
- The bundled snapshot inspected for this work contains **340 family entries, 527 stored edges, and 54 branching parents**. This is a structural count, not proof that every in-game condition or every form-specific edge is correct.
- Source evolution triggers contain more fields than the compact app label can display; preserve the source fields and review labels when the upstream schema changes.

## 🛠 Regeneration and maintenance entry points

See [Data pipeline](data-pipeline.md) for the safe order and the full command table. The principal entry points are:

- `tools/build_species_asset.py`, `tools/build_champions_forms_asset.py` (or the compatibility `tools/build_forms_asset.py`), and `tools/build_pokemon_metadata.py` for base/form/species metadata.
- `tools/build_moves_asset.py`, `tools/build_abilities_asset.py`, and `tools/build_items_asset.py` for data-backed dex records and explicit metadata.
- `tools/apply_champions_regulation_learnsets.py` for reviewed M-C `train` rows; it preserves non-`train` methods and rejects source/roster mismatches.
- `tools/build_dlc_overlay.py` only after its source-reviewed provenance manifest is populated; an empty manifest deliberately fails.
- `tools/audit_libredex_data.py`, `tools/validate_champions_data.py`, `tools/validate_forms_catalog.py`, `tools/validate_learnsets.py`, and `tools/validate_move_properties.py` for structural checks with different scopes.

Always inspect generated diffs. A script passing its structural checks does not establish that a community field is official, every move trait is mechanically correct, or a sprite URL will remain available upstream.

## 🧪 Verification status and known limits

**Not run in this implementation pass (per the request not to run them):** `flutter test`, `dart format`, and `flutter analyze`. Do not interpret this patch as a green Flutter verification result. See [Testing LibreDex](testing.md) for the exact command set and focused test inventory.

Additional limits to account for before a release:

- The current catalog snapshot is dated **1 October 2026**. Recheck official news and the active game/regulation before refreshing it.
- The M-C community source is pinned by commit in the catalog; the general PokéAPI CSV collection does not yet have a single checked-in upstream commit manifest. The vendored contents are reviewable, but refreshes should record upstream revision and retrieval date.
- Mega Golisopod and Mega Baxcalibur ability assignments have community corroboration; do not present those two as official announcements. Source separation is documented in [Champions support](champions-support.md).
- Python validators are structural and selective. They do not run the Flutter UI, verify responsive layout/semantics on devices, prove every provenance claim, or replace a game-mechanics review.
- The Foul Play critical-hit/stage interaction was not independently verified against an authoritative current reference in this pass. Treat the implementation and regression case as needing focused source review before claiming exact simulator parity.
- No visual/device pass was performed here for the 700-dp navigation breakpoint, screen-reader result announcements, artwork downloads, or online/offline evolution switching.
