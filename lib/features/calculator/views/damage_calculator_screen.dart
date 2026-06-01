import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
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

    // Speed Duel Analysis taking Trick Room into absolute consideration
    bool p1Outspeeds = attackerSpeed > defenderSpeed;
    if (state.trickRoomActive) {
      p1Outspeeds = attackerSpeed < defenderSpeed;
    }
    if (attackerSpeed == defenderSpeed) {
      p1Outspeeds = true; // Speed tie fallback
    }

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

    // Basic Combat Damage Formula
    double damageBase = ((((2 * state.attackerLevel / 5) + 2) * finalBp * attackerAtk / defenderDef) / 50) + 2;
    double finalMinDamage = damageBase * stabMult * effectivenessMult * screenMult * 0.85;
    double finalMaxDamage = damageBase * stabMult * effectivenessMult * screenMult * 1.0;

    // Percentage of Defender HP
    double minPercent = (finalMinDamage / defenderMaxHp) * 100;
    double maxPercent = (finalMaxDamage / defenderMaxHp) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1vs1 Duel Arena Comparison Row
          Row(
            children: [
              // Attacker Left Section
              Expanded(
                child: Column(
                  children: [
                    const Text('ATTACKER (LEFT)', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 8),
                    _buildDropdownHeader('POKEMON'),
                    _buildCardWrapper(
                      isDark,
                      DropdownButtonHideUnderline(
                        child: DropdownButton<Pokemon>(
                          value: p1,
                          dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          isExpanded: true,
                          items: pokemonList.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (p) {
                            if (p != null) vm.setAttacker(p);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownHeader('SPEED TWEAK (EV)'),
                    _buildCardWrapper(
                      isDark,
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: state.attackerEvs['spe'] ?? 4,
                          dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          isExpanded: true,
                          items: [0, 4, 128, 252].map((spe) {
                            return DropdownMenuItem(
                              value: spe,
                              child: Text('EV: $spe (Speed: $attackerSpeed)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) vm.updateAttackerEv('spe', val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('VS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orangeAccent)),
              ),
              // Defender Right Section
              Expanded(
                child: Column(
                  children: [
                    const Text('DEFENDER (RIGHT)', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 8),
                    _buildDropdownHeader('POKEMON'),
                    _buildCardWrapper(
                      isDark,
                      DropdownButtonHideUnderline(
                        child: DropdownButton<Pokemon>(
                          value: p2,
                          dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          isExpanded: true,
                          items: pokemonList.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.name, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (p) {
                            if (p != null) vm.setDefender(p);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdownHeader('SPEED TWEAK (EV)'),
                    _buildCardWrapper(
                      isDark,
                      DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: state.defenderEvs['spe'] ?? 0,
                          dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                          isExpanded: true,
                          items: [0, 4, 128, 252].map((spe) {
                            return DropdownMenuItem(
                              value: spe,
                              child: Text('EV: $spe (Speed: $defenderSpeed)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 11)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) vm.updateDefenderEv('spe', val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Speed Duel Comparison Indicator Banner
          _buildCardWrapper(
            isDark,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  p1Outspeeds ? Icons.offline_bolt_rounded : Icons.warning_amber_rounded,
                  color: p1Outspeeds ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  p1Outspeeds
                      ? '${p1.name} (Speed: $attackerSpeed) OUTSPEEDS ${p2.name} (Speed: $defenderSpeed)!'
                      : '${p2.name} (Speed: $defenderSpeed) OUTSPEEDS ${p1.name} (Speed: $attackerSpeed)!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: p1Outspeeds ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attacker Active Damaging Move Dropdown
          _buildDropdownHeader('ATTACKER DAMAGING MOVE'),
          _buildCardWrapper(
            isDark,
            DropdownButtonHideUnderline(
              child: DropdownButton<Move>(
                value: activeMove,
                dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                isExpanded: true,
                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                items: p1Moves.map((m) {
                  return DropdownMenuItem<Move>(
                    value: m,
                    child: Text('${m.name} (${m.type.toUpperCase()} - BP: ${m.power})'),
                  );
                }).toList(),
                onChanged: (m) {
                  if (m != null) {
                    vm.selectMove(m.name, m.type, m.damageClass, m.power!.toDouble());
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Real-Time Damage Summary Display Card
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
                  const Text(
                    'CALCULATED DAMAGE RANGE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${finalMinDamage.toStringAsFixed(0)} - ${finalMaxDamage.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Percentage: ${minPercent.toStringAsFixed(1)}% - ${maxPercent.toStringAsFixed(1)}% of Defender\'s HP',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orangeAccent),
                  ),
                  const SizedBox(height: 12),
                  // Effectiveness Capsule Label
                  if (effectivenessMult != 1.0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: effectivenessMult > 1.0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: effectivenessMult > 1.0 ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        effectivenessMult > 1.0 ? 'Super Effective! (${effectivenessMult}x)' : 'Not Very Effective... (${effectivenessMult}x)',
                        style: TextStyle(
                          color: effectivenessMult > 1.0 ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Battle Battlefield Global Tweaks Section
          _buildDropdownHeader('BATTLEFIELD GLOBAL TWEAKS'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildSwitchListTile(
                  'Trick Room Active',
                  state.trickRoomActive,
                  vm.toggleTrickRoom,
                ),
                _buildSwitchListTile(
                  'Light Screen Active (Reduce Sp. Atk)',
                  state.lightScreenActive,
                  vm.toggleLightScreen,
                ),
                _buildSwitchListTile(
                  'Reflect Active (Reduce Phys Atk)',
                  state.reflectActive,
                  vm.toggleReflect,
                ),
              ],
            ),
          ),
        ],
      ),
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
}
