import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';
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



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildStatsTab(),
          _buildMovesTab(),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0),
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
                padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 80),
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

}
