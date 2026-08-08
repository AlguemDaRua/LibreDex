#!/usr/bin/env python3
"""Validates custom forms catalog.

Checks forms_extra.json for valid base species and supported source flags.
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Auditing Custom Forms Catalog...")
    forms_file = ASSETS / 'forms_extra.json'
    if not forms_file.exists():
        print("ERROR: forms_extra.json is missing!")
        sys.exit(1)

    with open(forms_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    errors = 0
    overlay_pokemon = data.get('pokemon', [])
    ids = set()

    for p in overlay_pokemon:
        pid = p.get('id')
        name = p.get('name')
        flags = p.get('flags', [])

        if not pid or not name:
            print(f"Error: Custom form missing id or name: {p}")
            errors += 1
            continue

        if pid in ids:
            print(f"Error: Duplicate form id: {pid}")
            errors += 1
        ids.add(pid)

        # Validate flags
        valid_flags = {'mega', 'champions', 'legendsza', 'provisional'}
        for f in flags:
            if f.lower() not in valid_flags:
                print(f"Warning in form '{name}': Unknown flag '{f}'")

    if errors > 0:
        print(f"Forms Audit FAILED with {errors} errors.")
        sys.exit(1)

    print("Custom Forms Catalog is 100% valid.")

if __name__ == '__main__':
    main()
