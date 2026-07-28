#!/usr/bin/env python3
"""Builds assets/data/species.json from the official PokeAPI CSV extracts in tools/data/.

Run:  python3 tools/build_species_asset.py
Source: https://github.com/PokeAPI/pokeapi (data/v2/csv), CC-BY-NC-SA / see upstream.
"""
import csv, json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'tools', 'data')
OUT = os.path.join(ROOT, 'assets', 'data', 'species.json')

EGG_GROUPS = {
    1: 'Monster', 2: 'Water 1', 3: 'Bug', 4: 'Flying', 5: 'Field', 6: 'Fairy',
    7: 'Grass', 8: 'Human-Like', 9: 'Water 3', 10: 'Mineral', 11: 'Amorphous',
    12: 'Water 2', 13: 'Ditto', 14: 'Dragon', 15: 'Undiscovered',
}
GROWTH_RATES = {
    1: 'Slow', 2: 'Medium Fast', 3: 'Fast', 4: 'Medium Slow',
    5: 'Erratic', 6: 'Fluctuating',
}
# Total experience required to reach level 100 for each growth rate.
GROWTH_TOTALS = {
    1: 1250000, 2: 1000000, 3: 800000, 4: 1059860, 5: 600000, 6: 1640000,
}


def read_csv(name):
    with open(os.path.join(DATA, name), newline='', encoding='utf-8') as fh:
        return list(csv.DictReader(fh))


def as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def gender_label(rate):
    """PokeAPI stores gender_rate as eighths-female, or -1 for genderless."""
    if rate < 0:
        return {'genderless': True, 'male': 0.0, 'female': 0.0}
    female = rate / 8 * 100
    return {'genderless': False, 'male': round(100 - female, 1), 'female': round(female, 1)}


def main():
    forms = {as_int(r['id']): r for r in read_csv('forms.csv')}

    eggs = {}
    with open(os.path.join(DATA, 'egg_groups.csv'), encoding='utf-8') as fh:
        for line in fh:
            line = line.strip()
            if not line or ':' not in line:
                continue
            key, groups = line.split(':', 1)
            eggs[as_int(key)] = [
                EGG_GROUPS[as_int(g)] for g in groups.split(',') if as_int(g) in EGG_GROUPS
            ]

    species = {}
    for row in read_csv('species.csv'):
        sid = as_int(row['id'])
        growth = as_int(row['growth_rate'], 2)
        species[sid] = {
            'id': sid,
            'generation': as_int(row['gen'], 1),
            'evolvesFrom': as_int(row['evolves_from']) or None,
            'gender': gender_label(as_int(row['gender_rate'], -1)),
            'captureRate': as_int(row['capture_rate']),
            'baseHappiness': as_int(row['base_happiness']),
            'isBaby': as_int(row['is_baby']) == 1,
            'hatchCounter': as_int(row['hatch_counter']),
            'eggCycles': as_int(row['hatch_counter']),
            # Gen-VIII+ formula: (hatch_counter + 1) * 128 steps.
            'eggSteps': (as_int(row['hatch_counter']) + 1) * 128,
            'growthRate': GROWTH_RATES.get(growth, 'Medium Fast'),
            'growthTotalExp': GROWTH_TOTALS.get(growth, 1000000),
            'isLegendary': as_int(row['is_legendary']) == 1,
            'isMythical': as_int(row['is_mythical']) == 1,
            'eggGroups': eggs.get(sid, []),
        }

    payload = {
        'forms': {
            str(fid): {
                # PokeAPI stores height in decimetres and weight in hectograms.
                'heightM': round(as_int(f['height']) / 10, 2),
                'weightKg': round(as_int(f['weight']) / 10, 2),
                'baseExp': as_int(f['base_exp']),
            }
            for fid, f in sorted(forms.items())
        },
        'species': {str(sid): s for sid, s in sorted(species.items())},
    }

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as fh:
        json.dump(payload, fh, separators=(',', ':'), ensure_ascii=False)
    print(f'Wrote {OUT}: {len(payload["forms"])} forms, {len(payload["species"])} species')


if __name__ == '__main__':
    main()
