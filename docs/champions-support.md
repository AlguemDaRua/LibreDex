# Pokémon Champions support — Regulation Set M-C

**Data snapshot:** 1 October 2026 · **Game version:** 1.2.0  
**Official period:** 8 September–1 December 2026 in North American time zones (9 September–2 December UTC).

LibreDex keeps Champions support alongside its mainline calculator. Regulation Set M-C eligibility is stored separately from a record's game origin: an older move or item can be eligible in M-C without being new to Champions or originating there.

## 📚 M-C catalog and counts

The bundled, ID-based catalog is [`assets/data/champions_regulation_mc.json`](../assets/data/champions_regulation_mc.json). It contains eligible Pokémon/form, move, ability, and item IDs; the M-C delta; source-name-to-local-ID mapping; regulation descriptions; move PP adjustments; removed learnset pairs; and source attribution.

| Pool | M-C entries | Added versus M-B |
| --- | ---: | ---: |
| Pokémon roster records/forms | 345 | 35 local IDs: 29 non-Mega records/forms + 6 Mega forms |
| Moves | 510 | 14 |
| Abilities | 216 | 15 |
| Items | 140 | 7 |

The official announcement says **24 newly available Pokémon** and **six new Mega Evolutions**. Do not compare that headline number directly with a local ID count: the catalog tracks forms as separate IDs. In this snapshot, `newPokemonIds` contains 29 non-Mega records across 23 National Dex numbers; the exact local eligibility is the ID array, not a name-count guess.

### Newly available non-Mega roster rows

The CC BY 4.0 community roster snapshot used for the ID mapping includes these records/forms: Wigglytuff; Persian and Alolan Persian; Farfetch'd; Mr. Mime; Swalot; Salamence; Gogoat; Golisopod; Rillaboom; Cinderace; Inteleon; Thievul; Toxtricity (Amped and Low Key); Grapploct; Perrserker; Sirfetch'd; Pincurchin; Indeedee (Male and Female); Pawmot; Arboliva; Squawkabilly (Green, Blue, Yellow, and White Plumage); Mabosstiff; and Baxcalibur.

### Six Mega forms added to M-C

| Local ID | Form |
| ---: | --- |
| 10089 | Mega Salamence |
| 10307 | Mega Absol Z |
| 10309 | Mega Garchomp Z |
| 10310 | Mega Lucario Z |
| 10316 | Mega Golisopod |
| 10325 | Mega Baxcalibur |

### M-C delta lists

The 14 moves newly included in the M-C move pool are **Milk Drink, Shift Gear, Zing Zap, Snipe Shot, Jaw Lock, Octolock, Court Change, Drum Beating, Pyro Ball, Overdrive, Meteor Assault, Glaive Rush, Revival Blessing,** and **Double Shock**. Separately, **Slash** (move ID 163) becomes newly usable in the set; it is stored in `newlyUsableMoveIds` rather than being counted as an M-C-versus-M-B move-record addition.

The 15 abilities newly included in the pool are **Run Away, Liquid Ooze, Rattled, Grass Pelt, Emergency Exit, Stakeout, Psychic Surge, Grassy Surge, Libero, Punk Rock, Steely Spirit, Seed Sower, Thermal Exchange, Guard Dog,** and **Aura Guard**. These names were resolved from the catalog IDs against `abilities.json`; Aura Guard is the exception, custom local ability ID `314`, supplied through `forms_extra.json` and backed by the official Champions announcement. “New to M-C” means a pool delta, not that every listed ability was invented for Champions. Standard ability records remain shared with the wider Pokédex.

The seven items newly included are **Leek** (236), **Salamencite** (810), **Absolite Z** (2265), **Garchompite Z** (2267), **Lucarionite Z** (2268), **Golisopite** (2272), and **Baxcalibrite** (2275). Baxcalibrite is also an example of the label boundary: the [official Z-A Battle Club page](https://legends.pokemon.com/en-gb/news/battle-club-ranked-battles) gives it as a ranked-battle reward, while the M-C catalog separately makes it eligible in M-C.

## 📝 Version 1.2.0 M-C adjustments

- Wish and Strength Sap PP are **8** in M-C (previously 12).
- Slash becomes usable in the set.
- Politoed loses Pound; Archaludon loses Mirror Coat and Metal Burst from the M-C learnset.
- The learnset asset contains **21,488 `train` pairs** across the 345 mapped roster IDs. Rebuilding replaces stale `train` pairs only; non-`train` learning methods are preserved.
- The general move record is not rewritten to make regulation-specific PP/availability look universal. The move picker and relevant details show the M-C override explicitly.

## ✨ Mega abilities and Aura Guard

Curated form-ability overrides are applied during form-asset generation so that a standard source refresh does not silently replace reviewed ability assignments.

| Mega form | Ability | Source status |
| --- | --- | --- |
| Mega Absol Z | Sharpness | Official Pokémon Asia press release. |
| Mega Garchomp Z | Levitate | Official Pokémon Asia press release. |
| Mega Lucario Z | Aura Guard | Official Pokémon Asia press release. |
| Mega Golisopod | Tough Claws | Community corroboration (Serebii); not described here as an official announcement. |
| Mega Baxcalibur | Thermal Exchange | Community corroboration (Serebii); not described here as an official announcement. |

Aura Guard is local ability ID `314`. In Pokémon Champions only, it halves damage from **contact** moves. Contact metadata is carried from the database through `MoveState` into the battle calculation; mainline calculations do not apply Aura Guard's Champions effect. Mega Salamence uses the established Aerilate ability.

## 🧭 In-app labels and counts

- **Pokédex:** `Available in M-C` and `New in M-C` are separate filters. A species card shows the M-C badge if any included form ID is eligible; result counts are unique National Dex numbers, not form rows.
- **MoveDex, AbilityDex, ItemDex:** regulation eligibility/newness are separate from Champions-origin or Legends: Z-A-origin metadata. Move PP overrides are shown as regulation-specific.
- **Pokémon move details:** affected Pokémon show the Version 1.2.0 M-C removals; adjusted moves show general PP and M-C PP separately.
- **Damage calculator:** Champions mode can use M-C PP overrides, and Aura Guard is conditional on Champions rules plus the persisted contact flag.
- **FeatureHub:** explains M-C availability and groups the relevant Pokédex, MoveDex, AbilityDex, and ItemDex entry points.

“Available in M-C” means an ID is in this regulation. “New in M-C” means it is in the catalog delta. “Champions-origin” describes explicit provenance, not eligibility. Do not use ID thresholds as source labels: local move IDs `10001–10018` are Shadow moves, and Legends: Z-A provenance is attached to selected Mega Stone records. Item `2279` is the Roseli Berry alias; it is not a Mega Stone or a Champions-origin marker.

### Item examples and generation rules

Both Roseli Berry rows are retained: ID `723` is the canonical record and M-C-eligible; ID `2279` is the upstream duplicate alias with curated effect text and `aliasOf: 723`. Ordinary ItemDex browsing hides the alias to avoid showing the same item twice, but exact-ID search and the alias filter can reveal it.

Item introduction generation comes from the earliest PokéAPI item-game-index generation when available. In this snapshot, 2,175 item rows have generation metadata and 48 remain unknown; Mega Stone IDs `2243` and `2265` are among the unknown-generation records and are deliberately not back-filled from their IDs. Mega Stones are enriched in their existing records and classified as held evolution items even if upstream omits a holdable tag.

## 🧾 Provenance and maintenance

The M-C roster, move, ability, and item pool is cross-checked against [`vbbjandrade/pokemon-champions-data`](https://github.com/vbbjandrade/pokemon-champions-data), branch `data`, commit [`df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4`](https://github.com/vbbjandrade/pokemon-champions-data/commit/df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4), licensed CC BY 4.0. This is a community data source, not an official Pokémon source; commit/license metadata is retained in the catalog.

Official references:

- [Regulation Set M-C announcement](https://www.pokemon.com/us/news/get-ready-for-regulation-set-m-c-in-pokemon-champions) — regulation period, official headline count, and announced additions.
- [Pokémon Champions version history](https://www.nintendo.com/en-gb/Support/Purchases-Subscriptions/Games/How-to-Update-Pokemon-Champions-3079895.html) — Version 1.2.0 move availability, learnset, and PP changes.
- [Pokémon Asia press release](https://asia-press.portal-pokemon.com/press-release/pokemon-champions_20260830/) — Mega Absol Z, Mega Garchomp Z, Mega Lucario Z abilities and Aura Guard's contact-move effect.

Community cross-check for Mega Golisopod's Tough Claws and Mega Baxcalibur's Thermal Exchange: [Serebii's report](https://x.com/SerebiiNet/status/2097566417113551156). Community pages are not treated as official sourcing.

After changing overlays, use `python3 tools/validate_champions_data.py` for the validator's documented structural checks, and use `tools/apply_champions_regulation_learnsets.py` only with the reviewed M-C learnset source. See [Data pipeline](data-pipeline.md) for the full workflow and limitations.

## ⚔️ Champions battle rules

- **66 Stat Points total, max 32 per stat**; each point adds one stat point at level 50. IVs are fixed at 31.
- **Level 50** is fixed in Champions.
- Champions has 21 Stat Alignments: Hardy, Docile, Bashful, and Quirky are absent; Serious is the only neutral alignment. Other alignments use ±10%.
- Stat formulas: `HP = Base + SP + 75`; other stats are `floor((Base + SP + 20) × Alignment)`.
- Singles and doubles are supported. Screens are `0.5×` in singles and `2732/4096` in doubles; spread moves use `0.75×` in doubles.

The shared rules and stat formulas live in `lib/features/calculator/models/battle_ruleset.dart` and `lib/features/pokedex/models/stat_calculator.dart`. Regression tests exist but were not run in this implementation pass; see [Testing](testing.md).
