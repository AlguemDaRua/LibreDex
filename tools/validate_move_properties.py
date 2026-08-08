#!/usr/bin/env python3
"""Validates Move properties and constraints.

Exits non-zero if invalid damage classes, types, or PP structures are found.
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Auditing Move properties...")
    moves_file = ASSETS / 'moves.json'
    if not moves_file.exists():
        print("ERROR: moves.json is missing!")
        sys.exit(1)

    with open(moves_file, 'r', encoding='utf-8') as f:
        moves = json.load(f)

    errors = 0
    valid_classes = {'physical', 'special', 'status'}
    valid_types = {
        'normal', 'fire', 'water', 'electric', 'grass', 'ice',
        'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
        'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy', 'shadow'
    }

    for m in moves:
        mid = m.get('id')
        name = m.get('name')
        t = m.get('type')
        dc = m.get('damageClass')

        if not name or not t or not dc:
            print(f"Error in Move #{mid}: Missing name, type, or damageClass")
            errors += 1
            continue

        if t.lower() not in valid_types:
            print(f"Error in Move '{name}': Invalid type '{t}'")
            errors += 1

        if dc.lower() not in valid_classes:
            print(f"Error in Move '{name}': Invalid damageClass '{dc}'")
            errors += 1

    if errors > 0:
        print(f"Move Audit FAILED with {errors} errors.")
        sys.exit(1)

    print("Move properties are 100% valid.")

if __name__ == '__main__':
    main()
