#!/usr/bin/env python3
"""Validates pokemon moves and learnsets structure.

Confirms all junction references point to valid entities.
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Auditing Learnsets & Junction pairings...")
    moves_file = ASSETS / 'moves.json'
    pokemon_file = ASSETS / 'pokemon.json'
    junctions_file = ASSETS / 'pokemon_moves.json'

    if not all(f.exists() for f in (moves_file, pokemon_file, junctions_file)):
        print("ERROR: Missing one or more required data files!")
        sys.exit(1)

    with open(moves_file, 'r', encoding='utf-8') as f:
        moves = {m['id'] for m in json.load(f)}
    with open(pokemon_file, 'r', encoding='utf-8') as f:
        pokemons = {p['id'] for p in json.load(f)}

    # Allow extra forms from forms_extra.json as valid Pokémon ID targets
    forms_file = ASSETS / 'forms_extra.json'
    if forms_file.exists():
        with open(forms_file, 'r', encoding='utf-8') as f:
            extra = json.load(f)
            for p in extra.get('pokemon', []):
                if p.get('id'):
                    pokemons.add(p['id'])

    with open(junctions_file, 'r', encoding='utf-8') as f:
        junctions = json.load(f)

    errors = 0
    for j in junctions:
        # junction format is [pokemonId, moveId, learnMethod, level]
        if isinstance(j, list):
            pid, mid = j[0], j[1]
        else:
            pid, mid = j.get('pokemonId'), j.get('moveId')

        if pid not in pokemons:
            print(f"Error: Junction refers to missing Pokémon ID: {pid}")
            errors += 1
        if mid not in moves:
            print(f"Error: Junction refers to missing Move ID: {mid}")
            errors += 1

    if errors > 0:
        print(f"Learnsets Audit FAILED with {errors} errors.")
        sys.exit(1)

    print("Learnsets pairings are 100% valid.")

if __name__ == '__main__':
    main()
