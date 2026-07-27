#!/usr/bin/env python3
"""Build assets/data/pokemon_ev_yields.json from PokéAPI pokemon data."""

from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path
from urllib.error import URLError

API = "https://pokeapi.co/api/v2"
OUT = Path("assets/data/pokemon_ev_yields.json")
STAT_KEYS = {
    "hp": "hp",
    "attack": "atk",
    "defense": "def",
    "special-attack": "spatk",
    "special-defense": "spdef",
    "speed": "spd",
}


def get_json(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def main() -> int:
    try:
        index = get_json(f"{API}/pokemon?limit=20000")
        rows = index.get("results") or []
        yields: dict[str, dict[str, int]] = {}
        for i, row in enumerate(rows, start=1):
            pokemon = get_json(row["url"])
            values: dict[str, int] = {}
            for stat in pokemon.get("stats") or []:
                effort = stat.get("effort") or 0
                if effort <= 0:
                    continue
                key = STAT_KEYS.get(stat.get("stat", {}).get("name"))
                if key:
                    values[key] = effort
            if values:
                yields[str(pokemon["id"])] = values
            if i % 100 == 0:
                print(f"Fetched {i}/{len(rows)} Pokémon...")
    except (URLError, TimeoutError, OSError, KeyError, ValueError) as error:
        print(f"Could not build EV yield asset: {error}", file=sys.stderr)
        print("Existing asset was left untouched.", file=sys.stderr)
        return 1

    OUT.write_text(json.dumps(yields, separators=(",", ":")))
    print(f"Wrote {OUT} with {len(yields)} EV yield rows.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
