#!/usr/bin/env python3
"""Enrich ``assets/data/moves.json`` from the vendored PokéAPI CSV extracts.

The app-facing move records already contain the display names, descriptions,
base stats, and locally curated provenance. This builder fills the persisted
battle properties from PokéAPI's move, flag, and meta tables and applies only
small, exact-name overrides for traits that PokéAPI does not publish.

Run from any directory with ``python3 tools/build_moves_asset.py``.
"""
from __future__ import annotations

import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "tools" / "data"
ASSET = ROOT / "assets" / "data" / "moves.json"
OVERRIDES = DATA / "move_trait_overrides.json"


def read_csv(name: str) -> list[dict[str, str]]:
    path = DATA / name
    if not path.exists():
        raise FileNotFoundError(f"missing source CSV: {path}")
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def as_int(value: str | None, default: int = 0) -> int:
    try:
        return int(value) if value not in (None, "") else default
    except (TypeError, ValueError):
        return default


def normalized_name(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.lower())


def main() -> int:
    if not ASSET.exists():
        print(f"Missing move asset: {ASSET}", file=sys.stderr)
        return 1

    try:
        move_rows = {int(row["id"]): row for row in read_csv("moves.csv")}
        flag_names = {
            int(row["id"]): row["identifier"] for row in read_csv("move_flags.csv")
        }
        flags_by_move: dict[int, set[str]] = {}
        for row in read_csv("move_flag_map.csv"):
            move_id = int(row["move_id"])
            flag_id = int(row["move_flag_id"])
            if flag_id not in flag_names:
                raise ValueError(f"move flag id {flag_id} has no identifier")
            flags_by_move.setdefault(move_id, set()).add(flag_names[flag_id])
        meta_by_move = {
            int(row["move_id"]): row for row in read_csv("move_meta.csv")
        }
        overrides = json.loads(OVERRIDES.read_text(encoding="utf-8"))
        moves = json.loads(ASSET.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, KeyError, ValueError) as error:
        print(f"Could not read move data: {error}", file=sys.stderr)
        print("Existing move asset was left untouched.", file=sys.stderr)
        return 1

    asset_by_id = {int(row["id"]): row for row in moves}
    missing_source = sorted(set(asset_by_id) - set(move_rows))
    if missing_source:
        print(f"Move IDs missing from moves.csv: {missing_source[:20]}", file=sys.stderr)
        print("Existing move asset was left untouched.", file=sys.stderr)
        return 1

    moves_by_name: dict[str, int] = {}
    for move_id, row in asset_by_id.items():
        key = normalized_name(row["name"])
        if key in moves_by_name:
            print(f"Ambiguous move display name: {row['name']}", file=sys.stderr)
            return 1
        moves_by_name[key] = move_id

    override_ids: dict[str, set[int]] = {}
    for property_name, names in overrides.items():
        if not isinstance(names, list):
            print(f"Override {property_name} must be a list of exact move names", file=sys.stderr)
            return 1
        ids: set[int] = set()
        unknown: list[str] = []
        for name in names:
            move_id = moves_by_name.get(normalized_name(str(name)))
            if move_id is None:
                unknown.append(str(name))
            else:
                ids.add(move_id)
        if unknown:
            print(f"Unknown {property_name} override names: {', '.join(unknown)}", file=sys.stderr)
            return 1
        override_ids[property_name] = ids

    for move_id, move in asset_by_id.items():
        source = move_rows[move_id]
        generation = as_int(source.get("generation_id"), 0)
        move_flags = flags_by_move.get(move_id, set())
        meta = meta_by_move.get(move_id, {})
        drain = as_int(meta.get("drain"), 0)
        healing = as_int(meta.get("healing"), 0)
        has_hit_range = bool(meta.get("min_hits") or meta.get("max_hits"))
        damage_class_id = as_int(source.get("damage_class_id"), 1)

        move.update({
            "generation": generation,
            "introducedIn": f"Generation {generation}" if generation else None,
            "priority": as_int(source.get("priority"), 0),
            "isContact": "contact" in move_flags,
            "isHealing": "heal" in move_flags or healing > 0,
            "isSound": "sound" in move_flags,
            "isPunching": "punch" in move_flags,
            "isBiting": "bite" in move_flags,
            "isBite": "bite" in move_flags,
            "isPowder": "powder" in move_flags,
            "isPulse": "pulse" in move_flags,
            "isBallistic": "ballistics" in move_flags,
            "isDance": "dance" in move_flags,
            "isMultiHit": has_hit_range,
            "isRecharge": "recharge" in move_flags,
            "isRecoil": drain < 0,
            "isDraining": drain > 0,
            "isStatusMove": damage_class_id == 1,
            "isDamagingMove": damage_class_id != 1,
        })
        for property_name, ids in override_ids.items():
            move[property_name] = move_id in ids

        # These are explicit origin fields, not ID/name-derived classifications.
        # Keep any existing curated values; M-C eligibility lives in its own catalog.
        move.setdefault("isDLCMove", False)
        move.setdefault("isChampionsMove", False)
        move.setdefault("isLegendsZAMove", False)

    output = sorted(moves, key=lambda row: int(row["id"]))
    temporary = ASSET.with_suffix(ASSET.suffix + ".tmp")
    temporary.write_text(
        json.dumps(output, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    temporary.replace(ASSET)
    print(f"Enriched {len(output)} moves from PokéAPI CSV metadata.")
    print("Updated generation, priority, move flags, and exact curated traits.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
