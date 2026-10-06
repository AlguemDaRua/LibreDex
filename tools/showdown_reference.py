"""Reimplementation of Pokémon Showdown's damage formula, used to generate
expected damage values for LibreDex's calculator tests.

Sources: smogon/damage-calc calc/src/mechanics/util.ts and gen789.ts
"""
import math

def OF16(n): return n % 65536 if n > 65535 else n
def OF32(n): return n % 4294967296 if n > 4294967295 else n

def pokeRound(x):
    # Game Freak rounds DOWN on .5
    return math.ceil(x) if x % 1 > 0.5 else math.floor(x)

def chainMods(mods, lo, hi):
    M = 4096
    for m in mods:
        if m != 4096:
            M = (M * m + 2048) >> 12
    return max(min(M, hi), lo)

def getBaseDamage(level, bp, atk, dfn):
    return math.floor(OF32(math.floor(
        OF32(OF32(math.floor((2*level)/5 + 2) * bp) * atk) / dfn) / 50 + 2))

def showdown(level, bp, atk, dfn, bpMods, stabMod, eff, burned=False,
             finalMods=(), weatherMod=4096, crit=False):
    # Base power modifiers are applied to the move's base power BEFORE it
    # reaches getBaseDamage - Showdown chains bpMods into basePower and only
    # then computes base damage. Applying them afterwards gives a different
    # answer, because the intermediate rounding happens at a different point.
    bp = OF16(max(1, pokeRound((bp * chainMods(list(bpMods), 41, 2097152)) / 4096)))
    b = getBaseDamage(level, bp, atk, dfn)
    b = pokeRound(OF32(b * weatherMod) / 4096)
    if crit: b = math.floor(OF32(b * 1.5))
    fm = chainMods(list(finalMods), 1, 0x7fffffff)
    rolls = []
    for i in range(16):
        d = math.floor(OF32(b * (85+i)) / 100)
        if stabMod != 4096: d = OF32(d * stabMod) / 4096
        d = math.floor(OF32(pokeRound(d) * eff))
        if burned: d = math.floor(d / 2)
        rolls.append(OF16(pokeRound(max(1, OF32(d * fm) / 4096))))
    return rolls

def stat(base, iv, ev, level, nature=1.0, hp=False):
    inner = (2*base + iv + (ev//4)) * level // 100
    return inner + level + 10 if hp else int((inner + 5) * nature)
