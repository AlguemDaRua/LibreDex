# Pokémon Champions Support — Updated 08 Aug 2026

LibreDex includes **full** additive support for **Pokémon Champions** ( Regulation M-B, 08 Aug 2026 ). Both **Singles and Doubles** are supported — the calculator is not doubles-only.

## Champions mechanics (verified vs Showdown Champions mode)

- **66 Stat Points total, max 32 per stat** — every SP is `+1` at Lv 50. IVs are fixed at 31.
- **Level is always 50** in Champions; LibreDex locks it and hides the slider.
- **21 Stat Alignments** — Hardy/Docile/Bashful/Quirky were removed, **Serious** is the only neutral. All others are ±10%.
- **Stat formulas:** `HP = Base + SP + 75`, `Other = floor((Base + SP + 20) × Alignment)`.
- **Damage engine is Showdown-parity:** integer Gen IX math, screens `0.5` singles / `2732/4096` doubles, spread moves `0.75×` in doubles (toggle `Double Battle`), Tera disabled in Champions (mainline-only), Helping Hand / burn / crit / `+1.5` correctly handled.

## Champions content in LibreDex

1. **Forms:** 35 Champions-legal Mega Evolutions + alignments are shipped in `assets/data/forms_extra.json` (IDs 10278-10326) and flagged `champions`/`legendsZA`.
2. **Abilities & Moves:** Custom abilities and moves are seeded into Drift with `isChampionsAbility` / `isChampionsMove` flags and are filterable in AbilityDex/MoveDex.
3. **Team Builder → Calculator:** “Open in calculator” carries the Champions ruleset and preserves the 66-SP spreads.

## Presets (all sum to 66)

- Physical Attacker `2 / 32 / 0 / 0 / 0 / 32` — fast physical
- Special Attacker `2 / 0 / 0 / 32 / 0 / 32`
- Bulky Physical `32 / 32 / 1 / 0 / 1 / 0`
- Bulky Special `32 / 0 / 0 / 32 / 1 / 1`
- Trick Room Attacker `32 / 32 / 2 / 0 / 0 / 0` — `Spe: 0`

See `lib/features/calculator/models/battle_ruleset.dart` and `lib/features/pokedex/models/stat_calculator.dart` for the single source of truth.
