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

  // Active move selected for the Simple tab
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
      body: SafeArea(
        bottom: true,
        child: pokedexAsync.when(
          data: (allPokemons) {
            if (allPokemons.isNotEmpty) {
              if (state.attacker == null) {
                final defaultAttacker = allPokemons.firstWhere(
                  (p) => p.name.toLowerCase() == 'charizard',
                  orElse: () => allPokemons.first,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  vm.setAttacker(defaultAttacker);
                });
              }
              if (state.defender == null) {
                final defaultDefender = allPokemons.firstWhere(
                  (p) => p.name.toLowerCase() == 'blastoise',
                  orElse: () => allPokemons.first,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  vm.setDefender(defaultDefender);
                });
              }
            }

            // Sync and resolve real attacker damaging learned moves
            if (state.attacker != null) {
              final movesAsync = ref.watch(pokemonMovesStreamProvider(state.attacker!.id));
              movesAsync.whenData((moves) {
                // Filter out non-damaging status moves completely!
                final List<Map<String, dynamic>> damagingMoves = moves
                    .where((m) => (m['power'] ?? 0) > 0 && m['damageClass'] != 'status')
                    .toList();

                if (damagingMoves.isNotEmpty) {
                  final bool hasSelectedMove = damagingMoves.any((m) => m['name'] == state.selectedMoveName);
                  if (!hasSelectedMove) {
                    final defaultMove = damagingMoves.first;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      vm.selectMove(
                        defaultMove['name'],
                        defaultMove['type'] ?? 'normal',
                        defaultMove['damageClass'] ?? 'physical',
                        (defaultMove['power'] ?? 80).toDouble(),
                      );
                    });
                  }
                }
              });
            }

            if (state.attacker == null || state.defender == null) {
              return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildSimpleTab(isDark, primaryColor, state, vm),
                _buildDuelTab(isDark, primaryColor, allPokemons, state, vm),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
          ),
          error: (err, stack) => Center(
            child: Text('Error loading Pokedex: $err', style: TextStyle(color: primaryColor)),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: SIMPLE CALCULATOR (BASE POWER CHECK)
  // ==========================================
  Widget _buildSimpleTab(
    bool isDark,
    Color primaryColor,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
  ) {
    // Collect damaging moves (DB + fallback)
    final Set<String> seenNames = {};
    final List<Move> simpleMoves = [];
    for (var m in _dbDamagingMoves) {
      if (seenNames.add(m.name.toLowerCase())) {
        simpleMoves.add(m);
      }
    }
    for (var m in _fallbackMoves) {
      if (seenNames.add(m.name.toLowerCase())) {
        simpleMoves.add(m);
      }
    }
    simpleMoves.sort((a, b) => a.name.compareTo(b.name));

    // Calculate Adjusted Base Power
    double adjustedPower = _simpleSelectedMove.power?.toDouble() ?? 80.0;
    List<String> multipliersText = [];

    // Weather tweaks
    if (state.weather == 'sun' && _simpleSelectedMove.type.toLowerCase() == 'fire') {
      adjustedPower *= 1.5;
      multipliersText.add('Sun Boost (x1.5)');
    } else if (state.weather == 'sun' && _simpleSelectedMove.type.toLowerCase() == 'water') {
      adjustedPower *= 0.5;
      multipliersText.add('Sun Dampen (x0.5)');
    } else if (state.weather == 'rain' && _simpleSelectedMove.type.toLowerCase() == 'water') {
      adjustedPower *= 1.5;
      multipliersText.add('Rain Boost (x1.5)');
    } else if (state.weather == 'rain' && _simpleSelectedMove.type.toLowerCase() == 'fire') {
      adjustedPower *= 0.5;
      multipliersText.add('Rain Dampen (x0.5)');
    }

    // Terrain tweaks
    if (state.terrain == 'electric' && _simpleSelectedMove.type.toLowerCase() == 'electric') {
      adjustedPower *= 1.3;
      multipliersText.add('Electric Terrain (x1.3)');
    } else if (state.terrain == 'grassy' && _simpleSelectedMove.type.toLowerCase() == 'grass') {
      adjustedPower *= 1.3;
      multipliersText.add('Grassy Terrain (x1.3)');
    } else if (state.terrain == 'psychic' && _simpleSelectedMove.type.toLowerCase() == 'psychic') {
      adjustedPower *= 1.3;
      multipliersText.add('Psychic Terrain (x1.3)');
    } else if (state.terrain == 'misty' && _simpleSelectedMove.type.toLowerCase() == 'dragon') {
      adjustedPower *= 0.5;
      multipliersText.add('Misty Terrain (x0.5)');
    }

    // Helping Hand
    if (state.helpingHandActive) {
      adjustedPower *= 1.5;
      multipliersText.add('Helping Hand (x1.5)');
    }

    final Color moveColor = CombatUtils.typeColors[_simpleSelectedMove.type] ?? Colors.grey;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ADJUSTED BASE POWER (BP)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1.2),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      adjustedPower.round().toString(),
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: moveColor),
                    ),
                    const SizedBox(width: 4),
                    const Text('BP', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Original Power: ${_simpleSelectedMove.power} BP',
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                if (multipliersText.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: multipliersText.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: moveColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: moveColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: moveColor)),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('SELECT MOVE TO TEST'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Move', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Move>(
                      value: simpleMoves.any((m) => m.name == _simpleSelectedMove.name)
                          ? simpleMoves.firstWhere((m) => m.name == _simpleSelectedMove.name)
                          : simpleMoves.first,
                      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      isExpanded: true,
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                      items: simpleMoves.map((m) {
                        return DropdownMenuItem<Move>(
                          value: m,
                          child: Text('${m.name.toUpperCase()} (${m.type.toUpperCase()}, ${m.power} BP)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _simpleSelectedMove = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('WEATHER, TERRAIN & HELPING HAND'),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weather Condition', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['none', 'sun', 'rain', 'sandstorm', 'snow'].map((w) {
                    final bool isSel = state.weather == w;
                    return ChoiceChip(
                      label: Text(w.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey)),
                      selected: isSel,
                      selectedColor: AppTheme.pokemonRed,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                      onSelected: (selected) {
                        if (selected) vm.setWeather(w);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                const Text('Active Terrain', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['none', 'electric', 'grassy', 'psychic', 'misty'].map((t) {
                    final bool isSel = state.terrain == t;
                    return ChoiceChip(
                      label: Text(t.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey)),
                      selected: isSel,
                      selectedColor: Colors.purple,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                      onSelected: (selected) {
                        if (selected) vm.setTerrain(t);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _buildToggleRow('Helping Hand (1.5x Power Boost)', state.helpingHandActive, (val) => vm.toggleHelpingHand(val)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Switch(
          value: value,
          activeColor: AppTheme.pokemonRed,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: 1VS1 EPIC DUEL
  // ==========================================
  Widget _buildDuelTab(
    bool isDark,
    Color primaryColor,
    List<Pokemon> allPokemons,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
  ) {
    final movesAsync = ref.watch(pokemonMovesStreamProvider(state.attacker!.id));
    List<Map<String, dynamic>> attackerMoves = [];
    movesAsync.whenData((moves) {
      // Filter out non-damaging/status moves immediately!
      attackerMoves = moves
          .where((m) => (m['power'] ?? 0) > 0 && m['damageClass'] != 'status')
          .toList();
    });

    // Attacker Stats
    final int baseAtkVal = state.moveCategory == 'physical' ? state.attacker!.baseAtk : state.attacker!.baseSpAtk;
    final String attackStatName = state.moveCategory == 'physical' ? 'Attack' : 'Sp. Atk';
    final int rawAtk = StatCalculator.calculateOtherStat(
      base: baseAtkVal,
      iv: state.moveCategory == 'physical' ? (state.attackerIvs['atk'] ?? 31) : (state.attackerIvs['spa'] ?? 31),
      level: state.attackerLevel,
      ev: state.moveCategory == 'physical' ? (state.attackerEvs['atk'] ?? 0) : (state.attackerEvs['spa'] ?? 0),
      natureModifier: CombatUtils.getNatureMultiplier(state.attackerNature, attackStatName),
    );
    final double attackModifier = CombatUtils.getStageMultiplier(state.attackerStages[state.moveCategory == 'physical' ? 'atk' : 'spa'] ?? 0);
    final int finalAttackStat = (rawAtk * attackModifier).round();

    // Defender HP & Defense
    final int maxDefenderHp = StatCalculator.calculateHp(
      base: state.defender!.baseHp,
      iv: state.defenderIvs['hp'] ?? 31,
      ev: state.defenderEvs['hp'] ?? 0,
      level: state.defenderLevel,
      isShedinja: state.defender!.name.toLowerCase() == 'shedinja',
    );

    final int baseDefVal = state.moveCategory == 'physical' ? state.defender!.baseDef : state.defender!.baseSpDef;
    final String defenseStatName = state.moveCategory == 'physical' ? 'Defense' : 'Sp. Def';
    final int rawDef = StatCalculator.calculateOtherStat(
      base: baseDefVal,
      iv: state.moveCategory == 'physical' ? (state.defenderIvs['def'] ?? 31) : (state.defenderIvs['spd'] ?? 31),
      level: state.defenderLevel,
      ev: state.moveCategory == 'physical' ? (state.defenderEvs['def'] ?? 0) : (state.defenderEvs['spd'] ?? 0),
      natureModifier: CombatUtils.getNatureMultiplier(state.defenderNature, defenseStatName),
    );
    final double defenseModifier = CombatUtils.getStageMultiplier(state.defenderStages[state.moveCategory == 'physical' ? 'def' : 'spd'] ?? 0);
    final int finalDefenseStat = (rawDef * defenseModifier).round();

    // Active power adjustment
    double calculatedPower = state.movePower;
    if (state.weather == 'sun' && state.moveType == 'fire') {
      calculatedPower *= 1.5;
    } else if (state.weather == 'sun' && state.moveType == 'water') {
      calculatedPower *= 0.5;
    } else if (state.weather == 'rain' && state.moveType == 'water') {
      calculatedPower *= 1.5;
    } else if (state.weather == 'rain' && state.moveType == 'fire') {
      calculatedPower *= 0.5;
    }

    if (state.terrain == 'electric' && state.moveType == 'electric') {
      calculatedPower *= 1.3;
    } else if (state.terrain == 'grassy' && state.moveType == 'grass') {
      calculatedPower *= 1.3;
    } else if (state.terrain == 'psychic' && state.moveType == 'psychic') {
      calculatedPower *= 1.3;
    } else if (state.terrain == 'misty' && state.moveType == 'dragon') {
      calculatedPower *= 0.5;
    }

    double levelPart = (2.0 * state.attackerLevel / 5.0) + 2.0;
    double baseDmg = 0.0;
    if (finalDefenseStat > 0) {
      baseDmg = ((levelPart * calculatedPower * finalAttackStat / finalDefenseStat) / 50.0) + 2.0;
    }

    final bool actualStab = state.attacker!.type1.toLowerCase() == state.moveType.toLowerCase() ||
        (state.attacker!.type2?.toLowerCase() == state.moveType.toLowerCase());
    final double stabMultiplier = actualStab ? 1.5 : 1.0;
    final double typeMultiplier = CombatUtils.getTypeEffectiveness(state.moveType, state.defender!.type1, state.defender!.type2);

    double totalMultiplier = stabMultiplier * typeMultiplier;
    if (state.helpingHandActive) totalMultiplier *= 1.5;
    if (state.moveCategory == 'physical' && state.reflectActive) {
      totalMultiplier *= 0.5;
    } else if (state.moveCategory == 'special' && state.lightScreenActive) {
      totalMultiplier *= 0.5;
    }

    final double minDmg = baseDmg * 0.85 * totalMultiplier;
    final double maxDmg = baseDmg * 1.00 * totalMultiplier;

    final int minDamageRounded = minDmg.round();
    final int maxDamageRounded = maxDmg.round();

    double minDmgPercent = maxDefenderHp > 0 ? (minDamageRounded / maxDefenderHp) * 100.0 : 0.0;
    double maxDmgPercent = maxDefenderHp > 0 ? (maxDamageRounded / maxDefenderHp) * 100.0 : 0.0;

    String koForecast = 'No rapid KO chance';
    if (minDamageRounded >= maxDefenderHp) {
      koForecast = 'Guaranteed OHKO (100% KO chance)';
    } else if (maxDamageRounded >= maxDefenderHp) {
      int koRolls = 0;
      for (int i = 0; i < 16; i++) {
        final double rollMultiplier = 0.85 + (i * 0.01);
        final int dmgRoll = (baseDmg * rollMultiplier * totalMultiplier).round();
        if (dmgRoll >= maxDefenderHp) {
          koRolls++;
        }
      }
      final double koChance = (koRolls / 16.0) * 100.0;
      koForecast = '${koChance.toStringAsFixed(1)}% chance of OHKO';
    } else if ((minDamageRounded * 2) >= maxDefenderHp) {
      koForecast = 'Guaranteed 2HKO (100% KO in 2 turns)';
    } else if ((maxDamageRounded * 2) >= maxDefenderHp) {
      koForecast = 'Chance of 2HKO';
    } else if ((minDamageRounded * 3) >= maxDefenderHp) {
      koForecast = 'Guaranteed 3HKO';
    } else {
      koForecast = 'Guaranteed 4HKO or more';
    }

    // Speeds
    final int attackerBaseSpeed = StatCalculator.calculateOtherStat(
      base: state.attacker!.baseSpd,
      iv: state.attackerIvs['spe'] ?? 31,
      ev: state.attackerEvs['spe'] ?? 0,
      level: state.attackerLevel,
      natureModifier: CombatUtils.getNatureMultiplier(state.attackerNature, 'Speed'),
    );
    final double attackerSpeModifier = CombatUtils.getStageMultiplier(state.attackerStages['spe'] ?? 0);
    final int finalAttackerSpeed = (attackerBaseSpeed * attackerSpeModifier).round();

    final int defenderBaseSpeed = StatCalculator.calculateOtherStat(
      base: state.defender!.baseSpd,
      iv: state.defenderIvs['spe'] ?? 31,
      ev: state.defenderEvs['spe'] ?? 0,
      level: state.defenderLevel,
      natureModifier: CombatUtils.getNatureMultiplier(state.defenderNature, 'Speed'),
    );
    final double defenderSpeModifier = CombatUtils.getStageMultiplier(state.defenderStages['spe'] ?? 0);
    final int finalDefenderSpeed = (defenderBaseSpeed * defenderSpeModifier).round();

    bool attackerMovesFirst = finalAttackerSpeed >= finalDefenderSpeed;
    if (state.trickRoomActive) {
      attackerMovesFirst = finalAttackerSpeed <= finalDefenderSpeed;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildCombatantCard(
                    context: context,
                    allPokemons: allPokemons,
                    pokemon: state.attacker!,
                    level: state.attackerLevel,
                    isAttacker: true,
                    isDark: isDark,
                    attackerMoves: attackerMoves,
                    state: state,
                    vm: vm,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.pokemonRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.pokemonRed.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('VS', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                ),
                Expanded(
                  child: _buildCombatantCard(
                    context: context,
                    allPokemons: allPokemons,
                    pokemon: state.defender!,
                    level: state.defenderLevel,
                    isAttacker: false,
                    isDark: isDark,
                    attackerMoves: attackerMoves,
                    state: state,
                    vm: vm,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DUEL DAMAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    _buildTypeBadgeMini(state.moveType),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: attackerMoves.any((m) => m['name'] == state.selectedMoveName)
                          ? state.selectedMoveName
                          : (attackerMoves.isNotEmpty ? attackerMoves.first['name'] : null),
                      dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      isExpanded: true,
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                      items: attackerMoves.map((m) {
                        final String name = m['name'] ?? 'Unknown Move';
                        final String type = m['type'] ?? 'normal';
                        final int? bp = m['power'];
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text('$name (${type.toUpperCase()}, ${bp ?? 0} BP)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final selected = attackerMoves.firstWhere((m) => m['name'] == val);
                          vm.selectMove(
                            val,
                            selected['type'] ?? 'normal',
                            selected['damageClass'] ?? 'physical',
                            (selected['power'] ?? 0).toDouble(),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildDynamicHpBar(maxDefenderHp, minDamageRounded, maxDamageRounded, isDark),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Damage Range', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '$minDamageRounded - $maxDamageRounded HP',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Percentage', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          '${minDmgPercent.toStringAsFixed(1)}% - ${maxDmgPercent.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24, color: Colors.grey),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        koForecast,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WEATHER & BATTLEFIELD TWEAKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                
                const Text('Weather', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['none', 'sun', 'rain', 'sandstorm', 'snow'].map((w) {
                    final bool isSel = state.weather == w;
                    return ChoiceChip(
                      label: Text(w.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey)),
                      selected: isSel,
                      selectedColor: AppTheme.pokemonRed,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                      onSelected: (selected) {
                        if (selected) vm.setWeather(w);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                const Text('Terrain', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['none', 'electric', 'grassy', 'psychic', 'misty'].map((t) {
                    final bool isSel = state.terrain == t;
                    return ChoiceChip(
                      label: Text(t.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey)),
                      selected: isSel,
                      selectedColor: Colors.purple,
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                      onSelected: (selected) {
                        if (selected) vm.setTerrain(t);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                _buildToggleRow('Reflect (Halve Physical Damage)', state.reflectActive, (val) => vm.toggleReflect(val)),
                _buildToggleRow('Light Screen (Halve Special Damage)', state.lightScreenActive, (val) => vm.toggleLightScreen(val)),
                _buildToggleRow('Helping Hand (1.5x Power Boost)', state.helpingHandActive, (val) => vm.toggleHelpingHand(val)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SPEED CONTROL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Row(
                      children: [
                        const Text('Trick Room', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple)),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 24,
                          child: Switch(
                            value: state.trickRoomActive,
                            activeColor: Colors.purple,
                            onChanged: (val) => vm.toggleTrickRoom(val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSpeedCol('Attacker Speed', finalAttackerSpeed.toString(), const Color(0xFF30A7D7)),
                    const Icon(Icons.compare_arrows_rounded, color: Colors.grey, size: 20),
                    _buildSpeedCol('Defender Speed', finalDefenderSpeed.toString(), const Color(0xFFF7D02C)),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: attackerMovesFirst ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: attackerMovesFirst ? Colors.blue.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        attackerMovesFirst ? Icons.arrow_circle_right : Icons.arrow_circle_left,
                        color: attackerMovesFirst ? Colors.blue : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        attackerMovesFirst ? 'Attacker moves first!' : 'Defender moves first!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: attackerMovesFirst ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildCombatantCard({
    required BuildContext context,
    required List<Pokemon> allPokemons,
    required Pokemon pokemon,
    required int level,
    required bool isAttacker,
    required bool isDark,
    required List<Map<String, dynamic>> attackerMoves,
    required DamageCalculatorState state,
    required DamageCalculatorViewModel vm,
  }) {
    final String pName = pokemon.name.toUpperCase();
    final Color badgeColor = isAttacker ? AppTheme.pokemonBlue : Colors.grey;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E7EB)),
          ),
          alignment: Alignment.center,
          child: pokemon.spriteUrl.isNotEmpty
              ? Image.network(
                  pokemon.spriteUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.catching_pokemon, size: 36, color: badgeColor);
                  },
                )
              : Icon(Icons.catching_pokemon, size: 36, color: badgeColor),
        ),
        const SizedBox(height: 8),
        Text(
          pName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          'Lvl $level',
          style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _openAdjustmentBottomSheet(context, allPokemons, isAttacker, attackerMoves, state, vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE2E8F0),
            foregroundColor: isDark ? Colors.white : Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            minimumSize: const Size(0, 26),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Adjust', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDynamicHpBar(int maxHp, int minDmg, int maxDmg, bool isDark) {
    if (maxHp <= 0) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double remainMaxFraction = ((maxHp - maxDmg).clamp(0, maxHp) / maxHp).toDouble();
        final double remainMinFraction = ((maxHp - minDmg).clamp(0, maxHp) / maxHp).toDouble();

        Color hpColor = Colors.green;
        final double currentHpFraction = remainMinFraction;
        if (currentHpFraction <= 0.2) {
          hpColor = Colors.red;
        } else if (currentHpFraction <= 0.5) {
          hpColor = Colors.amber;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 16,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 16,
                  width: barWidth * remainMaxFraction,
                  decoration: BoxDecoration(
                    color: hpColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Positioned(
                  left: barWidth * remainMaxFraction,
                  child: Container(
                    height: 16,
                    width: (barWidth * (remainMinFraction - remainMaxFraction)).clamp(0, barWidth),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Max HP: $maxHp', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  'Remaining: ${(remainMinFraction * 100).round()}% ~ ${(remainMaxFraction * 100).round()}%',
                  style: TextStyle(fontSize: 10, color: hpColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _openAdjustmentBottomSheet(
    BuildContext context,
    List<Pokemon> allPokemons,
    bool isAttacker,
    List<Map<String, dynamic>> attackerMoves,
    DamageCalculatorState state,
    DamageCalculatorViewModel vm,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryColor = isDark ? Colors.white : Colors.black;

            return StatefulBuilder(
              builder: (context, setStateModal) {
                final Pokemon currentPokemon = isAttacker ? state.attacker! : state.defender!;
                final int currentLevel = isAttacker ? state.attackerLevel : state.defenderLevel;
                final String currentNature = isAttacker ? state.attackerNature : state.defenderNature;
                final Map<String, int> ivMap = isAttacker ? state.attackerIvs : state.defenderIvs;
                final Map<String, int> evMap = isAttacker ? state.attackerEvs : state.defenderEvs;
                final Map<String, int> stageMap = isAttacker ? state.attackerStages : state.defenderStages;

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            Text(
                              isAttacker ? 'ADJUST ATTACKER' : 'ADJUST DEFENDER',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryColor),
                            ),
                            const SizedBox(height: 16),

                            const Text('Select Pokémon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Pokemon>(
                                  value: allPokemons.any((p) => p.id == currentPokemon.id)
                                      ? allPokemons.firstWhere((p) => p.id == currentPokemon.id)
                                      : allPokemons.first,
                                  dropdownColor: isDark ? const Color(0xFF121212) : Colors.white,
                                  isExpanded: true,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                  items: allPokemons.map((p) {
                                    return DropdownMenuItem<Pokemon>(
                                      value: p,
                                      child: Text(p.name.toUpperCase()),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      if (isAttacker) {
                                        vm.setAttacker(val);
                                      } else {
                                        vm.setDefender(val);
                                      }
                                      setStateModal(() {});
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Level', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    Text('$currentLevel', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.pokemonRed)),
                                  ],
                                ),
                                Slider(
                                  value: currentLevel.toDouble(),
                                  min: 1,
                                  max: 100,
                                  activeColor: AppTheme.pokemonRed,
                                  onChanged: (val) {
                                    if (isAttacker) {
                                      vm.updateAttackerLevel(val.round());
                                    } else {
                                      vm.updateDefenderLevel(val.round());
                                    }
                                    setStateModal(() {});
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (isAttacker) ...[
                              _buildSectionHeader('ACTIVE MOVE SELECTION'),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Choose Learned Move', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: attackerMoves.any((m) => m['name'] == state.selectedMoveName)
                                              ? state.selectedMoveName
                                              : (attackerMoves.isNotEmpty ? attackerMoves.first['name'] : null),
                                          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                          isExpanded: true,
                                          items: attackerMoves.map((m) {
                                            final String name = m['name'] ?? 'Unknown Move';
                                            final String type = m['type'] ?? 'normal';
                                            final int? bp = m['power'];
                                            return DropdownMenuItem<String>(
                                              value: name,
                                              child: Text('$name (${type.toUpperCase()}, ${bp ?? 0} BP)'),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              final selected = attackerMoves.firstWhere((m) => m['name'] == val);
                                              vm.selectMove(
                                                val,
                                                selected['type'] ?? 'normal',
                                                selected['damageClass'] ?? 'physical',
                                                (selected['power'] ?? 0).toDouble(),
                                              );
                                              setStateModal(() {});
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const Divider(height: 24),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Move Type Override', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              DropdownButton<String>(
                                                value: state.moveType,
                                                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                                isExpanded: true,
                                                items: CombatUtils.allTypes.map((t) {
                                                  return DropdownMenuItem<String>(
                                                    value: t,
                                                    child: Text(t.toUpperCase(), style: TextStyle(color: CombatUtils.typeColors[t], fontSize: 12)),
                                                  );
                                                }).toList(),
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    vm.updateMoveType(val);
                                                    setStateModal(() {});
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Category Override', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              DropdownButton<String>(
                                                value: state.moveCategory,
                                                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                                style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                                isExpanded: true,
                                                items: const [
                                                  DropdownMenuItem(value: 'physical', child: Text('PHYSICAL', style: TextStyle(fontSize: 12))),
                                                  DropdownMenuItem(value: 'special', child: Text('SPECIAL', style: TextStyle(fontSize: 12))),
                                                ],
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    vm.updateMoveCategory(val);
                                                    setStateModal(() {});
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Base Power (BP)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                        Text('${state.movePower.round()}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                                      ],
                                    ),
                                    Slider(
                                      value: state.movePower.clamp(10, 150),
                                      min: 10,
                                      max: 150,
                                      activeColor: CombatUtils.typeColors[state.moveType],
                                      onChanged: (val) {
                                        vm.updateMovePower(val.roundToDouble());
                                        setStateModal(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            _buildSectionHeader('STAT STAGE MODIFIERS'),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  _buildStageRow('Attack (Atk)', 'atk', stageMap, isAttacker, vm, setStateModal),
                                  _buildStageRow('Defense (Def)', 'def', stageMap, isAttacker, vm, setStateModal),
                                  _buildStageRow('Sp. Atk (SpA)', 'spa', stageMap, isAttacker, vm, setStateModal),
                                  _buildStageRow('Sp. Def (SpD)', 'spd', stageMap, isAttacker, vm, setStateModal),
                                  _buildStageRow('Speed (Spe)', 'spe', stageMap, isAttacker, vm, setStateModal),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildSectionHeader('BASE STATS & NATURE'),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF141414) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Nature', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      DropdownButton<String>(
                                        value: currentNature,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                                        items: const [
                                          DropdownMenuItem(value: 'serious', child: Text('Serious (Neutral)')),
                                          DropdownMenuItem(value: 'adamant', child: Text('Adamant (+Atk, -SpA)')),
                                          DropdownMenuItem(value: 'bold', child: Text('Bold (+Def, -Atk)')),
                                          DropdownMenuItem(value: 'timid', child: Text('Timid (+Spe, -Atk)')),
                                          DropdownMenuItem(value: 'modest', child: Text('Modest (+SpA, -Atk)')),
                                          DropdownMenuItem(value: 'jolly', child: Text('Jolly (+Spe, -SpA)')),
                                          DropdownMenuItem(value: 'calm', child: Text('Calm (+SpD, -Atk)')),
                                          DropdownMenuItem(value: 'careful', child: Text('Careful (+SpD, -SpA)')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            if (isAttacker) {
                                              vm.updateAttackerNature(val);
                                            } else {
                                              vm.updateDefenderNature(val);
                                            }
                                            setStateModal(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  _buildStatDetailRow('HP', currentPokemon.baseHp, 'hp', ivMap, evMap, isAttacker, vm, setStateModal),
                                  _buildStatDetailRow('Attack', currentPokemon.baseAtk, 'atk', ivMap, evMap, isAttacker, vm, setStateModal),
                                  _buildStatDetailRow('Defense', currentPokemon.baseDef, 'def', ivMap, evMap, isAttacker, vm, setStateModal),
                                  _buildStatDetailRow('Sp. Atk', currentPokemon.baseSpAtk, 'spa', ivMap, evMap, isAttacker, vm, setStateModal),
                                  _buildStatDetailRow('Sp. Def', currentPokemon.baseSpDef, 'spd', ivMap, evMap, isAttacker, vm, setStateModal),
                                  _buildStatDetailRow('Speed', currentPokemon.baseSpd, 'spe', ivMap, evMap, isAttacker, vm, setStateModal),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStageRow(
    String label,
    String statKey,
    Map<String, int> stageMap,
    bool isAttacker,
    DamageCalculatorViewModel vm,
    StateSetter setStateModal,
  ) {
    final int currentVal = stageMap[statKey] ?? 0;
    Color badgeColor = Colors.grey;
    if (currentVal > 0) {
      badgeColor = Colors.green;
    } else if (currentVal < 0) {
      badgeColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () {
                  if (currentVal > -6) {
                    if (isAttacker) {
                      vm.updateAttackerStage(statKey, currentVal - 1);
                    } else {
                      vm.updateDefenderStage(statKey, currentVal - 1);
                    }
                    setStateModal(() {});
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor, width: 1),
                ),
                child: Text(
                  currentVal >= 0 ? '+$currentVal' : '$currentVal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: badgeColor),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () {
                  if (currentVal < 6) {
                    if (isAttacker) {
                      vm.updateAttackerStage(statKey, currentVal + 1);
                    } else {
                      vm.updateDefenderStage(statKey, currentVal + 1);
                    }
                    setStateModal(() {});
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetailRow(
    String label,
    int baseVal,
    String statKey,
    Map<String, int> ivMap,
    Map<String, int> evMap,
    bool isAttacker,
    DamageCalculatorViewModel vm,
    StateSetter setStateModal,
  ) {
    final int iv = ivMap[statKey] ?? 31;
    final int ev = evMap[statKey] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text('$label: $baseVal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Text('IV: ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Expanded(
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: iv,
                        style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
                        items: [0, 15, 31].map((val) {
                          return DropdownMenuItem<int>(value: val, child: Text(val.toString()));
                        }).toList(),
                        onChanged: (newIv) {
                          if (newIv != null) {
                            if (isAttacker) {
                              vm.updateAttackerIv(statKey, newIv);
                            } else {
                              vm.updateDefenderIv(statKey, newIv);
                            }
                            setStateModal(() {});
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const Text('EV: ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Expanded(
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: ev,
                        style: const TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                        items: [0, 4, 85, 252].map((val) {
                          return DropdownMenuItem<int>(value: val, child: Text(val.toString()));
                        }).toList(),
                        onChanged: (newEv) {
                          if (newEv != null) {
                            if (isAttacker) {
                              vm.updateAttackerEv(statKey, newEv);
                            } else {
                              vm.updateDefenderEv(statKey, newEv);
                            }
                            setStateModal(() {});
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildTypeBadgeMini(String type) {
    final Color col = CombatUtils.typeColors[type] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: col, width: 1),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
