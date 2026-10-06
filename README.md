# LibreDex

LibreDex is a free, open-source Pokédex and team-planning companion built with Flutter. It includes a Pokédex, MoveDex, AbilityDex, ItemDex, NatureDex, type chart, team builder and damage calculator.

There are no ads, subscriptions, in-app purchases or account sign-in requirements.

## How it works

LibreDex is **online-first for artwork**, with a local reference database and an optional artwork download for offline use.

- Pokémon artwork loads from the PokeAPI sprite repository as you browse. Previously viewed artwork is kept in the normal app cache.
- The evolution section asks PokéAPI for the current chain when a connection is available. Successful lookups are kept for the current app session; a bundled evolution record is used when the request is unavailable. You can turn off live evolution data in Settings to use only the bundled records.
- Pokémon, moves, abilities, learnsets and the supporting reference data ship with the app. On first launch, LibreDex copies the needed records into its local database. This setup step does not need the internet.
- Searches, stat calculations, type-chart calculations, team building and the bundled reference data remain available without a connection. Artwork that has not been cached or downloaded cannot appear offline.
- On first launch, LibreDex asks whether you want to download artwork for offline use. It does not start a download unless you choose **Download**; choose **Ask me later** to see the question next time, **Never ask again** to hide it, or use **Settings → Download artwork for offline use** whenever you want. This user-requested library is stored separately from the normal cache and survives cache cleanup.

## Internet and privacy

The Android `INTERNET` permission is present because the app needs it for live artwork, optional artwork downloads and online evolution lookups.

LibreDex has no accounts, advertising SDKs, analytics SDKs or payment processing. It does not send a LibreDex profile, favorites, team or calculator data to a LibreDex server. As with any internet connection, the services contacted for artwork and evolution data can receive standard request information such as your IP address and requested URL.

The external services used by the app are:

- [PokéAPI](https://pokeapi.co/) for live evolution-chain lookups.
- [PokeAPI sprites](https://github.com/PokeAPI/sprites) on GitHub for artwork.

## What is stored on the device

LibreDex stores its app data in private, app-specific storage. Other apps cannot read it without elevated device access.

| Data | Location and purpose |
| --- | --- |
| Reference database | `libredex.db` in the app documents directory. This is a SQLite database populated from the JSON files bundled with the app. |
| Browsing artwork cache | The Flutter image cache in the app cache directory. It holds artwork viewed online and may be reclaimed by the operating system when storage is low. |
| Offline artwork library | `offline_artwork` in LibreDex's private app-support directory. It contains only artwork the user deliberately downloaded, plus a manifest with quality and size. It is not removed by **Clear browsing artwork cache**. |
| Preferences | The platform's private preferences store: theme choice, last open section, favorites, team slots, team format, calculator ruleset, bundled-data version and the first-launch download-prompt choice. |

On a typical Android install, the database is under `/data/user/0/com.alguemdarua.libredex/app_flutter/`; the image cache and offline artwork library are in the same private app sandbox. Android version and manufacturer can change the exact path, and normal file managers cannot browse these folders.

Use **Settings → Clear browsing artwork cache** for temporary images, **Delete downloaded artwork** for the durable library, or **Delete everything** to erase LibreDex data before closing, uninstalling or restarting the app.

## Features & data snapshot

Bundled game-data snapshot: **1 October 2026**. LibreDex includes Pokémon Champions Regulation Set M-C data (game version 1.2.0), alongside Champions stat rules and Legends: Z-A forms. Regulation eligibility is kept separate from a record's game origin.

**Documentation:** [`docs/reference.md`](docs/reference.md) covers architecture, data
provenance, the database, game support, filter semantics, battle calculations, testing
and the release checklist. [`plans.md`](plans.md) is the roadmap — what is done, what is
next, and what has been deliberately deferred.

LibreDex includes full-fledged, multi-game features covering:
- **Adaptive Navigation (new in Aug 2026)**: Bottom `NavigationBar` on phones + `NavigationRail` on tablets, single `More` overflow — no hamburger + bar duplication. Theme toggle plays the wavy reveal from the tap point.
- **Shared Filter & Sort Framework**: Universal debouncing, search, sorting menus, active filter summaries, and result counters.
- **Advanced Pokédex Filtering**: Query by generation, form/source, egg group, evolution stage/method, M-C eligibility, ability compatibility, per-Pokémon hidden ability, stats, and type predicates.
- **Expanded MoveDex**: 22 property switches share data-backed predicates, filter chips, and reset behavior; includes priority/contact traits, move classes, and source/rule filters.
- **AbilityDex Metadata**: Hidden-ability flags live on Pokémon–ability junctions; AbilityDex filters abilities used in a hidden slot, and detail pages identify the exact Pokémon rows.
- **ItemDex Provenance & Offline Artwork**: Category/role/origin filters, explicit aliases, source-backed generation (unknown stays unknown), and bulk downloads counted by unique stored artwork.
- **Random Pokémon**: Choose the full catalog, active Pokédex results, or custom type/generation/BST/evolution criteria; roll a single pick or a team of six distinct Pokémon. Settings persist locally.
- **Responsive Pokédex Counts**: Cards group matching forms by National Dex; the result count reports unique species, while MoveDex/AbilityDex/ItemDex counts report filtered records. Search matches species only — forms stay reachable from the detail page, the Mega Evolution filter, or the `N FORMS` badge on a card.
- **NatureDex Alignments**: Supports both Pokémon Champions' 66 Stat Points / 21 Alignments (Singles & Doubles, Regulation M-C) and Legends: Z-A Effort Level rules.
- **Damage Calculator**: One shared battle-engine damage result per duel view, data-backed move priority/contact metadata, critical-stage handling, level 50 Champions rules, and a separate raw sandbox formula.

## Run from source

### Requirements

- Flutter SDK compatible with Dart `^3.10.4`
- Android SDK for Android builds

```bash
git clone https://github.com/AlguemDaRua/LibreDex.git
cd LibreDex
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

## License and attribution

The LibreDex source code is available under the [MIT License](LICENSE). That license applies to the code written for LibreDex; it does not grant rights to Pokémon names, characters, game data or artwork.

Pokémon and Pokémon character names are trademarks of Nintendo. LibreDex is an unofficial fan project and is not affiliated with, endorsed by or sponsored by Nintendo, Game Freak, Creatures or The Pokémon Company.

See [NOTICE.md](NOTICE.md) for PokéAPI and artwork attribution, including the third-party license notice.
