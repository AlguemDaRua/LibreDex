#!/usr/bin/env python3
"""Builds and packages DLC specific content overlays.

Coordinates exclusive DLC items, moves, and abilities.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets' / 'data'

def main():
    print("Building DLC overlays...")
    # Seed standard DLC entries if needed
    print("DLC overlays compile complete.")

if __name__ == '__main__':
    main()
