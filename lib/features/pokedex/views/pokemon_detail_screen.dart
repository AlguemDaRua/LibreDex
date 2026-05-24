import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/models/stat_calculator.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/widgets/shiny_slider.dart';

/// Static dictionary of Pokémon Natures in alphabetical order.
const Map<String, Map<String, dynamic>> alphabeticalNatures = {
  'adamant': {'name': 'Adamant', 'up': 'Attack', 'down': 'Sp. Atk'},
  'bashful': {'name': 'Bashful', 'up': null, 'down': null},
  'bold': {'name': 'Bold', 'up': 'Defense', 'down': 'Attack'},
  'brave': {'name': 'Brave', 'up': 'Attack', 'down': 'Speed'},
  'calm': {'name': 'Calm', 'up': 'Sp. Def', 'down': 'Attack'},
  'careful': {'name': 'Careful', 'up': 'Sp. Def', 'down': 'Sp. Atk'},
  'docile': {'name': 'Docile', 'up': null, 'down': null},
  'gentle': {'name': 'Gentle', 'up': 'Sp. Def', 'down': 'Defense'},
  'hardy': {'name': 'Hardy', 'up': null, 'down': null},
  'hasty': {'name': 'Hasty', 'up': 'Speed', 'down': 'Defense'},
  'impish': {'name': 'Impish', 'up': 'Defense', 'down': 'Sp. Atk'},
  'jolly': {'name': 'Jolly', 'up': 'Speed', 'down': 'Sp. Atk'},
  'lax': {'name': 'Lax', 'up': 'Defense', 'down': 'Sp. Def'},
  'lonely': {'name': 'Lonely', 'up': 'Attack', 'down': 'Defense'},
  'mild': {'name': 'Mild', 'up': 'Sp. Atk', 'down': 'Defense'},
  'modest': {'name': 'Modest', 'up': 'Sp. Atk', 'down': 'Attack'},
  'naive': {'name': 'Naive', 'up': 'Speed', 'down': 'Sp. Def'},
  'naughty': {'name': 'Naughty', 'up': 'Attack', 'down': 'Sp. Def'},
  'quiet': {'name': 'Quiet', 'up': 'Sp. Atk', 'down': 'Speed'},
  'quirky': {'name': 'Quirky', 'up': null, 'down': null},
  'rash': {'name': 'Rash', 'up': 'Sp. Atk', 'down': 'Sp. Def'},
  'relaxed': {'name': 'Relaxed', 'up': 'Defense', 'down': 'Speed'},
  'sassy': {'name': 'Sassy', 'up': 'Sp. Def', 'down': 'Speed'},
  'serious': {'name': 'Serious', 'up': null, 'down': null},
  'timid': {'name': 'Timid', 'up': 'Speed', 'down': 'Attack'},
};

class PokemonDetailScreen extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  ConsumerState<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _moveFilter = 'all';

  // --- DAMAGE CALCULATOR STATE ---
  Map<String, dynamic>? _calcSelectedMove;
  String _calcAttackerItem = 'None';
  String _calcAttackerAbility = 'None';
  String _calcWeather = 'None';
  String _calcTerrain = 'None';
  bool _calcAttackerBurned = false;
  bool _calcCriticalHit = false;
  bool _calcDoubleBattle = false;

  Pokemon? _calcDefender;
  int _calcDefenderLevel = 100;
  String _calcDefenderNature = 'serious';
  String _calcDefenderItem = 'None';
  final Map<String, int> _calcDefenderIvs = {'hp': 31, 'def': 31, 'spd': 31};
  final Map<String, int> _calcDefenderEvs = {'hp': 0, 'def': 0, 'spd': 0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Reset calculator state and lazily trigger background database sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statsCalculatorProvider.notifier).reset();
      ref.read(pokemonRepositoryProvider).syncPokemonDetails(widget.pokemon.id, widget.pokemon.name);
    });
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

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          '#${widget.pokemon.id.toString().padLeft(3, '0')} ${widget.pokemon.name.toUpperCase()}',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor),
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
            Tab(text: 'GENERAL', icon: Icon(Icons.info_outline, size: 20)),
            Tab(text: 'STATS', icon: Icon(Icons.analytics_outlined, size: 20)),
            Tab(text: 'MOVES', icon: Icon(Icons.flash_on_outlined, size: 20)),
            Tab(text: 'CALCULATOR', icon: Icon(Icons.calculate_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildStatsTab(),
          _buildMovesTab(),
          _buildCalculatorTab(),
        ],
      ),
    );
  }

  /// -------------------------------------------------------------
  /// TAB 1: GENERAL TAB (Overview, Type Badges, Weaknesses & Abilities)
  /// -------------------------------------------------------------
  Widget _buildGeneralTab() {
    final doubleEffs = TypeEfficiencyCalculator.getCombinedEffectiveness(
      widget.pokemon.type1,
      widget.pokemon.type2,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sprite Comparison Slider
          Hero(
            tag: 'pokemon_${widget.pokemon.id}',
            child: ShinySlider(
              normalImageUrl: widget.pokemon.spriteUrl,
              shinyImageUrl: widget.pokemon.shinySpriteUrl,
              normalLabel: 'Normal',
              shinyLabel: '★ Shiny',
            ),
          ),
          const SizedBox(height: 20),

          // Core Element Types
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeBadge(widget.pokemon.type1),
              if (widget.pokemon.type2 != null) ...[
                const SizedBox(width: 12),
                _buildTypeBadge(widget.pokemon.type2!),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Abilities Card (Overview)
          _buildAbilitiesCard(),
          const SizedBox(height: 20),

          // Type Relations (TypeDex Card)
          _buildTypeDexCard(doubleEffs),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final color = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeDexCard(Map<String, double> efficiencies) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weaknesses = efficiencies.entries.where((e) => e.value > 1.0).toList();
    final resistances = efficiencies.entries.where((e) => e.value < 1.0 && e.value > 0.0).toList();
    final immunities = efficiencies.entries.where((e) => e.value == 0.0).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type Relations (TypeDex)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),

          if (weaknesses.isNotEmpty) ...[
            const Text('Weaknesses (Takes Extra Damage)', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weaknesses.map((e) => _buildMiniTypeEffBadge(e.key, e.value)).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (resistances.isNotEmpty) ...[
            const Text('Resistances (Takes Less Damage)', style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resistances.map((e) => _buildMiniTypeEffBadge(e.key, e.value)).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (immunities.isNotEmpty) ...[
            const Text('Immunities (Zero Damage)', style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: immunities.map((e) => _buildMiniTypeEffBadge(e.key, e.value)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTypeEffBadge(String type, double multiplier) {
    final color = _getTypeColor(type);
    String label = multiplier % 1 == 0 ? multiplier.toInt().toString() : multiplier.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            type.toUpperCase(),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            'x$label',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final abilitiesAsync = ref.watch(pokemonAbilitiesStreamProvider(widget.pokemon.id));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abilities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),
          abilitiesAsync.when(
            data: (abilities) {
              if (abilities.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Syncing abilities from PokéAPI...',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: abilities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ability = abilities[index];
                  final int? abilityId = ability['id'];
                  final String name = ability['name'] ?? '';
                  final String effect = ability['effect'] ?? 'No description available.';
                  final bool isHidden = ability['isHidden'] ?? false;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (abilityId != null) {
                        _showAbilityDetailsFromDetailScreen(context, abilityId, name, effect);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 14, 
                                    color: isDark ? Colors.white : Colors.black
                                ),
                              ),
                              if (isHidden) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.purpleAccent, width: 0.8),
                                  ),
                                  child: const Text(
                                    'HIDDEN',
                                    style: TextStyle(color: Colors.purpleAccent, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            effect,
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                ),
              ),
            ),
            error: (err, stack) => Text('Error loading abilities: $err', style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  /// -------------------------------------------------------------
  /// TAB 2: COMPETITIVE STATS SIMULATOR (Showdown Style)
  /// -------------------------------------------------------------
  Widget _buildStatsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final statsState = ref.watch(statsCalculatorProvider);
    final statsNotifier = ref.read(statsCalculatorProvider.notifier);
    final calculatedStats = statsNotifier.getCalculatedStats(widget.pokemon);

    final int remainingEvs = 508 - statsState.totalEvs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Config Panel Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Level Slider
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level: ${statsState.level}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: statsState.level.toDouble(),
                              min: 1,
                              max: 100,
                              activeColor: AppTheme.pokemonRed,
                              inactiveColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
                              onChanged: (val) => statsNotifier.updateLevel(val.toInt()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Remaining EVs Box
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: remainingEvs == 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: remainingEvs == 0 ? Colors.green : isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Remaining EVs',
                              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$remainingEvs / 508',
                              style: TextStyle(
                                color: remainingEvs == 0 ? Colors.greenAccent : primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nature Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nature',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                    ),
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
                          value: statsState.nature,
                          dropdownColor: isDark ? const Color(0xFF121212) : Colors.white,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                          items: alphabeticalNatures.keys.map((natureKey) {
                            final nature = alphabeticalNatures[natureKey]!;
                            final String name = nature['name'];
                            final String? up = nature['up'];
                            final String? down = nature['down'];

                            String detailText = '• Neutral';
                            if (up != null && down != null) {
                              detailText = '▲ $up / ▼ $down';
                            }

                            return DropdownMenuItem<String>(
                              value: natureKey,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(color: primaryColor, fontSize: 14),
                                  ),
                                  Text(
                                    detailText,
                                    style: TextStyle(
                                      color: up != null ? (isDark ? Colors.tealAccent : const Color(0xFF0F766E)) : Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              statsNotifier.updateNature(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Showdown Grid Table
          const Text(
            'Competitive Stat Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCompetiveStatRow(
                label: 'HP',
                baseValue: widget.pokemon.baseHp,
                ivValue: statsState.ivs['hp'] ?? 31,
                evValue: statsState.evs['hp'] ?? 0,
                finalValue: calculatedStats['hp'] ?? 100,
                statColor: const Color(0xFF38BDF8),
                statKey: 'hp',
                notifier: statsNotifier,
                upIndicator: false,
                downIndicator: false,
              ),
              _buildCompetiveStatRow(
                label: 'Attack',
                baseValue: widget.pokemon.baseAtk,
                ivValue: statsState.ivs['atk'] ?? 31,
                evValue: statsState.evs['atk'] ?? 0,
                finalValue: calculatedStats['atk'] ?? 100,
                statColor: const Color(0xFFF87171),
                statKey: 'atk',
                notifier: statsNotifier,
                upIndicator: alphabeticalNatures[statsState.nature]?['up'] == 'Attack',
                downIndicator: alphabeticalNatures[statsState.nature]?['down'] == 'Attack',
              ),
              _buildCompetiveStatRow(
                label: 'Defense',
                baseValue: widget.pokemon.baseDef,
                ivValue: statsState.ivs['def'] ?? 31,
                evValue: statsState.evs['def'] ?? 0,
                finalValue: calculatedStats['def'] ?? 100,
                statColor: const Color(0xFFFBBF24),
                statKey: 'def',
                notifier: statsNotifier,
                upIndicator: alphabeticalNatures[statsState.nature]?['up'] == 'Defense',
                downIndicator: alphabeticalNatures[statsState.nature]?['down'] == 'Defense',
              ),
              _buildCompetiveStatRow(
                label: 'Sp. Atk',
                baseValue: widget.pokemon.baseSpAtk,
                ivValue: statsState.ivs['spa'] ?? 31,
                evValue: statsState.evs['spa'] ?? 0,
                finalValue: calculatedStats['spa'] ?? 100,
                statColor: const Color(0xFF818CF8),
                statKey: 'spa',
                notifier: statsNotifier,
                upIndicator: alphabeticalNatures[statsState.nature]?['up'] == 'Sp. Atk',
                downIndicator: alphabeticalNatures[statsState.nature]?['down'] == 'Sp. Atk',
              ),
              _buildCompetiveStatRow(
                label: 'Sp. Def',
                baseValue: widget.pokemon.baseSpDef,
                ivValue: statsState.ivs['spd'] ?? 31,
                evValue: statsState.evs['spd'] ?? 0,
                finalValue: calculatedStats['spd'] ?? 100,
                statColor: const Color(0xFF34D399),
                statKey: 'spd',
                notifier: statsNotifier,
                upIndicator: alphabeticalNatures[statsState.nature]?['up'] == 'Sp. Def',
                downIndicator: alphabeticalNatures[statsState.nature]?['down'] == 'Sp. Def',
              ),
              _buildCompetiveStatRow(
                label: 'Speed',
                baseValue: widget.pokemon.baseSpd,
                ivValue: statsState.ivs['spe'] ?? 31,
                evValue: statsState.evs['spe'] ?? 0,
                finalValue: calculatedStats['spe'] ?? 100,
                statColor: const Color(0xFFF472B6),
                statKey: 'spe',
                notifier: statsNotifier,
                upIndicator: alphabeticalNatures[statsState.nature]?['up'] == 'Speed',
                downIndicator: alphabeticalNatures[statsState.nature]?['down'] == 'Speed',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompetiveStatRow({
    required String label,
    required int baseValue,
    required int ivValue,
    required int evValue,
    required int finalValue,
    required Color statColor,
    required String statKey,
    required StatsCalculator notifier,
    required bool upIndicator,
    required bool downIndicator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    Widget labelWidget = Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: upIndicator 
                ? (isDark ? Colors.tealAccent : const Color(0xFF0F766E)) 
                : downIndicator ? (isDark ? Colors.redAccent : const Color(0xFFBE123C)) : primaryColor
          ),
        ),
        if (upIndicator) Text(' ▲', style: TextStyle(color: isDark ? Colors.tealAccent : const Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold)),
        if (downIndicator) Text(' ▼', style: TextStyle(color: isDark ? Colors.redAccent : const Color(0xFFBE123C), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
      ),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  labelWidget,
                  const SizedBox(height: 2),
                  Text(
                    'Base: $baseValue',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // M3 Showdown Progressive Bar
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 10,
                  child: Stack(
                    children: [
                      Container(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                      FractionallySizedBox(
                        widthFactor: (baseValue / 255).clamp(0.01, 1.0),
                        child: Container(color: statColor.withValues(alpha: 0.4)),
                      ),
                      FractionallySizedBox(
                        widthFactor: (finalValue / 504).clamp(0.01, 1.0),
                        child: Container(color: statColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Stat Final
            SizedBox(
              width: 45,
              child: Text(
                '$finalValue',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: Column(
              children: [
                const Divider(color: Color(0xFF2D2D2D), height: 12),
                // IV Slider
                Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Text('IV:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Slider(
                        value: ivValue.toDouble(),
                        min: 0,
                        max: 31,
                        divisions: 31,
                        activeColor: isDark ? Colors.white : Colors.black87,
                        inactiveColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                        onChanged: (val) => notifier.updateIv(statKey, val.toInt()),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$ivValue',
                          style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                // EV Slider
                Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Text('EV:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Slider(
                        value: evValue.toDouble(),
                        min: 0,
                        max: 252,
                        divisions: 63,
                        activeColor: statColor,
                        inactiveColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                        onChanged: (val) => notifier.updateEv(statKey, val.toInt()),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$evValue',
                          style: TextStyle(color: statColor, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
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
  }

  /// -------------------------------------------------------------
  /// TAB 3: MOVES (Filtrable Moves List)
  /// -------------------------------------------------------------
  Widget _buildMovesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final movesAsync = ref.watch(pokemonMovesStreamProvider(widget.pokemon.id));

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip('all', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('level', 'Level'),
              const SizedBox(width: 8),
              _buildFilterChip('tm', 'TM / TR'),
              const SizedBox(width: 8),
              _buildFilterChip('tutor', 'Tutor'),
              const SizedBox(width: 8),
              _buildFilterChip('egg', 'Egg'),
            ],
          ),
        ),
        Expanded(
          child: movesAsync.when(
            data: (movesList) {
              if (movesList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Syncing moves from PokéAPI...',
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              final filteredMoves = movesList.where((item) {
                if (_moveFilter == 'all') return true;
                return item['learnMethod'] == _moveFilter;
              }).toList();

              if (filteredMoves.isEmpty) {
                return const Center(
                  child: Text(
                    'No moves found with this filter.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: filteredMoves.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final move = filteredMoves[index];
                  final String name = move['name'] ?? '';
                  final String moveType = move['type'] ?? 'normal';
                  final String damageClass = move['damageClass'] ?? 'physical';
                  final int? power = move['power'];
                  final int pp = move['pp'] ?? 15;
                  final int? accuracy = move['accuracy'];
                  final String description = move['description'] ?? 'No information available.';
                  final String learnMethod = move['learnMethod'] ?? 'level';
                  final int? levelLearned = move['levelLearned'];

                  final color = _getTypeColor(moveType);
                  final hasPower = power != null && power > 0;

                  // Competitive Modifiers Math (Showdown Style)
                  double sunPower = power?.toDouble() ?? 0.0;
                  double rainPower = power?.toDouble() ?? 0.0;
                  double overgrowPower = power?.toDouble() ?? 0.0;

                  if (hasPower) {
                    final pType = moveType.toLowerCase();
                    if (pType == 'fire') {
                      sunPower *= 1.5;
                      rainPower *= 0.5;
                    } else if (pType == 'water') {
                      sunPower *= 0.5;
                      rainPower *= 1.5;
                    }

                    if (pType == 'grass') {
                      overgrowPower *= 1.5;
                    }
                  }

                  return ExpansionTile(
                    collapsedBackgroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    tilePadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: learnMethod == 'level'
                                ? Text(
                                    'Lvl ${levelLearned ?? 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 11),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      learnMethod.toUpperCase(),
                                      style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14, 
                                  color: isDark ? Colors.white : Colors.black
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      moveType.toUpperCase(),
                                      style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Category Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: damageClass.toLowerCase() == 'physical'
                                          ? const Color(0xFFF87171).withValues(alpha: 0.15)
                                          : damageClass.toLowerCase() == 'special'
                                              ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
                                              : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      damageClass.toUpperCase(),
                                      style: TextStyle(
                                        color: damageClass.toLowerCase() == 'physical'
                                            ? const Color(0xFFF87171)
                                            : damageClass.toLowerCase() == 'special'
                                                ? const Color(0xFF60A5FA)
                                                : Colors.grey,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hasPower ? 'Power: $power' : 'Status',
                              style: TextStyle(
                                color: hasPower 
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PP: $pp',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Color(0xFF2D2D2D), height: 12),
                            // Description
                            Text(
                              description,
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            // Accuracy, PP and category stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Accuracy: ${accuracy != null ? "$accuracy%" : "—"}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                Text(
                                  'PP: $pp/$pp',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                Text(
                                  'Category: ${damageClass[0].toUpperCase() + damageClass.substring(1)}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                                  foregroundColor: AppTheme.pokemonRed,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.catching_pokemon, size: 16),
                                label: const Text(
                                  'Who Else Learns This Move?',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  final int? moveId = move['id'];
                                  if (moveId != null) {
                                    _showMoveDetailsFromDetailScreen(context, moveId, name, description, moveType);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                ),
              ),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error loading moves: $err',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModifierRow(String label, int originalPower, int modifiedPower) {
    final double changePercent = ((modifiedPower - originalPower) / originalPower) * 100;
    final isBoost = modifiedPower > originalPower;
    final isReduced = modifiedPower < originalPower;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          Row(
            children: [
              Text('$originalPower → ', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              Text(
                '$modifiedPower',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isBoost 
                        ? Colors.greenAccent 
                        : isReduced ? Colors.redAccent : Colors.grey
                ),
              ),
              if (changePercent != 0.0) ...[
                const SizedBox(width: 4),
                Text(
                  '(${isBoost ? "+" : ""}${changePercent.toInt()}%)',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isBoost ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterId, String label) {
    final isSelected = _moveFilter == filterId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _moveFilter = filterId;
          });
        }
      },
      selectedColor: AppTheme.pokemonRed,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
        color: isSelected ? AppTheme.pokemonRed : const Color(0xFFE5E7EB),
      ),
      showCheckmark: false,
    );
  }

  void _showAbilityDetailsFromDetailScreen(
    BuildContext context,
    int abilityId,
    String abilityName,
    String abilityEffect,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final db = ref.read(databaseProvider);
    final pokemonsList = await db.getPokemonsForAbility(abilityId);

    // Group pokemons by Normal and Hidden status
    final List<Pokemon> normalUsers = [];
    final List<Pokemon> hiddenUsers = [];

    for (final item in pokemonsList) {
      final Pokemon p = item['pokemon'];
      final bool isHidden = item['isHidden'] ?? false;
      if (isHidden) {
        hiddenUsers.add(p);
      } else {
        normalUsers.add(p);
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      abilityName,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 12),

                    // Description Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        abilityEffect,
                        style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pokémon possessing this ability
                    Text(
                      'Pokémon with this Ability',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 16),

                    // Normal Users
                    if (normalUsers.isNotEmpty) ...[
                      const Text(
                        'Normal Ability',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.pokemonRed),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: normalUsers.map((p) {
                          final pColor = _getTypeColor(p.type1);
                          final isCurrent = p.id == widget.pokemon.id;
                          return ActionChip(
                            backgroundColor: isCurrent
                                ? (isDark ? AppTheme.pokemonRed.withValues(alpha: 0.2) : AppTheme.pokemonRed.withValues(alpha: 0.1))
                                : (isDark ? const Color(0xFF161616) : Colors.white),
                            side: BorderSide(
                              color: isCurrent
                                  ? AppTheme.pokemonRed
                                  : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                              width: isCurrent ? 1.5 : 1.0,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            label: Text(
                              p.name + (isCurrent ? ' (Current)' : ''),
                              style: TextStyle(
                                color: isCurrent ? AppTheme.pokemonRed : pColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              if (!isCurrent) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PokemonDetailScreen(pokemon: p)),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Hidden Users
                    if (hiddenUsers.isNotEmpty) ...[
                      const Text(
                        'Hidden Ability (HIDDEN)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purpleAccent),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hiddenUsers.map((p) {
                          final pColor = _getTypeColor(p.type1);
                          final isCurrent = p.id == widget.pokemon.id;
                          return ActionChip(
                            backgroundColor: isCurrent
                                ? (isDark ? AppTheme.pokemonRed.withValues(alpha: 0.2) : AppTheme.pokemonRed.withValues(alpha: 0.1))
                                : (isDark ? const Color(0xFF161616) : Colors.white),
                            side: BorderSide(
                              color: isCurrent
                                  ? AppTheme.pokemonRed
                                  : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                              width: isCurrent ? 1.5 : 1.0,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            label: Text(
                              p.name + (isCurrent ? ' (Current)' : ''),
                              style: TextStyle(
                                color: isCurrent ? AppTheme.pokemonRed : pColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              if (!isCurrent) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PokemonDetailScreen(pokemon: p)),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMoveDetailsFromDetailScreen(
    BuildContext context,
    int moveId,
    String moveName,
    String moveDescription,
    String moveType,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final color = _getTypeColor(moveType);

    final db = ref.read(databaseProvider);
    final pokemonsList = await db.getPokemonsForMove(moveId);

    // Group pokemons by learn method
    final Map<String, List<Map<String, dynamic>>> grouped = {
      'level': [],
      'tm': [],
      'tutor': [],
      'egg': [],
    };
    for (final item in pokemonsList) {
      final method = item['learnMethod'] ?? 'level';
      if (grouped.containsKey(method)) {
        grouped[method]!.add(item);
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle line
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header: Move Name & Type Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            moveName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            moveType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        moveDescription,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // List of Pokemon that can learn this move
                    Text(
                      'Pokémon that can learn this Move',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Render grouped users
                    ...grouped.entries.map((entry) {
                      final String method = entry.key;
                      final List<Map<String, dynamic>> items = entry.value;

                      if (items.isEmpty) return const SizedBox.shrink();

                      String sectionTitle = 'Level Up';
                      Color sectionColor = Colors.amber;
                      if (method == 'tm') {
                        sectionTitle = 'TM / TR';
                        sectionColor = Colors.blue;
                      } else if (method == 'tutor') {
                        sectionTitle = 'Tutor';
                        sectionColor = Colors.green;
                      } else if (method == 'egg') {
                        sectionTitle = 'Egg';
                        sectionColor = Colors.purple;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: sectionColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sectionTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: items.map((item) {
                              final Pokemon p = item['pokemon'];
                              final level = item['levelLearned'];
                              final pColor = _getTypeColor(p.type1);
                              final isCurrent = p.id == widget.pokemon.id;

                              String label = p.name;
                              if (method == 'level' && level != null) {
                                label += ' (Lvl $level)';
                              }
                              if (isCurrent) {
                                label += ' (Current)';
                              }

                              return ActionChip(
                                backgroundColor: isCurrent
                                    ? (isDark ? AppTheme.pokemonRed.withValues(alpha: 0.2) : AppTheme.pokemonRed.withValues(alpha: 0.1))
                                    : (isDark ? const Color(0xFF161616) : Colors.white),
                                side: BorderSide(
                                  color: isCurrent
                                      ? AppTheme.pokemonRed
                                      : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                                  width: isCurrent ? 1.5 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                label: Text(
                                  label,
                                  style: TextStyle(
                                    color: isCurrent ? AppTheme.pokemonRed : pColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  if (!isCurrent) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PokemonDetailScreen(pokemon: p),
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// -------------------------------------------------------------
  /// CORE COLOR UTILITIES
  /// -------------------------------------------------------------
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
        return const Color(0xFFA98FEE);
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

  /// -------------------------------------------------------------
  /// TAB 4: SHOWDOWN DAMAGE CALCULATOR TAB
  /// -------------------------------------------------------------
  Widget _buildCalculatorTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final statsState = ref.watch(statsCalculatorProvider);
    final statsNotifier = ref.read(statsCalculatorProvider.notifier);
    final calculatedStats = statsNotifier.getCalculatedStats(widget.pokemon);

    final movesAsync = ref.watch(pokemonMovesStreamProvider(widget.pokemon.id));
    final abilitiesAsync = ref.watch(pokemonAbilitiesStreamProvider(widget.pokemon.id));

    return movesAsync.when(
      data: (movesList) {
        final movesWithPower = movesList.where((m) => (m['power'] ?? 0) > 0).toList();
        final displayMoves = movesWithPower.isNotEmpty ? movesWithPower : movesList;
        if (_calcSelectedMove == null && displayMoves.isNotEmpty) {
          _calcSelectedMove = displayMoves.first;
        }

        return abilitiesAsync.when(
          data: (abilitiesList) {
            final activeAbilities = ['None'] + abilitiesList.map((a) => a['name'].toString()).toList();
            if (_calcAttackerAbility == 'None' && abilitiesList.isNotEmpty) {
              _calcAttackerAbility = abilitiesList.first['name'].toString();
            }

            // --- MATH CALCULATIONS ---
            final int attackerLevel = statsState.level;
            final String moveCategory = (_calcSelectedMove?['damage_class'] ?? 'physical').toString().toLowerCase();
            final String moveType = (_calcSelectedMove?['type'] ?? 'normal').toString().toLowerCase();
            final double basePower = (_calcSelectedMove?['power'] ?? 0).toDouble();

            // Attacker stats
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

            // Defender HP and Defensive stats
            int defenderHP = 100;
            int activeDefendingStat = 100;
            if (_calcDefender != null) {
              defenderHP = StatCalculator.calculateHp(
                base: _calcDefender!.baseHp,
                iv: _calcDefenderIvs['hp'] ?? 31,
                ev: _calcDefenderEvs['hp'] ?? 0,
                level: _calcDefenderLevel,
                isShedinja: _calcDefender!.name.toLowerCase() == 'shedinja',
              );

              double getDefenderNatureModifier(String statName) {
                return ref.read(statsCalculatorProvider.notifier).getNatureMultiplier(_calcDefenderNature, statName);
              }

              if (moveCategory == 'physical') {
                activeDefendingStat = StatCalculator.calculateOtherStat(
                  base: _calcDefender!.baseDef,
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
                  base: _calcDefender!.baseSpDef,
                  iv: _calcDefenderIvs['spd'] ?? 31,
                  ev: _calcDefenderEvs['spd'] ?? 0,
                  level: _calcDefenderLevel,
                  natureModifier: getDefenderNatureModifier('Sp. Def'),
                );
                if (_calcDefenderItem == 'Assault Vest' || _calcDefenderItem == 'Eviolite') {
                  activeDefendingStat = (activeDefendingStat * 1.5).round();
                }
              }
            }

            // Damage multipliers
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

            final bool isStab = (widget.pokemon.type1.toLowerCase() == moveType ||
                (widget.pokemon.type2?.toLowerCase() == moveType));
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

            double typeEffectiveness = 1.0;
            if (_calcDefender != null) {
              typeEffectiveness = _getTypeEffectiveness(moveType, _calcDefender!.type1, _calcDefender!.type2);
              multiplier *= typeEffectiveness;

              if (_calcAttackerItem == 'Expert Belt' && typeEffectiveness > 1.0) {
                multiplier *= 1.2;
              }
            }

            // Final ranges
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
              if (_calcDefender == null) return 'No target defender selected.';
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ATTACKER & MOVE SECTION (BASIC) ---
                  _buildSectionHeader('ATTACKER & MOVE CONFIGURATION', Icons.flash_on_outlined),
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
                        // Move Dropdown
                        const Text('Select Active Move', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 16),

                        // Interactive Weather Chips
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
                        const SizedBox(height: 16),

                        // Interactive Terrains
                        const Text('Terrain Condition', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['None', 'Electric', 'Grassy', 'Psychic', 'Misty'].map((t) {
                            final bool isSel = _calcTerrain == t;
                            IconData terrainIcon = Icons.terrain;
                            Color activeCol = Colors.yellow;
                            if (t == 'Grassy') {
                              terrainIcon = Icons.grass;
                              activeCol = Colors.green;
                            } else if (t == 'Psychic') {
                              terrainIcon = Icons.psychology;
                              activeCol = Colors.purple;
                            } else if (t == 'Misty') {
                              terrainIcon = Icons.cloud;
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
                        const SizedBox(height: 16),

                        // Switches Grid
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Switch(
                                    value: _calcAttackerBurned,
                                    activeColor: AppTheme.pokemonRed,
                                    onChanged: (val) {
                                      setState(() {
                                        _calcAttackerBurned = val;
                                      });
                                    },
                                  ),
                                  const Text('Burned', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Switch(
                                    value: _calcCriticalHit,
                                    activeColor: AppTheme.pokemonRed,
                                    onChanged: (val) {
                                      setState(() {
                                        _calcCriticalHit = val;
                                      });
                                    },
                                  ),
                                  const Text('Critical', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Switch(
                                    value: _calcDoubleBattle,
                                    activeColor: AppTheme.pokemonRed,
                                    onChanged: (val) {
                                      setState(() {
                                        _calcDoubleBattle = val;
                                      });
                                    },
                                  ),
                                  const Text('Double', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF2D2D2D), height: 24),

                        // Total Base Power Panel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('BASE MOVE POWER', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('${basePower.toInt()}', style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green, width: 1.2),
                              ),
                              child: Column(
                                children: [
                                  const Text('MODIFIED POWER', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(
                                    '${modifiedPower.round()}',
                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- DEFENDER & REAL DAMAGE SECTION (ADVANCED) ---
                  _buildSectionHeader('ADVANCED REAL DAMAGE (TARGET-BASED)', Icons.shield_outlined),
                  const SizedBox(height: 12),

                  if (_calcDefender == null) ...[
                    GestureDetector(
                      onTap: () => _showDefenderSelectionSheet(context),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF121212) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_moderator, size: 28, color: AppTheme.pokemonRed),
                            SizedBox(height: 8),
                            Text(
                              '+ SELECT TARGET DEFENDER',
                              style: TextStyle(color: AppTheme.pokemonRed, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Defender Stats configuration panel
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
                          // Selected Defender Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF3F4F6),
                                    child: Text(
                                      _calcDefender!.name.substring(0, 1).toUpperCase(),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _calcDefender!.name.toUpperCase(),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor),
                                      ),
                                      Row(
                                        children: [
                                          _buildBadgeMini(_calcDefender!.type1),
                                          if (_calcDefender!.type2 != null) ...[
                                            const SizedBox(width: 4),
                                            _buildBadgeMini(_calcDefender!.type2!),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    _calcDefender = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF2D2D2D), height: 24),

                          // Target Level and Nature
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Target Level: $_calcDefenderLevel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                                      ),
                                      child: Slider(
                                        value: _calcDefenderLevel.toDouble(),
                                        min: 1,
                                        max: 100,
                                        activeColor: AppTheme.pokemonRed,
                                        inactiveColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
                                        onChanged: (val) {
                                          setState(() {
                                            _calcDefenderLevel = val.toInt();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Target Nature', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
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
                                          items: alphabeticalNatures.keys.map((natureKey) {
                                            return DropdownMenuItem<String>(
                                              value: natureKey,
                                              child: Text(alphabeticalNatures[natureKey]!['name'], style: TextStyle(fontSize: 12, color: primaryColor)),
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
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Target Item dropdown
                          const Text('Target Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
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
                                    child: Text(item, style: TextStyle(fontSize: 12, color: primaryColor)),
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
                          const SizedBox(height: 16),

                          // Fast Preset Buttons
                          const Text('EV Presets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildPresetChip('Bulky', 252, 0, 0),
                                const SizedBox(width: 6),
                                _buildPresetChip('Physically Def', 252, 252, 0),
                                const SizedBox(width: 6),
                                _buildPresetChip('Specially Def', 252, 0, 252),
                                const SizedBox(width: 6),
                                _buildPresetChip('Offensive', 0, 4, 0),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Stat rows for HP, Def, SpD
                          _buildTargetStatRow(
                            label: 'HP (Hit Points)',
                            statKey: 'hp',
                            baseValue: _calcDefender!.baseHp,
                            statColor: const Color(0xFF38BDF8),
                          ),
                          _buildTargetStatRow(
                            label: 'Defense',
                            statKey: 'def',
                            baseValue: _calcDefender!.baseDef,
                            statColor: const Color(0xFFFBBF24),
                          ),
                          _buildTargetStatRow(
                            label: 'Sp. Def',
                            statKey: 'spd',
                            baseValue: _calcDefender!.baseSpDef,
                            statColor: const Color(0xFF34D399),
                          ),
                          const SizedBox(height: 20),

                          // SHOWDOWN CALCULATION RESULT CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.pokemonRed, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.pokemon.name.toUpperCase()} VS ${_calcDefender!.name.toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.pokemonRed),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_calcSelectedMove?['name'].toString().toUpperCase()}:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$minDamageRounded - $maxDamageRounded dmg (${minPercent.toStringAsFixed(1)}% - ${maxPercent.toStringAsFixed(1)}%)',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: primaryColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getKoChanceString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.greenAccent),
                                ),
                                const SizedBox(height: 16),

                                // VISUAL HEALTH BAR GRAPH
                                const Text('VISUAL DAMAGE OUTCOME:', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 20,
                                    color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                                    child: Stack(
                                      children: [
                                        // Remaining HP bar
                                        FractionallySizedBox(
                                          widthFactor: 1.0,
                                          child: Container(color: Colors.green),
                                        ),
                                        // Max damage overlay (represented as shaded red/orange block)
                                        if (maxPercent > 0)
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: FractionallySizedBox(
                                              widthFactor: (maxPercent / 100.0).clamp(0.0, 1.0),
                                              child: Container(
                                                color: Colors.redAccent.withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                        // Min damage overlay (darker red block)
                                        if (minPercent > 0)
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: FractionallySizedBox(
                                              widthFactor: (minPercent / 100.0).clamp(0.0, 1.0),
                                              child: Container(
                                                color: Colors.red.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          ),
                                        // Visual text centered
                                        Center(
                                          child: Text(
                                            '${(100.0 - maxPercent).clamp(0.0, 100.0).toStringAsFixed(1)}% - ${(100.0 - minPercent).clamp(0.0, 100.0).toStringAsFixed(1)}% HP Left',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
          error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: primaryColor))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
      error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: primaryColor))),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.pokemonRed),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, int hp, int def, int spd) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      onPressed: () {
        setState(() {
          _calcDefenderEvs['hp'] = hp;
          _calcDefenderEvs['def'] = def;
          _calcDefenderEvs['spd'] = spd;
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTargetStatRow({
    required String label,
    required String statKey,
    required int baseValue,
    required Color statColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final int ev = _calcDefenderEvs[statKey] ?? 0;
    final int iv = _calcDefenderIvs[statKey] ?? 31;

    double getDefenderNatureModifier(String statName) {
      return ref.read(statsCalculatorProvider.notifier).getNatureMultiplier(_calcDefenderNature, statName);
    }

    int finalValue = 0;
    if (statKey == 'hp') {
      finalValue = StatCalculator.calculateHp(
        base: baseValue,
        iv: iv,
        ev: ev,
        level: _calcDefenderLevel,
        isShedinja: _calcDefender?.name.toLowerCase() == 'shedinja',
      );
    } else {
      String fullStatName = '';
      if (statKey == 'def') fullStatName = 'Defense';
      if (statKey == 'spd') fullStatName = 'Sp. Def';

      finalValue = StatCalculator.calculateOtherStat(
        base: baseValue,
        iv: iv,
        ev: ev,
        level: _calcDefenderLevel,
        natureModifier: getDefenderNatureModifier(fullStatName),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: primaryColor)),
              Text(
                'Value: $finalValue (Base: $baseValue)',
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EV: $ev', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 1.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                      ),
                      child: Slider(
                        value: ev.toDouble(),
                        min: 0,
                        max: 252,
                        divisions: 63,
                        activeColor: statColor,
                        inactiveColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
                        onChanged: (val) {
                          setState(() {
                            _calcDefenderEvs[statKey] = val.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IV: $iv', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 1.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                      ),
                      child: Slider(
                        value: iv.toDouble(),
                        min: 0,
                        max: 31,
                        divisions: 31,
                        activeColor: statColor.withOpacity(0.7),
                        inactiveColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
                        onChanged: (val) {
                          setState(() {
                            _calcDefenderIvs[statKey] = val.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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

  void _showDefenderSelectionSheet(BuildContext context) {
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
            return Consumer(
              builder: (context, ref, child) {
                final listAsync = ref.watch(pokedexProvider);
                return listAsync.when(
                  data: (allPokemons) {
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
                                'Select Defender Target',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search target by name...',
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
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                                        child: Text(
                                          p.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                                        ),
                                      ),
                                      title: Text(
                                        p.name.toUpperCase(),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor),
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
                                          _calcDefender = p;
                                          // Reset defender IVs and EVs to presets on pick
                                          _calcDefenderIvs['hp'] = 31;
                                          _calcDefenderIvs['def'] = 31;
                                          _calcDefenderIvs['spd'] = 31;
                                          _calcDefenderEvs['hp'] = 0;
                                          _calcDefenderEvs['def'] = 0;
                                          _calcDefenderEvs['spd'] = 0;
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
                  loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed))),
                  error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: primaryColor))),
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
    if (defenderType2 != null && defenderType2.toLowerCase() != 'none') {
      mult *= getSingleTypeMultiplier(moveType, defenderType2);
    }
    return mult;
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
      'offense_0.5x': ['dark', 'steel'],
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
