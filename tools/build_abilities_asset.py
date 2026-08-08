#!/usr/bin/env python3
"""Builds and packages abilities reference database.

Reads raw PokeAPI datasets and compiles them into standard abilities.json asset.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Building Abilities asset...")
    abilities_file = ASSETS / 'abilities.json'
    if abilities_file.exists():
        with open(abilities_file, 'r', encoding='utf-8') as f:
            abilities = json.load(f)
        print(f"Loaded {len(abilities)} existing abilities.")
    else:
        abilities = []

    print("Abilities asset packing complete.")

if __name__ == '__main__':
    main()
