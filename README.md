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

## Features & Enhancements

LibreDex is **100% up to date as of 08 Aug 2026** — Pokémon Champions **66 SP / 21 Alignments** and Legends: Z-A **Mega Dimension DLC (10 Dec 2025, 49 Megas)** are fully bundled and the damage engine is Showdown integer-parity (singles & doubles, spread `0.75×`, screens `0.5`/`2732`).

LibreDex includes full-fledged, multi-game features covering:
- **Adaptive Navigation (new in Aug 2026)**: Bottom `NavigationBar` on phones + `NavigationRail` on tablets, single `More` overflow — no hamburger + bar duplication. Theme toggle plays the wavy reveal from the tap point.
- **Shared Filter & Sort Framework**: Universal debouncing, search, sorting menus, active filter summaries, and result counters.
- **Advanced Pokédex Filtering**: Query Pokémon by generation, stage, form source (Alola, Galar, Hisui, Paldea, Champions, Legends: Z-A), and complex dual-type predicates.
- **Expanded MoveDex (27 Fields)**: Detailed property search for priority, contact, sound-based, punching, slicing, wind, dance, multi-hit, and battle property configurations.
- **AbilityDex Metadata**: Filter standard and hidden abilities affecting Weather, Terrain, Healing, Stats, Status, Damage, and more.
- **Offline ItemDex Caching**: Durable artwork, fallbacks, category fallback icons, and manual bulk downloader with real-time download progress.
- **NatureDex Alignments**: Supports both Pokémon Champions 66 SP / 21 Alignments (Singles & Doubles, Regulation M-B) and Legends: Z-A Effort level rules with responsive mobile/tablet displays.
- **Damage Calculator**: Showdown-parity integer engine — level 50 (Champions) / 1-100 (mainline), stages, weather, Tera, Protect/Unseen Fist, spread `0.75×`, Helping Hand `1.5×`, Life Orb `1.3×`, and more.

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
