# LibreDex 📱🌐

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org)
[![F-Droid](https://img.shields.io/badge/F--Droid-Active-blue?style=for-the-badge&logo=f-droid&logoColor=white)](https://f-droid.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

A beautiful, premium, **100% Offline-First & Open-Source Pokedex** application built with Flutter, Riverpod state management, and a high-performance relational database powered by Drift (SQLite). LibreDex features a striking AMOLED Dark Mode design and comprehensive game database sheets, tailored for absolute efficiency.

---

## 🌟 Key Features

* **Pokédex**: Clean grid interface listing Gen 1 Pokémons with dynamic type badges and shiny toggle animations.
* **Relational Details**: Inspect specific stats, stats modifier sliders (EV/IV configuration in real-time), and deep-relationship tables linking moves (categorized by learning method) and abilities.
* **MoveDex & AbilityDex**: Searchable databases containing complete power, category, description, and effects for all Gen 1 moves and abilities.
* **NatureDex**: Explore full Nature profiles, complete with dynamic high-contrast teals (up) and roses/reds (down) reflecting stat impact indicators.
* **Type Chart**: Complete defensive coverage matrix showing incoming damage multipliers dynamically for dual-type pairings.
* **Global Damage Calculator**:
  * *Normal (Basic) Tab*: Select a move and examine modified move power influenced by active **Weather** (Sun, Rain, Sandstorm, Snow) and **Terrain** (Electric, Grassy, Psychic, Misty) chips, complete with conditional gameplay cards (e.g. Blizzard accuracy, Solar Beam skips, Aurora Veil).
  * *Advanced (Showdown) Tab*: Search both the attacker and defender targets, configure EV presets, adjust Defensive items (Eviolite, Assault Vest, Leftovers), status indicators (Burn), and visualize OHKO probability banners with an overlay health bar.

---

## 🛠️ Technology Stack

* **UI Framework**: Flutter (Material 3 AMOLED theme, glassmorphic card widgets).
* **State Management**: Riverpod (with compile-time safe code generator integration).
* **Database**: Drift (relational SQLite binding allowing asynchronous streams and complex relation JOINs).
* **Networking**: Dio (used strictly for the initial offline sync phase).

---

## 🔒 Permission Transparency & Privacy

LibreDex operates under a **strictly transparent, 100% tracker-free, zero-analytics policy**. The application only requests a single permission from your device:

### `android.permission.INTERNET`
* **Why it is needed**: During the very first launch, the app connects to the public, open-source [PokéAPI](https://pokeapi.co) to perform a complete initial data synchronization. This populates your local SQLite database with all stats, moves, types, and descriptions.
* **Offline Operations**: Once this initial synchronization is complete, **LibreDex does not send or receive any network packets**. The internet connection can be completely disabled, and the app will continue to run with full database calculations, calculator features, and search tools completely offline.

---

## 🚀 Build and Installation

### Prerequisites
* Flutter SDK (Version `>=3.10.4`)
* Android SDK (for compiling the APK)

### Step 1: Clone the repository
```bash
git clone https://github.com/thedragon/LibreDex.git
cd LibreDex
```

### Step 2: Install dependencies & run generator
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Compile a release APK
```bash
flutter build apk --release --split-per-abi
```
The compiled APK will be available under `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🚧 Active Development & Road Map
LibreDex is actively maintained and expanding:
- [ ] Support for subsequent Generations (Gen 2 - Gen 9).
- [ ] Complete in-game held item database indexing.
- [ ] Full competitive Showdown Team Builder & Team Exporter dashboard.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
