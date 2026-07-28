#!/usr/bin/env python3
"""Merges Pokémon Champions learnset rows into ``assets/data/pokemon_moves.json``
from a local PokéAPI CSV dataset, fully offline.

``tools/generate_junctions.dart`` is the main generator for
``pokemon_moves.json``/``pokemon_abilities.json`` and talks to the live
PokéAPI GraphQL endpoint. The Pokémon Champions version group is very new,
so depending on the endpoint snapshot its rows may be missing. This tool is
the surgical companion step: it keeps every existing row untouched and only
merges in the Champions ``train`` rows (learn method id 12, which only
exists under the Champions version group, so nothing else can change).

Policy
------
* Existing rows are preserved byte-for-byte in content; they are re-sorted
  together with the new rows using the exact comparator of
  ``generate_junctions.dart`` (pokemonId, method, level, moveId) so the
  output matches what the Dart tool will produce once the endpoint ships
  Champions data.
* One row per (pokemonId, moveId, learnMethod); duplicates are skipped.
* Rows are only emitted for Pokémon bundled in ``pokemon.json`` plus the
  ``forms_extra.json`` overlay forms, and for moves bundled in
  ``moves.json``.
* Output stays in the compact ``[pokemonId, moveId, method, level]`` shape.

Usage
-----
    python3 tools/apply_pokeapi_csv_junctions.py --csv-dir /path/to/pokeapi-master/data/v2/csv

Fails gracefully without touching the existing asset on any validation error.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

# Version group that owns the "train" learn method (Champions trains moves
# with Victory Points; method id 12 only appears under this group).
CHAMPIONS_VERSION_GROUP = "champions"
TRAIN_METHOD = "train"

MUST_HAVE_BASE_DEX = (16, 18, 201, 351, 676)


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    print("Existing assets were left untouched.", file=sys.stderr)
    sys.exit(1)


def sort_key(row: list) -> tuple:
    # Mirrors _MoveChoice ordering in tools/generate_junctions.dart:
    # pokemonId, then method, then level, then moveId.
    pokemon_id, move_id, method, level = row
    return (pokemon_id, method, level, move_id)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    repo_root = Path(__file__).resolve().parent.parent
    parser.add_argument(
        "--csv-dir",
        type=Path,
        default=repo_root / "tools" / "data" / "pokeapi-csv",
        help="Directory with PokéAPI v2 CSV files.",
    )
    parser.add_argument("--out", type=Path, default=repo_root / "assets" / "data" / "pokemon_moves.json")
    args = parser.parse_args()

    pokemon_asset = repo_root / "assets" / "data" / "pokemon.json"
    moves_asset = repo_root / "assets" / "data" / "moves.json"
    overlay_asset = repo_root / "assets" / "data" / "forms_extra.json"
    moves_csv = args.csv_dir / "pokemon_moves.csv"
    vg_csv = args.csv_dir / "version_groups.csv"
    for path in (pokemon_asset, moves_asset, moves_csv, vg_csv, args.out):
        if not path.exists():
            fail(f"missing required file: {path}")

    with pokemon_asset.open() as handle:
        pokemon = json.load(handle)
    with moves_asset.open() as handle:
        move_ids = {m["id"] for m in json.load(handle)}
    with args.out.open() as handle:
        existing_rows = json.load(handle)

    pokemon_ids = {p["id"] for p in pokemon}
    if overlay_asset.exists():
        with overlay_asset.open() as handle:
            overlay = json.load(handle)
        pokemon_ids |= {p["id"] for p in overlay.get("pokemon", [])}

    champions_vg_id: str | None = None
    with vg_csv.open(newline="") as handle:
        for row in csv.DictReader(handle):
            if row["identifier"] == CHAMPIONS_VERSION_GROUP:
                champions_vg_id = row["id"]
                break
    if champions_vg_id is None:
        fail(f"version group '{CHAMPIONS_VERSION_GROUP}' missing from CSV dataset")

    known_keys = {(r[0], r[1], r[2]) for r in existing_rows}

    added: list[list] = []
    skipped_move = 0
    with moves_csv.open(newline="") as handle:
        for row in csv.DictReader(handle):
            if row["version_group_id"] != champions_vg_id:
                continue
            pokemon_id = int(row["pokemon_id"])
            if pokemon_id not in pokemon_ids:
                continue
            move_id = int(row["move_id"])
            if move_id not in move_ids:
                skipped_move += 1
                continue
            level = int(row["level"] or 0)
            key = (pokemon_id, move_id, TRAIN_METHOD)
            if key in known_keys:
                continue
            known_keys.add(key)
            added.append([pokemon_id, move_id, TRAIN_METHOD, level])

    if not added:
        fail("no Champions train rows could be derived; CSV dataset looks wrong")

    rows = [list(r) for r in existing_rows] + added
    rows.sort(key=sort_key)

    dex_by_id = {p["id"]: p.get("nationalDexNumber", p["id"]) for p in pokemon}
    species_with_moves = {dex_by_id[r[0]] for r in rows if r[0] in dex_by_id}
    missing = [dex for dex in MUST_HAVE_BASE_DEX if dex not in species_with_moves]
    if missing:
        fail(
            "Validation failed. Still missing learnsets for National Dex "
            f"{missing} after the merge; re-run tools/generate_junctions.dart first."
        )

    tmp = args.out.with_suffix(".tmp")
    tmp.write_text(json.dumps(rows, separators=(",", ":")))
    tmp.replace(args.out)
    print(f"Wrote {args.out}: {len(rows)} compact rows ({len(existing_rows)} kept + {len(added)} Champions rows).")
    print(f"  Pokémon covered: {len({r[0] for r in rows})} (Champions adds {len({r[0] for r in added})}).")
    if skipped_move:
        print(f"  Skipped {skipped_move} Champions rows for moves not bundled in moves.json.")
    for dex in MUST_HAVE_BASE_DEX:
        count = sum(1 for r in rows if dex_by_id.get(r[0]) == dex)
        print(f"  dex {dex}: {count} learnset rows")


if __name__ == "__main__":
    main()
