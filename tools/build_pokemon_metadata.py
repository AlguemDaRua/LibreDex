#!/usr/bin/env python3
"""Build data-driven Pokémon metadata and full evolution chains.

Inputs are the vendored PokéAPI CSV extracts under ``tools/data``. The builder
updates each bundled Pokémon/form with its species generation, evolution depth,
egg groups, baby status, form-specific evolution capability, and incoming
evolution-method categories. It also writes every selected default-species
PokéAPI evolution edge in each family, including branches and any form
constraints carried by those source rows, to ``assets/data/evolution_chains.json``.

Run from any directory with ``python3 tools/build_pokemon_metadata.py``.
"""
from __future__ import annotations

import csv
import json
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "tools" / "data"
POKEMON_ASSET = ROOT / "assets" / "data" / "pokemon.json"
FORMS_ASSET = ROOT / "assets" / "data" / "forms_extra.json"
EVOLUTION_ASSET = ROOT / "assets" / "data" / "evolution_chains.json"

EGG_GROUPS = {
    1: "Monster",
    2: "Water 1",
    3: "Bug",
    4: "Flying",
    5: "Field",
    6: "Fairy",
    7: "Grass",
    8: "Human-Like",
    9: "Water 3",
    10: "Mineral",
    11: "Amorphous",
    12: "Water 2",
    13: "Ditto",
    14: "Dragon",
    15: "Undiscovered",
}
TYPE_NAMES = {
    1: "Normal",
    2: "Fighting",
    3: "Flying",
    4: "Poison",
    5: "Ground",
    6: "Rock",
    7: "Bug",
    8: "Ghost",
    9: "Steel",
    10: "Fire",
    11: "Water",
    12: "Grass",
    13: "Electric",
    14: "Psychic",
    15: "Ice",
    16: "Dragon",
    17: "Dark",
    18: "Fairy",
}
REGION_NAMES = {
    1: "Kanto",
    2: "Johto",
    3: "Hoenn",
    4: "Sinnoh",
    5: "Unova",
    6: "Kalos",
    7: "Alola",
    8: "Galar",
    9: "Hisui",
    10: "Paldea",
}


def read_csv(name: str) -> list[dict[str, str]]:
    path = DATA / name
    if not path.is_file():
        raise FileNotFoundError(f"missing source CSV: {path}")
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def as_int(value: Any, default: int | None = None) -> int | None:
    if value in (None, ""):
        return default
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def title_slug(value: str) -> str:
    return " ".join(word.capitalize() for word in value.replace("-", " ").split())


def read_egg_groups() -> dict[int, list[str]]:
    groups: dict[int, list[str]] = {}
    path = DATA / "egg_groups.csv"
    with path.open(encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            line = line.strip()
            if not line:
                continue
            species_text, separator, group_text = line.partition(":")
            if not separator:
                raise ValueError(f"invalid egg-group row at {path}:{line_number}")
            species_id = int(species_text)
            group_ids = [int(value) for value in group_text.split(",") if value]
            unknown = sorted(set(group_ids) - EGG_GROUPS.keys())
            if unknown:
                raise ValueError(f"unknown egg-group ids for species {species_id}: {unknown}")
            groups[species_id] = [EGG_GROUPS[group_id] for group_id in group_ids]
    return groups


def method_category(row: dict[str, str]) -> str:
    trigger_id = as_int(row.get("evolution_trigger_id"), 0)
    if trigger_id == 1:
        if as_int(row.get("minimum_happiness"), 0) or as_int(row.get("minimum_affection"), 0):
            return "Friendship"
        if any(
            as_int(row.get(field), 0)
            for field in ("known_move_id", "known_move_type_id", "used_move_id", "minimum_move_count")
        ):
            return "Move"
        return "Level"
    if trigger_id == 2:
        return "Trade"
    if trigger_id == 3:
        return "Item/Stone"
    return "Other"


def evolution_trigger(
    row: dict[str, str],
    trigger_names: dict[int, str],
    item_names: dict[int, str],
    move_names: dict[int, str],
    species_names: dict[int, str],
) -> str:
    """Render all useful structured trigger conditions in a compact label."""
    trigger_id = as_int(row.get("evolution_trigger_id"), 0) or 0
    parts: list[str] = []
    if trigger_id == 2:
        parts.append("Trade")
    elif trigger_id == 4:
        parts.append("Empty party slot + Poké Ball")
    elif trigger_id == 5:
        parts.append("Spin to determine form")
    elif row.get("condition_expression") and trigger_id == 1:
        parts.append("Evolution branch is game-determined")

    minimum_level = as_int(row.get("minimum_level"))
    if minimum_level is not None:
        parts.append(f"Level {minimum_level}")
    if row.get("trigger_item_id"):
        item_name = item_names.get(as_int(row["trigger_item_id"], 0) or 0)
        if item_name:
            parts.append(f"Use {item_name}")
    if row.get("held_item_id"):
        item_name = item_names.get(as_int(row["held_item_id"], 0) or 0)
        if item_name:
            parts.append(f"Hold {item_name}")

    if as_int(row.get("minimum_happiness"), 0):
        parts.append("High friendship")
    if as_int(row.get("minimum_affection"), 0):
        parts.append("High affection")
    if as_int(row.get("minimum_beauty"), 0):
        parts.append("High beauty")
    if row.get("time_of_day"):
        parts.append(row["time_of_day"].capitalize())
    if row.get("gender_id"):
        parts.append("Female only" if row["gender_id"] == "1" else "Male only")

    known_move_id = as_int(row.get("known_move_id"))
    if known_move_id is not None:
        move_name = move_names.get(known_move_id)
        if move_name:
            parts.append(f"Know {move_name}")
    known_move_type_id = as_int(row.get("known_move_type_id"))
    if known_move_type_id is not None:
        type_name = TYPE_NAMES.get(known_move_type_id)
        if type_name:
            parts.append(f"Know a {type_name}-type move")
    used_move_id = as_int(row.get("used_move_id"))
    if used_move_id is not None:
        move_name = move_names.get(used_move_id)
        if move_name:
            parts.append(f"Use {move_name}")
    minimum_move_count = as_int(row.get("minimum_move_count"))
    if minimum_move_count is not None:
        parts.append(f"Use {minimum_move_count} moves")

    region_id = as_int(row.get("region_id"))
    if region_id is not None and region_id in REGION_NAMES:
        parts.append(f"In {REGION_NAMES[region_id]}")
    if row.get("location_id"):
        parts.append("At a specific location")
    if row.get("needs_overworld_rain") == "1":
        parts.append("While raining")
    if row.get("needs_multiplayer") == "1":
        parts.append("In multiplayer")
    if row.get("near_special_rock") == "1":
        parts.append("Near a special rock")
    if row.get("turn_upside_down") == "1":
        parts.append("Turn the device upside down")

    relative_stats = as_int(row.get("relative_physical_stats"))
    if relative_stats is not None:
        comparison = {-1: "Attack lower than Defense", 0: "Attack equal to Defense", 1: "Attack higher than Defense"}
        if relative_stats in comparison:
            parts.append(comparison[relative_stats])
    if row.get("party_species_id"):
        party_name = species_names.get(as_int(row["party_species_id"], 0) or 0)
        if party_name:
            parts.append(f"{party_name} in party")
    if row.get("party_type_id"):
        type_name = TYPE_NAMES.get(as_int(row["party_type_id"], 0) or 0)
        if type_name:
            parts.append(f"{type_name}-type in party")
    if row.get("trade_species_id"):
        trade_name = species_names.get(as_int(row["trade_species_id"], 0) or 0)
        if trade_name:
            parts.append(f"For {trade_name}")
    if row.get("minimum_steps"):
        parts.append(f"Walk {int(row['minimum_steps']):,} steps")
    if row.get("minimum_damage_taken"):
        parts.append(f"After taking {row['minimum_damage_taken']} damage")
    if row.get("percentage_chance"):
        parts.append(f"{row['percentage_chance']}% chance")

    if parts:
        return " · ".join(parts)

    trigger = trigger_names.get(trigger_id, "evolves")
    labels = {
        "level-up": "Level up",
        "trade": "Trade",
        "use-item": "Use an item",
        "shed": "Shed shell",
        "spin": "Spin",
        "tower-of-darkness": "Train at the Tower of Darkness",
        "tower-of-waters": "Train at the Tower of Waters",
        "three-critical-hits": "Land three critical hits",
        "take-damage": "Take damage",
        "other": "Special condition",
    }
    return labels.get(trigger, title_slug(trigger))


def species_stages(species: dict[int, dict[str, str]]) -> dict[int, int]:
    cache: dict[int, int] = {}

    def stage(species_id: int, visiting: set[int]) -> int:
        if species_id in cache:
            return cache[species_id]
        if species_id in visiting:
            raise ValueError(f"cycle in evolution parent data at species {species_id}")
        row = species.get(species_id)
        if row is None:
            raise ValueError(f"missing species {species_id} in pokemon_species.csv")
        parent = as_int(row.get("evolves_from_species_id"))
        if parent is None:
            cache[species_id] = 0
        else:
            cache[species_id] = stage(parent, visiting | {species_id}) + 1
        return cache[species_id]

    for species_id in species:
        stage(species_id, set())
    return cache


def build_evolution_data(
    species: dict[int, dict[str, str]],
    chain_roots: dict[int, int],
    form_rows: dict[int, dict[str, str]],
    pokemon_rows: dict[int, dict[str, Any]],
    trigger_rows: dict[int, str],
    item_names: dict[int, str],
    move_names: dict[int, str],
) -> tuple[dict[str, list[dict[str, Any]]], set[int], dict[int, set[str]]]:
    species_names = {
        species_id: title_slug(row["identifier"])
        for species_id, row in species.items()
    }
    rows_by_route: dict[tuple[int, int, int], dict[str, str]] = {}
    for row in read_csv("pokemon_evolution.csv"):
        if row.get("is_default") != "1":
            continue
        child_id = as_int(row.get("evolved_species_id"))
        child = species.get(child_id or -1)
        if child is None:
            raise ValueError(f"evolution row references unknown species {child_id}")
        parent_id = as_int(child.get("evolves_from_species_id"))
        if parent_id is None:
            raise ValueError(f"evolved species {child_id} has no parent species")

        from_form_id = as_int(row.get("required_pokemon_form_id"))
        to_form_id = as_int(row.get("evolved_pokemon_form_id"))
        from_form = form_rows.get(from_form_id or -1)
        to_form = form_rows.get(to_form_id or -1)
        from_pokemon_id = as_int(from_form.get("pokemon_id")) if from_form else parent_id
        to_pokemon_id = as_int(to_form.get("pokemon_id")) if to_form else child_id
        if from_pokemon_id is None or to_pokemon_id is None:
            raise ValueError(f"could not resolve Pokémon forms for evolution to species {child_id}")

        route_key = (child_id, from_pokemon_id, to_pokemon_id)
        current = rows_by_route.get(route_key)
        if current is None or (as_int(row.get("version_group_id"), 0) or 0) > (as_int(current.get("version_group_id"), 0) or 0):
            rows_by_route[route_key] = row

    chains: dict[str, list[dict[str, Any]]] = defaultdict(list)
    outgoing: set[int] = set()
    methods_by_pokemon: dict[int, set[str]] = defaultdict(set)
    for (child_id, from_pokemon_id, to_pokemon_id), row in rows_by_route.items():
        child = species[child_id]
        parent_id = as_int(child.get("evolves_from_species_id"))
        chain_id = as_int(child.get("evolution_chain_id"))
        root_id = chain_roots.get(chain_id or -1)
        if parent_id is None or root_id is None:
            raise ValueError(f"could not find parent/root for evolution to species {child_id}")

        from_pokemon = pokemon_rows.get(from_pokemon_id, {})
        to_pokemon = pokemon_rows.get(to_pokemon_id, {})
        from_form = str(from_pokemon.get("form") or "normal")
        to_form = str(to_pokemon.get("form") or "normal")
        display_forms = [form for form in (from_form, to_form) if form.lower() != "normal"]
        edge = {
            "from": parent_id,
            "to": child_id,
            "fromPokemon": from_pokemon_id,
            "toPokemon": to_pokemon_id,
            "fromForm": from_form,
            "toForm": to_form,
            "trigger": evolution_trigger(row, trigger_rows, item_names, move_names, species_names),
            "form": " → ".join(dict.fromkeys(display_forms)) if display_forms else "normal",
        }
        chains[str(root_id)].append(edge)
        outgoing.add(from_pokemon_id)
        methods_by_pokemon[to_pokemon_id].add(method_category(row))

    ordered_chains: dict[str, list[dict[str, Any]]] = {}
    for root_id in sorted(chains, key=int):
        ordered_chains[root_id] = sorted(
            chains[root_id],
            key=lambda edge: (
                edge["from"],
                edge["to"],
                edge["fromPokemon"],
                edge["toPokemon"],
                edge["trigger"],
            ),
        )

    return ordered_chains, outgoing, methods_by_pokemon


def enrich_pokemon_rows(
    rows: list[dict[str, Any]],
    species: dict[int, dict[str, str]],
    stages: dict[int, int],
    egg_groups: dict[int, list[str]],
    outgoing: set[int],
    methods_by_pokemon: dict[int, set[str]],
) -> None:
    method_order = {name: order for order, name in enumerate(("Level", "Item/Stone", "Friendship", "Trade", "Move", "Other"))}
    for row in rows:
        pokemon_id = as_int(row.get("id"))
        dex_id = as_int(row.get("nationalDexNumber"), pokemon_id)
        if pokemon_id is None or dex_id is None or dex_id not in species:
            raise ValueError(f"Pokémon row has no matching species metadata: {row.get('id')}")
        source = species[dex_id]
        row.update({
            "generation": as_int(source.get("generation_id"), 1),
            "evolutionStage": stages[dex_id],
            "eggGroups": ", ".join(egg_groups.get(dex_id, [])),
            "isBaby": source.get("is_baby") == "1",
            "hasEvolution": pokemon_id in outgoing,
            "evolutionMethods": "|".join(sorted(methods_by_pokemon.get(pokemon_id, set()), key=method_order.__getitem__)),
        })


def write_atomic(path: Path, content: str) -> Path:
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(content, encoding="utf-8")
    return temporary


def main() -> int:
    try:
        if not POKEMON_ASSET.is_file() or not FORMS_ASSET.is_file():
            raise FileNotFoundError("pokemon.json or forms_extra.json is missing")
        species = {int(row["id"]): row for row in read_csv("pokemon_species.csv")}
        chain_rows = read_csv("evolution_chains.csv")
        chain_ids = {int(row["id"]) for row in chain_rows}
        chain_roots = {
            int(row["evolution_chain_id"]): species_id
            for species_id, row in species.items()
            if row.get("evolves_from_species_id") in (None, "")
            and as_int(row.get("evolution_chain_id")) in chain_ids
        }
        form_rows = {int(row["id"]): row for row in read_csv("pokemon_forms.csv")}
        trigger_rows = {int(row["id"]): row["identifier"] for row in read_csv("evolution_triggers.csv")}
        item_names = {int(row["id"]): title_slug(row["identifier"]) for row in read_csv("items.csv")}
        move_names = {int(row["id"]): title_slug(row["identifier"]) for row in read_csv("moves.csv")}
        egg_groups = read_egg_groups()
        pokemon = json.loads(POKEMON_ASSET.read_text(encoding="utf-8"))
        overlay = json.loads(FORMS_ASSET.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, KeyError, ValueError) as error:
        print(f"Could not read Pokémon metadata inputs: {error}", file=sys.stderr)
        print("Existing assets were left untouched.", file=sys.stderr)
        return 1

    base_by_id = {int(row["id"]): row for row in pokemon}
    overlay_rows = overlay.get("pokemon") or []
    combined_by_id = dict(base_by_id)
    for row in overlay_rows:
        pokemon_id = int(row["id"])
        if pokemon_id in combined_by_id:
            print(f"Pokémon form id {pokemon_id} collides with the base asset", file=sys.stderr)
            return 1
        combined_by_id[pokemon_id] = row

    stages = species_stages(species)
    try:
        chains, outgoing, methods_by_pokemon = build_evolution_data(
            species,
            chain_roots,
            form_rows,
            combined_by_id,
            trigger_rows,
            item_names,
            move_names,
        )
        enrich_pokemon_rows(pokemon, species, stages, egg_groups, outgoing, methods_by_pokemon)
        enrich_pokemon_rows(overlay_rows, species, stages, egg_groups, outgoing, methods_by_pokemon)

        expected_edges = {
            int(row["evolved_species_id"])
            for row in read_csv("pokemon_evolution.csv")
            if row.get("is_default") == "1"
        }
        generated_edges = {edge["to"] for rows in chains.values() for edge in rows}
        if expected_edges != generated_edges:
            missing = sorted(expected_edges - generated_edges)
            extra = sorted(generated_edges - expected_edges)
            raise ValueError(f"evolution asset does not cover source species (missing={missing[:10]}, extra={extra[:10]})")
    except (KeyError, ValueError) as error:
        print(f"Could not build Pokémon metadata: {error}", file=sys.stderr)
        print("Existing assets were left untouched.", file=sys.stderr)
        return 1

    pokemon_tmp = write_atomic(
        POKEMON_ASSET,
        json.dumps(sorted(pokemon, key=lambda row: int(row["id"])), ensure_ascii=False, separators=(",", ":")) + "\n",
    )
    forms_tmp = write_atomic(
        FORMS_ASSET,
        json.dumps(overlay, ensure_ascii=False, separators=(",", ":")) + "\n",
    )
    evolution_tmp = write_atomic(
        EVOLUTION_ASSET,
        json.dumps(chains, ensure_ascii=False, separators=(",", ":")) + "\n",
    )
    pokemon_tmp.replace(POKEMON_ASSET)
    forms_tmp.replace(FORMS_ASSET)
    evolution_tmp.replace(EVOLUTION_ASSET)

    edge_count = sum(len(rows) for rows in chains.values())
    print(f"Enriched {len(pokemon) + len(overlay_rows)} Pokémon/forms across {len(species)} species.")
    print(f"Wrote {edge_count} form-aware evolution edges in {len(chains)} complete chains.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
