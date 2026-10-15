/// Legal notices and credits shown inside the app.
///
/// Keep this text in sync with NOTICE.md, which is the complete reference.
abstract final class AppLegal {
  /// Keep equal to the `version:` name in pubspec.yaml.
  static const String version = '1.0.0';

  static const String disclaimer =
      'LibreDex is an unofficial, free and open-source fan project. It is not '
      'affiliated with, endorsed by or sponsored by Nintendo, Game Freak, '
      'Creatures or The Pokémon Company.\n\n'
      'Pokémon and Pokémon character names are trademarks of Nintendo. '
      'Pokémon artwork, sprites and game text are copyright their respective '
      'owners and are shown for reference only.';

  static const String credits = '''
LibreDex code
MIT License. Copyright (c) 2026 Azam Usman.

PokéAPI data and service
Reference data and Pokédex category labels are derived from PokéAPI
(BSD 3-Clause). Copyright (c) 2013–2023 Paul Hallett and PokéAPI contributors.

Artwork and item images
Loaded from the PokeAPI sprites repository. Images are copyright
The Pokémon Company. Used for reference only; not licensed to LibreDex.

Pokémon Champions regulation data
Derived from pokemon-champions-data by the Pokemon Champions Data Contributors,
licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/).
Commit df262d8, snapshot 1 October 2026.

Pokémon Showdown
Regulation and mechanics data trace to Pokémon Showdown, MIT License.
Copyright (c) 2011–2026 Guangcong Luo and other contributors.

Damage calculation reference
Formulas and test expectations were checked against smogon/damage-calc,
MIT License. Copyright (c) 2013–2025 Honko and other contributors.

Flutter, Dart and other packages
See "Open-source licences" for the full license text of every package.

Pokémon and Pokémon character names are trademarks of Nintendo.''';
}
