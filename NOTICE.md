# Notices and third-party attribution

## LibreDex code

Copyright (c) 2026 Azam Usman. The LibreDex source code is licensed under the [MIT License](LICENSE).

## PokéAPI data and service

LibreDex includes reference data derived from PokéAPI and uses the PokéAPI service for live evolution-chain lookups. PokéAPI asks clients to cache resources and avoid unnecessary requests; LibreDex keeps successful online evolution lookups for the current app session and has a bundled fallback.

PokéAPI's license notice is reproduced below:

> Copyright (c) © 2013–2023 Paul Hallett and PokéAPI contributors (https://github.com/PokeAPI/pokeapi#contributing). Pokémon and Pokémon character names are trademarks of Nintendo.
>
> All rights reserved.
>
> Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
>
> 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
> 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
> 3. Neither the name of PokéAPI nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
>
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Source: [PokeAPI license](https://github.com/PokeAPI/pokeapi/blob/master/LICENSE.md).

## Pokémon artwork and trademarks

LibreDex requests artwork from the [PokeAPI sprites repository](https://github.com/PokeAPI/sprites). That repository's `LICENCE.txt` says that its image contents are copyright The Pokémon Company and distributes the repository under CC0 1.0 to the extent of the repository contributors' rights. Pokémon and Pokémon character names are trademarks of Nintendo.

The MIT license for LibreDex does not convey rights in Pokémon intellectual property. This notice is attribution, not legal advice; a maintainer should obtain legal advice before distributing the app in a jurisdiction or store with additional requirements.

## Pokémon Showdown and damage-calculation reference

Regulation and mechanics data trace to [Pokémon Showdown](https://github.com/smogon/pokemon-showdown), MIT License, Copyright (c) 2011–2026 Guangcong Luo and other contributors.

Damage-calculation formulas and test expectations were checked against [smogon/damage-calc](https://github.com/smogon/damage-calc), MIT License, Copyright (c) 2013–2025 Honko and other contributors.

## Champions regulation data

`assets/data/champions_regulation_mc.json` and the Pokémon Champions learnset data are derived from [pokemon-champions-data](https://github.com/vbbjandrade/pokemon-champions-data) (commit `df262d8f27ba94ce6c0a421c1f83b3e57b11ceb4`, snapshot 1 October 2026), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Changes made by LibreDex are recorded in the repository history.

## Pokédex descriptions

The short category labels (for example "Seed Pokémon") and the Pokédex description sentences in `assets/data/pokedex_entries.json` come from PokéAPI, which takes them from the Pokémon games. The description text is copyright Nintendo / Game Freak / The Pokémon Company and is included for reference only.

## Artwork, item images and Pokémon game content

Artwork and item images are not bundled in the app. The app loads them from the PokeAPI sprite repository, and the optional offline library stores copies on the user's device. The sprite repository states that its image contents are copyright The Pokémon Company. Their use here is for reference; LibreDex does not claim any rights in them.

## App icon

The LibreDex icon (`Icons/Icon.png`) is original artwork created for this project. It contains no Pokémon artwork.

## Trademarks

Pokémon and Pokémon character names are trademarks of Nintendo. LibreDex is an unofficial fan project and is not affiliated with, endorsed by or sponsored by Nintendo, Game Freak, Creatures or The Pokémon Company.

## Flutter and Dart packages

Each package is licensed under its own terms. The app's "Credits & licences" screen (Settings → Application Info) lists every package and its license text.
