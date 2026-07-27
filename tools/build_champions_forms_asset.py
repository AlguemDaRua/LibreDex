#!/usr/bin/env python3
"""Builds ``assets/data/forms_extra.json`` — the bundled Pokémon Champions /
Legends Z-A overlay.

The overlay adds officially numbered forms that are missing from the older
generated ``pokemon.json`` snapshot (new Mega Evolutions from Legends Z-A, the
Mega Dimension DLC and Pokémon Champions) plus small overrides for base rows
(e.g. the broken upstream Eternal Flower Floette shiny render).

How it works
------------
Base statistics, typings, National Dex numbers and abilities come straight from
the canonical PokéAPI CSV dataset (``pokeapi-master/data/v2/csv``). Curated,
human-reviewed metadata (display names, flags, notes) is embedded in
``CURATED_FORMS`` below, because PokéAPI does not carry display strings.

Usage
-----
    python3 tools/build_champions_forms_asset.py --csv-dir /path/to/pokeapi-master/data/v2/csv

If the CSV directory is missing or incomplete the script fails gracefully and
leaves any existing asset untouched. Nothing is ever written on failure.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

# Sprite URLs on the official PokeAPI/sprites repo. Every id in CURATED_FORMS
# was verified to exist (normal + shiny) before being listed here.
HOME_SPRITE = (
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/"
    "sprites/pokemon/other/home/{}.png"
)
HOME_SHINY_SPRITE = (
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/"
    "sprites/pokemon/other/home/shiny/{}.png"
)

# ---------------------------------------------------------------------------
# Curated form metadata.
#
# flags vocabulary:
#   mega       — Mega Evolution form
#   champions  — playable (ability + learnset) in Pokémon Champions
#   legendsZA  — introduced in Pokémon Legends Z-A (incl. Mega Dimension DLC)
#   provisional— marked when a form is not fully confirmed yet (kept off)
#
# "abilityInChampions": False means the form is confirmed for Legends Z-A but
# has no released Champions ability yet (Mega Dimension wave); the app then
# falls back to the base species abilities with a visible note.
# ---------------------------------------------------------------------------
CURATED_FORMS = [
    # id      display name                    form label                champions ability
    (10278, "Mega Clefable",                 "Mega",                  True),
    (10279, "Mega Victreebel",               "Mega",                  True),
    (10280, "Mega Starmie",                  "Mega",                  True),
    (10281, "Mega Dragonite",                "Mega",                  True),
    (10282, "Mega Meganium",                 "Mega",                  True),
    (10283, "Mega Feraligatr",               "Mega",                  True),
    (10284, "Mega Skarmory",                 "Mega",                  True),
    (10285, "Mega Froslass",                 "Mega",                  True),
    (10286, "Mega Emboar",                   "Mega",                  True),
    (10287, "Mega Excadrill",                "Mega",                  True),
    (10288, "Mega Scolipede",                "Mega",                  True),
    (10289, "Mega Scrafty",                  "Mega",                  True),
    (10290, "Mega Eelektross",               "Mega",                  True),
    (10291, "Mega Chandelure",               "Mega",                  True),
    (10292, "Mega Chesnaught",               "Mega",                  True),
    (10293, "Mega Delphox",                  "Mega",                  True),
    (10294, "Mega Greninja",                 "Mega",                  True),
    (10295, "Mega Pyroar",                   "Mega",                  True),
    (10296, "Mega Floette",                  "Mega",                  True),
    (10297, "Mega Malamar",                  "Mega",                  True),
    (10298, "Mega Barbaracle",               "Mega",                  True),
    (10299, "Mega Dragalge",                 "Mega",                  True),
    (10300, "Mega Hawlucha",                 "Mega",                  True),
    (10301, "Mega Zygarde",                  "Mega",                  False),
    (10302, "Mega Drampa",                   "Mega",                  True),
    (10303, "Mega Falinks",                  "Mega",                  True),
    (10304, "Mega Raichu X",                 "Mega X",                True),
    (10305, "Mega Raichu Y",                 "Mega Y",                True),
    (10306, "Mega Chimecho",                 "Mega",                  True),
    (10307, "Mega Absol Z",                  "Mega Z",                False),
    (10308, "Mega Staraptor",                "Mega",                  True),
    (10309, "Mega Garchomp Z",               "Mega Z",                False),
    (10310, "Mega Lucario Z",                "Mega Z",                False),
    (10311, "Mega Heatran",                  "Mega",                  False),
    (10312, "Mega Darkrai",                  "Mega",                  False),
    (10313, "Mega Golurk",                   "Mega",                  True),
    (10314, "Mega Meowstic (Male)",          "Mega (Male)",           True),
    (10315, "Mega Crabominable",             "Mega",                  True),
    (10316, "Mega Golisopod",                "Mega",                  False),
    (10317, "Mega Magearna",                 "Mega",                  False),
    (10318, "Mega Magearna (Original Color)", "Mega (Original Color)", False),
    (10319, "Mega Zeraora",                  "Mega",                  False),
    (10320, "Mega Scovillain",               "Mega",                  True),
    (10321, "Mega Glimmora",                 "Mega",                  True),
    (10322, "Mega Tatsugiri (Curly)",        "Mega (Curly)",          False),
    (10323, "Mega Tatsugiri (Droopy)",       "Mega (Droopy)",         False),
    (10324, "Mega Tatsugiri (Stretchy)",     "Mega (Stretchy)",       False),
    (10325, "Mega Baxcalibur",               "Mega",                  False),
    (10326, "Mega Meowstic (Female)",        "Mega (Female)",         True),
]

# Patches applied on top of rows that already exist in pokemon.json. "null"
# values are written through as empty strings to remove broken upstream data.
POKEMON_OVERRIDES = [
    {
        "id": 10061,
        "name": "Eternal Flower Floette",
        "shinySpriteUrl": "",
        "note": (
            "PokeAPI's shiny/10061.png render is an upside-down broken model; "
            "hidden on purpose so the UI shows its graceful no-shiny state. "
            "Eternal Flower Floette cannot be shiny officially."
        ),
    },
]

# New Champions abilities missing from the bundled abilities.json snapshot.
# Descriptions quoted from PokéAPI ability_prose (short_effect, English).
EXTRA_ABILITIES = [
    {
        "id": 308,
        "name": "Piercing Drill",
        "description": "When the Pokémon uses contact moves, it can hit even targets that are protecting themselves.",
    },
    {
        "id": 309,
        "name": "Dragonize",
        "description": "The Pokémon's Normal-type moves become Dragon-type moves and their power is boosted by 20%.",
    },
    {
        "id": 310,
        "name": "Mega Sol",
        "description": "The Pokémon can use its moves as if the weather were harsh sunlight.",
    },
    {
        "id": 311,
        "name": "Spicy Spray",
        "description": "When the Pokémon takes damage from a move, it burns the attacker.",
    },
    {
        "id": 312,
        "name": "Eelevate",
        "description": "The Pokémon floats off the ground, making it immune to Ground-type moves, as well as the Spikes, Toxic Spikes, and Sticky Web statuses. When the Pokémon knocks out a target with an attack, its highest stat is boosted by 1 stage.",
    },
    {
        "id": 313,
        "name": "Fire Mane",
        "description": "Boosts the power of the Pokémon's Fire-type moves by 50%.",
    },
]

TYPE_NAMES = {
    1: "normal", 2: "fighting", 3: "flying", 4: "poison", 5: "ground",
    6: "rock", 7: "bug", 8: "ghost", 9: "steel", 10: "fire", 11: "water",
    12: "grass", 13: "electric", 14: "psychic", 15: "ice", 16: "dragon",
    17: "dark", 18: "fairy",
}


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    print("Existing assets were left untouched.", file=sys.stderr)
    sys.exit(1)


def load_csv_map(csv_dir: Path, name: str, key_field: str):
    path = csv_dir / name
    if not path.exists():
        fail(f"missing required CSV: {path}. Pass --csv-dir pointing at data/v2/csv.")
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--csv-dir",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "tools" / "data" / "pokeapi-csv",
        help="Directory with PokéAPI v2 CSV files (pokemon.csv, pokemon_stats.csv, ...). "
        "Download https://github.com/PokeAPI/pokeapi/archive/refs/heads/master.tar.gz and extract first.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "assets" / "data" / "forms_extra.json",
    )
    args = parser.parse_args()

    wanted_ids = [row[0] for row in CURATED_FORMS]
    if len(wanted_ids) != len(set(wanted_ids)):
        fail("CURATED_FORMS contains duplicate ids.")

    pokemon_rows = {int(r["id"]): r for r in load_csv_map(args.csv_dir, "pokemon.csv", "id")}
    stats_rows = load_csv_map(args.csv_dir, "pokemon_stats.csv", "pokemon_id")
    type_rows = load_csv_map(args.csv_dir, "pokemon_types.csv", "pokemon_id")
    ability_rows = load_csv_map(args.csv_dir, "pokemon_abilities.csv", "pokemon_id")

    stats: dict[int, dict[int, int]] = {}
    for row in stats_rows:
        stats.setdefault(int(row["pokemon_id"]), {})[int(row["stat_id"])] = int(row["base_stat"])

    types: dict[int, list[tuple[int, int]]] = {}
    for row in type_rows:
        types.setdefault(int(row["pokemon_id"]), []).append((int(row["slot"]), int(row["type_id"])))

    abilities: dict[int, list[dict]] = {}
    for row in ability_rows:
        abilities.setdefault(int(row["pokemon_id"]), []).append(
            {
                "abilityId": int(row["ability_id"]),
                "isHidden": row["is_hidden"] == "1",
                "slot": int(row["slot"]),
            }
        )

    # Display names for every ability id so the overlay asset stays
    # self-contained (search never has to join back to abilities.json).
    ability_display_names: dict[int, str] = {
        a["id"]: a["name"] for a in EXTRA_ABILITIES
    }
    abilities_csv = args.csv_dir / "abilities.csv"
    if abilities_csv.exists():
        with abilities_csv.open(newline="") as handle:
            for row in csv.DictReader(handle):
                slug = row["identifier"].split("-")
                ability_display_names.setdefault(
                    int(row["id"]), " ".join(part.capitalize() for part in slug)
                )
    else:
        print("warning: abilities.csv not found; bundle ability names may be missing from search aliases.", file=sys.stderr)

    forms = []
    problems = []
    for poke_id, display_name, form_label, has_champions_ability in CURATED_FORMS:
        base = pokemon_rows.get(poke_id)
        if base is None:
            problems.append(f"{display_name} (#{poke_id}): no pokemon.csv row — CSV dataset too old?")
            continue
        stat_map = stats.get(poke_id)
        if not stat_map or set(stat_map) != {1, 2, 3, 4, 5, 6}:
            problems.append(f"{display_name} (#{poke_id}): missing or partial base stats.")
            continue
        type_slots = sorted(types.get(poke_id, []))
        if not type_slots:
            problems.append(f"{display_name} (#{poke_id}): missing type rows.")
            continue

        flags = ["mega", "legendsZA"]
        if has_champions_ability:
            flags.append("champions")
        form_abilities = abilities.get(poke_id, [])
        if has_champions_ability and not form_abilities:
            problems.append(f"{display_name} (#{poke_id}): expected a Champions ability row, found none.")
            continue

        species_name = base["identifier"].split("-mega")[0]
        forms.append(
            {
                "id": poke_id,
                "name": display_name,
                "form": form_label,
                "nationalDexNumber": int(base["species_id"]),
                "pokedexIdentifier": species_name,
                "type1": TYPE_NAMES[type_slots[0][1]],
                "type2": TYPE_NAMES[type_slots[1][1]] if len(type_slots) > 1 else None,
                "baseHp": stat_map[1],
                "baseAtk": stat_map[2],
                "baseDef": stat_map[3],
                "baseSpAtk": stat_map[4],
                "baseSpDef": stat_map[5],
                "baseSpd": stat_map[6],
                "isLegendary": False,
                "isMythical": False,
                "isParadox": False,
                "isUltraBeast": False,
                "spriteUrl": HOME_SPRITE.format(poke_id),
                "shinySpriteUrl": HOME_SHINY_SPRITE.format(poke_id),
                "abilities": form_abilities,
                "abilityNames": [
                    ability_display_names.get(a["abilityId"], "Ability #{}".format(a["abilityId"]))
                    for a in form_abilities
                ],
                "championsAbility": has_champions_ability,
                "flags": flags,
                "provisional": False,
            }
        )

    if problems:
        for problem in problems:
            print(f"validation problem: {problem}", file=sys.stderr)
        fail("Overlay not written. Refresh the CSV dataset or adjust CURATED_FORMS.")

    overlay = {
        "meta": {
            "title": "LibreDex forms overlay — Pokémon Champions / Legends Z-A",
            "source": "PokéAPI CSV master (official ids 10278-10326) cross-checked with Serebii Legends Z-A & Pokémon Champions pages",
            "idNamespace": "Official PokéAPI form ids (10278..10326); no collisions with the bundled pokemon.json snapshot",
            "flags": {"mega": "Mega Evolution", "champions": "usable in Pokémon Champions", "legendsZA": "introduced in Pokémon Legends Z-A"},
        },
        "pokemon": forms,
        "extraAbilities": EXTRA_ABILITIES,
        "pokemonOverrides": POKEMON_OVERRIDES,
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    tmp = args.out.with_suffix(".tmp")
    tmp.write_text(json.dumps(overlay, ensure_ascii=False, indent=2) + "\n")
    tmp.replace(args.out)
    print(f"Wrote {args.out} with {len(forms)} forms, "
          f"{len(EXTRA_ABILITIES)} new abilities and {len(POKEMON_OVERRIDES)} overrides.")


if __name__ == "__main__":
    main()
