# LibreDex reference

Everything stable about how LibreDex works today: architecture, data provenance,
database, game support, filter semantics, battle calculations, testing and release.

For what is planned, done or deliberately deferred, see [`plans.md`](../plans.md).
For legal attribution, see [`NOTICE.md`](../NOTICE.md).

**Data snapshot:** 1 October 2026 · **Pokémon Champions:** Version 1.2.0 / Regulation Set M-C
**Database:** Drift schema 5, bundled-data version 5
**Verified:** 2026-10-06 — `flutter analyze` clean, `flutter test` passing (260 tests)

---

## 1. Architecture

1. **Bundled JSON** under `assets/data/` is the offline source for Pokémon/forms, moves,
   abilities, items, learnsets, EV yields and evolution edges. 12 files, 5.7 MB.
2. **`StartupGate`** calls `SyncRepository.ensureSeeded()` before showing the app.
   `SyncRepository` decodes the database-seed JSON assets and transactionally seeds the
   local Drift tables. ItemDex reads `items.json` directly rather than from Drift; the
   regulation provider reads its catalog asset directly rather than seeding it. The app
   needs no network connection to build its reference database.
3. **Drift** (`lib/core/database/app_database.dart`) stores Pokémon, move, ability and
   junction rows. Schema upgrades and bundled-data refreshes have independent version
   numbers — see [§3](#3-database-schema-and-migrations).
4. **Riverpod repositories/providers** expose database streams, regulation catalogs,
   favorites, teams and settings to screens.
5. **`champions_regulation_mc.json`** is a separate ID-based regulation snapshot. It
   provides eligibility and the M-C delta; it does not rewrite general game-origin
   metadata or universal move PP.
6. **The battle engine** consumes immutable battle state built from database move
   properties and user-selected combat state. The duel view calculates one
   `DamageResult` and passes that result to the summary card. The raw sandbox remains a
   separate, deliberately simpler calculation surface.

Settings such as the randomizer mode and calculator ruleset live in preferences.
Favorites and team slots are outside the bundled reference tables and survive a
reference-data reseed.

---

## 2. Data pipeline and provenance

### Asset map

| Asset | Purpose |
| --- | --- |
| `pokemon.json` | Base Pokémon records and generated species metadata → `pokemon_table` |
| `forms_extra.json` | Curated Mega/overlay forms, form and source flags, extra abilities, reviewed base-row overrides |
| `moves.json` | Move facts, source flags, descriptions, persisted battle properties → `move_table` |
| `abilities.json` | Ability facts, generation, source labels, effect metadata → `ability_table` |
| `items.json` | Item display records, categories, tags, provenance, explicit aliases (ItemDex reads directly) |
| `pokemon_moves.json` | Pokémon–move pairs and learning methods → `pokemon_moves_table` |
| `pokemon_abilities.json` | Pokémon–ability pairs with each Pokémon's hidden-slot flag |
| `evolution_chains.json` | Family-rooted, form-aware directed evolution edges and trigger labels |
| `champions_regulation_mc.json` | ID-based Regulation Set M-C catalog, delta, PP changes, learnset removals, attribution |
| `pokemon_ev_yields.json` | EV yields, fetched from live PokéAPI |
| `tools/data/` | Vendored source CSV extracts and reviewed JSON override manifests |

### Source roles

| Source | Used for | Boundary |
| --- | --- | --- |
| [PokéAPI](https://pokeapi.co/) and its [CSV data](https://github.com/PokeAPI/pokeapi/tree/master/data/v2/csv) | Standard Pokémon/move/ability/item records; generation, egg-group, form, evolution, learnset, move-flag, priority/contact and item-game-index metadata | Checked-in CSVs are source snapshots; some builders also fetch current REST data |
| [PokéAPI sprites](https://github.com/PokeAPI/sprites) | Remote and optionally downloaded artwork | Separate from the local facts database |
| Official Pokémon/Nintendo news and update notes | Champions regulation window, patch changes, announced roster/abilities, Legends: Z-A announcements and rewards | Distinguished from third-party cross-checks |
| [`pokemon-champions-data`](https://github.com/vbbjandrade/pokemon-champions-data) branch `data`, commit [`df262d8`](https://github.com/vbbjandrade/pokemon-champions-data/commit/df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4), CC BY 4.0 | ID roster and M-C learnset cross-check | Community-maintained, **not** an official Pokémon source |
| [Pokémon Showdown damage calculator](https://github.com/smogon/damage-calc/blob/master/calc/src/mechanics/gen789.ts) | Independent cross-check for battle mechanics | Mechanics only; not the source of PokéAPI move flags or the Champions roster |
| Local reviewed overrides/manifests | Labels and facts absent upstream, game-specific ability metadata, explicit aliases, known asset corrections, game-origin tags | Must be tied to a reviewed source; never inferred from an ID range or M-C eligibility |

### Provenance invariants

1. **M-C eligibility is not game origin.** Store roster membership in
   `champions_regulation_mc.json`; store origin only in reviewed `isChampions*`,
   `isLegendsZA*`, `formSource`, `dlcSource`, or item tags/fields.
2. **Never infer provenance from numeric IDs.** Local move IDs `10001–10018` are Shadow
   moves; item `2279` is a Roseli Berry alias, not a Mega Stone. The data wins over a
   numeric pattern.
3. **Preserve canonical records.** Enrich existing Mega Stone rows in place. Keep source
   aliases with an explicit `aliasOf` link; do not silently delete or duplicate them.
4. **Unknown stays unknown.** Item generation is the earliest source game-index
   generation when available; missing metadata stays null and sorts as unknown.
5. **Hidden ability is relational.** `pokemon_abilities_table.isHidden` is the
   Pokémon-specific fact. Ability-level hidden metadata does not replace it.
6. **Move properties are data-backed.** PokéAPI supplies priority/contact and published
   flags; exact-name overrides are limited to traits absent from the source tables.

Not every current override row carries its own source URL and review date — move-trait
classifications and item tags in particular are local curation, not an official Pokémon
taxonomy. Record evidence and date when changing one; do not imply that every custom
label is an official game term.

### Snapshot caveat

The checked-in `tools/data/*.csv` files make local regeneration reviewable, but the
repository does not yet record one upstream PokéAPI commit SHA and retrieval date for
the full CSV collection. Treat their contents as the repository snapshot, not as proof
of a pinned upstream revision. Before refreshing them, record the exact PokéAPI
revision and date in the same change and review the resulting JSON diffs. Some scripts
(`build_items_asset.py`, `build_pokedex_lore_asset.py`, artwork URL checks) query live
services and are not fully deterministic from the vendored CSVs alone.

### Builder inventory

Run from the repository root unless the command takes an explicit source directory.

| Command | Inputs → outputs | Guardrails |
| --- | --- | --- |
| `python3 tools/build_species_asset.py` | `tools/data/species.csv` and local PokéAPI extracts → species asset | Uses the checked-in snapshot; inspect rows before replacing related content |
| `python3 tools/build_champions_forms_asset.py --csv-dir /path/to/pokeapi-master/data/v2/csv` | PokéAPI CSVs + reviewed `CURATED_FORMS` → `forms_extra.json` | Fails without required CSVs; writes to a temp file and leaves the old asset untouched on failure. `build_forms_asset.py` is the compatibility wrapper |
| `python3 tools/build_pokemon_metadata.py` | Species/form/evolution/egg-group CSVs + current base/overlay assets → `pokemon.json`, `forms_extra.json`, `evolution_chains.json` | Checks IDs, cycles, source edge coverage and inputs before replacing. Review all three outputs together |
| `python3 tools/build_moves_asset.py` | `moves.json`, `moves.csv`, move flag/meta CSVs, `move_trait_overrides.json` → enriched `moves.json` | Rejects missing source IDs, ambiguous names, unknown overrides. Does not infer M-C/game-origin flags from IDs |
| `python3 tools/build_abilities_asset.py` | `abilities.json`, `abilities.csv`, `ability_provenance_overrides.json` → enriched `abilities.json` | Unknown override identifiers fail without replacing the asset |
| `python3 tools/build_items_asset.py` | Live PokéAPI item REST + `item_game_indices.csv`, existing `items.json`, `item_metadata_overrides.json` → enriched `items.json` | Requires network. Preserves local copy/tags/rows, atomic replace after successful fetch |
| `python3 tools/build_pokedex_lore_asset.py` | Live PokéAPI species/flavor-text responses → lore asset | Network-backed; review language, version and text diffs |
| `python3 tools/apply_champions_regulation_learnsets.py --source /path/to/pokemon-champions-data/m-c/learnsets.json` | Pinned regulation source + `sourcePokemonIds`, move catalog, current junctions → `pokemon_moves.json` | Requires exact source-roster key equality; preserves every non-`train` method; atomic write. Use only with the reviewed commit |
| `python3 tools/apply_pokeapi_csv_junctions.py --csv-dir /path/to/...` | Legacy PokéAPI learnset CSV → junction rows | Guarded against overwriting the pinned M-C `train` learnset — **not** the M-C builder |
| `python3 tools/build_dlc_overlay.py` | `tools/data/dlc_provenance_overrides.json` → DLC provenance overlay | Manifest is intentionally empty; the builder rejects empty rather than reporting false success |
| `python3 tools/fix_sprite_urls.py` | Audited URL exceptions → corrected sprite URLs | Keeps known 404/fallback choices explicit; run its validator after changing the map |
| `python3 tools/build_ev_yields_asset.py` | Live PokéAPI `/pokemon` index and records → `pokemon_ev_yields.json` | Network-backed; fetch failures leave the old asset untouched; final write is direct, so review promptly |

Builders that write JSON use temporary files where implemented, but multi-file outputs
are not a single filesystem-wide transaction. Keep a working-tree diff or backup, and
review every output if a process is interrupted during final replacement.

### Safe refresh workflow

1. **Research first.** Start from official game news and patch notes. Record URLs,
   update date/version and exact third-party commit/licence. Never promote a community
   claim to "official".
2. **Pin the input snapshot.** Check out PokéAPI CSVs at a known revision; record the
   commit and retrieval date with the source update.
3. **Update source tables and reviewed overrides.** Change only the intended records.
   Keep provenance, M-C eligibility, alias mapping and generation data separate.
4. **Regenerate base/form assets.** Run `build_pokemon_metadata.py` after both base
   Pokémon and overlay rows are current.
5. **Apply the M-C learnset last.** Confirm it preserves non-`train` rows and that no
   legacy importer runs afterward.
6. **Review the diff and validate.** Compare IDs, counts, source tags, PP/learnset
   differences, aliases, form flags and sprite URLs. A script's success message is not
   a substitute for this review.
7. **Version the right layer.** Increment `SyncRepository.bundledDataVersion` for seeded
   content changes; increment Drift `schemaVersion` and add a migration only for
   table/column/index shape changes.
8. **Run verification.** Asset validators, then `dart format`, `flutter analyze`,
   `flutter test`, then device checks — see [§8](#8-testing) and [§9](#9-release-checklist).

### Structural validators

```bash
python3 tools/audit_libredex_data.py
python3 tools/validate_champions_data.py
python3 tools/validate_forms_catalog.py
python3 tools/validate_learnsets.py
python3 tools/validate_move_properties.py
```

| Validator | Scope |
| --- | --- |
| `audit_libredex_data.py` | Required IDs/fields, junction references, required move priority/contact booleans, item alias targets, basic item generation values |
| `validate_champions_data.py` | Overlay form data/IDs, ability references, learnset fallback, required forms, selected sprite exceptions, a few known learnset cases |
| `validate_forms_catalog.py` | Overlay IDs/names; warns on unknown flags |
| `validate_learnsets.py` | Pokémon/move junction references |
| `validate_move_properties.py` | Move names, types, damage classes — **not** whether every priority/contact/trait classification matches a game |

These are intentionally selective. They do not run the Flutter UI, verify responsive
layout or semantics on devices, prove every provenance claim, or replace a
game-mechanics review.

### Runtime data refresh

`SyncRepository.bundledDataVersion` is currently **5**. Raising it triggers a
transactional re-seed of reference tables so stale learnsets and metadata cannot
coexist with new rows. Favorites, teams and settings remain outside those tables.
**Rebuild local database** in the app performs the same reseed; it does not delete
artwork held by the offline artwork service.

Item artwork downloads only on user request; a bulk ItemDex run counts unique stored
artwork URLs and verifies each download. The image cache, persistent offline artwork
library and reference database have separate storage lifetimes.

---

## 3. Database schema and migrations

LibreDex uses [Drift](https://drift.simonbinder.eu/) over SQLite. The schema and
bundled JSON assets have separate version numbers: `AppDatabase.schemaVersion` governs
SQL migrations, `SyncRepository.bundledDataVersion` governs when an installed app
re-seeds reference data.

| Version | Location | Purpose |
| --- | --- | --- |
| **Schema 5** | `lib/core/database/app_database.dart` | SQLite tables and columns |
| **Bundle 5** | `SyncRepository.bundledDataVersion` | Bundled assets copied into Drift |

### Tables

1. **`pokemon_table`** — species/form identity, types, base stats, source tags,
   generation, egg groups, baby/evolution metadata, sprites.
2. **`move_table`** — move identity, class, power/accuracy/PP, priority, battle traits,
   generation, source flags.
3. **`ability_table`** — descriptions, generation, source labels, effect tags,
   game-specific metadata.
4. **`pokemon_moves_table`** — junction keyed by `(pokemonId, moveId, learnMethod)`, so
   one move may be available through several methods.
5. **`pokemon_abilities_table`** — junction keyed by `(pokemonId, abilityId)`, with
   `isHidden` stored on the relationship.

Reverse-lookup and filter indexes are created in `beforeOpen` (names, forms, types,
generation, National Dex number, move class/power/priority, junction foreign keys).
They are single-column, not composite. **Do not move index creation to `onUpgrade`** —
that would leave fresh installs with no indexes. The hazard is guarded by a comment in
`beforeOpen`.

### Data ownership rules

- `pokemon_abilities_table.isHidden` is authoritative for whether an ability is hidden
  **for that Pokémon**. An ability can be hidden for one Pokémon and standard for
  another. `ability_table.isHiddenAbility` is only a record-level summary and must not
  replace the junction value in filters or detail pages.
- `move_table.priority` and `move_table.isContact` are persisted move facts. Battle
  calculations and MoveDex filters read those same fields rather than maintaining a
  separate hard-coded list.
- Pokémon generation, evolution depth, egg groups and evolution capability are explicit
  data fields. UI filters must not reconstruct them from a Dex number or name pattern.
- Regulation membership (for example M-C) comes from its separate ID catalog, not from
  a schema-level game-origin flag.

### Schema history

- **v1** — initial Pokémon, move, ability and junction tables.
- **v2** — nullable move descriptions.
- **v3** — National Dex number on Pokémon rows.
- **v4** — source and battle metadata: Pokémon generation, evolution stage, egg groups,
  form/DLC source, Champions and Legends: Z-A flags; move priority, contact,
  damage-class and battle-trait flags; ability generation, source labels, effect tags.
- **v5** — `pokemon_table.isBaby`, `hasEvolution`, `evolutionMethods`, populated from
  the bundled species/evolution metadata.

### Upgrade behavior

Drift applies `onUpgrade` steps in order; the `from < N` guards let an older install
move through all applicable versions without dropping tables. New non-null columns use
documented defaults; nullable metadata stays null when the source does not provide it.

The reseed runs in a transaction: junction rows and the Pokémon/move/ability tables are
rebuilt together, so old learnsets and obsolete relationships do not remain mixed with
new seeded assets.

### Migration checklist

1. Add or change the Drift table definition.
2. Increment `schemaVersion` and add the matching guarded `onUpgrade` migration; never
   edit an old migration to assume it has not shipped.
3. Regenerate `app_database.g.dart` with Drift's builder.
4. If bundled rows or decoding behavior changed, increment `bundledDataVersion` too.
5. Confirm a fresh database and an older-version upgrade both retain valid references.
6. Review the changed data asset and the migration together — a schema migration does
   not refresh bundled rows, and a bundle bump does not add SQL columns.

**Maintenance rule of thumb:** for an asset-only data correction, update the JSON/CSV
source and provenance notes, validate asset references, and bump `bundledDataVersion`.
For a database shape change, also update the Drift table, migration, `schemaVersion`
and generated code.

---

## 4. Pokémon Champions — Regulation Set M-C

**Game version 1.2.0.** Official period 8 September – 1 December 2026 in North American
time zones (9 September – 2 December UTC).

### Catalog and counts

The bundled ID-based catalog is `assets/data/champions_regulation_mc.json`.

| Pool | M-C entries | Added versus M-B |
| --- | ---: | ---: |
| Pokémon roster records/forms | 345 | 35 local IDs: 29 non-Mega + 6 Mega forms |
| Moves | 510 | 14 |
| Abilities | 216 | 15 |
| Items | 151 | 18 |

The official announcement says **24 newly available Pokémon** and **six new Mega
Evolutions**. Do not compare that headline directly with a local ID count — the catalog
tracks forms as separate IDs, and `newPokemonIds` holds 29 non-Mega records across 23
National Dex numbers.

**Six Mega forms added to M-C:** Mega Salamence (10089), Mega Absol Z (10307), Mega
Garchomp Z (10309), Mega Lucario Z (10310), Mega Golisopod (10316), Mega Baxcalibur
(10325).

**14 moves added:** Milk Drink, Shift Gear, Zing Zap, Snipe Shot, Jaw Lock, Octolock,
Court Change, Drum Beating, Pyro Ball, Overdrive, Meteor Assault, Glaive Rush, Revival
Blessing, Double Shock. Separately, **Slash** (ID 163) becomes newly usable and is
stored in `newlyUsableMoveIds` rather than counted as a record addition.

**15 abilities added:** Run Away, Liquid Ooze, Rattled, Grass Pelt, Emergency Exit,
Stakeout, Psychic Surge, Grassy Surge, Libero, Punk Rock, Steely Spirit, Seed Sower,
Thermal Exchange, Guard Dog, Aura Guard. Aura Guard is a custom local ability, ID 314,
supplied through `forms_extra.json` and backed by the official announcement.

**18 items added:** six Mega Stones — Salamencite (810), Absolite Z (2265), Garchompite
Z (2267), Lucarionite Z (2268), Golisopite (2272), Baxcalibrite (2275) — plus 12 held
items: Leek (236), Rocky Helmet (583), Air Balloon (584), Red Card (585), Binding Band
(587), Eject Button (590), Normal Gem (669), Terrain Extender (896), Electric Seed
(898), Psychic Seed (899), Misty Seed (900), Grassy Seed (901).

Baxcalibrite illustrates the label boundary: the [official Z-A Battle Club page](https://legends.pokemon.com/en-gb/news/battle-club-ranked-battles)
gives it as a ranked-battle reward, while the M-C catalog separately makes it eligible.
Air Balloon's Ground immunity is modeled in the damage engine.

### Version 1.2.0 adjustments

- Wish and Strength Sap PP are **8** in M-C (previously 12).
- Slash becomes usable in the set.
- Politoed loses Pound; Archaludon loses Mirror Coat and Metal Burst.
- The learnset asset holds **21,488 `train` pairs** across the 345 mapped roster IDs.
  Rebuilding replaces stale `train` pairs only; non-`train` methods are preserved.
- The general move record is not rewritten to make regulation-specific PP look
  universal — the move picker shows the M-C override explicitly.

### Mega abilities and Aura Guard

Curated form-ability overrides are applied during form-asset generation so a standard
source refresh cannot silently replace reviewed assignments.

| Mega form | Ability | Source status |
| --- | --- | --- |
| Mega Absol Z | Sharpness | Official Pokémon Asia press release |
| Mega Garchomp Z | Levitate | Official Pokémon Asia press release |
| Mega Lucario Z | Aura Guard | Official Pokémon Asia press release |
| Mega Golisopod | Tough Claws | Community corroboration (Serebii) — **not** official |
| Mega Baxcalibur | Thermal Exchange | Community corroboration (Serebii) — **not** official |

Mega Salamence uses the established Aerilate. Aura Guard (ID 314) halves damage from
**contact** moves in Pokémon Champions only; mainline calculations do not apply it.
Contact metadata is carried from the database through `MoveState` into the calculation.

### In-app labels

- **Available in M-C** — the ID is in this regulation.
- **New in M-C** — the ID is in the catalog delta.
- **Champions-origin** — explicit provenance, not eligibility.

The Pokédex shows `Available in M-C` and `New in M-C` as separate filters; a species
card shows the M-C badge if **any** included form ID is eligible.

### Battle rules

- **66 Stat Points total, max 32 per stat**; each point adds one stat point at level 50.
  IVs fixed at 31. **Level 50** fixed.
- 21 Stat Alignments: Hardy, Docile, Bashful and Quirky are absent; Serious is the only
  neutral alignment; others use ±10 %.
- `HP = Base + SP + 75`; other stats are `floor((Base + SP + 20) × Alignment)`.
- Singles and doubles supported. Screens are `0.5×` in singles and `2732/4096` in
  doubles; spread moves use `0.75×` in doubles.

Shared rules live in `lib/features/calculator/models/battle_ruleset.dart` and
`lib/features/pokedex/models/stat_calculator.dart`.

### Item examples and generation rules

Both Roseli Berry rows are retained: ID `723` is canonical and M-C-eligible; ID `2279`
is the upstream duplicate alias with curated effect text and `aliasOf: 723`. Ordinary
ItemDex browsing hides the alias; exact-ID search and the alias toggle reveal it.

Item introduction generation comes from the earliest PokéAPI item-game-index generation
when available. In this snapshot 2,175 item rows have generation metadata and 48 remain
unknown; Mega Stones `2243` and `2265` are among the unknown-generation records and are
deliberately **not** back-filled from their IDs. Mega Stones are enriched in place and
classified as held evolution items even if upstream omits a holdable tag.

### Sources

- [Regulation Set M-C announcement](https://www.pokemon.com/us/news/get-ready-for-regulation-set-m-c-in-pokemon-champions)
- [Pokémon Champions version history](https://www.nintendo.com/en-gb/Support/Purchases-Subscriptions/Games/How-to-Update-Pokemon-Champions-3079895.html)
- [Pokémon Asia press release](https://asia-press.portal-pokemon.com/press-release/pokemon-champions_20260830/)
- [Serebii](https://x.com/SerebiiNet/status/2097566417113551156) — community
  cross-check for Mega Golisopod and Mega Baxcalibur abilities only

---

## 5. Pokémon Legends: Z-A support

LibreDex bundles a curated overlay of **49 Mega form records** (PokéAPI form IDs
`10278–10326`), including forms introduced with Legends: Z-A and its Mega Dimension
DLC, released **10 December 2025**. This is form and battle metadata — not a story
guide, DLC walkthrough, or a claim that every form is usable in Champions.

### Mega Dimension DLC coverage

**23 local form records** (`10304–10326`) across 18 base species. These are data IDs,
not a claim of 23 distinct Mega Evolutions — the local rows keep Raichu X/Y, both
Meowstic sex records, both Magearna appearances and all three Tatsugiri appearances
separate. Use the bundled ID list for LibreDex record counts; other references use
different conventions.

Mega Raichu X/Y, Mega Chimecho, Mega Baxcalibur, Mega Zeraora, Mega Absol Z, Mega
Garchomp Z, Mega Lucario Z, Mega Heatran, Mega Darkrai, Mega Golurk, Mega Golisopod,
Mega Glimmora, Mega Scovillain, Mega Staraptor, Mega Meowstic (Male/Female), Mega
Crabominable, Mega Magearna (+ Original Color), Mega Tatsugiri (Curly/Droopy/Stretchy).

### Base-game records

**26 form records** (`10278–10303`): Clefable, Victreebel, Starmie, Dragonite,
Meganium, Feraligatr, Skarmory, Froslass, Emboar, Excadrill, Scolipede, Scrafty,
Eelektross, Chandelure, Chesnaught, Delphox, Greninja, Pyroar, Eternal Flower Floette,
Malamar, Barbaracle, Dragalge, Hawlucha, Zygarde, Drampa, Falinks.

### Form flags, origin and eligibility

- Each overlay Mega form carries the `mega` and `legendsZA` flags. `champions` is used
  **only** where curated Champions ability data exists; it does not mean the form is
  eligible in every Champions regulation.
- M-C membership comes only from `champions_regulation_mc.json`. Never turn a
  Legends: Z-A origin tag into Champions eligibility, and never infer either from the
  numeric ID.
- Mega Stone item rows are retained and enriched in place with explicit per-record
  provenance. PokéAPI form IDs and sprite URLs provide stable keys; display names,
  flags, notes, ability assignments and known bad-artwork exceptions are reviewed local
  metadata.

### Effort Levels and NatureDex

Legends: Z-A uses Effort Levels rather than the mainline EV-growth model. NatureDex
explains the distinction while keeping the `+10 % / −10 %` modifier display for
side-by-side comparison. The comparison display is **not** a claim that the games share
an identical stat-building system.

### Sources

- [Mega Dimension launch](https://legends.pokemon.com/en-us/news/mega-dimension-launch)
  and [trailer announcement](https://legends.pokemon.com/en-us/news/december-09-mega-dimension-trailer)
- [Mega Zeraora announcement](https://legends.pokemon.com/en-us/news/mega_zeraora)
- [Z-A Battle Club ranked-battle rewards](https://legends.pokemon.com/en-gb/news/battle-club-ranked-battles)
  — provenance for Baxcalibrite
- Serebii's [Legends: Z-A Mega list](https://www.serebii.net/legendsz-a/megaevolutions.shtml)
  and [Mega Dimension list](https://www.serebii.net/legendsz-a/dlc-megaevolutions.shtml);
  [Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Mega_Dimension) counts species,
  Mega identities and alternate forms separately

No single official page enumerates every bundled record. `forms_extra.json` and its
metadata are the app's exact snapshot. Sprite URLs can change upstream —
`tools/fix_sprite_urls.py` records known invalid renders and the fallback behavior. The
Eternal Flower Floette shiny URL is intentionally blank because that form cannot
officially be shiny and the upstream render is broken.

---

## 6. Filters and counts

Filters within a screen combine as constraints; a Pokémon failing any active constraint
is excluded. Search text is managed by its search field, independently of the removable
filter chips.

### Pokédex

- **Types:** one selected type matches either slot; two require the exact dual-type pair
  in either order. Multiple selected generations are alternatives.
- **Classifications:** Legendary, Mythical, Ultra Beast, Paradox and **Mega Evolution**
  are alternatives within that group. Favorites, team, shiny-art availability and M-C
  eligibility/newness are separate constraints. `Shiny display` changes the artwork;
  `Has Shiny Form` filters out records with no shiny URL.
- **Roster metadata:** generation, egg group, evolution stage, outgoing-evolution and
  single-stage flags, and incoming evolution-method category use stored metadata — the
  UI never infers them from an ID threshold.
- **Ability compatibility:** matched against ability name/description on the Pokémon's
  own junction rows. `Hidden Ability Only` reads `pokemon_abilities_table.isHidden` for
  that Pokémon, so a hidden slot on one species does not make the ability hidden
  everywhere. It works without an ability-name query.
- **Stats:** BST range, per-stat minimums and EV-yield selection can be combined.
- **Result count:** unique National Dex numbers with at least one surviving form — not
  form rows. Cards group forms by Dex number and open the complete local form group.

**Search is answered by the species, never by its forms.** A form's own name, regional
name and Champion ability names cannot decide whether its species appears. Forms remain
reachable through the detail page and through the Mega Evolution filter. Species with
more than one form carry an `N FORMS` badge, where the count includes the species' own
row (Charizard reads `4 FORMS`). See [`plans.md`](../plans.md).

### MoveDex

- Search, type, damage class, generation, power/accuracy/PP ranges, description-effect
  keyword and source/rules filters combine.
- **22 battle-property switches** share one definition for label, state, predicate,
  reset and active chip: positive priority, negative priority, contact, non-contact,
  status, damaging, multi-hit, recoil, draining, healing, switching, protective,
  recharge, sound, punching, biting, powder, pulse/aura, ballistic, slicing, wind,
  dance.
- Contact and priority predicates use the persisted `Move` record. Enabling both sides
  of a mutually exclusive pair naturally gives no results.
- `Available in M-C`, `New to M-C`, `Champions-origin`, `Legends: Z-A`, `DLC` and
  `signature` are distinct filters.
- **Result count:** filtered move records, not learnset pairs.

### AbilityDex

Filters cover generation, effect tags, Champions origin, M-C availability/newness,
Legends: Z-A provenance and hidden status. The hidden-status list means **at least one**
Pokémon–ability junction marks that ability hidden; the detail view marks the specific
Pokémon whose junction says so. **Result count:** ability records, not the number of
Pokémon using them.

### ItemDex

Filters cover source category/subcategory/tag, held/battle/evolution roles, DLC
provenance, M-C availability/newness, explicit Champions/Legends: Z-A origin, effect
keyword and whether to show upstream aliases. **Result count:** visible item rows; a
shown alias is a separate row. Bulk artwork reports unique non-alias artwork URLs and
counts verified stored downloads, not item rows or attempted requests.

### Randomizer

The settings sheet offers three pool sources and a roll size:

1. **Everything** — any bundled Pokémon/form, independent of the current filter.
2. **Active Dex Search & Filters** — the current filtered Pokédex rows.
3. **Custom Criteria Rules** — selected types, generations, BST range, optionally
   final-evolution-or-single-stage entries.

**Roll size** is `Single` (1) or `Team of 6`. A team picks **without replacement**, so
the six are distinct; a pool smaller than six yields what it has. `Instant Roll on Tap`
skips the sheet on a normal tap; long-press still opens customization. Settings persist.

---

## 7. Battle calculations

- Move priority and contact flags are persisted in `move_table`. The move picker
  displays them, `MoveState` carries them into the engine, and the engine uses the same
  fields for priority/contact-dependent effects such as Psychic Terrain, Unseen Fist and
  Champions-only Aura Guard.
- Both mainline and Champions engines use `StatEngine` for critical-stage handling.
  Critical hits ignore the relevant negative attacking stages and positive defending
  stages. Body Press uses the user's Defense; Foul Play uses the target's Attack source.
- Aura Guard is conditional on Champions rules **and** contact metadata. The general move
  record remains valid outside Champions.
- The duel view creates one engine result per render pass and passes it to
  `DamageSummaryCard` — do not add a second identical `BattleEngine.calculate` call. The
  **RAW SANDBOX** stays separate and must not be described as the full engine.

### Showdown parity

The damage path matches Pokémon Showdown's `gen789.ts` exactly:

- **Chained modifiers round once.** `chainMods` accumulates
  `M = (M * mod + 2048) >> 12` and clamps once at the end — not per step.
- **Overflow wrapping.** 16-bit and 32-bit wrapping at the same points as the game.
- **Exact fractions.** Game values are 4096-based: Muscle Band / Wise Glasses `4505`,
  Punching Glove `4506`, type-boost items and plates `4915`, Technician / Sharpness /
  Strong Jaw / Mega Launcher / Steely Spirit `6144`, Sheer Force / Analytic / Tough
  Claws / Punk Rock `5325`, Life Orb `5324`, Expert Belt `4915` as a **final** modifier.
- **Base power is bounded** `(41, 2097152)`; attack and defense `(410, 131072)`.
- **Expert Belt belongs to the final modifier chain**, not base power.

Parity is pinned by `test/damage_showdown_parity_test.dart` and
`test/sandbox_damage_parity_test.dart` over real Gen 9 matchups.

### Known limits

- Mega Golisopod and Mega Baxcalibur ability assignments have community corroboration
  only; do not present them as official announcements.
- Python validators are structural and selective.
- The Foul Play critical-hit/stage interaction has not been independently verified
  against an authoritative current reference; treat it as needing focused source review
  before claiming exact simulator parity.

---

## 8. Testing

**Structural asset validators** (Python, JSON invariants), **Flutter tests** (Dart
unit/widget behaviour) and **device/release checks** are three different things. A
validator or test passing does not prove every source claim or every in-game mechanic.

### Flutter test inventory

| File | Coverage |
| --- | --- |
| `battle_engine_test.dart` | Damage results, critical stat-stage behaviour, Body Press/Foul Play stat sources, data-backed move effects |
| `damage_math_test.dart`, `showdown_parity_test.dart`, `showdown_parser_test.dart`, `move_gimmicks_test.dart` | Integer damage math, Showdown comparisons/parsing, move gimmicks |
| `damage_showdown_parity_test.dart`, `sandbox_damage_parity_test.dart` | Damage parity against Showdown over real Gen 9 matchups |
| `champions_ruleset_test.dart`, `champions_regulation_test.dart` | Champions rules; the ID-based M-C catalog and delta |
| `itemdex_entry_test.dart` | Mega Stone records/provenance, Roseli Berry alias, M-C eligibility versus origin |
| `forms_extra_asset_test.dart`, `sprite_urls_asset_test.dart`, `species_gender_overrides_test.dart` | Curated overlay fields, sprite URL exceptions, species gender data |
| `held_item_placement_test.dart` | Held-item placement in the damage formula |
| `randomizer_settings_test.dart`, `random_roll_overlay_test.dart` | Randomizer settings persistence/criteria; the roll overlay, single and team |
| `form_count_badge_test.dart` | The `N FORMS` badge and card rendering |
| `pokemon_detail_render_test.dart`, `section_back_stack_test.dart`, `pokedex_layout_test.dart`, `widget_test.dart` | Detail rendering, navigation back-stack, layout geometry, app widget behaviour |
| `complete_improvement_plan_test.dart` | MoveDex/AbilityDex/Pokédex metadata checks |
| `test/viewmodels/` | 87 tests: stat calculator (22), damage calculator (16), Pokédex search (25), stat comparison (24) |

```bash
flutter test                                    # full suite
flutter test test/battle_engine_test.dart       # one focused suite
```

### Asset validators

See [§2](#2-data-pipeline-and-provenance) for scope and commands.

### Formatting and static analysis

```bash
dart format lib test
flutter analyze
dart format --set-exit-if-changed lib test      # check without writing
```

Use the project's Flutter/Dart SDK version from `pubspec.yaml`/CI; do not regenerate
Drift output with a different incompatible version.

### Device and manual checks

- Test narrow phone and wide/tablet layouts at the actual **700 logical-pixel**
  adaptive-navigation threshold.
- Confirm the Pokédex count is species-based while detail navigation retains all
  matching forms; result-count announcements should reach assistive technology.
- Exercise every filter's individual chip removal and **Clear all**, especially the
  no-query `Hidden Ability Only` filter and all MoveDex property switches.
- Check M-C availability versus origin labels independently in all four dexes.
- Verify item alias visibility/search, unknown-generation sorting, Mega Stone
  categories and bulk download totals.
- Test all three randomizer pool modes **and** both roll sizes, including empty pools,
  persisted settings, instant tap and long-press customization.
- Test online evolution lookup, offline fallback, complete branches in both directions
  and form-specific navigation.
- Confirm the main battle view uses one engine result; keep the raw sandbox separate.
- Test real device sizing, screen readers, touch targets, network failure, cached
  artwork and user-requested offline artwork.

---

## 9. Release checklist

A checked item means it was actually performed against the candidate build. Do not copy
a previous release's checkmarks forward.

### Data, provenance and asset integrity

- [ ] Confirm the data snapshot date/game version and recheck official updates.
- [ ] Record upstream PokéAPI CSV commit/retrieval date when refreshing vendored tables;
      record community source commit and licence where applicable.
- [ ] Confirm M-C eligibility stays separate from origin flags and that no numeric-ID
      inference was introduced.
- [ ] Confirm existing Mega Stone rows were enriched rather than duplicated or dropped;
      verify explicit item aliases and unknown generations.
- [ ] Run `audit_libredex_data.py` and the specialized validators.
- [ ] Review every generated JSON diff: duplicate/missing IDs, stale learnsets, PP
      changes, ability mappings, form metadata, false provenance.
- [ ] Check artwork URLs and offline storage; distinguish attempted, succeeded, failed
      and unique non-alias counts.

### Drift database and migration

- [ ] Increment `schemaVersion` and add guarded migration code for any shape change.
- [ ] Regenerate `app_database.g.dart` with the compatible Drift builder.
- [ ] Increment `bundledDataVersion` when seeded content or decoding changed.
- [ ] Test fresh install, migration from supported older schemas, and bundled reseed.
- [ ] Confirm rollback behavior and that favorites/team/preferences survive a rebuild.

### Automated tests and code quality

- [ ] Run `dart format lib test` and review any diff.
- [ ] Run `flutter analyze` and resolve new issues.
- [ ] Run `flutter test`.
- [ ] Retain logs for the release record; do not describe unrun checks as passed.

### UI, accessibility and responsive behavior

- [ ] Test below and at/above **700 logical pixels**.
- [ ] Confirm navigation destinations, FeatureHub overflow, back-stack behavior and
      selected-section metadata are consistent.
- [ ] Confirm the Pokédex result count is unique species by National Dex, while
      MoveDex/AbilityDex/ItemDex counts describe filtered record rows.
- [ ] Test active filter chips and reset, including hidden ability without a text query.
- [ ] Test all randomizer pool modes and both roll sizes, including empty pools.
- [ ] Confirm form groups and both evolution directions are navigable online/offline.
- [ ] Verify screen-reader announcements, **44 × 44** minimum touch targets, contrast
      and keyboard behavior where applicable.

### Battle behavior

- [ ] Confirm mainline and Champions rulesets remain isolated where required.
- [ ] Confirm persisted priority/contact flags reach the picker and engine.
- [ ] Exercise critical hit stage handling, Body Press, Foul Play, Aura Guard and M-C PP
      overrides.
- [ ] Confirm the duel summary renders the existing `DamageResult` without a duplicate
      engine calculation.
- [ ] Compare selected cases against trusted mechanics references and record the cases
      and versions used.

### Documentation

- [ ] Update this reference and [`plans.md`](../plans.md) when sources or game support
      change.
- [ ] Update the data snapshot date and source attribution; distinguish official sources
      from community corroboration.
- [ ] Check [`NOTICE.md`](../NOTICE.md), README and build metadata.

### Before distributing

**Create `android/key.properties` and a keystore (git-ignored).** Signing is configured
in `build.gradle.kts` but reads from that file; without it the build is unsigned.

---

## 10. Standing notes

- **`Icons/` holds pre-staged platform icons.** `Icons/ios/` (22 files) and `Icons/web/`
  exist ahead of those platforms. `Icons/android/` is the source for the Play Store icon
  and is referenced by nothing at build time — `android/app/src/main/res/mipmap-*` is
  what ships. Do not delete it while iOS is planned.
- **Two test files are misnamed, not junk.** `widget_test.dart` is actually a
  PokedexScreen + `FormFacts` + `CombatUtils` + `GenderRatio` + `SpriteQuality` suite,
  and `complete_improvement_plan_test.dart` covers move properties, ability tags and
  Pokémon classification. Rename them when next touching either file.
- **`.metadata` and `.vscode/settings.json` are intentionally tracked.** Flutter
  documents `.metadata` as version-controlled; the VS Code setting affects Gradle
  build-configuration prompts.
- **The Pokédex `stream → filter → rebuild` path is the app's performance centre of
  gravity.** Optimisations elsewhere are unlikely to be felt. There is no known
  performance problem: the app is smooth while typing.
