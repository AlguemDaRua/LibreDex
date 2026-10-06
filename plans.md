# LibreDex — Roadmap

**Owner:** @AlguemDaRua · **Last verified:** 2026-10-06 · **Against commit:** `4d58f1f`
**Reference docs:** [`docs/reference.md`](docs/reference.md) — architecture, data, game support, testing, release

This is the single living plan for LibreDex. Everything is either **closed** with
evidence or **explicitly deferred** with a reason and a revisit condition — nothing
sits in an ambiguous state.

If a number in this file disagrees with the code, the code wins — re-run
[§H](#h-measurement-appendix) and correct this file.

---

## 0. How to use this file

| Status | Meaning |
|:---:|---|
| ✅ | **Closed.** Verified against the tree, with evidence in [§B](#b-completed). |
| ⛔ | **Not doing.** Deferred *on purpose*, reason recorded, revisit condition stated. |

**Every item in this file carries one of those two marks.** There is no "in progress"
bucket on purpose: an item that is half-done is an item that will be rediscovered
half-undone three audits from now. Work that was started and deliberately stopped is
recorded under [§F](#f-not-doing) with what was learned.

**One rule:** an item is not ready to start until it has a **Done-when** that a machine
can check. An effort estimate without a Done-when is a wish.

**Two anti-patterns this file is designed to prevent:**

1. *Report accumulation.* The God Screens survived two full audit cycles carrying the
   same recommendation ("split them") without ever getting a first commit. That is the
   signature of a task too large to start, not of a task needing more detail.
2. *Symptom-as-goal.* "229 `setState` calls" is not a defect — `setState` for a
   `TextEditingController` is correct. Counts in [§A](#a-measurement-basis) are context,
   never targets.

---

## A. Measurement basis

Measured at `4d58f1f`. Re-derive with [§H](#h-measurement-appendix) before trusting.

| Metric | Value | Δ vs `0f63c88` |
|---|---|---|
| Dart files in `lib/` | 122 | +4 |
| Lines in `lib/` | 47,390 | +1,041 |
| Of which generated (`.g.dart`) | 8,530 | — |
| Test files / lines | 26 / 5,635 | +8 / +2,023 |
| Test declarations | 260 | +~100 |
| Test-to-source ratio | 1 : 8.4 | was 1 : 12.8 |
| Feature modules | 13 | — |
| DB tables | 5 (indexes created in `beforeOpen`) | — |
| Bundled JSON assets | 12 files, 5.7 MB (`pokemon_moves.json` alone = 2.9 MB) | — |
| God Screens | 3 files, 7,093 lines, **15.0 %** of `lib/` | 7,202 / 15.5 % |

**God Screens** are `damage_calculator_screen.dart` (3,461), `pokedex_screen.dart`
(2,289) and `movedex_screen.dart` (1,343). The calculator shrank by 111 lines when the
duplicate damage implementation was deleted rather than moved.

**Health signals**

| Signal | Count | Reading |
|---|---|:---|
| `Semantics` annotations | 9 | Still a real a11y gap — see [§F](#f-not-doing) |
| `catch (_)` silent swallows | 23 | Several are user-visible wrong-answer bugs |
| `setState` calls | 229 | Not inherently bad — see §0 |
| `late` fields | 119 | Moderate |
| `Color(0x…)` literals | 569 | Cosmetic / maintainability |
| `ValueKey` in list builders | 1 | Second-order perf |
| `RepaintBoundary` | 5 | Second-order perf |
| `precacheImage` | 0 | Second-order perf |
| `SelectionArea` | 0 | Attempted and **removed** — it crashed. See [§F](#f-not-doing) |
| `Navigator.push` | 11 | See [§G](#g-correction-log) |
| `ref.read` / `ref.watch` | 52 / 57 | Healthy |
| View/widget files importing `app_database.dart` | 18 (34 repo-wide) | Layering drift |

---

## B. Completed

Verified present in the tree at `4d58f1f`, with `flutter analyze` clean and
`flutter test` passing (260 tests).

### B1. Damage calculation and battle engine

| ✅ | Item | Evidence |
|:---:|---|---|
| ✅ | **Two damage implementations unified** | `SandboxDamageEngine` resolves through the shared `ModifierPipeline`. The ~155-line hand-rolled copy in `_buildRawSandboxTab` is gone. |
| ✅ | **Showdown parity: chained modifiers round once** | `DamageMath.chainMods` accumulates `M = (M * mod + 2048) >> 12` and clamps once — not per step. Previously each modifier rounded independently. |
| ✅ | **Showdown parity: overflow wrapping** | 16-bit and 32-bit wrapping at the same points as the game (`OF16` / `OF32`). |
| ✅ | **Exact 4096 fractions** | `damage_math.dart` uses `boost11 = 4505`, `boost12 = 4915`, `boost13 = 5324`, `boost15 = 6144`, `boostTerrain = 5325`, `boostPunchingGlove = 4506`. `_modifierFromDouble` maps the common decimals to those exact values, so the pipeline's `1.2` becomes `4915`, not `1.2 * 4096`. |
| ✅ | **Base-power bounds** | Base power clamped `(41, 2097152)`; attack and defense `(410, 131072)` — matching `gen789.ts`. |
| ✅ | **Base-power mods apply before `getBaseDamage`** | Found by the parity test: the Showdown *reference* applied them after. Fixed in `e94d50e`. |
| ✅ | **Move-power items moved to base power** | Muscle Band / Wise Glasses / Punching Glove were being applied to final damage. Now `physicalPowerMultiplier`, `specialPowerMultiplier`, `punchingPowerMultiplier` on `HeldItem`, applied at the base-power stage. |
| ✅ | **Expert Belt is a conditional final modifier** | `modifier_pipeline.dart:727` — `effectiveness > 1.0` → `1.2`, applied in the final chain, not base power. |
| ✅ | **Held items no longer double-count on the sandbox path** | Fixed in `389b762`. |
| ✅ | Parity tests over real Gen 9 matchups | `test/damage_showdown_parity_test.dart` (164 lines), `test/sandbox_damage_parity_test.dart` (424 lines). |
| ✅ | Held-item placement pinned | `test/held_item_placement_test.dart` (203 lines). |
| ✅ | Sandbox gained missing mechanics | Aurora Veil, Multiscale/Shadow Shield, Filter/Solid Rock/Prism Armor, Ice Scales/Thick Fat/Purifying Salt, Tinted Lens, Expert Belt, Muscle Band/Wise Glasses, Life Orb and type gems, Weather Ball/Terrain Pulse, Technician/Sharpness/Iron Fist and friends. |
| ✅ | Air Balloon immunity | Threaded through `combat_utils.dart` (grounding) into `getTypeEffectiveness`. |
| ✅ | Cosmetic-form filter shared by all three pickers | `lib/core/utils/cosmetic_forms.dart`, used by `pokemon_picker_dialog.dart`, `stat_comparison_screen.dart`, `team_builder_screen.dart`. |

### B2. Pokédex search

The single largest user-visible improvement this cycle. Documented in full because the
reasoning is easy to lose.

| ✅ | Item | Evidence |
|:---:|---|---|
| ✅ | **Results appear while typing** | `DebouncedSearchField` used a pure 300 ms *trailing* debounce, which cancelled on every keystroke — a normal-speed typist saw nothing until they paused. Replaced with a leading-edge throttle at 100 ms plus a guaranteed trailing emit. Fixes every search in the app: all four dex screens, three calculator pickers, stat comparison. |
| ✅ | **Real matches rank above subsequence noise** | `PokemonSearch.rank`: exact → name-prefix → word-prefix → substring → form → dex → type → tokens → subsequence. While searching on the default sort, relevance outranks dex order. |
| ✅ | **Search is answered by the species, never its forms** | `pokedex_screen.dart` — the row whose `id` equals its dex number answers the search for every row of that species. Every one of the 1,025 species has exactly one such row. |
| ✅ | **Groups rebuilt from the full list** | The filtered list carries only the species row while searching, and the card passes its group to the detail page — so groups are rebuilt from `pokemonList`. Without this, filtering silently stripped a species' forms. |
| ✅ | **Mega Evolution filter** | 87 species match. Tests the `form` field for classic Megas and the overlay flag for Legends: Z-A Megas — deliberately **not** the name, because Meganium and Yanmega contain "mega" but are not Mega Evolutions. |
| ✅ | **`N FORMS` badge** | 224 of 1,025 species. The count includes the species' own row (Charizard reads `4 FORMS`, Pikachu `17`), which is the Pokédex convention. Sits in the existing `Wrap` with the type and M-C badges. |
| ✅ | Species categories are data-driven | Replaced ~130 lines of hardcoded Dex IDs and name prefixes. |
| ✅ | `_loadRelationsData` no longer swallows every failure | Wrapped in `catch (_) {}`; a failure silently returned zero results for the hidden-ability filter. |
| ✅ | One card per species, base form only | Card picks `form == 'normal'` explicitly rather than relying on `group.first`. |
| ✅ | Search extracted into a testable utility | `lib/features/pokedex/utils/pokemon_search.dart`. It lived in the screen's `State` object and could not be tested at all — which is how the ranking bug survived. |
| ✅ | Ability-compatibility search debounced | Uses the existing `DebouncedQuery`. |

**Measured effect on the bundled data:**

| Query | Before | After |
|---|---|---|
| `mag` | 45 species | **17**, all genuinely Mag-named |
| `gar` | 74 | **25** (Garchomp still 2nd) |
| `pika` | 2 | **1** |
| `clef` + Mega filter | *broken — 0* | **Clefable** |

The `mag` bug had two causes, both from the same root: `mag` is a substring of `mega`,
so every classic Mega form matched and dragged its species in; and Champion ability
names were searchable, so `magic` matched Mega Clefable through **Magic Bounce**.

**Ordering rule:** match quality first, then dex number within a tier. Dex order was
kept over alphabetical deliberately — for `char`, dex gives Charmander, Charmeleon,
Charizard (evolution line adjacent); alphabetical gives Charcadet, Charizard,
Charjabug, Charmander, Charmeleon. Dex is also canonical Pokédex order.

Consequence worth knowing: for `gar`, Gardevoir, Garchomp, Garbodor and Garganacl are
all *equally good* prefix matches, so Garchomp can legitimately be 2nd. No ordering rule
can infer which one the user meant — that is not a bug.

### B3. Randomizer

| ✅ | Item | Evidence |
|:---:|---|---|
| ✅ | **Roll a team of six** | `RandomizerSettings.rollCount` (1 or 6), chosen from the existing settings sheet. Picks are **without replacement**, so the six are distinct; a pool smaller than six yields what it has. Pool size is floored at 1 before clamping because `clamp()` throws when the lower bound exceeds the upper. |
| ✅ | Team reveal | 3-across grid of tappable cards; header reads `TEAM ACQUIRED!`; the single-pick "VIEW POKÉMON DETAILS" button is hidden since a team is read card by card. The slot machine still spins and lands on the first pick. |
| ✅ | Settings persist | `rollCount` saved with the rest of the randomizer prefs. |
| ✅ | Button tooltip follows the setting | Reads "Random Team of 6". |
| ✅ | Two no-op test scenarios fixed | Two `sandbox_damage_parity_test.dart` scenarios named items that do not exist. `findByName` returned `null`, every multiplier fell back to 1.0, and both engines trivially agreed — **2 of 12 scenarios passed while testing nothing**. A `checkItem` guard now throws on unknown names. |

### B4. Tests

| ✅ | Item | Evidence |
|:---:|---|---|
| ✅ | **ViewModel tests** | 87 tests in `test/viewmodels/`: stat calculator (22), damage calculator (16), Pokédex search (25), stat comparison (24). |
| ✅ | Pokédex search logic extracted so it could be tested | See B2. |
| ✅ | Tie-break reversal in stat comparison fixed | `a4233a5` — the tie-break returned after the direction negation, so descending order reversed ties. |
| ✅ | Four test defects fixed alongside it | Including two HP expectations that were wrong. |
| ✅ | Form-count badge tests | `test/form_count_badge_test.dart` — label, tooltip, four-form card, single-form card. |
| ✅ | Team-roll test | `test/random_roll_overlay_test.dart` — six of an eight-Pokémon pool, all distinct, single-pick button absent, tapping a card reports that Pokémon. |
| ✅ | Full suite green | 260 tests, `flutter analyze` clean. |

### B5. Data, provenance and infrastructure

| ✅ | Item | Evidence |
|:---:|---|---|
| ✅ | Index-creation hazard guarded | `app_database.dart` `beforeOpen` carries a do-not-move warning. |
| ✅ | ItemDex duplicate rows hidden | Reuses the existing alias mechanism rather than a new special case. |
| ✅ | Navigation redundancy removed | `app_drawer.dart` and `navigation_style_provider.dart` gone. |
| ✅ | Single source of truth for destinations | `AppSection` enum in `lib/core/navigation/app_sections.dart`. |
| ✅ | Adaptive shell | `home_screen.dart:121` — `NavigationRail` ≥ 700 dp, `NavigationBar` below. |
| ✅ | Champions rule accuracy | `ChampionsRules.totalStatPoints = 66`, asserted at `champions_ruleset_test.dart:143`. |
| ✅ | Regulation M-C held items | `champions_regulation_mc.json` — 151 items / 18 new. Test asserts `hasLength(151)` / `hasLength(18)`. |
| ✅ | **Android launcher icons restored** | `0807265` (a docs commit) deleted 22 files under `Icons/`, including every mipmap launcher asset. `AndroidManifest.xml` declares `android:icon="@mipmap/ic_launcher"`, so merging without them would have broken the Android build. Restored verbatim in `4d58f1f`. |
| ✅ | CI pipeline | Java 17 + Gradle cache, Flutter cache, Python 3.12, format gate, `analyze --fatal-infos`, 5 data validators, `flutter test --coverage`, debug APK. |
| ✅ | Workflow protection | `.github/CODEOWNERS` requires @AlguemDaRua on `.github/**`. |
| ✅ | Release signing configured | `build.gradle.kts` signs from `android/key.properties` when present. **Needs your keystore before distributing** — see [§I](#i-standing-notes). |

### B6. Accessibility (partial — see §F)

| ✅ | Item | Evidence |
|:---:|---|---|
| ✅ | Labels for unlabelled buttons | `e964575` — tooltips added across the app. |
| ✅ | Startup live region | `Semantics` block announcing app-ready state. |
| ⛔ | App-wide text selection | Attempted via `SelectionArea` in `MaterialApp.builder`; **crashed the app**. Reverted. See [§F](#f-not-doing). |

---

## C. Critical path

**All five closed.** C3 closed *without* measurement because the app owner reports the
Pokédex is smooth while typing — there is no performance problem to chase. The real bug
in that area turned out to be search **responsiveness and ranking**, now closed under B2.

| # | Item | Status | Note |
|:---:|---|:---:|---|
| C1 | Unify the two damage paths | ✅ | Second implementation deleted; parity tests added |
| C2 | Guard the index-creation hazard | ✅ | Warning comment in `beforeOpen` |
| C3 | Instrument before optimising | ✅ | **No perf problem exists.** Owner confirms the app is smooth while typing. The premise was inherited from the v1 audit and never verified. No perf work planned. |
| C4 | Debounce the undebounced field | ✅ | Scope corrected — see [§G](#g-correction-log) |
| C5 | Release signing | ✅ | Lands **unsigned-ready**; needs your `key.properties` |

---

## D. Next — all closed or explicitly deferred

Every item that was on this list is now either ✅ with evidence above or ⛔ with a
reason in [§F](#f-not-doing). Nothing remains open.

| # | Item | Status |
|:---:|---|:---:|
| D0 | Search responsiveness and ranking | ✅ B2 |
| D1 | Decompose `pokedex_screen.dart` | ⛔ [F1](#f-not-doing) |
| D2 | Species categories to data | ✅ B2 |
| D3 | `_loadRelationsData` swallowed failures | ✅ B2 |
| D4 | Calculator picker: hide no-op cosmetic forms | ✅ B1 |
| D4b | The same filter everywhere | ✅ B1 |
| D5 | Held items: correct placement, reachable in UI | ✅ B1 |
| D5b | Held items the model could not express | ✅ B1 |
| D6 | ItemDex duplicate item names | ✅ B5 |
| D7 | Accessibility baseline | ⛔ [F2](#f-not-doing) — partially delivered, see B6 |
| D8 | ViewModel unit tests | ✅ B4 |
| D9 | Silent-failure audit | ⛔ [F3](#f-not-doing) |
| D10 | Feature repositories for the 18 view/widget files | ⛔ [F4](#f-not-doing) |
| D11 | Release-readiness hygiene | ⛔ [F5](#f-not-doing) |

**D5b deserves a note.** Four items were previously unimplementable: Expert Belt
(conditional on super-effective), Muscle Band and Wise Glasses (move *power*, not the
Attack *stat*), and Punching Glove (punching-only). Adding them approximately would
have put wrong numbers into the component the owner wants 100 % correct. They are now
all expressible — Expert Belt as a conditional final modifier, the other three through
the new move-power fields on `HeldItem` — and all four are pinned against Showdown.

---

## E. Later

Real work, deliberately undated. Pull one in when a concrete need appears.

| # | Item | Note |
|:---:|---|---|
| E1 | `go_router` / declarative routing | Only if deep linking becomes a requirement. See [§F](#f-not-doing). |
| E2 | SQLite FTS5 search | Only after search moves into SQL. There are currently **zero** `LIKE` queries — search is `_isSubsequence()` over an in-memory list. |
| E3 | Localisation (i18n / ARB) | Large, mechanical, easier once the UI structure settles. |
| E4 | iOS support | `Icons/ios/` (22 files) and `Icons/web/` are already staged. |
| E5 | Golden / visual regression tests | Needs a stable UI first — after D1. |
| E6 | `OfflineArtworkStore` → Riverpod provider | Currently a static singleton with a manual `_persistQueue` chain. Do it when it needs mocking in a test. |
| E7 | Extract 569 `Color(0x…)` literals into `AppTheme` | Cosmetic; opportunistically, file-by-file, not as a campaign. |
| E8 | Integration test (`integration_test/app_flow_test.dart`) | Highest-value test investment after the ViewModel work. |
| E9 | Binary asset compression (`pokemon_moves.json`, 2.9 MB) | Prefer `--split-per-abi` + App Bundle first; measure before adding CBOR complexity. |

---

## F. Not doing

Deferred *on purpose*, each with a reason and a revisit condition, so these stop
regenerating every audit cycle. Revisit when the condition is true — not because an
entry is old.

| # | Item | Why not now | Revisit when |
|:---:|---|---|---|
| ⛔ F1 | **Decompose `pokedex_screen.dart`** (2,289 lines) | Splitting a file is worth doing only when it makes a specific change easier. The targeted extraction that *was* needed already happened: search moved to `PokemonSearch`, the card to `PokemonGridCard`. The remaining 2,289 lines are cohesive filter/sort UI that is not currently blocking anything. Splitting it now would be motion, not progress. | A specific change in that file becomes hard to make |
| ⛔ F2 | **Full accessibility baseline** (9 `Semantics` in 47 k lines) | Partially delivered: tooltips on unlabelled buttons, a startup live region. The remaining work — `TypePill`, `StatTile`, `PokemonGridCard`, type-chart cells — is broad and needs a device/screen-reader pass to verify, which has not happened. Half-measures here are worse than none, because an untested `Semantics` node can make a screen reader *worse*. | Someone can verify with a real screen reader |
| ⛔ F3 | **`SelectionArea` for app-wide text selection** | **Tried and reverted.** Placing it in `MaterialApp.builder` crashes at startup — it requires an `Overlay` ancestor that does not exist there. A cheap 15-minute win that cost a broken build. It has to wrap a screen *inside* the navigator, not the app. | Someone wires it per-screen with a real test |
| ⛔ F4 | **Silent-failure audit** (23 `catch (_)`) | Triage by blast radius, not by count. The two user-visible wrong-answer bugs in this class — `_loadRelationsData` and the swallowed Pokédex load error — are already fixed. The rest are logging gaps, not wrong answers. | One is shown to hide a real failure |
| ⛔ F5 | **Feature repositories for the 18 view/widget files** | Some of the 18 import a Drift *data class* for typing, which is fine; only running `db.select()` in a widget is a real problem, and there are few of those. A blanket repository layer is churn with regression risk and no user-visible gain. | A specific widget query causes a bug |
| ⛔ F6 | **Release-readiness hygiene** (Gradle JVM args, ProGuard rules, network security config) | Not blocking: no release has been attempted. The one genuinely required item — signing — is configured and waiting on a keystore. | A release build is actually attempted |
| ⛔ F7 | **`go_router` migration** | There are 11 `Navigator.push` calls, not 82. This is an `IndexedStack` app with a bespoke, already-tested `SectionBackStack`. go_router buys deep links for a URL scheme that has not been designed. | A URL scheme or deep-link requirement exists |
| ⛔ F8 | **Move index creation to `onUpgrade`** | Would leave fresh installs with no indexes. | Never as written — only with `onCreate` **and** `onUpgrade` |
| ⛔ F9 | **SQLite FTS5** | No `LIKE` queries exist; search is in-Dart. | Search moves into SQL |
| ⛔ F10 | **ApiClient retry / connectivity / rate limiting** | 2 call sites, both for evolution chains, both with a bundled fallback. | A second, non-optional network feature appears |
| ⛔ F11 | **Coverage gate (`--min-coverage 60`)** | At ~12 % this is a gate that goes red on day one and is ignored by day five. A red light everyone ignores is worse than no light. | Coverage is within ~10 pts of the threshold |
| ⛔ F12 | **Blanket `setState` → Riverpod migration** | 229 calls, mostly correct usage (text controllers, expansion state, animation). | A specific `setState` is shown to cause a bug |
| ⛔ F13 | **Blanket `ref.read` → `ref.watch`** | 52 / 57 is healthy; `ref.read` in callbacks is the *recommended* pattern. Only `ref.read` inside `build()` is a bug. | — |
| ⛔ F14 | **Removing all cross-feature imports** | Some are legitimate shared-model use (`stat_comparison` → `calculator` for `ChampionsRules`). The ones worth fixing are *cycles*: `pokedex ↔ movedex`, `pokedex ↔ abilitydex`. | Scoped to cycles only |
| ⛔ F15 | **Web / desktop targets** | Android is the only shipped platform. | Android + iOS are stable |

---

## G. Correction log

Errors found in previous plans by verifying them line-by-line against the tree. Recorded
so nobody re-derives them.

| Claim | Actual | Consequence |
|---|---|---|
| "Active test regression: expects 140/7, actual 151/18" | Test already asserted `151` / `18` | The #1 P0 was already resolved; starting there wastes a cycle |
| "82 imperative `Navigator.push` calls" | **11** pushes (73 `Navigator` refs, mostly `pop` in dialogs) | Inflated the go_router business case ~7× |
| "10 UI view/widget files import `app_database.dart`" | **18** (34 repo-wide) | Understated the layering work by ~80 % |
| "Move index creation from `beforeOpen` to `onUpgrade`" | Would break fresh installs | Would ship a silent, permanent, CI-invisible regression |
| "3 God Screens = 7,136 lines / 15.6 %" | 7,093 lines / 15.0 % at `4d58f1f` | Cosmetic |
| "227 `setState` · 131 `late` · 467 `Color()`" | 229 · 119 · 569 | Cosmetic |
| Pokedex split targets | Omitted the 826-line bottom sheet | Would leave the worst 40 % of the file untouched |
| Calculator split into 8 panels | File is 2 mega-methods organised by tab, not 8 panels | A contributor cannot find the proposed seams |
| "Debounce AbilityDex and ItemDex" | `DebouncedSearchField` already existed; the Pokédex (largest list) was excluded | Wrong priority; infrastructure existed |
| `battle_ruleset.dart` under `battle_engine` | Lives in `features/calculator/models/` | Minor path error |
| — | **Two divergent damage implementations in one screen** | Missed entirely; became C1 |
| **v2:** "Pokédex/MoveDex/AbilityDex/ItemDex search is not debounced" | All four already debounced at 300 ms | Wrong target. Came from inferring behaviour via a direct grep and missing an indirect call |
| **v2:** "Swap the four raw `TextField`s for `DebouncedSearchField`" | There were no raw search `TextField`s | Task was already complete |
| **v1:** "Synchronous main-thread filtering… 900+ items filtered on every character typed", cold-start, energy/frame budgets — the whole §6 performance audit | Owner confirms **nothing feels laggy**. No measurement ever backed it | An entire audit section was fabricated from code-reading. **Lesson: any performance claim in this file must cite a measurement or be labelled a hypothesis** |
| **v1:** `DebouncedSearchField` at 300 ms | A trailing debounce that long never fires while a normal-speed typist types | Caused the exact bug the owner reported |
| **2026-10-06:** two `sandbox_damage_parity_test.dart` scenarios named items that do not exist | `findByName` returned `null`, all multipliers fell back to 1.0, both engines trivially agreed | **2 of 12 scenarios passed while testing nothing.** A `checkItem` guard now throws |
| **2026-10-06:** the Showdown reference applied base-power mods *after* `getBaseDamage` | The games apply them before | Found only because the parity test was written; fixed in `e94d50e` |
| **2026-10-06:** `SelectionArea` in `MaterialApp.builder` is "a cheap whole-app a11y win" | It crashes the app — no `Overlay` ancestor | Passing `flutter analyze` and `flutter test` does **not** prove a widget-tree change works. Now F3 |

**The last row is the important one.** Three times this cycle, code that analysed clean
and passed the existing tests was wrong when run: the Jolly/Adamant NatureDex case, the
HP expectations in the stats test, and the `SelectionArea` crash. Static analysis and
unit tests verify *logic*; they do not verify that a widget is wired into the tree
correctly, and they do not verify that an expectation matches the game.

---

## H. Measurement appendix

Re-run from the repository root to re-derive [§A](#a-measurement-basis).

```bash
# Size
find lib -name "*.dart" | wc -l                     # files
find lib -name "*.dart" -exec cat {} + | wc -l      # lines
find lib -name "*.g.dart" -exec cat {} + | wc -l    # generated lines
find lib -name "*.dart" -exec wc -l {} + | sort -rn | head -15

# Tests
find test -name "*.dart" | wc -l
find test -name "*.dart" -exec cat {} + | wc -l
grep -rhoE '^\s*(test|testWidgets)\(' test --include=*.dart | wc -l

# Health signals (escape the parens — an unescaped "(" opens a group and silently matches nothing)
grep -rEo 'Semantics\('    lib --include=*.dart | wc -l
grep -rEo 'setState\('     lib --include=*.dart | wc -l
grep -rEo 'SelectionArea'  lib --include=*.dart | wc -l
grep -rEo 'Color\(0x[0-9A-Fa-f]{8}\)' lib --include=*.dart | wc -l
grep -rEo 'catch[[:space:]]*\(_[[:space:]]*\)' lib --include=*.dart | wc -l
grep -rEow 'late'          lib --include=*.dart | wc -l

# The number that was 7x wrong
grep -rEo "Navigator\.push[A-Za-z]*\(" lib --include=*.dart | wc -l   # pushes
grep -rEo "Navigator\.[a-zA-Z]+"       lib --include=*.dart | wc -l   # all refs

# Layering
grep -rln "app_database.dart" lib/features --include=*.dart | grep -E "/(views|widgets)/" | wc -l
grep -rEo "ref\.(read|watch)\(" lib --include=*.dart | sort | uniq -c

# Cross-feature import pairs (cycles are the ones that matter)
for f in $(find lib/features -name "*.dart" ! -name "*.g.dart"); do
  feat=$(echo "$f" | cut -d/ -f3)
  grep -oE "package:libredex/features/[a-z_]+/" "$f" \
    | sed 's|package:libredex/features/||;s|/||' | sort -u \
    | while read -r t; do [ "$t" != "$feat" ] && echo "$feat -> $t"; done
done | sort | uniq -c | sort -rn

# Data assets
ls -la assets/data | tail -n +2 | awk '{s+=$5} END {print s/1048576 " MB"}'
python3 -c "import json;d=json.load(open('assets/data/champions_regulation_mc.json'));print(len(d['itemIds']),len(d['newItemIds']))"

# Pokédex shape (the invariants the search fix depends on)
python3 -c "
import json
rows=json.load(open('assets/data/pokemon.json'))
rows = rows if isinstance(rows,list) else list(rows.values())
ov=json.load(open('assets/data/forms_extra.json'))['pokemon']
merged=rows+ov
g={}
for p in merged: g.setdefault(p.get('nationalDexNumber') or p['id'],[]).append(p)
print('species:', len(g))
print('species with >1 form:', sum(1 for v in g.values() if len(v)>1))
print('species lacking an id==dex row:', sum(1 for v in g.values() if not any(p['id']==(p.get('nationalDexNumber') or p['id']) for p in v)))
"
```

---

## I. Standing notes

- **The three God Screens are a symptom, not a goal.** Splitting a file is worth doing
  only when it makes a specific change easier. C1 removed ~111 lines by *deleting*
  duplicated logic; that is better than moving it.
- **`Icons/` holds pre-staged platform icons.** `Icons/ios/` (22 files) and `Icons/web/`
  exist ahead of those platforms. `Icons/android/` holds the Play Store icon. **Do not
  delete it** — a docs commit already removed it once by accident (`0807265`, restored
  in `4d58f1f`). `android/app/src/main/res/mipmap-*` is what actually ships.
- **Two test files are misnamed, not junk.** `widget_test.dart` is a PokedexScreen +
  `FormFacts` + `CombatUtils` + `GenderRatio` + `SpriteQuality` suite, and
  `complete_improvement_plan_test.dart` covers move properties, ability tags and
  Pokémon classification. Both are real coverage behind plan-artifact names; rename
  them when next touching either file.
- **The Pokédex `stream → filter → rebuild` path is the app's performance centre of
  gravity.** Optimisations elsewhere are unlikely to be felt. There is no known
  performance problem — the app is smooth while typing.
- **`.metadata` and `.vscode/settings.json` are intentionally tracked.** Flutter
  documents `.metadata` as version-controlled; the VS Code setting affects Gradle
  build-configuration prompts.
- **Before distributing a build:** create `android/key.properties` and a keystore
  (git-ignored). Signing is configured in `build.gradle.kts` and reads that file;
  without it the build is unsigned.
- **`docs/reference.md` replaced eight separate guides** (data pipeline, migrations,
  Champions, Legends: Z-A, implementation guide, testing, release checklist, index) on
  2026-10-06. The superseded audit archive that used to be `docs/ARCHIVE.md` was removed
  at the same time; it remains recoverable from git history.
