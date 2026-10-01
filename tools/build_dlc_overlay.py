#!/usr/bin/env python3
"""Apply reviewed DLC provenance to bundled Pokémon, move, and item assets.

This builder consumes ``tools/data/dlc_provenance_overrides.json``. It never
infers DLC origin from an ID, generation, or Regulation M-C eligibility. Every
entry must name an existing asset record and its source game/DLC. An empty
manifest fails clearly instead of pretending an overlay was built.

After adding source-reviewed entries, run:
    python3 tools/build_dlc_overlay.py
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "data"
DEFAULT_MANIFEST = ROOT / "tools" / "data" / "dlc_provenance_overrides.json"


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def unique_rows(rows: list[dict], asset: str) -> dict[int, dict]:
    index: dict[int, dict] = {}
    for row in rows:
        item_id = int(row["id"])
        if item_id in index:
            raise ValueError(f"{asset} contains duplicate id {item_id}")
        index[item_id] = row
    return index


def validate_entries(entries: Any, kind: str) -> list[dict[str, Any]]:
    if not isinstance(entries, list):
        raise ValueError(f"manifest '{kind}' must be a list")
    checked: list[dict[str, Any]] = []
    seen: set[int] = set()
    for entry in entries:
        if not isinstance(entry, dict):
            raise ValueError(f"every {kind} override must be an object")
        item_id = int(entry["id"])
        source = str(entry.get("source", "")).strip()
        if not source:
            raise ValueError(f"{kind} id {item_id} is missing its source game/DLC")
        if item_id in seen:
            raise ValueError(f"duplicate {kind} override id {item_id}")
        seen.add(item_id)
        checked.append({"id": item_id, "source": source})
    return checked


def write_atomic(path: Path, data: Any) -> None:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        json.dumps(data, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    args = parser.parse_args()

    try:
        manifest = load_json(args.manifest)
        if not isinstance(manifest, dict):
            raise ValueError("DLC manifest must be a JSON object")
        pokemon_entries = validate_entries(manifest.get("pokemon", []), "pokemon")
        move_entries = validate_entries(manifest.get("moves", []), "moves")
        item_entries = validate_entries(manifest.get("items", []), "items")
        if not (pokemon_entries or move_entries or item_entries):
            raise ValueError(
                "the DLC manifest has no reviewed records; add explicit IDs and sources "
                "before building (no IDs are guessed)"
            )

        pokemon = load_json(ASSETS / "pokemon.json")
        forms_path = ASSETS / "forms_extra.json"
        forms = load_json(forms_path)
        moves = load_json(ASSETS / "moves.json")
        items = load_json(ASSETS / "items.json")

        pokemon_by_id = unique_rows(pokemon, "pokemon.json")
        form_by_id = unique_rows(forms.get("pokemon", []), "forms_extra.json")
        move_by_id = unique_rows(moves, "moves.json")
        item_by_id = unique_rows(items, "items.json")

        for entry in pokemon_entries:
            row = pokemon_by_id.get(entry["id"]) or form_by_id.get(entry["id"])
            if row is None:
                raise ValueError(f"DLC Pokémon id {entry['id']} is not bundled")
            row["dlcSource"] = entry["source"]
        for entry in move_entries:
            row = move_by_id.get(entry["id"])
            if row is None:
                raise ValueError(f"DLC move id {entry['id']} is not bundled")
            row["isDLCMove"] = True
        for entry in item_entries:
            row = item_by_id.get(entry["id"])
            if row is None:
                raise ValueError(f"DLC item id {entry['id']} is not bundled")
            row["tags"] = sorted(
                set(row.get("tags", [])) | {"dlc", "downloadable content"}
            )
            row["dlcSource"] = entry["source"]
    except (OSError, json.JSONDecodeError, KeyError, TypeError, ValueError) as error:
        print(f"Could not build DLC provenance overlay: {error}", file=sys.stderr)
        print("Existing assets were left untouched.", file=sys.stderr)
        return 1

    # Validate every record before writing any file; all writes are atomic.
    if pokemon_entries:
        write_atomic(ASSETS / "pokemon.json", pokemon)
        write_atomic(forms_path, forms)
    if move_entries:
        write_atomic(ASSETS / "moves.json", moves)
    if item_entries:
        write_atomic(ASSETS / "items.json", items)

    count = len(pokemon_entries) + len(move_entries) + len(item_entries)
    print(f"Applied reviewed DLC provenance to {count} existing asset records.")
    print("Regulation M-C availability and game-origin metadata remain separate.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
