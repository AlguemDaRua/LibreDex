#!/usr/bin/env python3
"""Build and enrich ``assets/data/items.json`` from PokéAPI.

The app-facing asset keeps PokéAPI records plus locally curated descriptions,
tags, generation metadata, provenance, and explicit duplicate aliases. M-C
eligibility remains in ``champions_regulation_mc.json`` and is never copied
into item-origin tags.

Run from any directory with ``python3 tools/build_items_asset.py``.
"""
from __future__ import annotations

import csv
import json
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.error import URLError

API = "https://pokeapi.co/api/v2"
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "data" / "items.json"
DATA = ROOT / "tools" / "data"
GAME_INDICES = DATA / "item_game_indices.csv"
OVERRIDES = DATA / "item_metadata_overrides.json"


def get_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": "LibreDex data builder"})
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


def _normalized(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", value.lower()).strip()


def load_generation_indices() -> dict[int, int]:
    if not GAME_INDICES.is_file():
        raise FileNotFoundError(f"missing item generation source CSV: {GAME_INDICES}")
    generations: dict[int, int] = {}
    with GAME_INDICES.open(newline="", encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            item_id = int(row["item_id"])
            generation_id = int(row["generation_id"])
            # The earliest generation in which the item has a game index is
            # its introduction; later games merely reuse the same item.
            generations[item_id] = min(generations.get(item_id, generation_id), generation_id)
    return generations


def preserve_curated_data(
    items: list[dict],
    existing_by_id: dict[int, dict],
    generation_by_id: dict[int, int],
    overrides: dict,
) -> list[dict]:
    aliases = {int(key): int(value) for key, value in overrides.get("aliases", {}).items()}
    tags_by_id = {
        int(key): {str(tag) for tag in values}
        for key, values in overrides.get("tagsById", {}).items()
    }
    generation_overrides = {
        int(key): int(value)
        for key, value in overrides.get("generationOverrides", {}).items()
    }

    items_by_id = {int(row["id"]): row for row in items}
    placeholder = {"", "No effect text available.", "No detailed effect text available."}

    # Retain every checked-in row, including records absent from a partial or
    # newer upstream response. Existing useful copy and tags are hand-curated.
    for item_id, old in existing_by_id.items():
        fresh = items_by_id.get(item_id)
        if fresh is None:
            items_by_id[item_id] = dict(old)
            continue
        for field in ("shortEffect", "description"):
            value = old.get(field, "")
            if value and value not in placeholder and not value.startswith("XXX new effect"):
                fresh[field] = value
        fresh["tags"] = sorted(set(fresh.get("tags", [])) | set(old.get("tags", [])))
        # Preserve other locally reviewed fields when the upstream record
        # returns no equivalent metadata (e.g. the duplicate Roseli stub).
        for field in ("generation", "aliasOf", "dlcSource"):
            if field not in fresh and field in old:
                fresh[field] = old[field]

    # Apply explicit, source-reviewed tags. In particular, don't infer a game's
    # origin from an ID range or from Regulation M-C eligibility.
    for item_id, tags in tags_by_id.items():
        row = items_by_id.get(item_id)
        if row is None:
            raise ValueError(f"item tag override references missing item id {item_id}")
        row["tags"] = sorted(set(row.get("tags", [])) | tags)

    # Mega Stones are held evolution items even where PokéAPI omits the
    # holdable attribute. Category membership is a source-provided property.
    for row in items_by_id.values():
        if _normalized(str(row.get("category", ""))) == "mega stones":
            row["tags"] = sorted(
                set(row.get("tags", [])) | {"holdable", "evolution", "mega stone"}
            )

    for item_id, row in items_by_id.items():
        alias_id = aliases.get(item_id)
        if alias_id is not None:
            if alias_id not in items_by_id:
                raise ValueError(f"item {item_id} aliases missing canonical item {alias_id}")
            row["aliasOf"] = alias_id
        elif item_id in aliases:
            row.pop("aliasOf", None)

        # ID 2279 is an upstream blank Roseli Berry stub; its curated canonical
        # relationship keeps the row intact and inherits the real item's intro.
        canonical_id = row.get("aliasOf")
        generation = generation_overrides.get(item_id)
        if generation is None:
            generation = generation_by_id.get(item_id)
        if generation is None and canonical_id is not None:
            canonical = items_by_id.get(int(canonical_id), {})
            generation = canonical.get("generation") or generation_by_id.get(int(canonical_id))
        if generation is None:
            generation = existing_by_id.get(item_id, {}).get("generation")
        row["generation"] = generation

    return sorted(items_by_id.values(), key=lambda row: (str(row["name"]).casefold(), int(row["id"])))


def main() -> int:
    try:
        if not OVERRIDES.is_file():
            raise FileNotFoundError(f"missing curated item metadata: {OVERRIDES}")
        generation_by_id = load_generation_indices()
        overrides = json.loads(OVERRIDES.read_text(encoding="utf-8"))
        index = get_json(f"{API}/item?limit=5000")
        results = index.get("results") or []
        if not results:
            raise ValueError("PokéAPI returned no items")

        def fetch_one(item: dict) -> dict:
            return normalize_item(get_json(item["url"]))

        items: list[dict] = []
        with ThreadPoolExecutor(max_workers=20) as executor:
            futures = [executor.submit(fetch_one, item) for item in results]
            for i, future in enumerate(as_completed(futures), start=1):
                items.append(future.result())
                if i % 100 == 0:
                    print(f"Fetched {i}/{len(results)} items...")

        existing_by_id: dict[int, dict] = {}
        if OUT.exists():
            existing_by_id = {
                int(row["id"]): row
                for row in json.loads(OUT.read_text(encoding="utf-8"))
            }
        items = preserve_curated_data(items, existing_by_id, generation_by_id, overrides)
    except (URLError, TimeoutError, OSError, json.JSONDecodeError, KeyError, TypeError, ValueError) as error:
        print(f"Could not build item data: {error}", file=sys.stderr)
        print("Existing item asset was left untouched.", file=sys.stderr)
        return 1

    temporary = OUT.with_suffix(OUT.suffix + ".tmp")
    temporary.write_text(
        json.dumps(items, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    temporary.replace(OUT)
    print(f"Wrote {OUT} with {len(items)} items (all local rows preserved).")
    print("Generation comes from item_game_indices.csv; M-C eligibility stays separate.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
