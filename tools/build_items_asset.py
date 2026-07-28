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
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as response:
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


from concurrent.futures import ThreadPoolExecutor, as_completed

def main() -> int:
    try:
        index = get_json(f"{API}/item?limit=5000")
        results = index.get("results") or []
        if not results:
            print("No items returned; existing asset was left untouched.", file=sys.stderr)
            return 1

        items: list[dict] = []
        def fetch_one(item: dict) -> dict:
            raw = get_json(item["url"])
            return normalize_item(raw)

        with ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(fetch_one, item) for item in results]
            for i, future in enumerate(as_completed(futures), start=1):
                items.append(future.result())
                if i % 100 == 0:
                    print(f"Fetched {i}/{len(results)} items...")

    except (URLError, TimeoutError, OSError) as error:
        print(f"Could not fetch item data: {error}", file=sys.stderr)
        print("Existing asset was left untouched.", file=sys.stderr)
        return 1

    OUT.write_text(json.dumps(sorted(items, key=lambda x: x["name"]), separators=(",", ":")))
    print(f"Wrote {OUT} with {len(items)} items.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
