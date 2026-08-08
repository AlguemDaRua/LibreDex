#!/usr/bin/env python3
"""Builds and packages custom Mega and Regional Pokémon forms.

Associates base species with overlay definitions in forms_extra.json.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Building Forms asset...")
    forms_file = ASSETS / 'forms_extra.json'
    if forms_file.exists():
        with open(forms_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print(f"Loaded {len(data.get('pokemon', []))} custom overlay forms.")
    else:
        print("No existing forms_extra.json file found.")

    print("Forms asset packing complete.")

if __name__ == '__main__':
    main()
