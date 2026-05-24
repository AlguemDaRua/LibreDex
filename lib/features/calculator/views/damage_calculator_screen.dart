import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';
import 'package:libredex/core/widgets/app_drawer.dart';

class DamageCalculatorScreen extends ConsumerStatefulWidget {
  const DamageCalculatorScreen({super.key});

  @override
  ConsumerState<DamageCalculatorScreen> createState() => _DamageCalculatorScreenState();
}

class _DamageCalculatorScreenState extends ConsumerState<DamageCalculatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Selected Attacker & Defender
  Pokemon? _attacker;
  Pokemon? _defender;

  // Active Move
  Map<String, dynamic>? _calcSelectedMove;

  // Attacker Options
  String _calcAttackerItem = 'None';
  String _calcAttackerAbility = 'None';
  String _calcWeather = 'None';
  String _calcTerrain = 'None';
  bool _calcAttackerBurned = false;
  bool _calcCriticalHit = false;
  bool _calcDoubleBattle = false;

  // Defender/Target Configuration
  int _calcDefenderLevel = 100;
  String _calcDefenderNature = 'serious';
  String _calcDefenderItem = 'None';
  final Map<String, int> _calcDefenderIvs = {'hp': 31, 'def': 31, 'spd': 31};
  final Map<String, int> _calcDefenderEvs = {'hp': 0, 'def': 0, 'spd': 0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

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
          tabs: const [
            Tab(text: 'NORMAL (BASIC)', icon: Icon(Icons.flash_on_outlined, size: 20)),
            Tab(text: 'ADVANCED (SHOWDOWN)', icon: Icon(Icons.calculate_outlined, size: 20)),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: 'calculator'),
      body: SafeArea(
        bottom: true,
        child: pokedexAsync.when(
          data: (allPokemons) {
            // Set defaults if null
            if (_attacker == null && allPokemons.isNotEmpty) {
              // Try to find Charizard as default attacker
              _attacker = allPokemons.firstWhere(
                (p) => p.name.toLowerCase() == 'charizard',
                orElse: () => allPokemons.first,
              );
            }
            if (_defender == null && allPokemons.isNotEmpty) {
              // Try to find Blastoise as default defender
              _defender = allPokemons.firstWhere(
                (p) => p.name.toLowerCase() == 'blastoise',
                orElse: () => allPokemons.first,
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildNormalTab(isDark, primaryColor, allPokemons),
                _buildAdvancedTab(isDark, primaryColor, allPokemons),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
          ),
          error: (err, stack) => Center(
            child: Text('Error loading Pokédex database: $err', style: TextStyle(color: primaryColor)),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: NORMAL (BASIC) CONDITIONS MODE
  // ==========================================
  Widget _buildNormalTab(bool isDark, Color primaryColor, List<Pokemon> allPokemons) {
    if (_attacker == null) return const SizedBox();

    final movesAsync = ref.watch(pokemonMovesStreamProvider(_attacker!.id));
    final abilitiesAsync = ref.watch(pokemonAbilitiesStreamProvider(_attacker!.id));

    return movesAsync.when(
      data: (movesList) {
        final movesWithPower = movesList.where((m) => (m['power'] ?? 0) > 0).toList();
        final displayMoves = movesWithPower.isNotEmpty ? movesWithPower : movesList;
        if (_calcSelectedMove == null && displayMoves.isNotEmpty) {
          _calcSelectedMove = displayMoves.first;
        }

        // Check if selected move is in this attacker's learned list
        final bool moveFound = displayMoves.any((m) => m['name'] == _calcSelectedMove?['name']);
        if (!moveFound && displayMoves.isNotEmpty) {
          _calcSelectedMove = displayMoves.first;
        }

        return abilitiesAsync.when(
          data: (abilitiesList) {
            final activeAbilities = ['None'] + abilitiesList.map((a) => a['name'].toString()).toList();
            if (_calcAttackerAbility == 'None' && abilitiesList.isNotEmpty) {
              _calcAttackerAbility = abilitiesList.first['name'].toString();
            }

            final double basePower = (_calcSelectedMove?['power'] ?? 0).toDouble();
            final String moveType = (_calcSelectedMove?['type'] ?? 'normal').toString().toLowerCase();
            final String moveName = (_calcSelectedMove?['name'] ?? 'Pound').toString().toLowerCase();

            // Calculate modified base power
            double modifiedPower = basePower;
            List<String> activeEffects = [];

            // Terrain modifiers
            if (_calcTerrain == 'Electric' && moveType == 'electric') {
              modifiedPower *= 1.3;
              activeEffects.add('Electric Terrain boosts Electric moves by 1.3x.');
            } else if (_calcTerrain == 'Grassy' && moveType == 'grass') {
              modifiedPower *= 1.3;
              activeEffects.add('Grassy Terrain boosts Grass moves by 1.3x.');
            } else if (_calcTerrain == 'Psychic' && moveType == 'psychic') {
              modifiedPower *= 1.3;
              activeEffects.add('Psychic Terrain boosts Psychic moves by 1.3x.');
            } else if (_calcTerrain == 'Misty' && moveType == 'dragon') {
              modifiedPower *= 0.5;
              activeEffects.add('Misty Terrain halves Dragon-type move power.');
            }

            // Ability multipliers
            if (_calcAttackerAbility == 'Overgrow' && moveType == 'grass') {
              modifiedPower *= 1.5;
              activeEffects.add('Overgrow boosts Grass-type moves by 1.5x at low HP.');
            } else if (_calcAttackerAbility == 'Torrent' && moveType == 'water') {
              modifiedPower *= 1.5;
              activeEffects.add('Torrent boosts Water-type moves by 1.5x at low HP.');
            } else if (_calcAttackerAbility == 'Blaze' && moveType == 'fire') {
              modifiedPower *= 1.5;
              activeEffects.add('Blaze boosts Fire-type moves by 1.5x at low HP.');
            } else if (_calcAttackerAbility == 'Swarm' && moveType == 'bug') {
              modifiedPower *= 1.5;
              activeEffects.add('Swarm boosts Bug-type moves by 1.5x at low HP.');
            } else if (_calcAttackerAbility == 'Technician' && basePower > 0 && basePower <= 60) {
              modifiedPower *= 1.5;
              activeEffects.add('Technician boosts base power of moves <= 60 BP by 1.5x.');
            }

            // Weather rules
            if (_calcWeather == 'Sun') {
              if (moveType == 'fire') {
                modifiedPower *= 1.5;
                activeEffects.add('Harsh Sunlight boosts Fire moves by 1.5x.');
              } else if (moveType == 'water') {
                modifiedPower *= 0.5;
                activeEffects.add('Harsh Sunlight halves Water move damage (0.5x).');
              }
            } else if (_calcWeather == 'Rain') {
              if (moveType == 'water') {
                modifiedPower *= 1.5;
                activeEffects.add('Rain Dance boosts Water moves by 1.5x.');
              } else if (moveType == 'fire') {
                modifiedPower *= 0.5;
                activeEffects.add('Rain Dance halves Fire move damage (0.5x).');
              }
            }

            // Specific moves condition checks
            if (moveName == 'aurora veil') {
              if (_calcWeather == 'Snow') {
                activeEffects.add('Aurora Veil is ACTIVE (halves all incoming physical & special damage for 5 turns).');
              } else {
                activeEffects.add('Aurora Veil FAILS (Requires active Snow weather).');
              }
            }
            if (moveName == 'blizzard') {
              if (_calcWeather == 'Snow') {
                activeEffects.add('Blizzard has 100% ACCURACY under active Snow weather.');
              }
            }
            if (moveName == 'hurricane' || moveName == 'thunder') {
              if (_calcWeather == 'Rain') {
                activeEffects.add('${_calcSelectedMove?['name']} has 100% ACCURACY under Rain.');
              } else if (_calcWeather == 'Sun') {
                activeEffects.add('${_calcSelectedMove?['name']} accuracy drops to 50% under harsh Sunlight.');
              }
            }
            if (moveName == 'solar beam') {
              if (_calcWeather == 'Sun') {
                activeEffects.add('Solar Beam fires instantly in 1 turn without requiring a charging turn.');
              } else if (_calcWeather == 'Rain' || _calcWeather == 'Sandstorm' || _calcWeather == 'Snow') {
                modifiedPower *= 0.5;
                activeEffects.add('Solar Beam\'s base power is halved (60 BP) under inclement weather conditions.');
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attacker & Move selector
                  _buildSectionHeader('ATTACKER & ACTIVE MOVE', Icons.flash_on_outlined),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Attacker selection button
                        const Text('Attacker Pokémon', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          tileColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                          leading: CircleAvatar(
                            backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                            child: Text(
                              _attacker!.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ),
                          title: Text(
                            _attacker!.name.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              _buildBadgeMini(_attacker!.type1),
                              if (_attacker!.type2 != null) ...[
                                const SizedBox(width: 4),
                                _buildBadgeMini(_attacker!.type2!),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          onTap: () => _showPokemonSelectionSheet(context, allPokemons, true),
                        ),
                        const SizedBox(height: 16),

                        // Move Dropdown
                        const Text('Active Attack Move', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Map<String, dynamic>>(
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              value: _calcSelectedMove,
                              items: displayMoves.map((m) {
                                final int powerVal = m['power'] ?? 0;
                                final String categoryStr = (m['damage_class'] ?? 'Status').toString();
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: m,
                                  child: Text(
                                    '${m['name'].toString().toUpperCase()} (Power: $powerVal, $categoryStr)',
                                    style: TextStyle(fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _calcSelectedMove = val;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ability and Item Rows
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Attacker Ability', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        value: _calcAttackerAbility,
                                        items: activeAbilities.map((a) {
                                          return DropdownMenuItem<String>(
                                            value: a,
                                            child: Text(a, style: TextStyle(fontSize: 12, color: primaryColor)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _calcAttackerAbility = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Attacker Item', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        value: _calcAttackerItem,
                                        items: ['None', 'Choice Band', 'Choice Specs', 'Life Orb', 'Expert Belt'].map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item, style: TextStyle(fontSize: 12, color: primaryColor)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _calcAttackerItem = val;
                                            });
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weather condition chips
                  _buildWeatherChips(isDark),
                  const SizedBox(height: 20),

                  // Terrain condition chips
                  _buildTerrainChips(isDark),
                  const SizedBox(height: 24),

                  // Results & calculations output
                  _buildSectionHeader('CALCULATED POWER & BEHAVIOR', Icons.analytics_outlined),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Base Move Power:',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                            ),
                            Text(
                              '${basePower.toInt()} BP',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Final Power after multipliers:',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                            ),
                            Text(
                              '${modifiedPower.round()} BP',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.pokemonRed),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Displays specific text warnings/boosts if active
                  if (activeEffects.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...activeEffects.map((effect) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F2625) : const Color(0xFFE6F4F1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF1B4D49) : const Color(0xFFBFE0DC)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: isDark ? Colors.tealAccent : Colors.teal[800], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                effect,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? Colors.grey[200] : Colors.teal[900],
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
          error: (err, stack) => Center(child: Text('Error fetching abilities: $err', style: TextStyle(color: primaryColor))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
      error: (err, stack) => Center(child: Text('Error loading attacker moves: $err', style: TextStyle(color: primaryColor))),
    );
  }

  // ==========================================
  // TAB 2: ADVANCED SHOWDOWN CALCULATOR MODE
  // ==========================================
  Widget _buildAdvancedTab(bool isDark, Color primaryColor, List<Pokemon> allPokemons) {
    if (_attacker == null || _defender == null) return const SizedBox();

    final statsState = ref.watch(statsCalculatorProvider);
    final statsNotifier = ref.read(statsCalculatorProvider.notifier);
    final calculatedStats = statsNotifier.getCalculatedStats(_attacker!);

    final movesAsync = ref.watch(pokemonMovesStreamProvider(_attacker!.id));
    final abilitiesAsync = ref.watch(pokemonAbilitiesStreamProvider(_attacker!.id));

    return movesAsync.when(
      data: (movesList) {
        final movesWithPower = movesList.where((m) => (m['power'] ?? 0) > 0).toList();
        final displayMoves = movesWithPower.isNotEmpty ? movesWithPower : movesList;
        if (_calcSelectedMove == null && displayMoves.isNotEmpty) {
          _calcSelectedMove = displayMoves.first;
        }

        // Check if selected move is in this attacker's learned list
        final bool moveFound = displayMoves.any((m) => m['name'] == _calcSelectedMove?['name']);
        if (!moveFound && displayMoves.isNotEmpty) {
          _calcSelectedMove = displayMoves.first;
        }

        return abilitiesAsync.when(
          data: (abilitiesList) {
            final activeAbilities = ['None'] + abilitiesList.map((a) => a['name'].toString()).toList();
            if (_calcAttackerAbility == 'None' && abilitiesList.isNotEmpty) {
              _calcAttackerAbility = abilitiesList.first['name'].toString();
            }

            // --- MATH ENGINE CALCULATIONS ---
            final int attackerLevel = statsState.level;
            final String moveCategory = (_calcSelectedMove?['damage_class'] ?? 'physical').toString().toLowerCase();
            final String moveType = (_calcSelectedMove?['type'] ?? 'normal').toString().toLowerCase();
            final double basePower = (_calcSelectedMove?['power'] ?? 0).toDouble();

            // Attacker Stats
            int activeAttackingStat = 100;
            if (moveCategory == 'physical') {
              activeAttackingStat = calculatedStats['atk'] ?? 100;
              if (_calcAttackerItem == 'Choice Band') {
                activeAttackingStat = (activeAttackingStat * 1.5).round();
              }
            } else if (moveCategory == 'special') {
              activeAttackingStat = calculatedStats['spa'] ?? 100;
              if (_calcAttackerItem == 'Choice Specs') {
                activeAttackingStat = (activeAttackingStat * 1.5).round();
              }
            }

            // Power modifiers
            double modifiedPower = basePower;
            if (_calcTerrain == 'Electric' && moveType == 'electric') {
              modifiedPower *= 1.3;
            } else if (_calcTerrain == 'Grassy' && moveType == 'grass') {
              modifiedPower *= 1.3;
            } else if (_calcTerrain == 'Psychic' && moveType == 'psychic') {
              modifiedPower *= 1.3;
            } else if (_calcTerrain == 'Misty' && moveType == 'dragon') {
              modifiedPower *= 0.5;
            }

            if (_calcAttackerAbility == 'Overgrow' && moveType == 'grass') {
              modifiedPower *= 1.5;
            } else if (_calcAttackerAbility == 'Torrent' && moveType == 'water') {
              modifiedPower *= 1.5;
            } else if (_calcAttackerAbility == 'Blaze' && moveType == 'fire') {
              modifiedPower *= 1.5;
            } else if (_calcAttackerAbility == 'Swarm' && moveType == 'bug') {
              modifiedPower *= 1.5;
            } else if (_calcAttackerAbility == 'Technician' && basePower > 0 && basePower <= 60) {
              modifiedPower *= 1.5;
            }

            // Defender HP and Defensive Stats
            int defenderHP = StatCalculator.calculateHp(
              base: _defender!.baseHp,
              iv: _calcDefenderIvs['hp'] ?? 31,
              ev: _calcDefenderEvs['hp'] ?? 0,
              level: _calcDefenderLevel,
              isShedinja: _defender!.name.toLowerCase() == 'shedinja',
            );

            double getDefenderNatureModifier(String statName) {
              return statsNotifier.getNatureMultiplier(_calcDefenderNature, statName);
            }

            int activeDefendingStat = 100;
            if (moveCategory == 'physical') {
              activeDefendingStat = StatCalculator.calculateOtherStat(
                base: _defender!.baseDef,
                iv: _calcDefenderIvs['def'] ?? 31,
                ev: _calcDefenderEvs['def'] ?? 0,
                level: _calcDefenderLevel,
                natureModifier: getDefenderNatureModifier('Defense'),
              );
              if (_calcDefenderItem == 'Eviolite') {
                activeDefendingStat = (activeDefendingStat * 1.5).round();
              }
            } else if (moveCategory == 'special') {
              activeDefendingStat = StatCalculator.calculateOtherStat(
                base: _defender!.baseSpDef,
                iv: _calcDefenderIvs['spd'] ?? 31,
                ev: _calcDefenderEvs['spd'] ?? 0,
                level: _calcDefenderLevel,
                natureModifier: getDefenderNatureModifier('Sp. Def'),
              );
              if (_calcDefenderItem == 'Assault Vest' || _calcDefenderItem == 'Eviolite') {
                activeDefendingStat = (activeDefendingStat * 1.5).round();
              }
            }

            // Final multipliers
            double multiplier = 1.0;
            if (_calcWeather == 'Sun') {
              if (moveType == 'fire') multiplier *= 1.5;
              if (moveType == 'water') multiplier *= 0.5;
            } else if (_calcWeather == 'Rain') {
              if (moveType == 'water') multiplier *= 1.5;
              if (moveType == 'fire') multiplier *= 0.5;
            }

            if (_calcCriticalHit) multiplier *= 1.5;
            if (_calcDoubleBattle) multiplier *= 0.75;
            if (_calcAttackerBurned && moveCategory == 'physical') multiplier *= 0.5;

            final bool isStab = (_attacker!.type1.toLowerCase() == moveType ||
                (_attacker!.type2?.toLowerCase() == moveType));
            if (isStab) {
              if (_calcAttackerAbility == 'Adaptability') {
                multiplier *= 2.0;
              } else {
                multiplier *= 1.5;
              }
            }

            if (_calcAttackerItem == 'Life Orb') {
              multiplier *= 1.3;
            }

            double typeEffectiveness = _getTypeEffectiveness(moveType, _defender!.type1, _defender!.type2);
            multiplier *= typeEffectiveness;

            if (_calcAttackerItem == 'Expert Belt' && typeEffectiveness > 1.0) {
              multiplier *= 1.2;
            }

            // Final damage min/max ranges
            double minDamage = 0.0;
            double maxDamage = 0.0;
            if (modifiedPower > 0) {
              final double levelPart = (2.0 * attackerLevel / 5.0) + 2.0;
              final double baseDamage = ((levelPart * modifiedPower * activeAttackingStat / activeDefendingStat) / 50.0) + 2.0;

              minDamage = baseDamage * 0.85 * multiplier;
              maxDamage = baseDamage * 1.00 * multiplier;
            }

            final int minDamageRounded = minDamage.round();
            final int maxDamageRounded = maxDamage.round();

            double minPercent = 0.0;
            double maxPercent = 0.0;
            if (defenderHP > 0) {
              minPercent = (minDamageRounded / defenderHP) * 100.0;
              maxPercent = (maxDamageRounded / defenderHP) * 100.0;
            }

            String getKoChanceString() {
              if (maxDamageRounded <= 0) return 'Deals no damage.';
              if (minDamageRounded >= defenderHP) {
                return 'Guaranteed OHKO (100% chance to KO in 1 hit)';
              }
              if (maxDamageRounded >= defenderHP) {
                final double ohkoChance = ((maxDamageRounded - defenderHP) / (maxDamageRounded - minDamageRounded)) * 100.0;
                final int chanceVal = ohkoChance.clamp(1, 99).round();
                return '$chanceVal% chance to OHKO';
              }
              if (minDamageRounded * 2 >= defenderHP) {
                return 'Guaranteed 2HKO';
              }
              if (maxDamageRounded * 2 >= defenderHP) {
                return 'Chance to 2HKO';
              }
              if (minDamageRounded * 3 >= defenderHP) {
                return 'Guaranteed 3HKO';
              }
              if (maxDamageRounded * 3 >= defenderHP) {
                return 'Chance to 3HKO';
              }
              final int hitsNeeded = (defenderHP / maxDamageRounded).ceil();
              return 'Guaranteed $hitsNeeded+HKO';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ATTACKER CONFIG ---
                  _buildSectionHeader('ATTACKER & OFFENSIVE SETUP', Icons.bolt),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Attacker Selection
                        const Text('Attacker Pokémon', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          tileColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                          leading: CircleAvatar(
                            backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                            child: Text(
                              _attacker!.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ),
                          title: Text(
                            _attacker!.name.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              _buildBadgeMini(_attacker!.type1),
                              if (_attacker!.type2 != null) ...[
                                const SizedBox(width: 4),
                                _buildBadgeMini(_attacker!.type2!),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          onTap: () => _showPokemonSelectionSheet(context, allPokemons, true),
                        ),
                        const SizedBox(height: 16),

                        // Move Dropdown
                        const Text('Active Attack Move', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Map<String, dynamic>>(
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              value: _calcSelectedMove,
                              items: displayMoves.map((m) {
                                final int powerVal = m['power'] ?? 0;
                                final String categoryStr = (m['damage_class'] ?? 'Status').toString();
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: m,
                                  child: Text(
                                    '${m['name'].toString().toUpperCase()} (Power: $powerVal, $categoryStr)',
                                    style: TextStyle(fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _calcSelectedMove = val;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Ability and Item Dropdowns
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Attacker Ability', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        value: _calcAttackerAbility,
                                        items: activeAbilities.map((a) {
                                          return DropdownMenuItem<String>(
                                            value: a,
                                            child: Text(a, style: TextStyle(fontSize: 12, color: primaryColor)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _calcAttackerAbility = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Attacker Item', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        value: _calcAttackerItem,
                                        items: ['None', 'Choice Band', 'Choice Specs', 'Life Orb', 'Expert Belt'].map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item, style: TextStyle(fontSize: 12, color: primaryColor)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _calcAttackerItem = val;
                                            });
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
                        const SizedBox(height: 16),

                        // Switch modifiers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _calcAttackerBurned,
                                  activeColor: AppTheme.pokemonRed,
                                  onChanged: (val) {
                                    setState(() {
                                      _calcAttackerBurned = val ?? false;
                                    });
                                  },
                                ),
                                Text('Burned', style: TextStyle(fontSize: 12, color: primaryColor)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _calcCriticalHit,
                                  activeColor: AppTheme.pokemonRed,
                                  onChanged: (val) {
                                    setState(() {
                                      _calcCriticalHit = val ?? false;
                                    });
                                  },
                                ),
                                Text('Critical Hit', style: TextStyle(fontSize: 12, color: primaryColor)),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _calcDoubleBattle,
                                  activeColor: AppTheme.pokemonRed,
                                  onChanged: (val) {
                                    setState(() {
                                      _calcDoubleBattle = val ?? false;
                                    });
                                  },
                                ),
                                Text('Double Spread', style: TextStyle(fontSize: 12, color: primaryColor)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Interactive Weather chips
                  _buildWeatherChips(isDark),
                  const SizedBox(height: 20),

                  // Interactive Terrain chips
                  _buildTerrainChips(isDark),
                  const SizedBox(height: 24),

                  // --- DEFENDER CONFIG ---
                  _buildSectionHeader('DEFENDER & DURABILITY SETUP', Icons.shield_outlined),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Defender Selection
                        const Text('Defender Pokémon', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          tileColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                          leading: CircleAvatar(
                            backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                            child: Text(
                              _defender!.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ),
                          title: Text(
                            _defender!.name.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              _buildBadgeMini(_defender!.type1),
                              if (_defender!.type2 != null) ...[
                                const SizedBox(width: 4),
                                _buildBadgeMini(_defender!.type2!),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          onTap: () => _showPokemonSelectionSheet(context, allPokemons, false),
                        ),
                        const SizedBox(height: 16),

                        // Defender EV Presets
                        const Text('Quick EV Presets', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPresetChip('Bulky', 252, 0, 0),
                            _buildPresetChip('Phys. Def', 252, 252, 0),
                            _buildPresetChip('Spec. Def', 252, 0, 252),
                            _buildPresetChip('Offensive', 0, 0, 0),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Defender level nature and defensive item
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Defender Nature', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        value: _calcDefenderNature,
                                        items: ['bold', 'relaxed', 'impish', 'lax', 'timid', 'jolly', 'modest', 'calm', 'gentle', 'sassy', 'careful', 'serious'].map((n) {
                                          return DropdownMenuItem<String>(
                                            value: n,
                                            child: Text(n.toUpperCase(), style: TextStyle(fontSize: 11, color: primaryColor)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _calcDefenderNature = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Defender Item', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        value: _calcDefenderItem,
                                        items: ['None', 'Eviolite', 'Assault Vest', 'Leftovers'].map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(item, style: TextStyle(fontSize: 11, color: primaryColor)),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _calcDefenderItem = val;
                                            });
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
                        const SizedBox(height: 16),

                        // Defender Sliders
                        _buildTargetStatRow('HP', 'hp'),
                        _buildTargetStatRow('Defense', 'def'),
                        _buildTargetStatRow('Sp. Def', 'spd'),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Defender Level:',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lvl $_calcDefenderLevel',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor),
                            ),
                          ],
                        ),
                        Slider(
                          min: 1,
                          max: 100,
                          divisions: 99,
                          value: _calcDefenderLevel.toDouble(),
                          activeColor: AppTheme.pokemonRed,
                          inactiveColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                          onChanged: (val) {
                            setState(() {
                              _calcDefenderLevel = val.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- DAMAGE OUTCOME RESULT ---
                  _buildSectionHeader('SHOWDOWN CALCULATION OUTCOME', Icons.bar_chart_outlined),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1416) : const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF3F1B22) : const Color(0xFFFEE2E2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated HKO chance:',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getKoChanceString(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.pokemonRed),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Min damage dealt:',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                            ),
                            Text(
                              '$minDamageRounded HP (${minPercent.toStringAsFixed(1)}%)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Max damage dealt:',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                            ),
                            Text(
                              '$maxDamageRounded HP (${maxPercent.toStringAsFixed(1)}%)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Double Overlay Custom Health Bar
                        Stack(
                          children: [
                            Container(
                              height: 12,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            // Safe range (remaining HP)
                            FractionallySizedBox(
                              widthFactor: ((defenderHP - maxDamageRounded).clamp(0, defenderHP) / defenderHP).toDouble(),
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            // Damage range overlay (Orange/Red bar)
                            Positioned(
                              right: 0,
                              left: ((defenderHP - maxDamageRounded).clamp(0, defenderHP) / defenderHP) * MediaQuery.of(context).size.width * 0.75,
                              child: Container(
                                height: 12,
                                width: ((maxDamageRounded - minDamageRounded).clamp(0, defenderHP) / defenderHP) * MediaQuery.of(context).size.width * 0.75,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Colors.orange, AppTheme.pokemonRed]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
          error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: primaryColor))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
      error: (err, stack) => Center(child: Text('Error loading moves: $err', style: TextStyle(color: primaryColor))),
    );
  }

  // ==========================================
  // GENERAL HELPER WIDGETS
  // ==========================================
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.pokemonRed, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, int hp, int def, int spd) {
    final bool isSelected = _calcDefenderEvs['hp'] == hp && _calcDefenderEvs['def'] == def && _calcDefenderEvs['spd'] == spd;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _calcDefenderEvs['hp'] = hp;
          _calcDefenderEvs['def'] = def;
          _calcDefenderEvs['spd'] = spd;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.pokemonRed.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.pokemonRed : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppTheme.pokemonRed : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetStatRow(String label, String statKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final int evVal = _calcDefenderEvs[statKey] ?? 0;
    final int ivVal = _calcDefenderIvs[statKey] ?? 31;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
            Text('EV: $evVal | IV: $ivVal', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 0,
                max: 252,
                divisions: 63,
                value: evVal.toDouble(),
                activeColor: AppTheme.pokemonRed,
                inactiveColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                onChanged: (val) {
                  setState(() {
                    _calcDefenderEvs[statKey] = val.toInt();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  value: ivVal,
                  items: [31, 30, 15, 0].map((int val) {
                    return DropdownMenuItem<int>(
                      value: val,
                      child: Center(
                        child: Text(
                          '$val',
                          style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? val) {
                    if (val != null) {
                      setState(() {
                        _calcDefenderIvs[statKey] = val;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Weather Condition', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['None', 'Sun', 'Rain', 'Sandstorm', 'Snow'].map((w) {
            final bool isSel = _calcWeather == w;
            IconData weatherIcon = Icons.wb_sunny_outlined;
            Color activeCol = Colors.orange;
            if (w == 'Rain') {
              weatherIcon = Icons.cloudy_snowing;
              activeCol = Colors.blue;
            } else if (w == 'Sandstorm') {
              weatherIcon = Icons.wind_power_outlined;
              activeCol = Colors.brown;
            } else if (w == 'Snow') {
              weatherIcon = Icons.ac_unit;
              activeCol = Colors.cyan;
            } else if (w == 'None') {
              weatherIcon = Icons.not_interested;
              activeCol = Colors.grey;
            }
            return GestureDetector(
              onTap: () {
                setState(() {
                  _calcWeather = w;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel ? activeCol.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSel ? activeCol : isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(weatherIcon, size: 14, color: isSel ? activeCol : Colors.grey),
                    const SizedBox(width: 4),
                    Text(w, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? activeCol : Colors.grey)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTerrainChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Terrain Condition', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['None', 'Electric', 'Grassy', 'Psychic', 'Misty'].map((t) {
            final bool isSel = _calcTerrain == t;
            IconData terrainIcon = Icons.landscape_outlined;
            Color activeCol = Colors.purple;
            if (t == 'Electric') {
              terrainIcon = Icons.flash_on_rounded;
              activeCol = Colors.amber;
            } else if (t == 'Grassy') {
              terrainIcon = Icons.grass_rounded;
              activeCol = Colors.green;
            } else if (t == 'Psychic') {
              terrainIcon = Icons.remove_red_eye_outlined;
              activeCol = Colors.pink;
            } else if (t == 'None') {
              terrainIcon = Icons.not_interested;
              activeCol = Colors.grey;
            }
            return GestureDetector(
              onTap: () {
                setState(() {
                  _calcTerrain = t;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel ? activeCol.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSel ? activeCol : isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(terrainIcon, size: 14, color: isSel ? activeCol : Colors.grey),
                    const SizedBox(width: 4),
                    Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? activeCol : Colors.grey)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeMini(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor(type),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }

  void _showPokemonSelectionSheet(BuildContext context, List<Pokemon> allPokemons, bool isAttacker) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                // Internal search state
                String query = '';
                final filteredPokemons = allPokemons
                    .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
                    .toList();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        isAttacker ? 'Select Attacker Pokémon' : 'Select Defender Pokémon',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Pokémon by name...',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        style: TextStyle(color: primaryColor, fontSize: 13),
                        onChanged: (val) {
                          setModalState(() {
                            query = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredPokemons.length,
                          itemBuilder: (context, idx) {
                            final p = filteredPokemons[idx];
                            final bool isCurrent = isAttacker ? (_attacker?.id == p.id) : (_defender?.id == p.id);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                                child: Text(
                                  p.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                ),
                              ),
                              title: Text(
                                p.name.toUpperCase() + (isCurrent ? ' (CURRENT)' : ''),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isCurrent ? AppTheme.pokemonRed : primaryColor,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  _buildBadgeMini(p.type1),
                                  if (p.type2 != null) ...[
                                    const SizedBox(width: 4),
                                    _buildBadgeMini(p.type2!),
                                  ],
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  if (isAttacker) {
                                    _attacker = p;
                                    // Reset active move so it forces update on next load
                                    _calcSelectedMove = null;
                                  } else {
                                    _defender = p;
                                    // Reset defender stats for new pick
                                    _calcDefenderIvs['hp'] = 31;
                                    _calcDefenderIvs['def'] = 31;
                                    _calcDefenderIvs['spd'] = 31;
                                    _calcDefenderEvs['hp'] = 0;
                                    _calcDefenderEvs['def'] = 0;
                                    _calcDefenderEvs['spd'] = 0;
                                  }
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
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

  double _getTypeEffectiveness(String moveType, String defenderType1, String? defenderType2) {
    double mult = 1.0;

    double getSingleTypeMultiplier(String attacking, String defending) {
      final atk = attacking.toLowerCase();
      final def = defending.toLowerCase();

      final data = _calcEffectiveness[atk];
      if (data == null) return 1.0;

      final double2x = data['offense_2x'] ?? [];
      final double05x = data['offense_0.5x'] ?? [];
      final double0x = data['offense_0x'] ?? [];

      if (double2x.contains(def)) return 2.0;
      if (double05x.contains(def)) return 0.5;
      if (double0x.contains(def)) return 0.0;
      return 1.0;
    }

    mult *= getSingleTypeMultiplier(moveType, defenderType1);
    if (defenderType2 != null) {
      mult *= getSingleTypeMultiplier(moveType, defenderType2);
    }
    return mult;
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return const Color(0xFFA8A77A);
      case 'fire':
        return const Color(0xFFEE8130);
      case 'water':
        return const Color(0xFF6390F0);
      case 'electric':
        return const Color(0xFFF7D02C);
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'ice':
        return const Color(0xFF96D9D6);
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'poison':
        return const Color(0xFFA33EA1);
      case 'ground':
        return const Color(0xFFE2BF65);
      case 'flying':
        return const Color(0xA9A890F0);
      case 'psychic':
        return const Color(0xFFF95587);
      case 'bug':
        return const Color(0xFFA6B91A);
      case 'rock':
        return const Color(0xFFB6A136);
      case 'ghost':
        return const Color(0xFF735797);
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'dark':
        return const Color(0xFF705746);
      case 'steel':
        return const Color(0xFFB7B7CE);
      case 'fairy':
        return const Color(0xFFD685AD);
      default:
        return Colors.grey;
    }
  }

  static const Map<String, Map<String, List<String>>> _calcEffectiveness = {
    'normal': {
      'offense_2x': [],
      'offense_0.5x': ['rock', 'steel'],
      'offense_0x': ['ghost'],
    },
    'fire': {
      'offense_2x': ['grass', 'ice', 'bug', 'steel'],
      'offense_0.5x': ['fire', 'water', 'rock', 'dragon'],
      'offense_0x': [],
    },
    'water': {
      'offense_2x': ['fire', 'ground', 'rock'],
      'offense_0.5x': ['water', 'grass', 'dragon'],
      'offense_0x': [],
    },
    'electric': {
      'offense_2x': ['water', 'flying'],
      'offense_0.5x': ['electric', 'grass', 'dragon'],
      'offense_0x': ['ground'],
    },
    'grass': {
      'offense_2x': ['water', 'ground', 'rock'],
      'offense_0.5x': ['fire', 'grass', 'poison', 'flying', 'bug', 'dragon', 'steel'],
      'offense_0x': [],
    },
    'ice': {
      'offense_2x': ['grass', 'ground', 'flying', 'dragon'],
      'offense_0.5x': ['fire', 'water', 'ice', 'steel'],
      'offense_0x': [],
    },
    'fighting': {
      'offense_2x': ['normal', 'ice', 'rock', 'dark', 'steel'],
      'offense_0.5x': ['poison', 'flying', 'psychic', 'bug', 'fairy'],
      'offense_0x': ['ghost'],
    },
    'poison': {
      'offense_2x': ['grass', 'fairy'],
      'offense_0.5x': ['poison', 'ground', 'rock', 'ghost'],
      'offense_0x': ['steel'],
    },
    'ground': {
      'offense_2x': ['fire', 'electric', 'poison', 'rock', 'steel'],
      'offense_0.5x': ['grass', 'bug'],
      'offense_0x': ['flying'],
    },
    'flying': {
      'offense_2x': ['grass', 'fighting', 'bug'],
      'offense_0.5x': ['electric', 'rock', 'steel'],
      'offense_0x': [],
    },
    'psychic': {
      'offense_2x': ['fighting', 'poison'],
      'offense_0.5x': ['psychic', 'steel'],
      'offense_0x': ['dark'],
    },
    'bug': {
      'offense_2x': ['grass', 'psychic', 'dark'],
      'offense_0.5x': ['fire', 'fighting', 'poison', 'flying', 'ghost', 'steel', 'fairy'],
      'offense_0x': [],
    },
    'rock': {
      'offense_2x': ['fire', 'ice', 'flying', 'bug'],
      'offense_0.5x': ['fighting', 'ground', 'steel'],
      'offense_0x': [],
    },
    'ghost': {
      'offense_2x': ['psychic', 'ghost'],
      'offense_0.5x': ['dark'],
      'offense_0x': ['normal'],
    },
    'dragon': {
      'offense_2x': ['dragon'],
      'offense_0.5x': ['steel'],
      'offense_0x': ['fairy'],
    },
    'dark': {
      'offense_2x': ['psychic', 'ghost'],
      'offense_0.5x': ['fighting', 'dark', 'fairy'],
      'offense_0x': [],
    },
    'steel': {
      'offense_2x': ['ice', 'rock', 'fairy'],
      'offense_0.5x': ['fire', 'water', 'electric', 'steel'],
      'offense_0x': [],
    },
    'fairy': {
      'offense_2x': ['fighting', 'dragon', 'dark'],
      'offense_0.5x': ['fire', 'poison', 'steel'],
      'offense_0x': [],
    },
  };
}
