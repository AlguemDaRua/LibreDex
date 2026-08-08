#!/usr/bin/env python3
"""Offline consistency audit for LibreDex bundled datasets.

Run from the repository root: python3 tools/audit_libredex_data.py
The command exits non-zero when references or required fields are invalid.
"""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'data'
errors, warnings = [], []
def load(name):
    try: return json.loads((ROOT / name).read_text(encoding='utf8'))
    except Exception as e: errors.append(f'{name}: cannot parse ({e})'); return []

def rows(value):
    return value.get('pokemon', []) if isinstance(value, dict) else value

def ids(data, name):
    result = {}
    for row in rows(data):
        key = row.get('id')
        if key in result: errors.append(f'{name}: duplicate id {key}')
        result[key] = row
    return result

pokemon = ids(load('pokemon.json'), 'pokemon')
moves = ids(load('moves.json'), 'moves')
abilities = ids(load('abilities.json'), 'abilities')
items = ids(load('items.json'), 'items')
forms = load('forms_extra.json')
# Overlay forms are valid Pokémon IDs used by the learnset export.
if isinstance(forms, dict):
    for row in forms.get('pokemon', []):
        if row.get('id') is not None:
            pokemon.setdefault(row['id'], row)

for label, data in [('pokemon', pokemon), ('moves', moves), ('abilities', abilities), ('items', items)]:
    if not data: warnings.append(f'{label}: no rows found')
    for key, row in data.items():
        for field in ('id', 'name'):
            if field not in row or row[field] in (None, ''):
                errors.append(f'{label} {key}: missing {field}')

for raw in rows(load('pokemon_moves.json')):
    row = {'pokemonId': raw[0], 'moveId': raw[1]} if isinstance(raw, list) else raw
    if row.get('pokemonId') not in pokemon: errors.append(f"pokemon_moves: missing pokemon {row.get('pokemonId')}")
    if row.get('moveId') not in moves: errors.append(f"pokemon_moves: missing move {row.get('moveId')}")
for row in rows(load('pokemon_abilities.json')):
    if row.get('pokemonId') not in pokemon: errors.append(f"pokemon_abilities: missing pokemon {row.get('pokemonId')}")
    if row.get('abilityId') not in abilities: errors.append(f"pokemon_abilities: missing ability {row.get('abilityId')}")

if isinstance(forms, dict):
    for row in forms.get('pokemon', []):
        if not row.get('name'): errors.append('forms_extra: form missing name')
        if not row.get('flags'): warnings.append(f"forms_extra {row.get('id')}: no source flags")

print(f'Pokémon: {len(pokemon)} | Moves: {len(moves)} | Abilities: {len(abilities)} | Items: {len(items)}')
for warning in warnings: print(f'WARNING: {warning}')
for error in errors: print(f'ERROR: {error}')
if errors:
    print(f'FAILED: {len(errors)} error(s), {len(warnings)} warning(s)'); sys.exit(1)
print(f'PASSED: {len(warnings)} warning(s)')
