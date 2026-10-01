#!/usr/bin/env python3
"""Replace the bundled Champions ``train`` rows with a pinned regulation's learnsets.

The source JSON is the ``learnsets.json`` file from the regulation data
repository recorded in ``champions_regulation_mc.json``. Non-Champions
learnset rows are preserved. The command validates every source key and move
before atomically writing ``pokemon_moves.json``.

Example:
    python3 tools/apply_champions_regulation_learnsets.py \
      --source /path/to/pokemon-champions-data/m-c/learnsets.json
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data"
REGULATION = DATA / "champions_regulation_mc.json"
MOVES = DATA / "moves.json"
JUNCTIONS = DATA / "pokemon_moves.json"


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    print("Existing assets were left untouched.", file=sys.stderr)
    raise SystemExit(1)


def slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.lower())


def sort_key(row: list) -> tuple:
    pokemon_id, move_id, method, level = row
    return (pokemon_id, method, level, move_id)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path, help="Pinned M-C learnsets.json")
    parser.add_argument("--out", type=Path, default=JUNCTIONS, help="Output junction asset")
    args = parser.parse_args()

    for path in (REGULATION, MOVES, JUNCTIONS, args.source):
        if not path.exists():
            fail(f"missing required file: {path}")

    regulation = json.loads(REGULATION.read_text())
    source_to_pokemon = regulation.get("sourcePokemonIds") or {}
    if not source_to_pokemon:
        fail("regulation asset has no sourcePokemonIds mapping")

    learnsets = json.loads(args.source.read_text())
    expected_keys = set(source_to_pokemon)
    source_keys = set(learnsets)
    if source_keys != expected_keys:
        fail(
            "learnset source keys differ from the pinned roster mapping "
            f"(missing {len(expected_keys - source_keys)}, extra {len(source_keys - expected_keys)})"
        )

    move_rows = json.loads(MOVES.read_text())
    move_ids_by_slug: dict[str, int] = {}
    for move in move_rows:
        key = slug(move["name"])
        if key in move_ids_by_slug:
            fail(f"move name normalization is ambiguous: {move['name']}")
        move_ids_by_slug[key] = move["id"]

    allowed_move_ids = set(regulation["moveIds"])
    train_rows: set[tuple[int, int]] = set()
    for source_key, pokemon_id in source_to_pokemon.items():
        source_moves = learnsets[source_key].get("moves", [])
        if not source_moves:
            fail(f"{source_key}: empty M-C learnset")
        for move_slug in source_moves:
            move_id = move_ids_by_slug.get(slug(move_slug))
            if move_id is None:
                fail(f"{source_key}: move {move_slug!r} is not in moves.json")
            if move_id not in allowed_move_ids:
                fail(f"{source_key}: move id {move_id} is not in the M-C move catalog")
            train_rows.add((pokemon_id, move_id))

    expected_roster = set(regulation["pokemonIds"])
    mapped_roster = set(source_to_pokemon.values())
    if mapped_roster != expected_roster:
        fail("sourcePokemonIds does not map exactly to the pinned M-C roster")

    existing = json.loads(JUNCTIONS.read_text())
    preserved = [list(row) for row in existing if row[2] != "train"]
    output = preserved + [
        [pokemon_id, move_id, "train", 0]
        for pokemon_id, move_id in train_rows
    ]
    output.sort(key=sort_key)

    keys = [(row[0], row[1], row[2]) for row in output]
    if len(keys) != len(set(keys)):
        fail("duplicate (Pokémon, move, method) junctions would violate the database key")

    forbidden = {
        (entry["pokemonId"], entry["moveId"])
        for entry in regulation.get("removedMoves", [])
    }
    actual_train = {
        (row[0], row[1]) for row in output if row[2] == "train"
    }
    if forbidden & actual_train:
        fail(f"removed M-C move pairs remain in learnsets: {sorted(forbidden & actual_train)}")

    slash_ids = set(regulation.get("newlyUsableMoveIds", []))
    if slash_ids and not any(move_id in slash_ids for _, move_id in actual_train):
        fail("newly usable M-C moves have no Champions learnset rows")

    tmp = args.out.with_suffix(args.out.suffix + ".tmp")
    tmp.write_text(json.dumps(output, separators=(",", ":")))
    tmp.replace(args.out)
    print(
        f"Wrote {args.out}: {len(output)} rows "
        f"({len(preserved)} non-Champions rows + {len(train_rows)} M-C learnset pairs "
        f"for {len(mapped_roster)} Pokémon/forms)."
    )


if __name__ == "__main__":
    main()
