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
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


from concurrent.futures import ThreadPoolExecutor, as_completed

def main() -> int:
    try:
        index = get_json(f"{API}/pokemon?limit=20000")
        rows = index.get("results") or []
        yields: dict[str, dict[str, int]] = {}

        def fetch_ev(row: dict) -> tuple[int, dict[str, int]]:
            pokemon = get_json(row["url"])
            values: dict[str, int] = {}
            for stat in pokemon.get("stats") or []:
                effort = stat.get("effort") or 0
                if effort <= 0:
                    continue
                key = STAT_KEYS.get(stat.get("stat", {}).get("name"))
                if key:
                    values[key] = effort
            return (pokemon["id"], values)

        with ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(fetch_ev, row) for row in rows]
            for i, future in enumerate(as_completed(futures), start=1):
                p_id, values = future.result()
                if values:
                    yields[str(p_id)] = values
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
