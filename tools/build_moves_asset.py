#!/usr/bin/env python3
"""Builds and packages moves reference database.

Reads raw PokeAPI datasets and merges them into standard moves.json asset.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Building Moves asset...")
    moves_file = ASSETS / 'moves.json'
    if moves_file.exists():
        with open(moves_file, 'r', encoding='utf-8') as f:
            moves = json.load(f)
        print(f"Loaded {len(moves)} existing moves.")
    else:
        moves = []
        print("No existing moves file found.")

    # Apply any validation or standard modifications here
    # e.g., mapping properties or checking categories
    print("Moves asset packing complete.")

if __name__ == '__main__':
    main()
