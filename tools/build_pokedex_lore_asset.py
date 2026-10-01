#!/usr/bin/env python3
"""Build English Pokédex flavor text and genera from PokéAPI.

Evolution chains and Pokémon generation/evolution metadata are built offline
from the pinned CSV extracts by ``tools/build_pokemon_metadata.py``. Keeping
these pipelines separate prevents this online lore refresh from replacing the
complete, form-aware bundled evolution graph with a thinner API response.

Run from any directory with ``python3 tools/build_pokedex_lore_asset.py``.
"""
from __future__ import annotations

import json
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.error import URLError

API = "https://pokeapi.co/api/v2"
ROOT = Path(__file__).resolve().parents[1]
ENTRIES_OUT = ROOT / "assets" / "data" / "pokedex_entries.json"


def get_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": "LibreDex data builder"})
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def clean(text: str) -> str:
    return re.sub(r"\s+", " ", text.replace("\f", " ").replace("\n", " ")).strip()


def english_genus(genera: list[dict]) -> str:
    for row in genera:
        if row.get("language", {}).get("name") == "en":
            return clean(row.get("genus") or "")
    return ""


def english_flavor(entries: list[dict]) -> str:
    for row in reversed(entries):
        if row.get("language", {}).get("name") == "en":
            return clean(row.get("flavor_text") or "")
    return ""


def main() -> int:
    try:
        index = get_json(f"{API}/pokemon-species?limit=20000")
        species = index.get("results") or []
        entries: dict[str, dict[str, str]] = {}

        def fetch_species(row: dict) -> tuple[int, dict[str, str]]:
            raw = get_json(row["url"])
            dex = int(raw["id"])
            entry = {
                "genus": english_genus(raw.get("genera") or []),
                "flavor": english_flavor(raw.get("flavor_text_entries") or []),
            }
            return dex, entry

        with ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(fetch_species, row) for row in species]
            for index, future in enumerate(as_completed(futures), start=1):
                dex, entry = future.result()
                entries[str(dex)] = entry
                if index % 100 == 0:
                    print(f"Fetched {index}/{len(species)} Pokédex entries...")
    except (URLError, TimeoutError, OSError, KeyError, ValueError) as error:
        print(f"Could not build Pokédex lore asset: {error}", file=sys.stderr)
        print("Existing lore asset was left untouched.", file=sys.stderr)
        return 1

    ENTRIES_OUT.parent.mkdir(parents=True, exist_ok=True)
    temporary = ENTRIES_OUT.with_suffix(ENTRIES_OUT.suffix + ".tmp")
    temporary.write_text(
        json.dumps(entries, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    temporary.replace(ENTRIES_OUT)
    print(f"Wrote {len(entries)} Pokédex entries to {ENTRIES_OUT}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
