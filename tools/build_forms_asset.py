#!/usr/bin/env python3
"""Compatibility entry point for the real curated forms-asset builder.

The implementation lives in ``build_champions_forms_asset.py`` so the
Pokémon/Legends Z-A overlay is generated from PokéAPI CSV records and reviewed
form overrides in one place. This script forwards the original convenient
command name instead of silently reporting that an asset was "packed".

Example:
    python3 tools/build_forms_asset.py --csv-dir /path/to/pokeapi/data/v2/csv
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV_DIR = ROOT / "tools" / "data" / "pokeapi-csv"
DEFAULT_OUTPUT = ROOT / "assets" / "data" / "forms_extra.json"
BUILDER = ROOT / "tools" / "build_champions_forms_asset.py"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--csv-dir",
        type=Path,
        default=DEFAULT_CSV_DIR,
        help="PokéAPI v2 CSV directory (pokemon.csv, pokemon_stats.csv, etc.).",
    )
    parser.add_argument("--out", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    command = [
        sys.executable,
        str(BUILDER),
        "--csv-dir",
        str(args.csv_dir),
        "--out",
        str(args.out),
    ]
    return subprocess.run(command, cwd=ROOT, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())
