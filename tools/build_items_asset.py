#!/usr/bin/env python3
"""Build assets/data/items.json from PokéAPI's public item API.

The checked-in asset is intentionally small and battle-focused so the ItemDex UI
works offline today. Run this script in a networked environment to replace it
with the full item catalog while preserving the same compact app-facing shape.
"""

from __future__ import annotations

import json
import sys
import time
import urllib.request
from pathlib import Path
from urllib.error import URLError

API = "https://pokeapi.co/api/v2"
OUT = Path("assets/data/items.json")


def get_json(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def english_effect(effects: list[dict], key: str) -> str:
    for effect in effects:
        if effect.get("language", {}).get("name") == "en":
            return effect.get(key) or ""
    return ""


def display_name(names: list[dict], fallback: str) -> str:
    for name in names:
        if name.get("language", {}).get("name") == "en":
            return name.get("name") or fallback
    return fallback.replace("-", " ").title()


def normalize_item(raw: dict) -> dict:
    category = raw.get("category") or {}
    attributes = raw.get("attributes") or []
    tags = [a.get("name", "").replace("-", " ") for a in attributes if a.get("name")]
    short = english_effect(raw.get("effect_entries") or [], "short_effect")
    description = english_effect(raw.get("effect_entries") or [], "effect") or short

    return {
        "id": raw["id"],
        "name": display_name(raw.get("names") or [], raw["name"]),
        "category": display_name(category.get("names") or [], category.get("name", "Item")),
        "subcategory": category.get("name", "item").replace("-", " ").title(),
        "shortEffect": short or "No effect text available.",
        "description": description or "No detailed effect text available.",
        "tags": tags,
    }


def main() -> int:
    try:
        index = get_json(f"{API}/item?limit=5000")
        results = index.get("results") or []
        if not results:
            print("No items returned; existing asset was left untouched.", file=sys.stderr)
            return 1

        items: list[dict] = []
        for i, item in enumerate(results, start=1):
            raw = get_json(item["url"])
            items.append(normalize_item(raw))
            if i % 100 == 0:
                print(f"Fetched {i}/{len(results)} items...")
                time.sleep(0.1)
    except (URLError, TimeoutError, OSError) as error:
        print(f"Could not fetch item data: {error}", file=sys.stderr)
        print("Existing asset was left untouched.", file=sys.stderr)
        return 1

    OUT.write_text(json.dumps(sorted(items, key=lambda x: x["name"]), separators=(",", ":")))
    print(f"Wrote {OUT} with {len(items)} items.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
