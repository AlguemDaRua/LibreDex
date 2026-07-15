import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';

class DamageCalculatorScreen extends ConsumerStatefulWidget {
  const DamageCalculatorScreen({super.key});

  @override
  ConsumerState<DamageCalculatorScreen> createState() => _DamageCalculatorScreenState();
}

class _DamageCalculatorScreenState extends ConsumerState<DamageCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Move> _dbDamagingMoves = [];

  // Predefined popular damaging moves as fallbacks
  static final List<Move> _fallbackMoves = [
    const Move(id: 9901, name: 'Flamethrower', type: 'fire', power: 90, accuracy: 100, pp: 15, damageClass: 'special', description: 'Burns the foe.'),
    const Move(id: 9902, name: 'Thunderbolt', type: 'electric', power: 90, accuracy: 100, pp: 15, damageClass: 'special', description: 'Electrifies the foe.'),
    const Move(id: 9903, name: 'Ice Beam', type: 'ice', power: 90, accuracy: 100, pp: 15, damageClass: 'special', description: 'Freezes the foe.'),
    const Move(id: 9904, name: 'Earthquake', type: 'ground', power: 100, accuracy: 100, pp: 10, damageClass: 'physical', description: 'Strikes the ground.'),
    const Move(id: 9905, name: 'Hydro Pump', type: 'water', power: 110, accuracy: 80, pp: 5, damageClass: 'special', description: 'High water pressure blast.'),
    const Move(id: 9906, name: 'Close Combat', type: 'fighting', power: 120, accuracy: 100, pp: 5, damageClass: 'physical', description: 'Launches close attack.'),
    const Move(id: 9907, name: 'Draco Meteor', type: 'dragon', power: 130, accuracy: 90, pp: 5, damageClass: 'special', description: 'Summons stars.'),
    const Move(id: 9908, name: 'Psychic', type: 'psychic', power: 90, accuracy: 100, pp: 10, damageClass: 'special', description: 'Telekinetic strike.'),
    const Move(id: 9909, name: 'Giga Drain', type: 'grass', power: 75, accuracy: 100, pp: 10, damageClass: 'special', description: 'Absorbs opponent energy.'),
  ];

  Move _simpleSelectedMove = _fallbackMoves.first;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDbMoves();
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
          .where((m) => m.power != null && m.power! > 0 && m.damageClass != 'status')
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
            Tab(text: 'SIMPLE', icon: Icon(Icons.bolt_rounded, size: 20)),
            Tab(text: '1VS1 DUEL', icon: Icon(Icons.compare_arrows_rounded, size: 20)),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: 'calculator'),
      body: pokedexAsync.when(
        data: (pokemonList) {
          if (pokemonList.isEmpty) {
            return const Center(
              child: Text(
                'Please synchronize the Pokedex first in Settings or Pokedex Screen.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSimpleTab(state, vm, isDark, primaryColor),
              _buildDuelTab(state, vm, pokemonList, isDark, primaryColor),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
        error: (err, _) => Center(child: Text('Error loading Pokédex: $err')),
      ),
    );
  }

  // --- SIMPLE TAB DESIGN ---
  Widget _buildSimpleTab(DamageCalculatorState state, DamageCalculatorViewModel vm, bool isDark, Color primaryColor) {
    // Safely resolve simpleSelectedMove to guarantee it exists in the active moves list
    final List<Move> simpleMovesList = _dbDamagingMoves.isNotEmpty ? _dbDamagingMoves : _fallbackMoves;
    Move simpleSelectedMove = _simpleSelectedMove;
    if (!simpleMovesList.any((m) => m.id == simpleSelectedMove.id)) {
      simpleSelectedMove = simpleMovesList.first;
    }

    // Weather Boost Calculations
    double weatherMult = 1.0;
    if (state.weather == 'sunny' && simpleSelectedMove.type.toLowerCase() == 'fire') weatherMult = 1.5;
    if (state.weather == 'sunny' && simpleSelectedMove.type.toLowerCase() == 'water') weatherMult = 0.5;
    if (state.weather == 'rainy' && simpleSelectedMove.type.toLowerCase() == 'water') weatherMult = 1.5;
    if (state.weather == 'rainy' && simpleSelectedMove.type.toLowerCase() == 'fire') weatherMult = 0.5;

    // Terrain Boost Calculations
    double terrainMult = 1.0;
    if (state.terrain == 'electric' && simpleSelectedMove.type.toLowerCase() == 'electric') terrainMult = 1.3;
    if (state.terrain == 'grassy' && simpleSelectedMove.type.toLowerCase() == 'grass') terrainMult = 1.3;
    if (state.terrain == 'psychic' && simpleSelectedMove.type.toLowerCase() == 'psychic') terrainMult = 1.3;

    // Helping Hand Calculation
    double helpingHandMult = state.helpingHandActive ? 1.5 : 1.0;

    // Total Modified Base Power
    double finalBasePower = simpleSelectedMove.power! * weatherMult * terrainMult * helpingHandMult;

    final typeColor = CombatUtils.typeColors[simpleSelectedMove.type.toLowerCase()] ?? Colors.grey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Base Power Display
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                     'MODIFIED BASE POWER',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    finalBasePower.toStringAsFixed(1),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: typeColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${simpleSelectedMove.name.toUpperCase()} (${simpleSelectedMove.type.toUpperCase()})',
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Direct Move Selector Dropdown
          _buildDropdownHeader('SELECT DAMAGE MOVE'),
          _buildCardWrapper(
            isDark,
            DropdownButtonHideUnderline(
              child: DropdownButton<Move>(
                value: simpleSelectedMove,
                dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                isExpanded: true,
                items: simpleMovesList.map((m) {
                  return DropdownMenuItem<Move>(
                    value: m,
                    child: Text(
                      '${m.name} (${m.type.toUpperCase()} - BP: ${m.power})',
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (m) {
                  if (m != null) {
                    setState(() {
                      _simpleSelectedMove = m;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weather Selector
          _buildDropdownHeader('BATTLE WEATHER'),
          _buildCardWrapper(
            isDark,
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.weather,
                dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                isExpanded: true,
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('No Weather (Normal)')),
                  DropdownMenuItem(value: 'sunny', child: Text('Harsh Sunlight (Sunny)')),
                  DropdownMenuItem(value: 'rainy', child: Text('Rainy Weather (Rain)')),
                ],
                onChanged: (w) => vm.setWeather(w ?? 'none'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Terrain Selector
          _buildDropdownHeader('BATTLEFIELD TERRAIN'),
          _buildCardWrapper(
            isDark,
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.terrain,
                dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                isExpanded: true,
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('No Terrain')),
                  DropdownMenuItem(value: 'electric', child: Text('Electric Terrain')),
                  DropdownMenuItem(value: 'grassy', child: Text('Grassy Terrain')),
                  DropdownMenuItem(value: 'psychic', child: Text('Psychic Terrain')),
                ],
                onChanged: (t) => vm.setTerrain(t ?? 'none'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Helping Hand Toggle Switch
          _buildCardWrapper(
            isDark,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Helping Hand Boost (1.5x BP)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Switch(
                  value: state.helpingHandActive,
                  activeThumbColor: AppTheme.pokemonRed,
                  onChanged: vm.toggleHelpingHand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1VS1 DUEL TAB DESIGN ---
  Widget _buildDuelTab(
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
    List<Pokemon> pokemonList,
    bool isDark,
    Color primaryColor,
  ) {
    // Lazy default setup
    if (state.attacker == null && pokemonList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.setAttacker(pokemonList.firstWhere((p) => p.name.toLowerCase() == 'charizard', orElse: () => pokemonList.first));
        vm.setDefender(pokemonList.firstWhere((p) => p.name.toLowerCase() == 'blastoise', orElse: () => pokemonList.first));
      });
    }

    if (state.attacker == null || state.defender == null) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)));
    }

    final p1 = state.attacker!;
    final p2 = state.defender!;

    // Move options available for current attacker
    final List<Move> p1Moves = _dbDamagingMoves.isNotEmpty ? _dbDamagingMoves : _fallbackMoves;
    Move? activeMove;
    if (state.selectedMoveName != null) {
      activeMove = p1Moves.firstWhere(
        (m) => m.name.toLowerCase() == state.selectedMoveName!.toLowerCase(),
        orElse: () => p1Moves.first,
      );
    } else {
      activeMove = p1Moves.first;
    }

    // Precise Speed and combat statistics calculation using StatCalculator
    final int rawAttackerSpeed = StatCalculator.calculateOtherStat(
      base: p1.baseSpd,
      iv: state.attackerIvs['spe'] ?? 31,
      ev: state.attackerEvs['spe'] ?? 4,
      level: state.attackerLevel,
      natureModifier: CombatUtils.getNatureMultiplier(state.attackerNature, 'Speed'),
    );
    final int attackerSpeed = (rawAttackerSpeed * CombatUtils.getStageMultiplier(state.attackerStages['spe'] ?? 0)).toInt();

    final int rawDefenderSpeed = StatCalculator.calculateOtherStat(
      base: p2.baseSpd,
      iv: state.defenderIvs['spe'] ?? 31,
      ev: state.defenderEvs['spe'] ?? 0,
      level: state.defenderLevel,
      natureModifier: CombatUtils.getNatureMultiplier(state.defenderNature, 'Speed'),
    );
    final int defenderSpeed = (rawDefenderSpeed * CombatUtils.getStageMultiplier(state.defenderStages['spe'] ?? 0)).toInt();

    // Real-Time Precise Damage Calculations
    final isSpecial = activeMove.damageClass.toLowerCase() == 'special';
    
    final int rawAttackerAtk = StatCalculator.calculateOtherStat(
      base: isSpecial ? p1.baseSpAtk : p1.baseAtk,
      iv: isSpecial ? (state.attackerIvs['spa'] ?? 31) : (state.attackerIvs['atk'] ?? 31),
      ev: isSpecial ? (state.attackerEvs['spa'] ?? 0) : (state.attackerEvs['atk'] ?? 252),
      level: state.attackerLevel,
      natureModifier: CombatUtils.getNatureMultiplier(state.attackerNature, isSpecial ? 'Sp. Atk' : 'Attack'),
    );
    final int attackerAtk = (rawAttackerAtk * CombatUtils.getStageMultiplier(isSpecial ? (state.attackerStages['spa'] ?? 0) : (state.attackerStages['atk'] ?? 0))).toInt();

    final int rawDefenderDef = StatCalculator.calculateOtherStat(
      base: isSpecial ? p2.baseSpDef : p2.baseDef,
      iv: isSpecial ? (state.defenderIvs['spd'] ?? 31) : (state.defenderIvs['def'] ?? 31),
      ev: isSpecial ? (state.defenderEvs['spd'] ?? 4) : (state.defenderEvs['def'] ?? 252),
      level: state.defenderLevel,
      natureModifier: CombatUtils.getNatureMultiplier(state.defenderNature, isSpecial ? 'Sp. Def' : 'Defense'),
    );
    final int defenderDef = (rawDefenderDef * CombatUtils.getStageMultiplier(isSpecial ? (state.defenderStages['spd'] ?? 0) : (state.defenderStages['def'] ?? 0))).toInt();

    final int defenderMaxHp = StatCalculator.calculateHp(
      base: p2.baseHp,
      iv: state.defenderIvs['hp'] ?? 31,
      ev: state.defenderEvs['hp'] ?? 252,
      level: state.defenderLevel,
    );

    // Weather Boost Calculations
    double weatherMult = 1.0;
    if (state.weather == 'sunny' && activeMove.type.toLowerCase() == 'fire') weatherMult = 1.5;
    if (state.weather == 'sunny' && activeMove.type.toLowerCase() == 'water') weatherMult = 0.5;
    if (state.weather == 'rainy' && activeMove.type.toLowerCase() == 'water') weatherMult = 1.5;
    if (state.weather == 'rainy' && activeMove.type.toLowerCase() == 'fire') weatherMult = 0.5;

    // Same Type Attack Bonus (STAB)
    double stabMult = 1.0;
    if (p1.type1.toLowerCase() == activeMove.type.toLowerCase() ||
        p1.type2?.toLowerCase() == activeMove.type.toLowerCase()) {
      stabMult = 1.5;
    }

    // Type Effectiveness Calculator
    double effectivenessMult = CombatUtils.getTypeEffectiveness(activeMove.type, p2.type1, p2.type2);

    // Screens Reduction
    double screenMult = 1.0;
    if (isSpecial && state.lightScreenActive) screenMult = 0.5;
    if (!isSpecial && state.reflectActive) screenMult = 0.5;

    // Total Modified Base Power
    double terrainMult = 1.0;
    if (state.terrain == 'electric' && activeMove.type.toLowerCase() == 'electric') terrainMult = 1.3;
    if (state.terrain == 'grassy' && activeMove.type.toLowerCase() == 'grass') terrainMult = 1.3;
    if (state.terrain == 'psychic' && activeMove.type.toLowerCase() == 'psychic') terrainMult = 1.3;

    double hhMult = state.helpingHandActive ? 1.5 : 1.0;

    double finalBp = activeMove.power! * weatherMult * terrainMult * hhMult;

    // ── Apply held item multipliers + final calculations ──────────────────────
    final double atkItemMult = HeldItemsData.getAttackMultiplier(
        state.attackerHeldItem, activeMove.type, isSpecial);
    final double defResistMult = HeldItemsData.getDefenderResistMultiplier(
        state.defenderHeldItem, activeMove.type, effectivenessMult);
    final double defStatItemMult = HeldItemsData.getDefenseMultiplier(state.defenderHeldItem, isSpecial);

    // Final Speed with held items
    final int finalAttackerSpeed = (attackerSpeed * HeldItemsData.getSpeedMultiplier(state.attackerHeldItem)).toInt();
    final int finalDefenderSpeed = (defenderSpeed * HeldItemsData.getSpeedMultiplier(state.defenderHeldItem)).toInt();
    bool p1Outspeeds = state.trickRoomActive ? finalAttackerSpeed < finalDefenderSpeed : finalAttackerSpeed > finalDefenderSpeed;
    if (finalAttackerSpeed == finalDefenderSpeed) p1Outspeeds = true;

    // Final damage incorporating all modifiers
    final int defenderDefFinal = (defenderDef * defStatItemMult).toInt().clamp(1, 9999);
    final double atkWithItem = attackerAtk * atkItemMult;
    final double damageBase = ((((2 * state.attackerLevel / 5) + 2) * finalBp * atkWithItem / defenderDefFinal) / 50) + 2;
    final double finalMinDamage = damageBase * stabMult * effectivenessMult * screenMult * defResistMult * 0.85;
    final double finalMaxDamage = damageBase * stabMult * effectivenessMult * screenMult * defResistMult * 1.0;
    final double minPercent = (finalMinDamage / defenderMaxHp) * 100;
    final double maxPercent = (finalMaxDamage / defenderMaxHp) * 100;

    Widget _pokemonDuelCard(Pokemon p, bool isAttacker, String heldItem) {
      final typeColor = CombatUtils.typeColors[p.type1.toLowerCase()] ?? Colors.grey;
      final spd = isAttacker ? finalAttackerSpeed : finalDefenderSpeed;
      return GestureDetector(
        onTap: () => _showPokemonPicker(context, pokemonList, isAttacker, vm),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [BoxShadow(color: typeColor.withValues(alpha: 0.08), blurRadius: 12, spreadRadius: 2)],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Sprite
              SizedBox(
                height: 80,
                child: p.spriteUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: p.spriteUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)))),
                        errorWidget: (_, __, ___) => Icon(Icons.catching_pokemon, size: 48, color: typeColor.withValues(alpha: 0.4)),
                      )
                    : Icon(Icons.catching_pokemon, size: 48, color: typeColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 6),
              // Name
              Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              // Types
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _typeChip(p.type1),
                if (p.type2 != null) ...[ const SizedBox(width: 4), _typeChip(p.type2!) ],
              ]),
              const SizedBox(height: 6),
              // Speed
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text('⚡ SPD $spd', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              const SizedBox(height: 6),
              // Held Item
              GestureDetector(
                onTap: () => _showItemPicker(context, isAttacker, vm),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: heldItem != 'None' ? AppTheme.pokemonRed.withValues(alpha: 0.1) : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: heldItem != 'None' ? AppTheme.pokemonRed.withValues(alpha: 0.4) : Colors.transparent),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.backpack_outlined, size: 12, color: heldItem != 'None' ? AppTheme.pokemonRed : Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(heldItem, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: heldItem != 'None' ? AppTheme.pokemonRed : Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Pokemon Cards Row ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: [
                const Text('ATTACKER', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 6),
                _pokemonDuelCard(p1, true, state.attackerHeldItem),
              ])),
              Padding(
                padding: const EdgeInsets.only(top: 44),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('VS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.orangeAccent)),
                ),
              ),
              Expanded(child: Column(children: [
                const Text('DEFENDER', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 6),
                _pokemonDuelCard(p2, false, state.defenderHeldItem),
              ])),
            ],
          ),
          const SizedBox(height: 12),

          // ── Speed Comparison Banner ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: p1Outspeeds ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p1Outspeeds ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(p1Outspeeds ? Icons.offline_bolt_rounded : Icons.warning_amber_rounded,
                  color: p1Outspeeds ? Colors.greenAccent : Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(
                p1Outspeeds
                    ? '${p1.name} ($finalAttackerSpeed) outspeeds ${p2.name} ($finalDefenderSpeed)${state.attackerHeldItem != 'None' ? ' [+${state.attackerHeldItem}]' : ''}'
                    : '${p2.name} ($finalDefenderSpeed) outspeeds ${p1.name} ($finalAttackerSpeed)${state.defenderHeldItem != 'None' ? ' [+${state.defenderHeldItem}]' : ''}',
                style: TextStyle(fontWeight: FontWeight.bold, color: p1Outspeeds ? Colors.greenAccent : Colors.redAccent, fontSize: 11),
                textAlign: TextAlign.center,
              )),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Trick Room Toggle ───────────────────────────────────────────────
          _buildSwitchListTile('Trick Room Active', state.trickRoomActive, vm.toggleTrickRoom),
          const SizedBox(height: 12),

          // ── Move Selector ─────────────────────────────────────────────────
          _buildDropdownHeader('ATTACKER MOVE (ANY MOVE — TAP TO SEARCH)'),
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
                    color: (CombatUtils.typeColors[state.moveType.toLowerCase()] ?? Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(state.moveType.toUpperCase(),
                      style: TextStyle(color: CombatUtils.typeColors[state.moveType.toLowerCase()] ?? Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  state.selectedMoveName ?? 'Tap to search all moves...',
                  style: TextStyle(fontWeight: FontWeight.bold, color: state.selectedMoveName != null ? primaryColor : Colors.grey, fontSize: 13),
                )),
                Text('BP: ${activeMove.power ?? "—"}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(width: 4),
                const Icon(Icons.search, color: AppTheme.pokemonRed, size: 18),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── Damage Result Card ─────────────────────────────────────────────
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
                const SizedBox(height: 8),
                // Modifier chips row
                Wrap(spacing: 6, runSpacing: 4, alignment: WrapAlignment.center, children: [
                  if (stabMult > 1.0) _modChip('STAB ×1.5', Colors.amber),
                  if (effectivenessMult > 1.0) _modChip('Super Effective ×${effectivenessMult.toStringAsFixed(1)}', Colors.green),
                  if (effectivenessMult < 1.0) _modChip('Not Effective ×${effectivenessMult.toStringAsFixed(2)}', Colors.red),
                  if (state.attackerHeldItem != 'None') _modChip(state.attackerHeldItem, Colors.purple),
                  if (state.defenderHeldItem != 'None') _modChip('Def: ${state.defenderHeldItem}', Colors.blueAccent),
                  if (state.weather != 'none') _modChip('☁ ${state.weather}', Colors.teal),
                  if (state.helpingHandActive) _modChip('Helping Hand ×1.5', Colors.orange),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── Battlefield Tweaks ────────────────────────────────────────────
          _buildDropdownHeader('BATTLEFIELD TWEAKS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
            ),
            child: Column(children: [
              _buildSwitchListTile('Light Screen (Halves Sp. Atk)', state.lightScreenActive, vm.toggleLightScreen),
              _buildSwitchListTile('Reflect (Halves Physical Atk)', state.reflectActive, vm.toggleReflect),
              _buildSwitchListTile('Helping Hand (+50% damage)', state.helpingHandActive, vm.toggleHelpingHand),
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
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      value: val,
      activeThumbColor: AppTheme.pokemonRed,
      onChanged: onChanged,
    );
  }

  // ── Searchable Pickers ───────────────────────────────────────────────────

  void _showPokemonPicker(BuildContext context, List<Pokemon> list, bool isAttacker,
      DamageCalculatorViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String q = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        final filtered = list
            .where((p) =>
                p.name.toLowerCase().contains(q.toLowerCase()) ||
                p.id.toString().contains(q) ||
                p.type1.toLowerCase().contains(q.toLowerCase()) ||
                (p.type2?.toLowerCase().contains(q.toLowerCase()) ?? false))
            .toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
          builder: (ctx, sc) => Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => ss(() => q = v),
                decoration: InputDecoration(
                  hintText: 'Search Pokémon by name, ID or type...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final p = filtered[i];
                  return ListTile(
                    leading: p.spriteUrl.isNotEmpty
                        ? SizedBox(
                            width: 40,
                            height: 40,
                            child: CachedNetworkImage(
                              imageUrl: p.spriteUrl,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) => const Icon(Icons.catching_pokemon, color: Colors.grey),
                            ),
                          )
                        : const Icon(Icons.catching_pokemon, color: Colors.grey),
                    title: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                    subtitle: Text('#${p.id.toString().padLeft(3, '0')} • ${p.type1.toUpperCase()}${p.type2 != null ? ' / ${p.type2!.toUpperCase()}' : ''}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    onTap: () {
                      if (isAttacker) vm.setAttacker(p); else vm.setDefender(p);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ]),
        );
      }),
    );
  }

  void _showMovePicker(BuildContext context, DamageCalculatorViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moves = _dbDamagingMoves.isNotEmpty ? _dbDamagingMoves : _fallbackMoves;
    String q = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        final filtered = moves
            .where((m) =>
                m.name.toLowerCase().contains(q.toLowerCase()) ||
                m.type.toLowerCase().contains(q.toLowerCase()) ||
                m.damageClass.toLowerCase().contains(q.toLowerCase()) ||
                (m.power?.toString().contains(q) ?? false))
            .toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
          builder: (ctx, sc) => Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => ss(() => q = v),
                decoration: InputDecoration(
                  hintText: 'Search moves by name, type or BP...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  final typeColor = CombatUtils.typeColors[m.type.toLowerCase()] ?? Colors.grey;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: Text(m.type.toUpperCase(), style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 13)),
                    subtitle: Text('BP: ${m.power ?? "—"} • ${m.damageClass.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    onTap: () {
                      vm.selectMove(m.name, m.type, m.damageClass, (m.power ?? 0).toDouble());
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ]),
        );
      }),
    );
  }

  void _showItemPicker(BuildContext context, bool isAttacker, DamageCalculatorViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String q = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        final items = HeldItemsData.allItems
            .where((i) =>
                i.name.toLowerCase().contains(q.toLowerCase()) ||
                i.category.toLowerCase().contains(q.toLowerCase()) ||
                i.description.toLowerCase().contains(q.toLowerCase()))
            .toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.4, expand: false,
          builder: (ctx, sc) => Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => ss(() => q = v),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return ListTile(
                    leading: Icon(Icons.backpack_outlined, color: item.name == 'None' ? Colors.grey : AppTheme.pokemonRed, size: 20),
                    title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 13)),
                    subtitle: Text('${item.category} • ${item.description}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    onTap: () {
                      if (isAttacker) vm.setAttackerHeldItem(item.name);
                      else vm.setDefenderHeldItem(item.name);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ]),
        );
      }),
    );
  }

  // Also used by Simple tab for move picking
  void _showSimpleMovePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moves = _dbDamagingMoves.isNotEmpty ? _dbDamagingMoves : _fallbackMoves;
    String q = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) {
        final filtered = moves
            .where((m) =>
                m.name.toLowerCase().contains(q.toLowerCase()) ||
                m.type.toLowerCase().contains(q.toLowerCase()) ||
                (m.power?.toString().contains(q) ?? false))
            .toList();
        return DraggableScrollableSheet(
          initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
          builder: (ctx, sc) => Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                onChanged: (v) => ss(() => q = v),
                decoration: InputDecoration(
                  hintText: 'Search moves by name, type or BP...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  final typeColor = CombatUtils.typeColors[m.type.toLowerCase()] ?? Colors.grey;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: Text(m.type.toUpperCase(), style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(m.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 13)),
                    subtitle: Text('BP: ${m.power ?? "—"} • ${m.damageClass.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    onTap: () {
                      setState(() => _simpleSelectedMove = m);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ]),
        );
      }),
    );
  }
}
