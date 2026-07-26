#!/usr/bin/env python3
"""Build flavor text/genus and local evolution-chain assets from PokéAPI.

Run this in a networked environment. Existing assets are left untouched on
failure so the app always keeps a usable offline bundle.
"""

from __future__ import annotations

import json
import re
import sys
import urllib.request
from pathlib import Path
from urllib.error import URLError

API = "https://pokeapi.co/api/v2"
ENTRIES_OUT = Path("assets/data/pokedex_entries.json")
EVOS_OUT = Path("assets/data/evolution_chains.json")


def get_json(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=30) as response:
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


def species_id(url: str) -> int:
    return int([part for part in url.split("/") if part][-1])


def trigger_text(detail: dict) -> str:
    parts: list[str] = []
    if detail.get("min_level") is not None:
        parts.append(f"Lvl {detail['min_level']}")
    for key, prefix in (("item", ""), ("held_item", "Hold "), ("known_move", "Know ")):
        value = detail.get(key)
        if value:
            parts.append(prefix + value["name"].replace("-", " ").title())
    if detail.get("min_happiness") is not None:
        parts.append("High Friendship")
    if detail.get("time_of_day"):
        parts.append(f"({detail['time_of_day'].title()})")
    if parts:
        return " ".join(parts)
    trigger = detail.get("trigger", {}).get("name")
    return "Trade" if trigger == "trade" else "Level Up"


def walk_chain(node: dict, steps: list[dict]) -> None:
    from_id = species_id(node["species"]["url"])
    for child in node.get("evolves_to") or []:
        to_id = species_id(child["species"]["url"])
        details = child.get("evolution_details") or [{}]
        steps.append({"from": from_id, "to": to_id, "trigger": trigger_text(details[0])})
        walk_chain(child, steps)


def main() -> int:
    try:
        index = get_json(f"{API}/pokemon-species?limit=20000")
        species = index.get("results") or []
        entries: dict[str, dict] = {}
        evolution_urls: dict[str, str] = {}

        for i, row in enumerate(species, start=1):
            raw = get_json(row["url"])
            dex = raw["id"]
            entries[str(dex)] = {
                "genus": english_genus(raw.get("genera") or []),
                "flavor": english_flavor(raw.get("flavor_text_entries") or []),
            }
            evo_url = raw.get("evolution_chain", {}).get("url")
            if evo_url:
                evolution_urls.setdefault(evo_url, str(dex))
            if i % 100 == 0:
                print(f"Fetched {i}/{len(species)} species...")

        chains: dict[str, list[dict]] = {}
        for url, root_dex in evolution_urls.items():
            raw = get_json(url)
            steps: list[dict] = []
            walk_chain(raw["chain"], steps)
            if steps:
                chains[root_dex] = steps
    except (URLError, TimeoutError, OSError, KeyError, ValueError) as error:
        print(f"Could not build Pokédex lore assets: {error}", file=sys.stderr)
        print("Existing assets were left untouched.", file=sys.stderr)
        return 1

    ENTRIES_OUT.write_text(json.dumps(entries, separators=(",", ":")))
    EVOS_OUT.write_text(json.dumps(chains, separators=(",", ":")))
    print(f"Wrote {len(entries)} Pokédex entries and {len(chains)} evolution chains.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
