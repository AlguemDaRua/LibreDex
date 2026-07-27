#!/usr/bin/env python3
"""Validates the LibreDex Pokémon Champions overlay and junction assets.

Checks (exit code 1 when anything fails):
* every overlay form has name, form label, all six base stats, type1 and a
  National Dex number
* stat totals are sane for Mega Evolutions (555..780)
* form ids do not collide with the bundled pokemon.json ids
* ability ids referenced by overlay forms exist either in the bundled
  abilities.json or in the overlay's own extraAbilities section
* every Champions form can resolve a learnset fallback: it either has direct
  rows in pokemon_moves.json or its National Dex has rows there
* required known forms are present (Mega Raichu X/Y, Mega Meganium, Mega
  Staraptor, Mega Floette, Eternal Flower Floette override)
* sprite fields are URLs of the expected shape unless explicitly blanked via
  an override
* the bundled pokemon_moves.json keeps non-empty learnsets for National Dex
  16 / 18 / 201 / 351 / 676

Run: python3 tools/validate_champions_data.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "assets" / "data"

MUST_HAVE_BASE_DEX = (16, 18, 201, 351, 676)
REQUIRED_FORMS = ("Mega Raichu X", "Mega Raichu Y", "Mega Meganium", "Mega Staraptor", "Mega Floette")
REQUIRED_OVERRIDE_NAMES = {10061: "Eternal Flower Floette"}
ALLOWED_FLAGS = {"mega", "champions", "legendsZA", "provisional"}
VALID_TYPES = {
    "normal", "fire", "water", "electric", "grass", "ice", "fighting", "poison",
    "ground", "flying", "psychic", "bug", "rock", "ghost", "dragon", "dark",
    "steel", "fairy",
}


def main() -> None:
    problems: list[str] = []

    with (DATA / "pokemon.json").open() as handle:
        base_pokemon = json.load(handle)
    with (DATA / "pokemon_moves.json").open() as handle:
        move_rows = json.load(handle)
    with (DATA / "abilities.json").open() as handle:
        bundled_abilities = json.load(handle)
    with (DATA / "forms_extra.json").open() as handle:
        overlay = json.load(handle)

    base_ids = {p["id"] for p in base_pokemon}
    dex_by_id = {p["id"]: p.get("nationalDexNumber", p["id"]) for p in base_pokemon}
    rows_by_pokemon: dict[int, int] = {}
    for row in move_rows:
        rows_by_pokemon[row[0]] = rows_by_pokemon.get(row[0], 0) + 1
    dex_with_moves = {dex_by_id[pid] for pid, count in rows_by_pokemon.items() if count > 0 and pid in dex_by_id}

    ability_names = {a["id"]: a["name"] for a in bundled_abilities}
    ability_names.update({a["id"]: a["name"] for a in overlay.get("extraAbilities", [])})

    overlay_ids: set[int] = set()
    names = []
    for form in overlay.get("pokemon", []):
        fid = form.get("id")
        label = form.get("name", f"#{fid}")
        names.append(label)

        if fid in overlay_ids:
            problems.append(f"{label}: duplicate overlay id {fid}")
        overlay_ids.add(fid)
        if fid in base_ids:
            problems.append(f"{label}: id {fid} collides with bundled pokemon.json")

        if not form.get("name"):
            problems.append(f"#{fid}: empty name")
        if not form.get("form"):
            problems.append(f"{label}: empty form label")
        for stat_key in ("baseHp", "baseAtk", "baseDef", "baseSpAtk", "baseSpDef", "baseSpd"):
            if not isinstance(form.get(stat_key), int) or form[stat_key] <= 0:
                problems.append(f"{label}: invalid {stat_key}={form.get(stat_key)}")
        bst = sum(form.get(k, 0) for k in ("baseHp", "baseAtk", "baseDef", "baseSpAtk", "baseSpDef", "baseSpd"))
        if not 555 <= bst <= 780:
            problems.append(f"{label}: suspicious BST {bst} (expected 555..780 for Mega Evolutions)")

        if form.get("type1") not in VALID_TYPES:
            problems.append(f"{label}: invalid type1 {form.get('type1')}")
        if form.get("type2") is not None and form.get("type2") not in VALID_TYPES:
            problems.append(f"{label}: invalid type2 {form.get('type2')}")

        if not isinstance(form.get("nationalDexNumber"), int) or form["nationalDexNumber"] <= 0:
            problems.append(f"{label}: missing nationalDexNumber")
        if form["nationalDexNumber"] == fid:
            problems.append(f"{label}: nationalDexNumber should point at the base species, not the form id")

        for flag in form.get("flags", []):
            if flag not in ALLOWED_FLAGS:
                problems.append(f"{label}: unknown flag {flag}")

        # Declared Champions ability must resolve to a real ability row.
        if form.get("championsAbility"):
            if not form.get("abilities"):
                problems.append(f"{label}: championsAbility=true but no ability junctions")
            for junction in form.get("abilities", []):
                aid = junction.get("abilityId")
                if aid not in ability_names:
                    problems.append(f"{label}: ability id {aid} unknown (not bundled nor in extraAbilities)")

        # Learnset fallback must resolve: direct rows, or base species rows.
        direct = rows_by_pokemon.get(fid, 0)
        fallback = form.get("nationalDexNumber") in dex_with_moves
        if direct == 0 and not fallback:
            problems.append(f"{label}: no direct learnset and base species {form.get('nationalDexNumber')} has none either")

        sprite = form.get("spriteUrl", "")
        if not re.match(r"^https://[^\s]+$", sprite):
            problems.append(f"{label}: spriteUrl is not a URL (got {sprite!r})")

    for required in REQUIRED_FORMS:
        if required not in names:
            problems.append(f"required form missing from overlay: {required}")

    for override in overlay.get("pokemonOverrides", []):
        oid = override.get("id")
        if oid not in base_ids:
            problems.append(f"pokemonOverrides: id {oid} does not exist in bundled pokemon.json")
        expected = REQUIRED_OVERRIDE_NAMES.get(oid)
        if expected and override.get("name") != expected:
            problems.append(f"pokemonOverrides: id {oid} should be named {expected!r}, got {override.get('name')!r}")

    for dex in MUST_HAVE_BASE_DEX:
        if dex not in dex_with_moves:
            problems.append(f"pokemon_moves.json: National Dex {dex} still has an empty learnset")

    for ability in overlay.get("extraAbilities", []):
        if not ability.get("name") or not ability.get("description"):
            problems.append(f"extraAbilities: id {ability.get('id')} lacks name/description")

    if problems:
        for problem in problems:
            print(f"FAIL {problem}")
        print(f"\n{len(problems)} problem(s) found.")
        sys.exit(1)

    print(f"OK — {len(overlay['pokemon'])} overlay forms, "
          f"{len(overlay.get('extraAbilities', []))} extra abilities, "
          f"{len(move_rows)} junction rows; all Champions checks passed.")


if __name__ == "__main__":
    main()
