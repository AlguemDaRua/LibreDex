import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
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
    // Reset calculator state to defaults upon entering details screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statsCalculatorProvider.notifier).reset();
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

    // Relational caching placeholder simulated in English
    final List<Map<String, dynamic>> dummyAbilities = [
      {
        'name': 'Overgrow', 
        'desc': "Increases the power of Grass-type moves by 50% when the Pokémon's HP is low.", 
        'isHidden': false
      },
      {
        'name': 'Chlorophyll', 
        'desc': 'Doubles the Speed of the Pokémon in harsh sunlight conditions.', 
        'isHidden': true
      },
    ];

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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyAbilities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ability = dummyAbilities[index];
              final bool isHidden = ability['isHidden'];
              return Container(
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
                          ability['name'],
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
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ability['desc'],
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              );
            },
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
                                      color: up != null ? Colors.tealAccent : Colors.grey,
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
                ? Colors.tealAccent 
                : downIndicator ? Colors.redAccent : primaryColor
          ),
        ),
        if (upIndicator) const Text(' ▲', style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        if (downIndicator) const Text(' ▼', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
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

    // Relational caching placeholder simulated in English
    final List<Map<String, dynamic>> dummyMoves = [
      {'name': 'Tackle', 'type': 'normal', 'method': 'level', 'lvl': 1, 'power': 40, 'pp': 35},
      {'name': 'Vine Whip', 'type': 'grass', 'method': 'level', 'lvl': 3, 'power': 45, 'pp': 25},
      {'name': 'Razor Leaf', 'type': 'grass', 'method': 'level', 'lvl': 15, 'power': 55, 'pp': 25},
      {'name': 'Energy Ball', 'type': 'grass', 'method': 'machine', 'power': 90, 'pp': 10},
      {'name': 'Giga Drain', 'type': 'grass', 'method': 'tutor', 'power': 75, 'pp': 10},
      {'name': 'Grassy Glide', 'type': 'grass', 'method': 'tutor', 'power': 55, 'pp': 20},
      {'name': 'Petal Dance', 'type': 'grass', 'method': 'egg', 'power': 120, 'pp': 10},
    ];

    final filteredMoves = dummyMoves.where((move) {
      if (_moveFilter == 'all') return true;
      return move['method'] == _moveFilter;
    }).toList();

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
              _buildFilterChip('machine', 'TM / TR'),
              const SizedBox(width: 8),
              _buildFilterChip('tutor', 'Tutor'),
              const SizedBox(width: 8),
              _buildFilterChip('egg', 'Egg'),
            ],
          ),
        ),
        Expanded(
          child: filteredMoves.isEmpty
              ? const Center(
                  child: Text(
                    'No moves found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filteredMoves.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final move = filteredMoves[index];
                    final moveType = move['type'];
                    final color = _getTypeColor(moveType);
                    final hasPower = move['power'] != null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Center(
                              child: move['method'] == 'level'
                                  ? Text(
                                      'Lvl ${move['lvl']}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 11),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        move['method'].toString().toUpperCase(),
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
                                  move['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 14, 
                                    color: isDark ? Colors.white : Colors.black
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                hasPower ? 'Power: ${move['power']}' : 'Status',
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
                                'PP: ${move['pp']}',
                                style: const TextStyle(color: Colors.grey, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
