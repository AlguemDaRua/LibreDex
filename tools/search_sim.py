"""Runs the Pokédex search logic against the real bundled dataset.

A faithful Python port of lib/features/pokedex/utils/pokemon_search.dart, so
search behaviour can be checked without building the app. The Dart is the
source of truth; if the two disagree, this port is the one that is wrong.

Usage:  python3 tools/search_sim.py            # built-in sample queries
        python3 tools/search_sim.py gar char   # or your own
"""
import json, sys, re

def load(path='assets/data/pokemon.json'):
    d = json.load(open(path))
    return d if isinstance(d, list) else list(d.values())

def is_subsequence(q, text):
    if len(q) < 3: return False
    i = 0
    for ch in text:
        if ch == q[i]:
            i += 1
            if i == len(q): return True
    return False

def matches_tokens(q, name, form):
    toks = [t for t in re.split(r'\s+', q) if t]
    if len(toks) < 2: return False
    hay = name + ' ' + form
    return all(t in hay for t in toks)

def rank(p, q):
    q = q.strip().lower()
    if not q: return 0
    name = p['name'].lower()
    form = (p.get('form') or '').lower()
    t1   = (p.get('type1') or '').lower()
    t2   = (p.get('type2') or '').lower() or ''
    dn   = p.get('nationalDexNumber') or 0
    dex  = str(dn if dn > 0 else p['id'])
    if name == q: return 0
    if name.startswith(q): return 1
    if any(part.startswith(q) for part in name.split('-')): return 2
    if q in name: return 3
    if q in form: return 4
    if q == dex or q == dex.zfill(3): return 5
    if q in t1 or q in t2: return 6
    toks = [t for t in re.split(r'\s+', q) if t]
    if len(toks) >= 2 and all(t in (name + ' ' + form) for t in toks): return 7
    return 8

def matches(p, q):
    q = q.strip().lower()
    if not q: return True
    name = p['name'].lower(); form = (p.get('form') or '').lower()
    t1 = (p.get('type1') or '').lower(); t2 = (p.get('type2') or '').lower() or ''
    dn = p.get('nationalDexNumber') or 0
    dex = str(dn if dn > 0 else p['id'])
    return (q in name or q in form or q in t1 or q in t2
            or q in dex or q in dex.zfill(3)
            or matches_tokens(q, name, form)
            or is_subsequence(q, name.replace('-', '')))

def collapse(rows):
    """One entry per species, as the Pokédex list does.

    The screen keeps every form but displays one row per species, and ranks
    the group by its BEST match across all forms (groupRank), not by the
    first or lowest-id form. So a group matches if ANY form matches.
    """
    by_dex = {}
    for p in rows:
        dn = p.get('nationalDexNumber') or p['id']
        by_dex.setdefault(dn, []).append(p)
    groups = []
    for dn, forms in by_dex.items():
        base = min(forms, key=lambda f: f['id'])
        groups.append({'base': base, 'forms': forms,
                       'name': base['name'], 'form': base.get('form',''),
                       'dex': dn,
                       'matched_forms': [f for f in forms
                                         if len(forms) > 1 and f is not base]})
    return groups

def search(groups, q, n=8):
    hits = [g for g in groups if any(matches(f, q) for f in g['forms'])]
    def key(g):
        return (min(rank(f, q) for f in g['forms']), g['dex'], g['name'])
    hits.sort(key=key)
    return hits[:n], len(hits)

if __name__ == '__main__':
    rows = collapse(load('assets/data/pokemon.json'))
    print(f"species after collapsing forms: {len(rows)}\n")
    queries = sys.argv[1:] or ['gar', 'char', 'pika', 'garchomp', '006', 'fire', 'floette eternal']
    for q in queries:
        top, total = search(rows, q, 8)
        print(f"query {q!r:20} {total:4} matches")
        for g in top:
            r = min(rank(f, q) for f in g['forms'])
            via = [f"{f['name']}/{f.get('form','')}" for f in g['forms']
                   if matches(f, q) and f is not g['base']][:2]
            extra = f"   (via {', '.join(via)})" if via else ""
            print(f"    rank {r}  #{g['dex']:<5} {g['name']}{extra}")
        print()
