import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/data/species_data.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/utils/damage_math.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/data/battle_data_manifest.dart';
import 'package:libredex/features/battle_engine/battle_engine.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/features/calculator/views/damage_summary_card.dart';
import 'package:libredex/features/calculator/widgets/item_ability_picker_dialog.dart';
import 'package:libredex/features/calculator/widgets/move_picker_dialog.dart';
import 'package:libredex/features/calculator/widgets/pokemon_picker_dialog.dart';

const Map<String, String> natureFormattedNames = {
  'hardy': 'HARDY (Neutral)',
  'lonely': 'LONELY (+Atk, -Def)',
  'brave': 'BRAVE (+Atk, -Speed)',
  'adamant': 'ADAMANT (+Atk, -Sp.Atk)',
  'naughty': 'NAUGHTY (+Atk, -Sp.Def)',
  'bold': 'BOLD (+Def, -Atk)',
  'docile': 'DOCILE (Neutral)',
  'relaxed': 'RELAXED (+Def, -Speed)',
  'impish': 'IMPISH (+Def, -Sp.Atk)',
  'lax': 'LAX (+Def, -Sp.Def)',
  'timid': 'TIMID (+Speed, -Atk)',
  'hasty': 'HASTY (+Speed, -Def)',
  'jolly': 'JOLLY (+Speed, -Sp.Atk)',
  'naive': 'NAIVE (+Speed, -Sp.Def)',
  'serious': 'SERIOUS (Neutral)',
  'modest': 'MODEST (+Sp.Atk, -Atk)',
  'mild': 'MILD (+Sp.Atk, -Def)',
  'quiet': 'QUIET (+Sp.Atk, -Speed)',
  'bashful': 'BASHFUL (Neutral)',
  'rash': 'RASH (+Sp.Atk, -Sp.Def)',
  'calm': 'CALM (+Sp.Def, -Atk)',
  'gentle': 'GENTLE (+Sp.Def, -Def)',
  'sassy': 'SASSY (+Sp.Def, -Speed)',
  'careful': 'CAREFUL (+Sp.Def, -Sp.Atk)',
  'quirky': 'QUIRKY (Neutral)',
};

/// Pokémon Champions has 21 Stat Alignments: the four flat fillers (Hardy,
/// Docile, Bashful, Quirky) are gone and Serious is the only neutral one.
final Map<String, String> championsAlignmentNames = {
  for (final entry in natureFormattedNames.entries)
    if (ChampionsRules.alignments.contains(entry.key)) entry.key: entry.value,
};

class DamageCalculatorScreen extends ConsumerStatefulWidget {
  const DamageCalculatorScreen({super.key});

  @override
  ConsumerState<DamageCalculatorScreen> createState() => _DamageCalculatorScreenState();
}

class _DamageCalculatorScreenState extends ConsumerState<DamageCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Move> _dbDamagingMoves = [];

  Move _simpleSelectedMove = const Move(id: 0, name: 'Custom Move', type: 'fire', pp: 15, damageClass: 'physical', power: 90, priority: 0, isContact: false, isHealing: false, isSound: false, isPunching: false, isBiting: false, isPowder: false, isPulse: false, isBallistic: false, isSlicing: false, isWind: false, isDance: false, isBite: false, isMultiHit: false, isProtective: false, isSwitching: false, isRecharge: false, isRecoil: false, isDraining: false, isStatusMove: false, isDamagingMove: true, isSignatureMove: false, isDLCMove: false, isChampionsMove: false, isLegendsZAMove: false, generation: 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDbMoves();
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumeLaunchIntent());
  }

  /// Team Builder (and future surfaces) can park a one-shot intent asking
  /// the calculator to open with a given ruleset / attacker. Applied once,
  /// after the notifier finished loading the persisted ruleset.
  Future<void> _consumeLaunchIntent() async {
    final intent = ref.read(calculatorLaunchIntentProvider.notifier).consume();
    if (intent == null) return;
    final vm = ref.read(damageCalculatorViewModelProvider.notifier);
    await vm.rulesetReady;
    if (!mounted) return;
    if (intent.ruleset != null) {
      await vm.setRuleset(intent.ruleset!);
    }
    final pokemonId = intent.attackerPokemonId;
    if (pokemonId == null) return;
    try {
      final db = ref.read(databaseProvider);
      final pokemon = await (db.select(db.pokemonTable)
            ..where((t) => t.id.equals(pokemonId)))
          .getSingleOrNull();
      if (pokemon == null) return;
      final abilities = await ref
          .read(pokemonRepositoryProvider)
          .getAbilitiesWithFallback(pokemon.id);
      vm.setAttacker(
        pokemon,
        defaultAbility: abilities.isNotEmpty ? abilities.first['name'] as String : null,
      );
    } catch (_) {
      // The intent is best-effort; a wiped table must never break the screen.
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDbMoves() async {
    try {
      final db = ref.read(databaseProvider);
      final allMoves = await db.select(db.moveTable).get();
      final damaging = allMoves
          .where((m) =>
              m.damageClass != 'status' &&
              ((m.power != null && m.power! > 0) || CombatUtils.supportsDynamicBasePower(m.name)))
          .toList();
      damaging.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() {
          _dbDamagingMoves = damaging;
          if (damaging.isNotEmpty) {
            if (!_dbDamagingMoves.any((m) => m.id == _simpleSelectedMove.id)) {
              _simpleSelectedMove = damaging.first;
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final state = ref.watch(damageCalculatorViewModelProvider);
    final vm = ref.read(damageCalculatorViewModelProvider.notifier);
    final pokedexAsync = ref.watch(pokedexProvider);

    // One-shot launch intents (Team Builder's "open in calculator") apply on
    // the frame after they are requested — watching keeps this alive even
    // while the section is parked inside HomeScreen's IndexedStack, so a
    // returning visit never misses the handoff.
    if (ref.watch(calculatorLaunchIntentProvider) != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _consumeLaunchIntent());
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Damage Calculator',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.pokemonRed,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          dividerColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'RAW SANDBOX', icon: Icon(Icons.tune_rounded, size: 20)),
            Tab(text: '1VS1 DUEL', icon: Icon(Icons.compare_arrows_rounded, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildRulesetBar(isDark, state, vm),
          Expanded(
            child: pokedexAsync.when(
        data: (pokemonList) {
          if (pokemonList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed));
          }

          if (state.attacker == null) {
            final defAttacker = pokemonList.firstWhere((p) => p.name.toLowerCase() == 'charizard', orElse: () => pokemonList.first);
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final abs = await ref.read(databaseProvider).getPokemonAbilities(defAttacker.id);
                vm.setAttacker(defAttacker, defaultAbility: abs.isNotEmpty ? abs.first.ability.name : null);
              } catch (_) {
                vm.setAttacker(defAttacker);
              }
            });
          }

          if (state.defender == null) {
            final defDefender = pokemonList.firstWhere((p) => p.name.toLowerCase() == 'blastoise', orElse: () => pokemonList.length > 1 ? pokemonList[1] : pokemonList.first);
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final abs = await ref.read(databaseProvider).getPokemonAbilities(defDefender.id);
                vm.setDefender(defDefender, defaultAbility: abs.isNotEmpty ? abs.first.ability.name : null);
              } catch (_) {
                vm.setDefender(defDefender);
              }
            });
          }

          final p1 = state.attacker ?? pokemonList.first;
          final p2 = state.defender ?? (pokemonList.length > 1 ? pokemonList[1] : pokemonList.first);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRawSandboxTab(context, isDark, primaryColor, state, vm),
              _buildDuelCalculatorTab(context, isDark, primaryColor, pokemonList, p1, p2, state, vm),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed)),
        error: (err, stack) => Center(child: Text('Error loading Pokémon data: $err')),
            ),
          ),
        ],
      ),
    );
  }

  /// Mainline / Pokémon Champions ruleset switcher pinned above both tabs.
  ///
  /// Champions is an additional mode: the mainline calculator keeps working
  /// exactly as before, and both setups survive the toggle. Persisted via
  /// SharedPreferences in the view model.
  Widget _buildRulesetBar(
    bool isDark,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
  ) {
    final isChampions = state.ruleset.isChampions;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isChampions
              ? Colors.deepPurpleAccent.withValues(alpha: 0.45)
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final ruleset in BattleRuleset.values) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => vm.setRuleset(ruleset),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: state.ruleset == ruleset
                            ? (ruleset.isChampions ? Colors.deepPurpleAccent : AppTheme.pokemonRed)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            ruleset.isChampions
                                ? Icons.emoji_events_rounded
                                : Icons.videogame_asset_rounded,
                            size: 14,
                            color: state.ruleset == ruleset ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ruleset.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                              color: state.ruleset == ruleset ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.verified_outlined, size: 18, color: Colors.blueAccent),
                tooltip: 'Engine Parity & Data Manifest',
                onPressed: () => _showManifestDialog(context),
              ),
            ],
          ),
          if (isChampions) ...[
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'Champions uses 66 Stat Points instead of EVs and its own fixed stat formula.',
                style: TextStyle(fontSize: 10.5, height: 1.35, color: Colors.grey, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showManifestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Battle Engine Manifest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in BattleDataManifest.details.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── 1. Pure Raw Move Power & Damage Sandbox (No Pokémon Required) ────────

  Widget _buildRawSandboxTab(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
  ) {
    final bool isSpecial = state.moveCategory.toLowerCase() == 'special';
    final double bp = state.movePower;
    final moveType = state.moveType.toLowerCase();

    // Integer-parity sandbox — same fixed-point path as the Duel tab & Showdown.
    final int sandboxLevel = state.ruleset.isChampions ? ChampionsRules.level : state.attackerLevel;

    // Stages are ignored correctly on crit (negative Atk / positive Def don't apply).
    final double atkRaw = state.simpleAttackerStat;
    final int atkStage = state.attackerStages['atk'] ?? 0;
    final int effectiveAtkStage = state.isCriticalHit ? (atkStage < 0 ? 0 : atkStage) : atkStage;
    final double atkWithStage = (atkRaw * CombatUtils.getStageMultiplier(effectiveAtkStage)).clamp(1.0, 9999.0);
    final double defRaw = state.simpleDefenderStat;
    final int defStage = state.defenderStages['def'] ?? 0;
    final int effectiveDefStage = state.isCriticalHit ? (defStage > 0 ? 0 : defStage) : defStage;
    final double defWithStage = (defRaw * CombatUtils.getStageMultiplier(effectiveDefStage)).clamp(1.0, 9999.0);

    final double atkItemMult = HeldItemsData.getAttackMultiplier(state.attackerHeldItem, moveType, isSpecial);
    final double defStatItemMult = HeldItemsData.getDefenseMultiplier(state.defenderHeldItem, isSpecial);
    final double defResistMult = HeldItemsData.getDefenderResistMultiplier(state.defenderHeldItem, moveType, state.simpleEffectiveness);
    final int atkFinal = (atkWithStage * atkItemMult).round().clamp(1, 9999);
    final int defFinal = (defWithStage * defStatItemMult).round().clamp(1, 9999);

    double weatherMult = 1.0;
    if (state.weather == 'sunny' && moveType == 'fire') weatherMult = 1.5;
    if (state.weather == 'sunny' && moveType == 'water') weatherMult = 0.5;
    if (state.weather == 'rainy' && moveType == 'water') weatherMult = 1.5;
    if (state.weather == 'rainy' && moveType == 'fire') weatherMult = 0.5;

    double terrainMult = 1.0;
    if (state.terrain == 'electric' && moveType == 'electric') terrainMult = 1.3;
    if (state.terrain == 'grassy' && moveType == 'grass') terrainMult = 1.3;
    if (state.terrain == 'psychic' && moveType == 'psychic') terrainMult = 1.3;
    double hhMult = state.helpingHandActive ? 1.5 : 1.0;
    final double typeAbilityBpMult = CombatUtils.typeChangingAbilityPowerMultiplier(state.attackerAbility, state.moveType);
    final int finalBasePower = (bp * terrainMult * hhMult * typeAbilityBpMult).round().clamp(1, 9999);

    // Screens: 0.5 singles, 2732/4096 doubles; Champions supports both formats like mainline.
    double screenMult = 1.0;
    if (!state.isCriticalHit) {
      final double doublesScreen = 2732 / 4096;
      final bool isDoubles = state.isDoubleBattle;
      if (isSpecial && state.lightScreenActive) screenMult = isDoubles ? doublesScreen : 0.5;
      if (!isSpecial && state.reflectActive) screenMult = isDoubles ? doublesScreen : 0.5;
    }
    final bool burned = !isSpecial && state.attackerStatus == 'burn' && state.attackerAbility?.toLowerCase() != 'guts' && state.selectedMoveName?.toLowerCase() != 'facade';
    final double spreadMult = CombatUtils.spreadMultiplier(state.selectedMoveName ?? 'custom move', state.isDoubleBattle);
    final List<double> sandboxFinalMods = [
      if (screenMult != 1.0) screenMult,
      if (defResistMult != 1.0) defResistMult,
      if (spreadMult != 1.0) spreadMult,
    ];
    final DamageRange sandboxRange = DamageMath.calculate(
      level: sandboxLevel,
      basePower: finalBasePower,
      attack: atkFinal,
      defense: defFinal,
      stab: state.simpleStab,
      effectiveness: state.simpleEffectiveness,
      critical: state.isCriticalHit,
      weather: weatherMult,
      burned: burned,
      finalModifiers: sandboxFinalMods,
    );
    final int rawMinDamage = sandboxRange.min;
    final int rawMaxDamage = sandboxRange.max;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.topContentGap, AppSpacing.pagePadding, AppSpacing.bottomScrollPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.pokemonRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.tune_rounded, color: AppTheme.pokemonRed, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PURE RAW MOVE SANDBOX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.pokemonRed)),
                      Text('Calculate raw move output with full items, stats, STAB, effectiveness & conditions.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Move Parameters Card
          _buildDropdownHeader('MOVE PARAMETERS'),
          _buildCardWrapper(
            isDark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Base Power (BP): ${state.movePower.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search, size: 14),
                      label: const Text('Pick Preset Move', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppTheme.pokemonRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      onPressed: () => _showMovePicker(context, vm),
                    ),
                  ],
                ),
                Slider(
                  value: state.movePower.clamp(1.0, 250.0),
                  min: 1, max: 250, divisions: 249,
                  activeColor: AppTheme.pokemonRed,
                  onChanged: (val) => vm.updateMovePower(val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MOVE TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: CombatUtils.allTypes.contains(state.moveType.toLowerCase()) ? state.moveType.toLowerCase() : CombatUtils.allTypes.first,
                                isExpanded: true,
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                                items: CombatUtils.allTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                                onChanged: (t) { if (t != null) vm.updateMoveType(t); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.moveCategory.toLowerCase(),
                                isExpanded: true,
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                                items: const [
                                  DropdownMenuItem(value: 'physical', child: Text('PHYSICAL ⚔️')),
                                  DropdownMenuItem(value: 'special', child: Text('SPECIAL')),
                                ],
                                onChanged: (c) { if (c != null) vm.updateMoveCategory(c); },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Raw Stats & Stage Boosts
          _buildDropdownHeader('ATTACKER & DEFENDER STATS'),
          _buildCardWrapper(
            isDark,
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Attacker Stat: ${state.simpleAttackerStat.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Slider(
                            value: state.simpleAttackerStat.clamp(10.0, 500.0), min: 10, max: 500, divisions: 98,
                            activeColor: AppTheme.pokemonRed,
                            onChanged: (v) => vm.setSimpleAttackerStat(v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Defender Stat: ${state.simpleDefenderStat.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          Slider(
                            value: state.simpleDefenderStat.clamp(10.0, 500.0), min: 10, max: 500, divisions: 98,
                            activeColor: AppTheme.pokemonRed,
                            onChanged: (v) => vm.setSimpleDefenderStat(v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ATTACKER ITEM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                          GestureDetector(
                            onTap: () => _showItemPicker(context, true, vm),
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                              child: Text(state.attackerHeldItem, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DEFENDER ITEM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
                          GestureDetector(
                            onTap: () => _showItemPicker(context, false, vm),
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                              child: Text(state.defenderHeldItem, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Multipliers & Flags
          _buildDropdownHeader('STAB & TYPE EFFECTIVENESS'),
          _buildCardWrapper(
            isDark,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STAB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: state.simpleStab,
                            isExpanded: true,
                            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                            items: const [
                              DropdownMenuItem(value: 1.0, child: Text('No STAB (1.0x)')),
                              DropdownMenuItem(value: 1.5, child: Text('Standard STAB (1.5x)')),
                              DropdownMenuItem(value: 2.0, child: Text('Adaptability / Tera (2.0x)')),
                            ],
                            onChanged: (v) { if (v != null) vm.setSimpleStab(v); },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EFFECTIVENESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: state.simpleEffectiveness,
                            isExpanded: true,
                            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                            items: const [
                              DropdownMenuItem(value: 0.0, child: Text('Immune (0.0x)')),
                              DropdownMenuItem(value: 0.25, child: Text('0.25x (Double Resist)')),
                              DropdownMenuItem(value: 0.5, child: Text('0.5x (Resisted)')),
                              DropdownMenuItem(value: 1.0, child: Text('1.0x (Neutral)')),
                              DropdownMenuItem(value: 2.0, child: Text('2.0x (Super Effective)')),
                              DropdownMenuItem(value: 4.0, child: Text('4.0x (4x Super)')),
                            ],
                            onChanged: (v) { if (v != null) vm.setSimpleEffectiveness(v); },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Result Sandbox Display
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text('CALCULATED RAW DAMAGE RANGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    '${rawMinDamage.toStringAsFixed(0)} – ${rawMaxDamage.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('TARGET HP BENCHMARK PERCENTAGES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _hpBenchmark('100 HP Target', rawMinDamage, rawMaxDamage, 100),
                      _hpBenchmark('200 HP Target', rawMinDamage, rawMaxDamage, 200),
                      _hpBenchmark('300 HP Target', rawMinDamage, rawMaxDamage, 300),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6, runSpacing: 4, alignment: WrapAlignment.center,
                    children: [
                      if (state.simpleStab > 1.0) _modChip('STAB ×${state.simpleStab}', Colors.amber),
                      if (state.simpleEffectiveness != 1.0) _modChip('Eff ×${state.simpleEffectiveness}', state.simpleEffectiveness > 1.0 ? Colors.green : Colors.red),
                      if (state.attackerHeldItem != 'None') _modChip(state.attackerHeldItem, Colors.purple),
                      if (state.defenderHeldItem != 'None') _modChip('Def Item: ${state.defenderHeldItem}', Colors.blue),
                      if (state.isCriticalHit) _modChip('CRITICAL HIT ×1.5', Colors.redAccent),
                      if (spreadMult != 1.0) _modChip('Spread ×0.75', Colors.indigo),
                      if (state.isDoubleBattle) _modChip('Doubles', Colors.cyan),
                      if (state.weather != 'none') _modChip('☁ ${state.weather}', Colors.teal),
                      if (state.helpingHandActive) _modChip('Helping Hand ×1.5', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hpBenchmark(String label, double minDmg, double maxDmg, double hp) {
    final minP = (minDmg / hp * 100).toStringAsFixed(1);
    final maxP = (maxDmg / hp * 100).toStringAsFixed(1);
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text('$minP% – $maxP%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed)),
      ],
    );
  }

  // ── 2. 1vs1 Duel Tab Implementation ───────────────────────────────────────

  Widget _buildDuelCalculatorTab(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    List<Pokemon> pokemonList,
    Pokemon p1,
    Pokemon p2,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
  ) {
    if (_dbDamagingMoves.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed));
    }

    final bool isChampions = state.ruleset.isChampions;
    final int battleLevel = isChampions ? ChampionsRules.level : state.attackerLevel;

    /// One funnel for final stat math. Mainline keeps the classic IV/EV
    /// formulas; Champions swaps in the Lv. 50 / 31 IV / Stat Point system
    /// (Stat Alignment = nature) — the rest of the engine is ruleset-agnostic.
    int sideStat({
      required bool attacker,
      required String key,
      required int base,
      required String natureLabel,
    }) {
      final nature = attacker ? state.attackerNature : state.defenderNature;
      final natureMod = CombatUtils.getNatureMultiplier(nature, natureLabel);
      if (isChampions) {
        final sp = (attacker ? state.attackerSps : state.defenderSps)[key] ?? 0;
        return StatCalculator.calculateChampionsStat(base: base, sp: sp, alignmentModifier: natureMod);
      }
      final iv = (attacker ? state.attackerIvs : state.defenderIvs)[key] ?? 31;
      final ev = (attacker ? state.attackerEvs : state.defenderEvs)[key] ?? 0;
      final level = attacker ? state.attackerLevel : state.defenderLevel;
      return StatCalculator.calculateOtherStat(base: base, iv: iv, ev: ev, level: level, natureModifier: natureMod);
    }

    final p1Moves = _dbDamagingMoves;
    Move activeMove;
    if (state.selectedMoveName != null) {
      activeMove = p1Moves.firstWhere(
        (m) => m.name.toLowerCase() == state.selectedMoveName!.toLowerCase(),
        orElse: () => p1Moves.first,
      );
    } else {
      activeMove = p1Moves.first;
    }
    // Guaranteed-crit moves override the UI toggle just like Showdown.
    final bool isCritical = state.isCriticalHit || CombatUtils.alwaysCriticalHit(activeMove.name);

    final isSlowStartActive = state.attackerAbility?.toLowerCase() == 'slow start' &&
        state.attackerTurnsOnField < 5;

    // Speed calculation with Paralysis check
    final int rawAttackerSpeed = sideStat(
      attacker: true, key: 'spe', base: p1.baseSpd, natureLabel: 'Speed',
    );
    double atkSpdMult = CombatUtils.getStageMultiplier(state.attackerStages['spe'] ?? 0);
    if (state.attackerStatus == 'paralysis' && state.attackerAbility != 'quick feet') atkSpdMult *= 0.5;
    if (state.attackerStatus != 'none' && state.attackerAbility == 'quick feet') atkSpdMult *= 1.5;
    if (isSlowStartActive) atkSpdMult *= 0.5;
    final int attackerSpeed = (rawAttackerSpeed * atkSpdMult).toInt();

    final int rawDefenderSpeed = sideStat(
      attacker: false, key: 'spe', base: p2.baseSpd, natureLabel: 'Speed',
    );
    double defSpdMult = CombatUtils.getStageMultiplier(state.defenderStages['spe'] ?? 0);
    if (state.defenderStatus == 'paralysis' && state.defenderAbility != 'quick feet') defSpdMult *= 0.5;
    if (state.defenderStatus != 'none' && state.defenderAbility == 'quick feet') defSpdMult *= 1.5;
    final int defenderSpeed = (rawDefenderSpeed * defSpdMult).toInt();

    // Dynamic Move Power: gimmick moves (weight, speed, status, item, HP%,
    // weather/terrain, ...) resolve from the live battle context instead of
    // their — often missing — database power. Runs after the speed block so
    // Gyro Ball / Electro Ball can use the final, paralysis-adjusted stats.
    final speciesDataset = ref.watch(speciesDatasetProvider).asData?.value;
    final double attackerWeightKg = speciesDataset
            ?.formFacts(p1.id, nationalDexNumber: p1.nationalDexNumber)
            ?.weightKg ??
        0.0;
    final double defenderWeightKg = speciesDataset
            ?.formFacts(p2.id, nationalDexNumber: p2.nationalDexNumber)
            ?.weightKg ??
        0.0;
    final double rawBp = activeMove.power?.toDouble() ?? 50.0;
    final dynamicBp = CombatUtils.resolveDynamicBasePower(
      moveName: activeMove.name,
      basePower: rawBp,
      friendship: state.attackerFriendship,
      attackerHpPercent: state.attackerHpPercent,
      defenderHpPercent: state.defenderHpPercent,
      attackerStatus: state.attackerStatus,
      defenderStatus: state.defenderStatus,
      attackerHeldItem: state.attackerHeldItem,
      defenderHeldItem: state.defenderHeldItem,
      rageFistHits: state.rageFistHits,
      attackerWeightKg: attackerWeightKg,
      defenderWeightKg: defenderWeightKg,
      attackerSpeedStat: attackerSpeed.toDouble(),
      defenderSpeedStat: defenderSpeed.toDouble(),
      weather: state.weather,
      terrain: state.terrain,
      championsRules: isChampions,
    );
    final double basePowerVal = dynamicBp.basePower;
    final String? dynamicBpNote = dynamicBp.note;

    // Weather Ball / Terrain Pulse transform into the matching type.
    final String effectiveMoveType = CombatUtils.effectiveMoveType(
      moveName: activeMove.name,
      moveType: activeMove.type,
      weather: state.weather,
      terrain: state.terrain,
      attackerAbility: state.attackerAbility,
    );

    final isSpecial = activeMove.damageClass.toLowerCase() == 'special';
    final bool isBodyPress = activeMove.name.toLowerCase() == 'body press';
    final bool isFoulPlay = activeMove.name.toLowerCase() == 'foul play';

    final int attackerAtk;
    final double atkItemMult;

    if (isFoulPlay) {
      // Foul Play uses defender's attack stat
      final int rawDefAtk = sideStat(
        attacker: false, key: 'atk', base: p2.baseAtk, natureLabel: 'Attack',
      );
      final int defAtkStage = state.defenderStages['atk'] ?? 0;
      final int effDefAtkStage = isCritical ? (defAtkStage < 0 ? 0 : defAtkStage) : defAtkStage;
      attackerAtk = (rawDefAtk * CombatUtils.getStageMultiplier(effDefAtkStage)).toInt();
      atkItemMult = HeldItemsData.getAttackMultiplier(state.attackerHeldItem, effectiveMoveType, false);
    } else if (isBodyPress) {
      final int rawAttackerDef = sideStat(
        attacker: true, key: 'def', base: p1.baseDef, natureLabel: 'Defense',
      );
      final int atkDefStage = state.attackerStages['def'] ?? 0;
      final int effAtkDefStage = isCritical ? (atkDefStage < 0 ? 0 : atkDefStage) : atkDefStage;
      final int attackerDef = (rawAttackerDef * CombatUtils.getStageMultiplier(effAtkDefStage)).toInt();
      final double defItemMult = HeldItemsData.getDefenseMultiplier(state.attackerHeldItem, false);
      attackerAtk = (attackerDef * defItemMult).toInt();
      final attackerItem = HeldItemsData.findByName(state.attackerHeldItem);
      atkItemMult = attackerItem?.universalDamageMultiplier ?? 1.0;
    } else {
      final int rawAttackerAtk = sideStat(
        attacker: true,
        key: isSpecial ? 'spa' : 'atk',
        base: isSpecial ? p1.baseSpAtk : p1.baseAtk,
        natureLabel: isSpecial ? 'Sp. Atk' : 'Attack',
      );
      final int stageVal = isSpecial ? (state.attackerStages['spa'] ?? 0) : (state.attackerStages['atk'] ?? 0);
      final int effStageVal = isCritical ? (stageVal < 0 ? 0 : stageVal) : stageVal;
      double gutsMult = 1.0;
      if (!isSpecial && state.attackerStatus != 'none' && state.attackerAbility == 'guts') gutsMult = 1.5;
      final slowStartMult = !isSpecial && isSlowStartActive ? 0.5 : 1.0;
      attackerAtk = (rawAttackerAtk * CombatUtils.getStageMultiplier(effStageVal) * gutsMult * slowStartMult).toInt();
      atkItemMult = HeldItemsData.getAttackMultiplier(state.attackerHeldItem, effectiveMoveType, isSpecial);
    }

    final int rawDefenderDef = sideStat(
      attacker: false,
      key: isSpecial ? 'spd' : 'def',
      base: isSpecial ? p2.baseSpDef : p2.baseDef,
      natureLabel: isSpecial ? 'Sp. Def' : 'Defense',
    );
    final int defStageVal = isSpecial ? (state.defenderStages['spd'] ?? 0) : (state.defenderStages['def'] ?? 0);
    final int effDefStageVal = isCritical ? (defStageVal > 0 ? 0 : defStageVal) : defStageVal;
    final int defenderDef = (rawDefenderDef * CombatUtils.getStageMultiplier(effDefStageVal)).toInt();

    final int defenderMaxHp = isChampions
        ? StatCalculator.calculateChampionsHp(
            base: p2.baseHp,
            sp: state.defenderSps['hp'] ?? 0,
            isShedinja: p2.name.toLowerCase() == 'shedinja',
          )
        : StatCalculator.calculateHp(
            base: p2.baseHp,
            iv: state.defenderIvs['hp'] ?? 31,
            ev: state.defenderEvs['hp'] ?? 252,
            level: state.defenderLevel,
          );

    double weatherMult = 1.0;
    if (state.weather == 'sunny' && effectiveMoveType == 'fire') weatherMult = 1.5;
    if (state.weather == 'sunny' && effectiveMoveType == 'water') weatherMult = 0.5;
    if (state.weather == 'rainy' && effectiveMoveType == 'water') weatherMult = 1.5;
    if (state.weather == 'rainy' && effectiveMoveType == 'fire') weatherMult = 0.5;

    // Gen 9 Terastallization STAB multiplier
    double stabMult = 1.0;
    final moveTypeLower = effectiveMoveType;
    if (!state.ruleset.isChampions && state.attackerTeraActive && state.attackerTeraType != null) {
      final teraTypeLower = state.attackerTeraType!.toLowerCase();
      final isOriginalStab = p1.type1.toLowerCase() == moveTypeLower || p1.type2?.toLowerCase() == moveTypeLower;
      if (teraTypeLower == moveTypeLower) {
        stabMult = isOriginalStab ? 2.0 : 1.5;
      } else if (isOriginalStab) {
        stabMult = 1.5;
      }
    } else {
      if (p1.type1.toLowerCase() == moveTypeLower || p1.type2?.toLowerCase() == moveTypeLower) {
        stabMult = 1.5;
      }
    }

    double effectivenessMult = CombatUtils.getTypeEffectiveness(
      effectiveMoveType,
      p2.type1,
      p2.type2,
      attackerAbility: state.attackerAbility,
      defenderAbility: state.defenderAbility,
      moveName: activeMove.name,
      defenderTeraActive: !state.ruleset.isChampions && state.defenderTeraActive,
      defenderTeraType: state.defenderTeraType,
    );

    double screenMult = 1.0;
    if (!isCritical) {
      final double doublesScreen = 2732 / 4096;
      final bool isDoubles = state.isDoubleBattle;
      if (isSpecial && state.lightScreenActive) screenMult = isDoubles ? doublesScreen : 0.5;
      if (!isSpecial && state.reflectActive) screenMult = isDoubles ? doublesScreen : 0.5;
    }

    double terrainMult = 1.0;
    if (state.terrain == 'electric' && effectiveMoveType == 'electric') terrainMult = 1.3;
    if (state.terrain == 'grassy' && effectiveMoveType == 'grass') terrainMult = 1.3;
    if (state.terrain == 'psychic' && effectiveMoveType == 'psychic') terrainMult = 1.3;

    final double hhMult = state.helpingHandActive ? 1.5 : 1.0;
    // -ate / Normalize's Gen IX 1.2× power bonus is a base-power modifier.
    final double typeAbilityBpMult = CombatUtils.typeChangingAbilityPowerMultiplier(
      state.attackerAbility,
      activeMove.type,
    );

    // Burn physical reduction (0.5x)
    double burnMult = 1.0;
    if (!isSpecial && state.attackerStatus == 'burn' && state.attackerAbility != 'guts' && activeMove.name.toLowerCase() != 'facade') {
      burnMult = 0.5;
    }

    final double defResistMult = HeldItemsData.getDefenderResistMultiplier(state.defenderHeldItem, effectiveMoveType, effectivenessMult);
    final double defStatItemMult = HeldItemsData.getDefenseMultiplier(state.defenderHeldItem, isSpecial);

    final int finalAttackerSpeed = (attackerSpeed * HeldItemsData.getSpeedMultiplier(state.attackerHeldItem)).toInt();
    final int finalDefenderSpeed = (defenderSpeed * HeldItemsData.getSpeedMultiplier(state.defenderHeldItem)).toInt();
    bool p1Outspeeds = state.trickRoomActive ? finalAttackerSpeed < finalDefenderSpeed : finalAttackerSpeed > finalDefenderSpeed;
    if (finalAttackerSpeed == finalDefenderSpeed) p1Outspeeds = true;

    final int defenderDefFinal = (defenderDef * defStatItemMult).toInt().clamp(1, 9999);
    final int atkWithItem = (attackerAtk * atkItemMult).toInt().clamp(1, 9999);
    // Keep the game's rounding boundaries. This replaces the former single
    // floating-point expression, whose intermediate rounding differed from
    // Pokémon Showdown by several points in common match-ups.
    // Apply base-power modifiers to every strike. Triple Axel's later hits
    // are 40/60 BP before Helping Hand and similar modifiers, not copies of
    // the first hit's final power.
    final bpModifier = terrainMult * hhMult * typeAbilityBpMult;
    final hitBasePowers = CombatUtils.guaranteedHitBasePowers(
      activeMove.name,
      basePowerVal.round(),
    ).map((bp) => (bp * bpModifier).round()).toList();
    final hasParentalBond = state.attackerAbility?.toLowerCase() == 'parental bond' &&
        hitBasePowers.length == 1;
    final breaksProtection = CombatUtils.breaksProtect(activeMove.name);
    final unseenFistProtectionHit = CombatUtils.isUnseenFistProtectionHit(
      activeMove.name,
      state.attackerAbility,
    );
    final blockedByProtect = state.defenderProtected && !breaksProtection && !unseenFistProtectionHit;
    final double spreadMult = CombatUtils.spreadMultiplier(activeMove.name, state.isDoubleBattle);
    final finalDamageModifiers = <double>[
      if (screenMult != 1.0) screenMult,
      if (defResistMult != 1.0) defResistMult,
      if (spreadMult != 1.0) spreadMult,
      if (state.defenderProtected && unseenFistProtectionHit) 0.25,
    ];
    final multiHitDamage = DamageMath.calculateMultiHit(
      basePowers: hitBasePowers,
      level: battleLevel,
      attack: atkWithItem,
      defense: defenderDefFinal,
      weather: weatherMult,
      critical: isCritical,
      stab: stabMult,
      effectiveness: blockedByProtect ? 0.0 : effectivenessMult,
      burned: burnMult != 1.0,
      finalModifiers: finalDamageModifiers,
      parentalBond: hasParentalBond,
    );
    final damageRange = multiHitDamage.total;
    final int finalMinDamage = damageRange.min;
    final int finalMaxDamage = damageRange.max;
    final double minPercent = (finalMinDamage / defenderMaxHp) * 100;
    final double maxPercent = (finalMaxDamage / defenderMaxHp) * 100;

    Widget buildPokemonDuelCard(Pokemon p, bool isAttacker, String heldItem) {
      final typeColor = CombatUtils.typeColors[p.type1.toLowerCase()] ?? Colors.grey;
      final spd = isAttacker ? finalAttackerSpeed : finalDefenderSpeed;
      final isTera = !state.ruleset.isChampions && (isAttacker ? state.attackerTeraActive : state.defenderTeraActive);
      final teraT = isAttacker ? state.attackerTeraType : state.defenderTeraType;
      final status = isAttacker ? state.attackerStatus : state.defenderStatus;

      return GestureDetector(
        onTap: () => _showSetupEditorSheet(context, isAttacker, state, vm, p, pokemonList),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isTera ? Colors.purpleAccent : typeColor.withValues(alpha: 0.4), width: isTera ? 2.0 : 1.5),
            boxShadow: [BoxShadow(color: typeColor.withValues(alpha: 0.08), blurRadius: 12, spreadRadius: 2)],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: p.spriteUrl.isNotEmpty
                    ? PokemonSprite(
                        imageUrl: p.spriteUrl,
                        fallbackUrl: PokemonSprite.homeArtworkUrl(p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id),
                        loadingIndicatorSize: 24,
                        loadingColor: AppTheme.pokemonRed,
                        errorIconSize: 48,
                        errorIconColor: typeColor.withValues(alpha: 0.4),
                      )
                    : Icon(Icons.catching_pokemon, size: 48, color: typeColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 6),
              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _typeChip(p.type1),
                if (p.type2 != null) ...[ const SizedBox(width: 4), _typeChip(p.type2!) ],
              ]),
              if (isTera && teraT != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('TERA ${teraT.toUpperCase()}', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.purpleAccent)),
                ),
              ],
              if (status != 'none') ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('STATUS: ${status.toUpperCase()}', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ),
              ],
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('⚡ SPD $spd', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              const SizedBox(height: 6),
              const Text('Tap to Edit Setup', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.pokemonRed)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.topContentGap, AppSpacing.pagePadding, AppSpacing.bottomScrollPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [
                const Text('ATTACKER', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 6),
                buildPokemonDuelCard(p1, true, state.attackerHeldItem),
              ])),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Tooltip(
                  message: 'Swap Attacker and Defender',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        vm.swapAttackerAndDefender();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.4)),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz_rounded, size: 20, color: Colors.orangeAccent),
                            Text('VS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orangeAccent)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: Column(children: [
                const Text('DEFENDER', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 6),
                buildPokemonDuelCard(p2, false, state.defenderHeldItem),
              ])),
            ],
          ),
          const SizedBox(height: 12),

          // Speed Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: p1Outspeeds ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p1Outspeeds ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(p1Outspeeds ? Icons.bolt : Icons.directions_run, color: p1Outspeeds ? Colors.greenAccent : Colors.redAccent, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(
                p1Outspeeds
                    ? '${p1.name} ($finalAttackerSpeed) outspeeds ${p2.name} ($finalDefenderSpeed)'
                    : '${p2.name} ($finalDefenderSpeed) outspeeds ${p1.name} ($finalAttackerSpeed)',
                style: TextStyle(fontWeight: FontWeight.bold, color: p1Outspeeds ? Colors.greenAccent : Colors.redAccent, fontSize: 11),
                textAlign: TextAlign.center,
              )),
            ]),
          ),
          const SizedBox(height: 12),

          // Attacker Move Selector
          _buildDropdownHeader('ATTACKER MOVE (TAP TO SEARCH ALL MOVES)'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showMovePicker(context, vm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: state.selectedMoveName != null ? AppTheme.pokemonRed.withValues(alpha: 0.5) : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)), width: 1.2),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (CombatUtils.typeColors[effectiveMoveType] ?? Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(effectiveMoveType.toUpperCase(), style: TextStyle(color: CombatUtils.typeColors[effectiveMoveType] ?? Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  state.selectedMoveName ?? activeMove.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                )),
                Text('BP: ${basePowerVal.toInt()}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(width: 4),
                const Icon(Icons.search, color: AppTheme.pokemonRed, size: 18),
              ]),
            ),
          ),

          // Explains which gimmick rule produced the resolved base power.
          if (dynamicBpNote != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_fix_high_rounded, size: 14, color: Colors.tealAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dynamicBpNote,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.tealAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Variable Multi-Hit Strike Count Selector (Rock Blast, Bullet Seed, Icicle Spear, Scale Shot, etc.)
          if (CombatUtils.isVariableMultiHitMove(activeMove.name)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.pokemonRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Multi-Hit Strikes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.pokemonRed)),
                    Text('${state.moveHits} strikes (${(basePowerVal.toInt() * state.moveHits)} total BP)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ]),
                  Row(
                    children: [2, 3, 4, 5].map((h) {
                      final isSelected = state.moveHits == h;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: ChoiceChip(
                          label: Text('$h'),
                          selected: isSelected,
                          onSelected: (_) => vm.updateMoveHits(h),
                          visualDensity: VisualDensity.compact,
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black87),
                          ),
                          selectedColor: AppTheme.pokemonRed,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Dynamic Move Steppers (Rage Fist / Return / Eruption)
          if (activeMove.name.toLowerCase() == 'rage fist' && !isChampions) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple.withValues(alpha: 0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Rage Fist Hits Taken', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purpleAccent)),
                    Text('+50 BP per hit taken (${basePowerVal.toInt()} BP)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ]),
                  Row(children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.purpleAccent, size: 20), onPressed: state.rageFistHits > 0 ? () => vm.setRageFistHits(state.rageFistHits - 1) : null),
                    Text('${state.rageFistHits}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.purpleAccent, size: 20), onPressed: state.rageFistHits < 6 ? () => vm.setRageFistHits(state.rageFistHits + 1) : null),
                  ]),
                ],
              ),
            ),
          ] else if (state.attackerAbility?.toLowerCase() == 'slow start') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Slow Start: ${isSlowStartActive ? 'ACTIVE — Attack & Speed halved' : 'ENDED — normal Attack & Speed'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orangeAccent)),
                Slider(
                  value: state.attackerTurnsOnField.toDouble(), min: 0, max: 5, divisions: 5,
                  label: '${state.attackerTurnsOnField} completed turns',
                  activeColor: Colors.orangeAccent,
                  onChanged: (v) => vm.setAttackerTurnsOnField(v.round()),
                ),
                Text('${state.attackerTurnsOnField}/5 completed turns on field', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ]),
            ),
          ] else if (activeMove.name.toLowerCase() == 'return' || activeMove.name.toLowerCase() == 'frustration') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.pink.withValues(alpha: 0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Friendship: ${state.attackerFriendship}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.pinkAccent)),
                  Text('Base Power: ${basePowerVal.toInt()} BP', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                ]),
                Slider(
                  value: state.attackerFriendship.toDouble(), min: 0, max: 255, divisions: 255, activeColor: Colors.pinkAccent,
                  onChanged: (v) => vm.setAttackerFriendship(v.toInt()),
                ),
              ]),
            ),
          ] else if (activeMove.name.toLowerCase() == 'eruption' || activeMove.name.toLowerCase() == 'water spout') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.deepOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Attacker HP: ${state.attackerHpPercent.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepOrangeAccent)),
                  Text('Base Power: ${basePowerVal.toInt()} BP', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                ]),
                Slider(
                  value: state.attackerHpPercent.clamp(1.0, 100.0), min: 1, max: 100, divisions: 99, activeColor: Colors.deepOrangeAccent,
                  onChanged: (v) => vm.setAttackerHpPercent(v),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 16),

          // Engine-Powered Damage Summary Card
          if (state.calculateDamage() != null) ...[
            DamageSummaryCard(
              result: state.calculateDamage()!,
              moveName: activeMove.name,
            ),
            const SizedBox(height: 16),
          ],

          // Legacy Quick Reference Range Card
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: [
                const Text('CALCULATED DAMAGE RANGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Text(
                  '${finalMinDamage.toStringAsFixed(0)} – ${finalMaxDamage.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed),
                ),
                const SizedBox(height: 6),
                Text(
                  '${minPercent.toStringAsFixed(1)}% – ${maxPercent.toStringAsFixed(1)}% of ${p2.name}\'s HP',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orangeAccent),
                ),
                if (multiHitDamage.perHit.length > 1) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasParentalBond
                              ? 'PARENTAL BOND — TOTAL INCLUDES BABY HIT'
                              : 'MULTI-HIT BREAKDOWN — TOTAL ABOVE',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 5),
                        for (var i = 0; i < multiHitDamage.perHit.length; i++)
                          Text(
                            '${hasParentalBond && i == 1 ? 'Baby hit (25%)' : 'Hit ${i + 1}${activeMove.name.toLowerCase() == 'triple axel' ? ' (${hitBasePowers[i]} BP)' : ''}'}: '
                            '${multiHitDamage.perHit[i].min} – ${multiHitDamage.perHit[i].max}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Contextual ability badge
                if (CombatUtils.getAbilityContextBadge(
                  moveType: effectiveMoveType,
                  t1: p2.type1,
                  t2: p2.type2,
                  attackerAbility: state.attackerAbility,
                  defenderAbility: state.defenderAbility,
                  moveName: activeMove.name,
                  defenderTeraActive: state.defenderTeraActive,
                  defenderTeraType: state.defenderTeraType,
                ) != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.pokemonRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      CombatUtils.getAbilityContextBadge(
                        moveType: effectiveMoveType,
                        t1: p2.type1,
                        t2: p2.type2,
                        attackerAbility: state.attackerAbility,
                        defenderAbility: state.defenderAbility,
                        moveName: activeMove.name,
                        defenderTeraActive: state.defenderTeraActive,
                        defenderTeraType: state.defenderTeraType,
                      )!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.pokemonRed),
                    ),
                  ),
                ],

                // Berry reduction badge
                if (defResistMult < 1.0) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '🫐 ${state.defenderHeldItem}: Halved Damage (0.5x)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueAccent),
                    ),
                  ),
                ],

                Wrap(spacing: 6, runSpacing: 4, alignment: WrapAlignment.center, children: [
                  if (stabMult > 1.0) _modChip('STAB ×${stabMult.toStringAsFixed(1)}', Colors.amber),
                  if (effectivenessMult > 1.0) _modChip('Super Effective ×${effectivenessMult.toStringAsFixed(1)}', Colors.green),
                  if (effectivenessMult < 1.0 && effectivenessMult > 0.0) _modChip('Not Effective ×${effectivenessMult.toStringAsFixed(2)}', Colors.red),
                  if (effectivenessMult == 0.0) _modChip('IMMUNE ×0.0', Colors.grey),
                  if (state.attackerHeldItem != 'None') _modChip(state.attackerHeldItem, Colors.purple),
                  if (state.defenderHeldItem != 'None') _modChip('Def: ${state.defenderHeldItem}', Colors.blueAccent),
                  if (isCritical) _modChip('CRITICAL HIT ×1.5', Colors.redAccent),
                  if (blockedByProtect) _modChip('PROTECT — BLOCKED', Colors.grey),
                  if (state.defenderProtected && unseenFistProtectionHit) _modChip('Unseen Fist through Protect (¼)', Colors.blueAccent),
                  if (state.defenderProtected && breaksProtection) _modChip('Breaks Protect', Colors.green),
                  if (spreadMult != 1.0) _modChip('Spread Move ×0.75', Colors.indigo),
                  if (state.isDoubleBattle) _modChip('Doubles', Colors.cyan),
                  if (state.attackerStatus == 'burn' && !isSpecial) _modChip('BURN (Halved Atk)', Colors.deepOrange),
                  if (isSlowStartActive) _modChip('Slow Start (½ Atk / Spe)', Colors.orangeAccent),
                  if (state.weather != 'none') _modChip('☁ ${state.weather}', Colors.teal),
                  if (state.helpingHandActive) _modChip('Helping Hand ×1.5', Colors.orange),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Battlefield Tweaks
          _buildDropdownHeader('BATTLEFIELD TWEAKS & FLAGS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
            ),
            child: Column(children: [
              _buildSwitchListTile('⚔ Double Battle (Spread 0.75× / Screens 0.667×)', state.isDoubleBattle, vm.toggleDoubleBattle),
              _buildSwitchListTile('💥 Critical Hit (1.5x, Ignores Defense Boosts)', state.isCriticalHit, vm.toggleCriticalHit),
              _buildSwitchListTile('🛡 Defender used Protect / Detect', state.defenderProtected, vm.toggleDefenderProtected),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text('Weather: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.weather,
                          dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          isExpanded: true,
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                          items: const [
                            DropdownMenuItem(value: 'none', child: Text('No Weather (Normal)')),
                            DropdownMenuItem(value: 'sunny', child: Text('Harsh Sunlight (Sunny)')),
                            DropdownMenuItem(value: 'rainy', child: Text('Rainy Weather (Rain)')),
                            DropdownMenuItem(value: 'sandstorm', child: Text('Sandstorm')),
                            DropdownMenuItem(value: 'snow', child: Text('Snow / Hail')),
                          ],
                          onChanged: (w) => vm.setWeather(w ?? 'none'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Text('Terrain: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.terrain,
                          dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          isExpanded: true,
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                          items: const [
                            DropdownMenuItem(value: 'none', child: Text('No Terrain')),
                            DropdownMenuItem(value: 'electric', child: Text('Electric Terrain')),
                            DropdownMenuItem(value: 'grassy', child: Text('Grassy Terrain')),
                            DropdownMenuItem(value: 'psychic', child: Text('Psychic Terrain')),
                            DropdownMenuItem(value: 'misty', child: Text('Misty Terrain')),
                          ],
                          onChanged: (t) => vm.setTerrain(t ?? 'none'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              _buildSwitchListTile('Light Screen (Halves Sp. Atk)', state.lightScreenActive, vm.toggleLightScreen),
              _buildSwitchListTile('Reflect (Halves Physical Atk)', state.reflectActive, vm.toggleReflect),
              _buildSwitchListTile('Helping Hand (+50% damage)', state.helpingHandActive, vm.toggleHelpingHand),
              _buildSwitchListTile('Trick Room Active', state.trickRoomActive, vm.toggleTrickRoom),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type) {
    final color = CombatUtils.typeColors[type.toLowerCase()] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  Widget _modChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdownHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildCardWrapper(bool isDark, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: child,
    );
  }

  Widget _buildSwitchListTile(String title, bool val, ValueChanged<bool> onChanged) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        value: val,
        activeThumbColor: AppTheme.pokemonRed,
        onChanged: onChanged,
      ),
    );
  }

  // ── Searchable Pickers ───────────────────────────────────────────────────

  void _showPokemonPicker(BuildContext context, List<Pokemon> list, bool isAttacker, DamageCalculatorViewModel vm) {
    PokemonPickerDialog.show(context, list: list, isAttacker: isAttacker, vm: vm);
  }

  void _showMovePicker(BuildContext context, DamageCalculatorViewModel vm) {
    MovePickerDialog.show(
      context,
      moves: _dbDamagingMoves,
      vm: vm,
      onMoveSelected: (m) => setState(() => _simpleSelectedMove = m),
    );
  }

  void _showItemPicker(BuildContext context, bool isAttacker, DamageCalculatorViewModel vm) {
    ItemPickerDialog.show(context, isAttacker: isAttacker, vm: vm);
  }

  // ── Centered Dialog Setup Editor ────────────────────────────────────────

  void _showSetupEditorSheet(
    BuildContext context,
    bool isAttacker,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
    Pokemon p,
    List<Pokemon> pokemonList,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final screenHeight = MediaQuery.of(context).size.height;

    // The setup editor contains a lot of controls. A gentle scale/fade makes
    // opening it feel deliberate instead of an abrupt dialog pop.
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Pokémon setup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, animation, secondaryAnimation) => Consumer(
        builder: (context, ref, _) {
          final currentState = ref.watch(damageCalculatorViewModelProvider);
          final isChampions = currentState.ruleset.isChampions;
          final nature = isAttacker ? currentState.attackerNature : currentState.defenderNature;
          final heldItem = isAttacker ? currentState.attackerHeldItem : currentState.defenderHeldItem;
          final ivs = isAttacker ? currentState.attackerIvs : currentState.defenderIvs;
          final evs = isAttacker ? currentState.attackerEvs : currentState.defenderEvs;
          final sps = isAttacker ? currentState.attackerSps : currentState.defenderSps;
          final stages = isAttacker ? currentState.attackerStages : currentState.defenderStages;
          final isTeraActive = isAttacker ? currentState.attackerTeraActive : currentState.defenderTeraActive;
          final teraType = (isAttacker ? currentState.attackerTeraType : currentState.defenderTeraType) ?? p.type1;
          final status = isAttacker ? currentState.attackerStatus : currentState.defenderStatus;
          // Champions uses its separate fixed Stat Point formula.
          final level = isChampions
              ? ChampionsRules.level
              : (isAttacker ? currentState.attackerLevel : currentState.defenderLevel);

          Widget buildStatRow(String label, String key, int baseVal, bool isHp) {
            final ivVal = ivs[key] ?? 31;
            final evVal = evs[key] ?? 0;
            final spVal = sps[key] ?? 0;
            final stageVal = stages[key] ?? 0;
            final int finalStat = isChampions
                ? (isHp
                    ? StatCalculator.calculateChampionsHp(
                        base: baseVal, sp: spVal,
                        isShedinja: p.name.toLowerCase() == 'shedinja',
                      )
                    : StatCalculator.calculateChampionsStat(
                        base: baseVal, sp: spVal,
                        alignmentModifier: CombatUtils.getNatureMultiplier(nature, label),
                      ))
                : (isHp
                    ? StatCalculator.calculateHp(base: baseVal, iv: ivVal, ev: evVal, level: level)
                    : StatCalculator.calculateOtherStat(
                        base: baseVal, iv: ivVal, ev: evVal, level: level,
                        natureModifier: CombatUtils.getNatureMultiplier(nature, label),
                      ));
            final double stageMult = isHp ? 1.0 : CombatUtils.getStageMultiplier(stageVal);
            final int finalStatWithStage = (finalStat * stageMult).toInt();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Expanded(flex: 1, child: Text('$baseVal', style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 32,
                        child: isChampions
                            // Champions treats IVs as perfect — show the
                            // fixed value instead of an editable field.
                            ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF161616) : const Color(0xFFE9EEF4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${ChampionsRules.fixedIv}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              )
                            : TextField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                          ),
                          style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          controller: TextEditingController(text: '$ivVal')
                            ..selection = TextSelection.fromPosition(TextPosition(offset: '$ivVal'.length)),
                          onChanged: (val) {
                            final parsed = int.tryParse(val) ?? 0;
                            final clamped = parsed.clamp(0, 31);
                            if (isAttacker) {
                              vm.updateAttackerIv(key, clamped);
                            } else {
                              vm.updateDefenderIv(key, clamped);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 32,
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                          ),
                          style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          controller: TextEditingController(text: isChampions ? '$spVal' : '$evVal')
                            ..selection = TextSelection.fromPosition(
                                TextPosition(offset: (isChampions ? '$spVal' : '$evVal').length)),
                          onChanged: (val) {
                            final parsed = int.tryParse(val) ?? 0;
                            if (isChampions) {
                              // Stat Points: 32 per stat cap, 66 overall —
                              // the view model enforces the total budget.
                              if (isAttacker) {
                                vm.updateAttackerSp(key, parsed);
                              } else {
                                vm.updateDefenderSp(key, parsed);
                              }
                            } else {
                              final clamped = parsed.clamp(0, 252);
                              if (isAttacker) {
                                vm.updateAttackerEv(key, clamped);
                              } else {
                                vm.updateDefenderEv(key, clamped);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: isHp
                        ? const Center(child: Text('-', style: TextStyle(color: Colors.grey)))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: stageVal,
                                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  items: List.generate(13, (i) => i - 6).map((stage) {
                                    return DropdownMenuItem<int>(
                                      value: stage,
                                      child: Text(stage >= 0 ? '+$stage' : '$stage', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      if (isAttacker) {
                                        vm.updateAttackerStage(key, v);
                                      } else {
                                        vm.updateDefenderStage(key, v);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('$finalStatWithStage', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.pokemonRed), textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(ctx),
                          tooltip: 'Close',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [

                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (p.spriteUrl.isNotEmpty)
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: PokemonSprite(
                              imageUrl: p.spriteUrl,
                              fallbackUrl: PokemonSprite.homeArtworkUrl(p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id),
                              errorIconColor: Colors.grey,
                              errorIconSize: 24,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isAttacker ? 'ATTACKER SETUP' : 'DEFENDER SETUP', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.swap_horiz, size: 14),
                      label: const Text('Change Pokémon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPokemonPicker(context, pokemonList, isAttacker, vm);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),

                if (isChampions) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, size: 16, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Pokémon Champions — 66 Stat Points in total, max 32 per stat, using Champions stat formulas.',
                            style: TextStyle(fontSize: 10.5, height: 1.35, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Terastallization Card (Mainline ruleset only — Pokémon Champions does not have Tera)
                if (!currentState.ruleset.isChampions) ...[
                  Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            const Text('💎 Terastallize (Tera Active)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            if (isTeraActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: (CombatUtils.typeColors[teraType.toLowerCase()] ?? Colors.purple).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text(teraType.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CombatUtils.typeColors[teraType.toLowerCase()] ?? Colors.purple)),
                              ),
                            ],
                          ],
                        ),
                        subtitle: const Text('Applies Tera STAB (Attacker) or pure Tera typing (Defender)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        value: isTeraActive,
                        activeThumbColor: AppTheme.pokemonRed,
                        onChanged: (val) {
                          if (isAttacker) {
                            vm.toggleAttackerTera(val);
                          } else {
                            vm.toggleDefenderTera(val);
                          }
                        },
                      ),
                      if (isTeraActive) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Tera Type: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: CombatUtils.allTypes.contains(teraType.toLowerCase()) ? teraType.toLowerCase() : CombatUtils.allTypes.first,
                                    isExpanded: true,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                                    items: CombatUtils.allTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                                    onChanged: (t) {
                                      if (t != null) {
                                        if (isAttacker) {
                                          vm.setAttackerTeraType(t);
                                        } else {
                                          vm.setDefenderTeraType(t);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

                // Status Condition & Held Item
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('STATUS CONDITION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: status,
                                isExpanded: true,
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11),
                                items: const [
                                  DropdownMenuItem(value: 'none', child: Text('Healthy (None)')),
                                  DropdownMenuItem(value: 'burn', child: Text('🔥 Burned (BRN)')),
                                  DropdownMenuItem(value: 'paralysis', child: Text('⚡ Paralyzed (PAR)')),
                                  DropdownMenuItem(value: 'poison', child: Text('☠️ Poisoned (PSN)')),
                                  DropdownMenuItem(value: 'toxic', child: Text('☣️ Badly Poisoned')),
                                  DropdownMenuItem(value: 'sleep', child: Text('💤 Asleep (SLP)')),
                                  DropdownMenuItem(value: 'freeze', child: Text('🧊 Frozen (FRZ)')),
                                ],
                                onChanged: (st) {
                                  if (st != null) {
                                    if (isAttacker) {
                                      vm.setAttackerStatus(st);
                                    } else {
                                      vm.setDefenderStatus(st);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HELD ITEM (TAP TO SEARCH)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _showItemPicker(context, isAttacker, vm),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.backpack_outlined, size: 16, color: AppTheme.pokemonRed),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(heldItem, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ability & Nature
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ABILITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                          const SizedBox(height: 4),
                          FutureBuilder<List<Map<String, dynamic>>>(
                            // Base-species abilities fill in for forms that
                            // have no released Champions ability yet.
                            future: ref.read(pokemonRepositoryProvider).getAbilitiesWithFallback(p.id),
                            builder: (context, snapshot) {
                              final abilitiesList = snapshot.data ?? [];
                              if (abilitiesList.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Default Ability', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                );
                              }
                              String abilityNameOf(Map<String, dynamic> a) => (a['name'] ?? '') as String;
                              final selectedAbility = isAttacker ? currentState.attackerAbility : currentState.defenderAbility;
                              final currentAbility = (selectedAbility != null && abilitiesList.any((a) => abilityNameOf(a).toLowerCase() == selectedAbility.toLowerCase()))
                                  ? abilityNameOf(abilitiesList.firstWhere((a) => abilityNameOf(a).toLowerCase() == selectedAbility.toLowerCase()))
                                  : abilityNameOf(abilitiesList.first);

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: currentAbility,
                                    isExpanded: true,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11),
                                    items: abilitiesList.map((a) {
                                      final name = abilityNameOf(a);
                                      final label = (a['isHidden'] == true) ? '$name (Hidden)' : name;
                                      return DropdownMenuItem<String>(value: name, child: Text(label, overflow: TextOverflow.ellipsis));
                                    }).toList(),
                                    onChanged: (ab) {
                                      if (ab != null) {
                                        if (isAttacker) {
                                          vm.setAttackerAbility(ab);
                                        } else {
                                          vm.setDefenderAbility(ab);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isChampions ? 'STAT ALIGNMENT' : 'NATURE (STAT DIRECTS)',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: (isChampions ? championsAlignmentNames : natureFormattedNames)
                                        .containsKey(nature.toLowerCase())
                                    ? nature.toLowerCase()
                                    : (isChampions ? 'serious' : 'adamant'),
                                isExpanded: true,
                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11),
                                items: (isChampions ? championsAlignmentNames : natureFormattedNames)
                                    .entries
                                    .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis)))
                                    .toList(),
                                onChanged: (n) {
                                  if (n != null) {
                                    if (isAttacker) {
                                      vm.updateAttackerNature(n);
                                    } else {
                                      vm.updateDefenderNature(n);
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Level Slider — Champions battles are always level 50.
                if (isChampions)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'LEVEL: 50 — fixed for all Pokémon Champions battles',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LEVEL: $level', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                      Slider(
                        value: level.toDouble(), min: 1, max: 100, divisions: 99,
                        activeColor: AppTheme.pokemonRed,
                        onChanged: (val) {
                          if (isAttacker) {
                            vm.updateAttackerLevel(val.toInt());
                          } else {
                            vm.updateDefenderLevel(val.toInt());
                          }
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // EVs & IVs (mainline) or Stat Point (Champions) editor table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isChampions ? 'STATS, SP & BOOSTS' : 'STATS, EVS, IVS & BOOSTS',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                    ),
                    if (isChampions)
                      Text(
                        '${ChampionsRules.remainingStatPoints(sps)} / ${ChampionsRules.totalStatPoints} SP remaining',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: ChampionsRules.remainingStatPoints(sps) == 0
                              ? Colors.deepPurpleAccent
                              : Colors.grey,
                        ),
                      )
                    else
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              final keys = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];
                              for (final k in keys) {
                                if (isAttacker) {
                                  vm.updateAttackerEv(k, k == 'hp' || k == 'atk' ? 252 : (k == 'spe' ? 4 : 0));
                                } else {
                                  vm.updateDefenderEv(k, k == 'hp' || k == 'def' ? 252 : (k == 'spd' ? 4 : 0));
                                }
                              }
                            },
                            child: const Text('252/252 Preset', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.pokemonRed)),
                          ),
                          TextButton(
                            onPressed: () {
                              final keys = ['hp', 'atk', 'def', 'spa', 'spd', 'spe'];
                              for (final k in keys) {
                                if (isAttacker) {
                                  vm.updateAttackerIv(k, 31);
                                } else {
                                  vm.updateDefenderIv(k, 31);
                                }
                              }
                            },
                            child: const Text('Max IVs', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                  ],
                ),
                if (isChampions) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final preset in ChampionsStatPreset.presets)
                        ActionChip(
                          label: Text(preset.label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEDF2F7),
                          side: BorderSide(color: Colors.deepPurpleAccent.withValues(alpha: 0.25)),
                          onPressed: () => vm.applyChampionsPreset(isAttacker: isAttacker, preset: preset),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Expanded(flex: 2, child: Text('STAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey))),
                    const Expanded(flex: 1, child: Text('BASE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
                    const Expanded(flex: 2, child: Text('IV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
                    Expanded(
                      flex: 2,
                      child: Text(
                        isChampions ? 'SP' : 'EV',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Expanded(flex: 2, child: Text('BOOST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
                    const Expanded(flex: 2, child: Text('FINAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.right)),
                  ],
                ),
                const Divider(),
                buildStatRow('HP', 'hp', p.baseHp, true),
                buildStatRow('Attack', 'atk', p.baseAtk, false),
                buildStatRow('Defense', 'def', p.baseDef, false),
                buildStatRow('Sp. Atk', 'spa', p.baseSpAtk, false),
                buildStatRow('Sp. Def', 'spd', p.baseSpDef, false),
                buildStatRow('Speed', 'spe', p.baseSpd, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
