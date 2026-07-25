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

  Move _simpleSelectedMove = const Move(id: 0, name: 'Loading...', type: 'normal', pp: 0, damageClass: 'physical');
  int _simpleStatStage = 0;
  bool _attackerExpanded = false;
  bool _defenderExpanded = false;

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
    final List<Move> simpleMovesList = _dbDamagingMoves;
    if (simpleMovesList.isEmpty) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)));
    }
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

    // Held Item Calculation
    final double itemMult = HeldItemsData.getAttackMultiplier(
      state.attackerHeldItem,
      simpleSelectedMove.type,
      simpleSelectedMove.damageClass.toLowerCase() == 'special',
    );

    // Stat Stage Multiplier (Simulates attacker's stat boost)
    double statStageMult = CombatUtils.getStageMultiplier(_simpleStatStage);

    // Total Modified Base Power
    final double finalBasePower = (simpleSelectedMove.power ?? 0) * weatherMult * terrainMult * helpingHandMult * itemMult * statStageMult;

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

          // Attacker Held Item Selector
          _buildDropdownHeader('ATTACKER HELD ITEM'),
          _buildCardWrapper(
            isDark,
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.attackerHeldItem,
                dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                isExpanded: true,
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                items: HeldItemsData.offensiveItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.name,
                    child: Text(
                      item.name == 'None' ? 'No Held Item' : '${item.name} (${item.description})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (item) {
                  if (item != null) {
                    vm.setAttackerHeldItem(item);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stat Stage Selector
          _buildDropdownHeader('STAT STAGE BOOST'),
          _buildCardWrapper(
            isDark,
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _simpleStatStage,
                dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                isExpanded: true,
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                items: List.generate(13, (i) => i - 6).map((stage) {
                  return DropdownMenuItem<int>(
                    value: stage,
                    child: Text(
                      stage >= 0 ? '+$stage Stage' : '$stage Stage',
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _simpleStatStage = val;
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
                  DropdownMenuItem(value: 'sandstorm', child: Text('Sandstorm')),
                  DropdownMenuItem(value: 'snow', child: Text('Snow / Hail')),
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
                  DropdownMenuItem(value: 'misty', child: Text('Misty Terrain')),
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
    final List<Move> p1Moves = _dbDamagingMoves;
    if (p1Moves.isEmpty) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)));
    }
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
    final bool isBodyPress = activeMove.name.toLowerCase() == 'body press';
    final int rawAttackerAtk;
    final int attackerAtk;
    final double atkItemMult;

    if (isBodyPress) {
      // Body Press uses Defense!
      final int rawAttackerDef = StatCalculator.calculateOtherStat(
        base: p1.baseDef,
        iv: state.attackerIvs['def'] ?? 31,
        ev: state.attackerEvs['def'] ?? 0,
        level: state.attackerLevel,
        natureModifier: CombatUtils.getNatureMultiplier(state.attackerNature, 'Defense'),
      );
      final int attackerDef = (rawAttackerDef * CombatUtils.getStageMultiplier(state.attackerStages['def'] ?? 0)).toInt();
      // Apply Eviolite or items that boost DEFENSE to the attacker's Defense stat!
      final double defItemMult = HeldItemsData.getDefenseMultiplier(state.attackerHeldItem, false);
      rawAttackerAtk = rawAttackerDef;
      attackerAtk = (attackerDef * defItemMult).toInt();
      // Universal damage items like Life Orb still boost Body Press
      final attackerItem = HeldItemsData.findByName(state.attackerHeldItem);
      atkItemMult = attackerItem?.universalDamageMultiplier ?? 1.0;
    } else {
      rawAttackerAtk = StatCalculator.calculateOtherStat(
        base: isSpecial ? p1.baseSpAtk : p1.baseAtk,
        iv: isSpecial ? (state.attackerIvs['spa'] ?? 31) : (state.attackerIvs['atk'] ?? 31),
        ev: isSpecial ? (state.attackerEvs['spa'] ?? 0) : (state.attackerEvs['atk'] ?? 252),
        level: state.attackerLevel,
        natureModifier: CombatUtils.getNatureMultiplier(state.attackerNature, isSpecial ? 'Sp. Atk' : 'Attack'),
      );
      final int stageMultiplier = isSpecial ? (state.attackerStages['spa'] ?? 0) : (state.attackerStages['atk'] ?? 0);
      attackerAtk = (rawAttackerAtk * CombatUtils.getStageMultiplier(stageMultiplier)).toInt();
      atkItemMult = HeldItemsData.getAttackMultiplier(state.attackerHeldItem, activeMove.type, isSpecial);
    }

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
      final isExpanded = isAttacker ? _attackerExpanded : _defenderExpanded;
      return GestureDetector(
        onTap: () {
          setState(() {
            if (isAttacker) {
              _attackerExpanded = !_attackerExpanded;
              if (_attackerExpanded) _defenderExpanded = false;
            } else {
              _defenderExpanded = !_defenderExpanded;
              if (_defenderExpanded) _attackerExpanded = false;
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpanded ? AppTheme.pokemonRed : typeColor.withValues(alpha: 0.4),
              width: isExpanded ? 2.0 : 1.5,
            ),
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
              Text(
                isExpanded ? 'Collapse ▲' : 'Edit Stats ▼',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
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

          // Attacker stats editor panel
          if (_attackerExpanded) ...[
            _buildStatsEditor(true, p1, state, vm, pokemonList),
            const SizedBox(height: 12),
          ],

          // Defender stats editor panel
          if (_defenderExpanded) ...[
            _buildStatsEditor(false, p2, state, vm, pokemonList),
            const SizedBox(height: 12),
          ],

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
              // Weather Dropdown
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
              // Terrain Dropdown
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
    final moves = _dbDamagingMoves;
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

  Widget _buildStatsEditor(bool isAttacker, Pokemon p, DamageCalculatorState state, DamageCalculatorViewModel vm, List<Pokemon> pokemonList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final level = isAttacker ? state.attackerLevel : state.defenderLevel;
    final nature = isAttacker ? state.attackerNature : state.defenderNature;
    final heldItem = isAttacker ? state.attackerHeldItem : state.defenderHeldItem;
    final ivs = isAttacker ? state.attackerIvs : state.defenderIvs;
    final evs = isAttacker ? state.attackerEvs : state.defenderEvs;
    final stages = isAttacker ? state.attackerStages : state.defenderStages;

    final List<String> natures = [
      'hardy', 'lonely', 'brave', 'adamant', 'naughty',
      'bold', 'docile', 'relaxed', 'impish', 'lax',
      'timid', 'hasty', 'serious', 'jolly', 'naive',
      'modest', 'mild', 'quiet', 'bashful', 'rash',
      'calm', 'gentle', 'sassy', 'careful', 'quirky'
    ];

    Widget _buildStatRow(String label, String key, int baseVal, bool isHp) {
      final ivVal = ivs[key] ?? 31;
      final evVal = evs[key] ?? 0;
      final stageVal = stages[key] ?? 0;

      final int finalStat;
      if (isHp) {
        finalStat = StatCalculator.calculateHp(base: baseVal, iv: ivVal, ev: evVal, level: level);
      } else {
        finalStat = StatCalculator.calculateOtherStat(
          base: baseVal,
          iv: ivVal,
          ev: evVal,
          level: level,
          natureModifier: CombatUtils.getNatureMultiplier(nature, label),
        );
      }
      final double stageMult = isHp ? 1.0 : CombatUtils.getStageMultiplier(stageVal);
      final int finalStatWithStage = (finalStat * stageMult).toInt();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$baseVal',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
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
                    controller: TextEditingController(text: '$evVal')
                      ..selection = TextSelection.fromPosition(TextPosition(offset: '$evVal'.length)),
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 0;
                      final clamped = parsed.clamp(0, 252);
                      if (isAttacker) {
                        vm.updateAttackerEv(key, clamped);
                      } else {
                        vm.updateDefenderEv(key, clamped);
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
                                child: Text(
                                  stage >= 0 ? '+$stage' : '$stage',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                                ),
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
              child: Text(
                '$finalStatWithStage',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.pokemonRed),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0C0C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAttacker ? 'ATTACKER SETUP' : 'DEFENDER SETUP',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5, color: Colors.grey),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.search_rounded, size: 14),
                label: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppTheme.pokemonRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showPokemonPicker(context, pokemonList, isAttacker, vm),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LEVEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                    Slider(
                      value: level.toDouble(),
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: '$level',
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
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NATURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: nature,
                          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          isExpanded: true,
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                          items: natures.map((n) {
                            return DropdownMenuItem<String>(
                              value: n,
                              child: Text(n.toUpperCase()),
                            );
                          }).toList(),
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
          const Text('HELD ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: heldItem,
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                isExpanded: true,
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12),
                items: HeldItemsData.allItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.name,
                    child: Text(
                      item.name == 'None' ? 'No Held Item' : '${item.name} (${item.description})',
                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (item) {
                  if (item != null) {
                    if (isAttacker) {
                      vm.setAttackerHeldItem(item);
                    } else {
                      vm.setDefenderHeldItem(item);
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(flex: 2, child: Text('STAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey))),
              Expanded(flex: 1, child: Text('BASE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('IV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('EV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('BOOST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('FINAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey), textAlign: TextAlign.right)),
            ],
          ),
          const Divider(),
          _buildStatRow('HP', 'hp', p.baseHp, true),
          _buildStatRow('Attack', 'atk', p.baseAtk, false),
          _buildStatRow('Defense', 'def', p.baseDef, false),
          _buildStatRow('Sp. Atk', 'spa', p.baseSpAtk, false),
          _buildStatRow('Sp. Def', 'spd', p.baseSpDef, false),
          _buildStatRow('Speed', 'spe', p.baseSpd, false),
        ],
      ),
    );
  }
}
