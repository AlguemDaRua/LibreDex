import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/widgets/shiny_slider.dart';

/// Highly advanced Pokémon Details view.
/// Houses an interactive ShinySlider, calculated defensive TypeDex effectiveness badges,
/// real-time competitive statistics recalculator popup (accessed by clicking stats/BST),
/// and lazy-loaded abilities/moves lists filterable by learning methods.
class PokemonDetailScreen extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
  });

  @override
  ConsumerState<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeMoveFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Reset competitive stats simulator values to fresh defaults (Lv. 100)
    Future.microtask(() {
      ref.read(statsCalculatorProvider.notifier).reset();
      // Lazy cache-load all moves and abilities in background SQLite transaction
      ref.read(pokemonRepositoryProvider).syncAbilitiesAndMoves(widget.pokemon.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Map standard Pokémon types to high-quality hex colors.
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return const Color(0xFFF08030);
      case 'water': return const Color(0xFF6890F0);
      case 'grass': return const Color(0xFF78C850);
      case 'electric': return const Color(0xFFF8D030);
      case 'ice': return const Color(0xFF98D8D8);
      case 'fighting': return const Color(0xFFC03028);
      case 'poison': return const Color(0xFFA040A0);
      case 'ground': return const Color(0xFFE0C068);
      case 'flying': return const Color(0xFFA890F0);
      case 'psychic': return const Color(0xFFF85888);
      case 'bug': return const Color(0xFFA8B820);
      case 'rock': return const Color(0xFFB8A038);
      case 'ghost': return const Color(0xFF705898);
      case 'dragon': return const Color(0xFF7038F8);
      case 'dark': return const Color(0xFF705848);
      case 'steel': return const Color(0xFFB8B8D0);
      case 'fairy': return const Color(0xFFEE99AC);
      default: return const Color(0xFFA8A878);
    }
  }

  /// Calculates individual stat progress bar coloring.
  Color _getStatColor(int value) {
    if (value >= 130) return Colors.tealAccent.shade400;
    if (value >= 90) return Colors.greenAccent.shade700;
    if (value >= 60) return Colors.orangeAccent.shade400;
    return Colors.redAccent.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _getTypeColor(widget.pokemon.type1);
    final statsState = ref.watch(statsCalculatorProvider);
    final calculatedStats = ref.read(statsCalculatorProvider.notifier).getCalculatedStats(widget.pokemon);

    final bstBase = widget.pokemon.baseHp +
        widget.pokemon.baseAtk +
        widget.pokemon.baseDef +
        widget.pokemon.baseSpAtk +
        widget.pokemon.baseSpDef +
        widget.pokemon.baseSpd;

    final bstCalculated = calculatedStats.values.fold(0, (sum, val) => sum + val);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.amoledBlack : const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(
          widget.pokemon.name,
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(
        children: [
          // Elegant sliding tabs header
          TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            labelColor: isDark ? Colors.white : Colors.black87,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'SIMULATOR'),
              Tab(text: 'MOVES & ABILITIES'),
            ],
          ),
          const SizedBox(height: 10),

          // Core sliding views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(isDark, primaryColor),
                _buildSimulatorTab(isDark, primaryColor, statsState, calculatedStats, bstBase, bstCalculated),
                _buildMovesAndAbilitiesTab(isDark, primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 1: OVERVIEW & TYPEDEX =================

  Widget _buildOverviewTab(bool isDark, Color primaryColor) {
    final Map<String, double> typeDef = TypeEfficiencyCalculator.getCombinedEffectiveness(
      widget.pokemon.type1,
      widget.pokemon.type2,
    );

    // Group effectiveness into lists
    final List<MapEntry<String, double>> weaknesses = [];
    final List<MapEntry<String, double>> resistances = [];
    final List<MapEntry<String, double>> immunities = [];

    for (final entry in typeDef.entries) {
      if (entry.value > 1.0) {
        weaknesses.add(entry);
      } else if (entry.value == 0.0) {
        immunities.add(entry);
      } else {
        resistances.add(entry);
      }
    }

    // Sort descending
    weaknesses.sort((a, b) => b.value.compareTo(a.value));
    resistances.sort((a, b) => a.value.compareTo(b.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Core Pill Badge Tags
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDetailTypeBadge(widget.pokemon.type1, primaryColor),
              if (widget.pokemon.type2 != null) ...[
                const SizedBox(width: 8),
                _buildDetailTypeBadge(widget.pokemon.type2!, _getTypeColor(widget.pokemon.type2!)),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Interlocking Shiny Slider
          ShinySlider(
            normalImageUrl: widget.pokemon.spriteUrl,
            shinyImageUrl: widget.pokemon.shinySpriteUrl,
          ),
          const SizedBox(height: 24),

          // TypeDex Card
          Card(
            elevation: 0,
            color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TypeDex Matchups',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 20, thickness: 1),

                  if (weaknesses.isNotEmpty) ...[
                    const Text(
                      'Weaknesses',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: weaknesses.map((w) => _buildTypeDexBadge(w.key, w.value)).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],

                  if (resistances.isNotEmpty) ...[
                    const Text(
                      'Resistances',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: resistances.map((r) => _buildTypeDexBadge(r.key, r.value)).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],

                  if (immunities.isNotEmpty) ...[
                    const Text(
                      'Immunities',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: immunities.map((i) => _buildTypeDexBadge(i.key, i.value)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDetailTypeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTypeDexBadge(String type, double multiplier) {
    final color = _getTypeColor(type);
    final String label = multiplier % 1 == 0 ? '${multiplier.toInt()}x' : '${multiplier}x';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type[0].toUpperCase() + type.substring(1),
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: COMPETITIVE STATS SIMULATOR =================

  Widget _buildSimulatorTab(
    bool isDark,
    Color primaryColor,
    StatsCalculatorState state,
    Map<String, int> calculatedStats,
    int bstBase,
    int bstCalculated,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info banner detailing interactivity
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap the card to open Showdown stats recalculator popup overlays!',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Interlocking Stats Card
          InkWell(
            onTap: () => _openStatsCalculatorPopup(isDark, primaryColor),
            borderRadius: BorderRadius.circular(20),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Heading Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stats Calculator',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${state.level} • Nature: ${state.nature}',
                              style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'BST: $bstBase ➔ $bstCalculated',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),

                    // Base vs Simulated rows
                    _buildSimulatedStatRow('HP', widget.pokemon.baseHp, calculatedStats['HP'] ?? 0, state.ivs['HP']!, state.evs['HP']!, isDark),
                    _buildSimulatedStatRow('Attack', widget.pokemon.baseAtk, calculatedStats['Atk'] ?? 0, state.ivs['Atk']!, state.evs['Atk']!, isDark),
                    _buildSimulatedStatRow('Defense', widget.pokemon.baseDef, calculatedStats['Def'] ?? 0, state.ivs['Def']!, state.evs['Def']!, isDark),
                    _buildSimulatedStatRow('Sp. Atk', widget.pokemon.baseSpAtk, calculatedStats['SpA'] ?? 0, state.ivs['SpA']!, state.evs['SpA']!, isDark),
                    _buildSimulatedStatRow('Sp. Def', widget.pokemon.baseSpDef, calculatedStats['SpD'] ?? 0, state.ivs['SpD']!, state.evs['SpD']!, isDark),
                    _buildSimulatedStatRow('Speed', widget.pokemon.baseSpd, calculatedStats['Spe'] ?? 0, state.ivs['Spe']!, state.evs['Spe']!, isDark),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSimulatedStatRow(
    String label,
    int baseValue,
    int simulatedValue,
    int iv,
    int ev,
    bool isDark,
  ) {
    final double baseProgress = (baseValue / 255.0).clamp(0.0, 1.0);
    final double simProgress = (simulatedValue / 500.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Base: $baseValue ➔ $simulatedValue (IV: $iv | EV: $ev)',
                style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Base Stat Bar (Grey)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: baseProgress,
              minHeight: 4,
              backgroundColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFEDF2F7),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
          const SizedBox(height: 3),

          // Simulated Stat Bar (Colored Highlight)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: simProgress,
              minHeight: 7,
              backgroundColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFEDF2F7),
              valueColor: AlwaysStoppedAnimation<Color>(_getStatColor(baseValue)),
            ),
          ),
        ],
      ),
    );
  }

  /// Showdown stats calculator blurred background modal bottom sheet popup
  void _openStatsCalculatorPopup(bool isDark, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {
              return Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(statsCalculatorProvider);
                  final notifier = ref.read(statsCalculatorProvider.notifier);

                  return Container(
                    padding: EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xEC0B0B0B) : const Color(0xFDF7FAFC),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border.all(
                        color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Draggable Pill
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Stats Settings',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Total EVs: ${state.totalEvs}/508',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: state.totalEvs > 508 ? Colors.red : primaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Level Customization
                        Row(
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                'Level:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: state.level.toDouble(),
                                min: 1,
                                max: 100,
                                activeColor: primaryColor,
                                inactiveColor: Colors.grey[700],
                                onChanged: (val) {
                                  notifier.updateLevel(val.toInt());
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: Text(
                                '${state.level}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),

                        // Nature Selection Dropdown
                        Row(
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                'Nature:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[600]!, width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: state.nature,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                                    items: natureModifiers.keys.map((nature) {
                                      return DropdownMenuItem<String>(
                                        value: nature,
                                        child: Text(
                                          nature,
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        notifier.updateNature(val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),

                        // IV/EV adjustments for all 6 stats
                        SizedBox(
                          height: 280,
                          child: ListView(
                            shrinkWrap: true,
                            children: ['HP', 'Atk', 'Def', 'SpA', 'SpD', 'Spe'].map((stat) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 45,
                                          child: Text(
                                            stat,
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                          ),
                                        ),
                                        // IV Slider
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('IV: ${state.ivs[stat]}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                                  Text('EV: ${state.evs[stat]}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                                ],
                                              ),
                                              Slider(
                                                value: state.ivs[stat]!.toDouble(),
                                                min: 0,
                                                max: 31,
                                                activeColor: Colors.amber[700],
                                                inactiveColor: Colors.grey[800],
                                                onChanged: (val) {
                                                  notifier.updateIv(stat, val.toInt());
                                                },
                                              ),
                                              Slider(
                                                value: state.evs[stat]!.toDouble(),
                                                min: 0,
                                                max: 252,
                                                activeColor: primaryColor,
                                                inactiveColor: Colors.grey[800],
                                                onChanged: (val) {
                                                  notifier.updateEv(stat, val.toInt());
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 10),
                                  ],
                                ),
                              );
                            }).toList(),
                            ),
                        ),
                        const SizedBox(height: 14),

                        // Close button
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Save & Recalculate', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ================= TAB 3: MOVES & ABILITIES =================

  Widget _buildMovesAndAbilitiesTab(bool isDark, Color primaryColor) {
    final abilitiesAsync = ref.watch(pokemonAbilitiesProvider(widget.pokemon.id));
    final movesAsync = ref.watch(pokemonMovesProvider(widget.pokemon.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Abilities Section
          const Text(
            'Abilities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          abilitiesAsync.when(
            data: (abilities) {
              if (abilities.isEmpty) {
                return _buildInlineLoadingIndicator(primaryColor);
              }
              return Column(
                children: abilities.map((item) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            item.ability.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (item.junction.isHidden) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.purple.withValues(alpha: 0.5), width: 1),
                              ),
                              child: const Text(
                                'Hidden Ability',
                                style: TextStyle(color: Colors.purpleAccent, fontSize: 8, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.ability.description,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => _buildInlineLoadingIndicator(primaryColor),
            error: (e, _) => Text('Error loading abilities: $e', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 24),

          // 2. Moves Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Moves Pool',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.tune_sharp, color: primaryColor, size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // Sliding chips filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All Moves', primaryColor),
                const SizedBox(width: 6),
                _buildFilterChip('level', 'Level Up', primaryColor),
                const SizedBox(width: 6),
                _buildFilterChip('tm', 'TM / Machine', primaryColor),
                const SizedBox(width: 6),
                _buildFilterChip('egg', 'Egg Moves', primaryColor),
                const SizedBox(width: 6),
                _buildFilterChip('tutor', 'Tutors', primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 14),

          movesAsync.when(
            data: (moves) {
              if (moves.isEmpty) {
                return _buildInlineLoadingIndicator(primaryColor);
              }

              // Apply active filters
              final filtered = moves.where((item) {
                if (_activeMoveFilter == 'all') return true;
                return item.junction.learnMethod == _activeMoveFilter;
              }).toList();

              // Sort Level up moves by level learned
              filtered.sort((a, b) {
                if (a.junction.learnMethod == 'level' && b.junction.learnMethod == 'level') {
                  return (a.junction.levelLearned ?? 0).compareTo(b.junction.levelLearned ?? 0);
                }
                return a.move.name.compareTo(b.move.name);
              });

              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No moves found in this category.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }

              return Column(
                children: filtered.map((item) {
                  final String learnText = item.junction.learnMethod == 'level'
                      ? 'Lvl ${item.junction.levelLearned}'
                      : item.junction.learnMethod.toUpperCase();

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        item.move.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.2),
                        ),
                        child: Text(
                          learnText,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => _buildInlineLoadingIndicator(primaryColor),
            error: (e, _) => Text('Error loading moves: $e', style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, Color primaryColor) {
    final active = _activeMoveFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _activeMoveFilter = value;
          });
        }
      },
      selectedColor: primaryColor.withValues(alpha: 0.25),
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        color: active ? primaryColor : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      side: BorderSide(
        color: active ? primaryColor : Colors.grey[800]!,
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildInlineLoadingIndicator(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Decrypting PokeAPI relational records...',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
