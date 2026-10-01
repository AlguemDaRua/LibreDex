#!/usr/bin/env python3
"""Enrich ``assets/data/abilities.json`` from PokéAPI's ability CSV.

Generation is a property of the ability record. Hidden status is deliberately
not set here: it belongs to a Pokémon–ability relationship and is read from
the junction data in ``pokemon_abilities.json``.
"""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "tools" / "data"
ASSET = ROOT / "assets" / "data" / "abilities.json"
PROVENANCE = DATA / "ability_provenance_overrides.json"


def main() -> int:
    if not ASSET.exists():
        print(f"Missing ability asset: {ASSET}", file=sys.stderr)
        return 1

    try:
        with (DATA / "abilities.csv").open(newline="", encoding="utf-8") as handle:
            source_rows = {
                int(row["id"]): row for row in csv.DictReader(handle)
            }
        provenance = json.loads(PROVENANCE.read_text(encoding="utf-8"))
        source_games = provenance.get("sourceGamesByIdentifier", {})
        abilities = json.loads(ASSET.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, KeyError, ValueError) as error:
        print(f"Could not read ability data: {error}", file=sys.stderr)
        print("Existing ability asset was left untouched.", file=sys.stderr)
        return 1

    assets_by_id = {int(row["id"]): row for row in abilities}
    missing_source = sorted(set(assets_by_id) - set(source_rows))
    if missing_source:
        print(f"Ability IDs missing from abilities.csv: {missing_source[:20]}", file=sys.stderr)
        print("Existing ability asset was left untouched.", file=sys.stderr)
        return 1

    seen_provenance: set[str] = set()
    for ability_id, ability in assets_by_id.items():
        source = source_rows[ability_id]
        identifier = source["identifier"]
        generation = int(source["generation_id"])
        ability["generation"] = generation
        ability["introducedIn"] = f"Generation {generation}"
        ability.setdefault("isHiddenAbility", False)
        ability.setdefault("isChampionsAbility", False)
        ability.setdefault("isLegendsZAAbility", False)

        origin = source_games.get(identifier)
        if origin:
            ability["sourceGames"] = origin
            # This curated group is from Pokémon Conquest, not Champions or
            # Legends: Z-A. Keep the relationship explicit and name-keyed.
            ability["isChampionsAbility"] = False
            ability["isLegendsZAAbility"] = False
            seen_provenance.add(identifier)

    unknown_provenance = sorted(set(source_games) - {
        row["identifier"] for row in source_rows.values()
    })
    if unknown_provenance:
        print(f"Unknown ability provenance identifiers: {unknown_provenance}", file=sys.stderr)
        print("Existing ability asset was left untouched.", file=sys.stderr)
        return 1

    output = sorted(abilities, key=lambda row: int(row["id"]))
    temporary = ASSET.with_suffix(ASSET.suffix + ".tmp")
    temporary.write_text(
        json.dumps(output, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    temporary.replace(ASSET)
    print(f"Enriched {len(output)} abilities with source generation metadata.")
    print(f"Applied explicit provenance to {len(seen_provenance)} Pokémon Conquest abilities.")
    print("Hidden-ability status remains on Pokémon–ability junction records.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
