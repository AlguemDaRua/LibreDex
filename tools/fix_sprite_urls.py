#!/usr/bin/env python3
"""Sanitizes the bundled sprite URLs in ``assets/data/pokemon.json``.

The bundle mirrors PokéAPI data, whose ``home`` renders do not cover every
cosmetic/transportation form. Pointing the app at those URLs produced broken
images in the form tabs (Koraidon's builds, Miraidon's modes, cosplay and cap
Pikachus, ...).

This tool applies a *curated, audited* map so every ``spriteUrl`` in the
bundle resolves to artwork that actually exists upstream, and every
``shinySpriteUrl`` is either a real shiny render or blank (the UI renders a
graceful "no shiny sprite bundled" note for blanks).

The audit below was performed on 2026-07-27 against the ``PokeAPI/sprites``
git tree (branch ``master``) via the GitHub trees API — the exact file
listings of ``sprites/pokemon/other/home`` and ``.../home/shiny``. It is
deterministic and offline: running it twice changes nothing.

To re-audit against fresh upstream listings, pass::

    python3 tools/fix_sprite_urls.py --verify HOME_LISTING SHINY_LISTING

where each listing file contains one filename per line (``.png`` entries of
the matching upstream directory — e.g. produced from
``gh api repos/PokeAPI/sprites/git/trees/<sha> --jq '.tree[] | .path'``).
Verification fails if any *additional* bundled URL would 404, so new forms
that lose their render upstream surface immediately.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
POKEMON_JSON = REPO_ROOT / 'assets' / 'data' / 'pokemon.json'
HOME_BASE = (
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
    'sprites/pokemon/other/home'
)


def home_url(dex: int) -> str:
    return f'{HOME_BASE}/{dex}.png'


# Audited 404s — the bundled record id → the base-species HOME render to use
# instead. Every id here 404s on its own ``home/{id}.png`` upstream.
BROKEN_NORMAL_FALLBACK_DEX: dict[int, int] = {
    # Cosplay Pikachu outfits from Omega Ruby/Alpha Sapphire — stage-only
    # forms that never received Pokémon HOME renders.
    10080: 25,  # Pikachu Rock Star
    10081: 25,  # Pikachu Belle
    10082: 25,  # Pikachu Pop Star
    10083: 25,  # Pikachu PhD
    10084: 25,  # Pikachu Libre
    10085: 25,  # Pikachu Cosplay
    # Let's Go partner forms ("super-sized" Pikachu/Eevee).
    10158: 25,  # Pikachu Starter
    10159: 133,  # Eevee Starter
    # Koraidon transportation builds — traversal-only, no renders exist.
    10264: 1007,  # Limited Build
    10265: 1007,  # Sprinting Build
    10266: 1007,  # Swimming Build
    10267: 1007,  # Gliding Build
    # Miraidon travel modes — same situation.
    10268: 1008,  # Low Power Mode
    10269: 1008,  # Drive Mode
    10270: 1008,  # Aquatic Mode
    10271: 1008,  # Glide Mode
}

# Forms whose shiny render does not exist upstream. All cosplay/transport
# forms above share this fate, plus the cap Pikachus (which DO have normal
# HOME art but officially cannot be shiny, so no shiny file exists).
BROKEN_SHINY_IDS: frozenset[int] = frozenset(
    BROKEN_NORMAL_FALLBACK_DEX
) | frozenset(
    {
        10094,  # Pikachu Original Cap
        10095,  # Pikachu Hoenn Cap
        10096,  # Pikachu Sinnoh Cap
        10097,  # Pikachu Unova Cap
        10098,  # Pikachu Kalos Cap
        10099,  # Pikachu Alola Cap
        10160,  # Pikachu World Cap
    }
)

_NORMAL_RE = re.compile(rf'^{re.escape(HOME_BASE)}/(\d+)\.png$')
_SHINY_RE = re.compile(rf'^{re.escape(HOME_BASE)}/shiny/(\d+)\.png$')


def patch_bundle(records: list[dict]) -> tuple[int, int]:
    """Applies the curated map. Returns (normal fixes, shiny fixes)."""
    normal_fixes = 0
    shiny_fixes = 0
    for record in records:
        pid = record.get('id')
        if pid in BROKEN_NORMAL_FALLBACK_DEX:
            wanted = home_url(BROKEN_NORMAL_FALLBACK_DEX[pid])
            if record.get('spriteUrl') != wanted:
                record['spriteUrl'] = wanted
                normal_fixes += 1
        if pid in BROKEN_SHINY_IDS:
            if record.get('shinySpriteUrl') != '':
                record['shinySpriteUrl'] = ''
                shiny_fixes += 1
    return normal_fixes, shiny_fixes


def verify_against_listings(
    records: list[dict],
    home_listing: Path,
    shiny_listing: Path,
) -> list[str]:
    """Cross-checks *every* URL shape + existence against upstream listings."""
    home_files = {
        line.strip() for line in home_listing.read_text().splitlines() if line.strip().endswith('.png')
    }
    shiny_files = {
        line.strip() for line in shiny_listing.read_text().splitlines() if line.strip().endswith('.png')
    }
    problems: list[str] = []
    for record in records:
        pid = record.get('id')
        name = record.get('name')
        normal = record.get('spriteUrl') or ''
        shiny = record.get('shinySpriteUrl') or ''

        match = _NORMAL_RE.match(normal)
        if not match:
            problems.append(f'#{pid} {name}: spriteUrl has unexpected shape: {normal!r}')
        elif match.group(1) + '.png' not in home_files:
            problems.append(f'#{pid} {name}: spriteUrl 404s upstream: {normal}')

        if shiny:
            match = _SHINY_RE.match(shiny)
            if not match:
                problems.append(f'#{pid} {name}: shinySpriteUrl has unexpected shape: {shiny!r}')
            elif match.group(1) + '.png' not in shiny_files:
                problems.append(f'#{pid} {name}: shinySpriteUrl 404s upstream: {shiny}')
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        '--verify',
        nargs=2,
        metavar=('HOME_LISTING', 'SHINY_LISTING'),
        help='Re-audit every URL against upstream directory listings.',
    )
    parser.add_argument(
        '--check',
        action='store_true',
        help='Do not write; fail if the bundle is not already patched.',
    )
    args = parser.parse_args()

    records = json.loads(POKEMON_JSON.read_text(encoding='utf-8'))
    normal_fixes, shiny_fixes = patch_bundle(records)

    if args.check:
        if normal_fixes or shiny_fixes:
            print(
                f'FAIL: bundle is not patched ({normal_fixes} normal + '
                f'{shiny_fixes} shiny URLs would change).',
                file=sys.stderr,
            )
            return 1
        print('OK: bundle already matches the curated sprite map.')
    else:
        if normal_fixes or shiny_fixes:
            POKEMON_JSON.write_text(
                json.dumps(records, ensure_ascii=False) + '\n',
                encoding='utf-8',
            )
        print(
            f'Patched {normal_fixes} normal + {shiny_fixes} shiny sprite URLs '
            f'({len(BROKEN_NORMAL_FALLBACK_DEX)} forms remapped, '
            f'{len(BROKEN_SHINY_IDS)} shinies blanked).'
        )

    if args.verify:
        problems = verify_against_listings(records, Path(args.verify[0]), Path(args.verify[1]))
        if problems:
            print(f'FAIL: {len(problems)} sprite URL problems:', file=sys.stderr)
            for problem in problems:
                print(f'  - {problem}', file=sys.stderr)
            return 1
        print('OK: every bundled sprite URL resolves upstream.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
