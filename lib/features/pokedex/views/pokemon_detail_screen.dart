import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/learn_method_utils.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/core/widgets/learn_method_badge.dart';
import 'package:libredex/features/calculator/utils/held_items_data.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:libredex/features/abilitydex/views/ability_detail_screen.dart';
import 'package:libredex/features/movedex/views/move_detail_screen.dart';
import 'package:libredex/features/pokedex/utils/pokemon_data_helpers.dart';
import 'package:libredex/core/data/ev_yield_data.dart';
import 'package:libredex/core/data/pokedex_entry_data.dart';
import 'package:libredex/core/data/species_data.dart';
import 'package:libredex/core/theme/app_spacing.dart';
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
  final List<Pokemon> forms;
  final int initialFormIndex;

  const PokemonDetailScreen({super.key, required this.forms, this.initialFormIndex = 0});

  @override
  ConsumerState<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _moveFilter = 'all';
  late int _selectedFormIndex;

  Pokemon get _activePokemon => widget.forms[_selectedFormIndex];

  @override
  void initState() {
    super.initState();
    _selectedFormIndex = widget.initialFormIndex < widget.forms.length ? widget.initialFormIndex : 0;
    _tabController = TabController(length: 3, vsync: this);
    _resetStatsForActiveForm();
  }

  /// Resets the EV/IV sliders whenever the displayed form changes.
  void _resetStatsForActiveForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(statsCalculatorProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addActivePokemonToTeam() async {
    final added = await ref.read(teamBuilderProvider.notifier).addPokemon(_activePokemon.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${_activePokemon.name} is on your team.'
              : 'Your team is full. Open Team Builder to replace a slot.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final dexNumber = _activePokemon.nationalDexNumber > 0 ? _activePokemon.nationalDexNumber : _activePokemon.id;
    final isFavorite = ref.watch(favoritePokemonProvider).contains(dexNumber);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          '#${_activePokemon.nationalDexNumber > 0 ? _activePokemon.nationalDexNumber.toString().padLeft(3, '0') : _activePokemon.id.toString().padLeft(3, '0')} ${_activePokemon.name.toUpperCase()}',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor, fontSize: 18),
          // Long form names ("#1007 KORAIDON-LIMITED-BUILD" & co.) must
          // ellipsize instead of overflowing next to the action icons.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            color: primaryColor,
            tooltip: 'Add to team',
            onPressed: () => _addActivePokemonToTeam(),
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
            color: isFavorite ? Colors.amber : primaryColor,
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () => ref.read(favoritePokemonProvider.notifier).toggle(dexNumber),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
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
      ),
      body: Column(
        children: [
          if (widget.forms.length > 1)
            Container(
              height: 48,
              color: isDark ? Colors.black : const Color(0xFFF9FAFB),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: widget.forms.length,
                itemBuilder: (context, index) {
                  final p = widget.forms[index];
                  final isSelected = index == _selectedFormIndex;
                  String label = p.form;
                  if (label == 'normal') label = 'Normal';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFormIndex = index;
                        _resetStatsForActiveForm();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.pokemonRed : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD1D5DB)),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildStatsTab(),
                _buildMovesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    final doubleEffs = TypeEfficiencyCalculator.getCombinedEffectiveness(
      _activePokemon.type1,
      _activePokemon.type2,
    );

    // Forms without their own render (transportation/cosplay forms) already
    // point at the base artwork in the bundle. Passing the base form's URLs
    // as fallbacks also keeps every form looking right on flaky networks.
    final Pokemon baseForm = widget.forms.firstWhere(
      (p) => p.form == 'normal',
      orElse: () => widget.forms.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: AppSpacing.topContentGap, bottom: AppSpacing.bottomScrollPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShinySlider(
            normalImageUrl: _activePokemon.spriteUrl,
            shinyImageUrl: _activePokemon.shinySpriteUrl,
            normalFallbackUrl: baseForm.spriteUrl,
            shinyFallbackUrl: baseForm.shinySpriteUrl,
            normalLabel: 'Normal',
            shinyLabel: 'Shiny',
            pokemonId: _activePokemon.id,
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeBadge(_activePokemon.type1),
              if (_activePokemon.type2 != null) ...[
                const SizedBox(width: 12),
                _buildTypeBadge(_activePokemon.type2!),
              ],
            ],
          ),
          const SizedBox(height: 24),

          _buildPokedexEntryCard(),
          const SizedBox(height: 20),

          _buildAbilitiesCard(),
          const SizedBox(height: 20),

          _buildBiologicalDataCard(),
          const SizedBox(height: 20),

          _buildEvolutionCard(),
          const SizedBox(height: 20),

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

  Widget _buildPokedexEntryCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dexNumber = _activePokemon.nationalDexNumber > 0 ? _activePokemon.nationalDexNumber : _activePokemon.id;
    final entriesAsync = ref.watch(pokedexEntryDatasetProvider);
    final entry = entriesAsync.hasValue ? entriesAsync.requireValue[dexNumber] : null;
    if (entry == null || (entry.genus.isEmpty && entry.flavor.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.genus.isNotEmpty)
            Text(
              entry.genus,
              style: const TextStyle(color: AppTheme.pokemonRed, fontWeight: FontWeight.w900, letterSpacing: 0.3),
            ),
          if (entry.genus.isNotEmpty) const SizedBox(height: 8),
          Text(
            entry.flavor,
            style: TextStyle(
              color: isDark ? Colors.grey[200] : const Color(0xFF1F2937),
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Small contextual note shown when a form borrows the base species'
  /// learnset or abilities (bundle Mega/G-Max forms and Z-A Megas whose
  /// Champions data has not shipped yet).
  Widget _buildFallbackNote(String message, {required String source, required bool isDark}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: Colors.deepPurpleAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$message ($source)',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final abilitiesAsync = ref.watch(pokemonAbilitiesStreamProvider(_activePokemon.id));
    final abilityFallbackFrom = abilitiesAsync.valueOrNull
        ?.firstWhere((a) => a['abilityFallbackFrom'] != null, orElse: () => const <String, dynamic>{})
            ['abilityFallbackFrom'] as String?;

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
          if (abilityFallbackFrom != null) ...[
            _buildFallbackNote(
              'Using base species abilities for this form.',
              source: abilityFallbackFrom,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          abilitiesAsync.when(
            data: (abilities) {
              if (abilities.isEmpty) {
                return AppEmptyState(
                  icon: Icons.auto_awesome_rounded,
                  title: 'No abilities linked yet',
                  message: 'Rebuild the bundled links now, or open Settings and use “Fix Moves & Abilities Links”.',
                  actionLabel: 'Fix links now',
                  onAction: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
                );
              }
              final sortedAbilities = List<Map<String, dynamic>>.from(abilities)
                ..sort((a, b) {
                  final bool aHidden = a['isHidden'] ?? false;
                  final bool bHidden = b['isHidden'] ?? false;
                  if (aHidden && !bHidden) return 1;
                  if (!aHidden && bHidden) return -1;
                  return 0;
                });

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedAbilities.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ability = sortedAbilities[index];
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

  void _navigateToPokemon(int targetId) async {
    if (targetId == _activePokemon.id) return;

    final db = ref.read(pokemonRepositoryProvider).db;
    final targetPokemon = await (db.select(db.pokemonTable)..where((t) => t.id.equals(targetId))).getSingleOrNull();

    if (targetPokemon != null && mounted) {
      final int targetDexNum = targetPokemon.nationalDexNumber > 0 ? targetPokemon.nationalDexNumber : targetPokemon.id;
      final allForms = await (db.select(db.pokemonTable)..where((t) => t.nationalDexNumber.equals(targetDexNum))).get();
      final formsList = allForms.isNotEmpty ? allForms : [targetPokemon];
      final targetIdx = formsList.indexWhere((p) => p.id == targetId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PokemonDetailScreen(
            forms: formsList,
            initialFormIndex: targetIdx >= 0 ? targetIdx : 0,
          ),
        ),
      );
    }
  }

  Widget _buildEvolutionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int dexNum = _activePokemon.nationalDexNumber > 0 ? _activePokemon.nationalDexNumber : _activePokemon.id;
    final evoAsync = ref.watch(pokemonEvolutionChainProvider((dexNum: dexNum, forms: widget.forms)));

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
          Row(
            children: [
              Text(
                'Evolutions & Forms',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const Spacer(),
              Icon(Icons.account_tree_outlined, size: 18, color: AppTheme.pokemonRed),
            ],
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),
          evoAsync.when(
            data: (steps) {
              if (steps.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      'This Pokémon does not evolve.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isFormEvolution = step.form != 'normal';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isFormEvolution
                            ? AppTheme.pokemonRed.withValues(alpha: 0.4)
                            : (isDark ? const Color(0xFF2B2B2B) : const Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (isFormEvolution)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.pokemonRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.pokemonRed, width: 0.8),
                              ),
                              child: Text(
                                step.form.toUpperCase(),
                                style: const TextStyle(color: AppTheme.pokemonRed, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _navigateToPokemon(step.fromId),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    children: [
                                      if (step.fromSprite != null && step.fromSprite!.isNotEmpty)
                                        CachedNetworkImage(
                                          imageUrl: step.fromSprite!,
                                          height: 54,
                                          width: 54,
                                          fit: BoxFit.contain,
                                          errorWidget: (context, url, error) => const Icon(Icons.catching_pokemon, size: 40, color: Colors.grey),
                                        )
                                      else
                                        const Icon(Icons.catching_pokemon, size: 40, color: Colors.grey),
                                      const SizedBox(height: 4),
                                      Text(
                                        step.fromName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: step.fromId == _activePokemon.id ? AppTheme.pokemonRed : (isDark ? Colors.white : Colors.black87),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      step.trigger,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.pokemonRed, size: 20),
                                ],
                              ),
                            ),

                            Expanded(
                              child: InkWell(
                                onTap: () => _navigateToPokemon(step.toId),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    children: [
                                      if (step.toSprite != null && step.toSprite!.isNotEmpty)
                                        CachedNetworkImage(
                                          imageUrl: step.toSprite!,
                                          height: 54,
                                          width: 54,
                                          fit: BoxFit.contain,
                                          errorWidget: (context, url, error) => const Icon(Icons.catching_pokemon, size: 40, color: Colors.grey),
                                        )
                                      else
                                        const Icon(Icons.catching_pokemon, size: 40, color: Colors.grey),
                                      const SizedBox(height: 4),
                                      Text(
                                        step.toName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: step.toId == _activePokemon.id ? AppTheme.pokemonRed : (isDark ? Colors.white : Colors.black87),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                ),
              ),
            ),
            error: (err, stack) => Text('Could not load evolutions: $err', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final statsState = ref.watch(statsCalculatorProvider);
    final statsNotifier = ref.read(statsCalculatorProvider.notifier);
    final calculatedStats = statsNotifier.getCalculatedStats(_activePokemon);

    final int remainingEvs = 508 - statsState.totalEvs;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: AppSpacing.topContentGap, bottom: AppSpacing.bottomScrollPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                                  Text(name, style: TextStyle(color: primaryColor, fontSize: 14)),
                                  Text(detailText, style: TextStyle(
                                    color: up != null ? (isDark ? Colors.tealAccent : const Color(0xFF0F766E)) : Colors.grey,
                                    fontSize: 11,
                                  )),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) statsNotifier.updateNature(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Held Item',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _showItemPickerForStats(statsNotifier),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: statsState.heldItem != 'None'
                                ? AppTheme.pokemonRed.withValues(alpha: 0.5)
                                : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.backpack_outlined,
                                size: 16,
                                color: statsState.heldItem != 'None' ? AppTheme.pokemonRed : Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                statsState.heldItem,
                                style: TextStyle(
                                  color: statsState.heldItem != 'None' ? primaryColor : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (statsState.heldItem != 'None')
                              GestureDetector(
                                onTap: () => statsNotifier.updateHeldItem('None'),
                                child: const Icon(Icons.close, size: 16, color: Colors.grey),
                              )
                            else
                              const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
                          ],
                        ),
                      ),
                    ),
                    if (statsState.heldItem != 'None') ...[
                      const SizedBox(height: 4),
                      Text(
                        HeldItemsData.findByName(statsState.heldItem)?.description ?? '',
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                baseValue: _activePokemon.baseHp,
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
                baseValue: _activePokemon.baseAtk,
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
                baseValue: _activePokemon.baseDef,
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
                baseValue: _activePokemon.baseSpAtk,
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
                baseValue: _activePokemon.baseSpDef,
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
                baseValue: _activePokemon.baseSpd,
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

  Widget _buildMovesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final movesAsync = ref.watch(pokemonMovesStreamProvider(_activePokemon.id));

    // Forms without direct learnset rows receive the base species learnset
    // tagged with `learnsetFallbackFrom` by the repository.
    final fallbackFrom = movesAsync.valueOrNull
        ?.firstWhere((m) => m['learnsetFallbackFrom'] != null, orElse: () => const <String, dynamic>{})
            ['learnsetFallbackFrom'] as String?;

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
              _buildFilterChip('tm', learnMethodLabel('machine')),
              const SizedBox(width: 8),
              _buildFilterChip('tutor', 'Tutor'),
              const SizedBox(width: 8),
              _buildFilterChip('egg', 'Egg'),
              const SizedBox(width: 8),
              _buildFilterChip('train', learnMethodLabel('train')),
            ],
          ),
        ),
        if (fallbackFrom != null)
          _buildFallbackNote(
            'Using base species learnset for this form.',
            source: fallbackFrom,
            isDark: isDark,
          ),
        Expanded(
          child: movesAsync.when(
            data: (movesList) {
              if (movesList.isEmpty) {
                return AppEmptyState(
                  icon: Icons.flash_off_rounded,
                  title: 'No moves linked yet',
                  message: 'Rebuild the bundled links now, or open Settings and use “Fix Moves & Abilities Links”.',
                  actionLabel: 'Fix links now',
                  onAction: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
                );
              }

              final filteredMoves = movesList.where((item) {
                if (_moveFilter == 'all') return true;
                final kind = learnMethodKind((item['learnMethod'] ?? '').toString());
                switch (_moveFilter) {
                  case 'level':
                    return kind == LearnMethodKind.level;
                  case 'tm':
                    return kind == LearnMethodKind.machine;
                  case 'tutor':
                    return kind == LearnMethodKind.tutor;
                  case 'egg':
                    return kind == LearnMethodKind.egg;
                  case 'train':
                    // Pokémon Champions trains moves with Victory Points.
                    return (item['learnMethod'] ?? '').toString() == 'train';
                  default:
                    return false;
                }
              }).toList();

              if (filteredMoves.isEmpty) {
                return AppEmptyState(
                  icon: Icons.filter_alt_off_rounded,
                  title: 'No ${_moveFilter == "tm" ? learnMethodLabel("machine") : _moveFilter} moves',
                  message: 'This Pokémon has no bundled moves for the selected learn method.',
                  actionLabel: 'Show all moves',
                  onAction: () => setState(() => _moveFilter = 'all'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: 4, bottom: AppSpacing.bottomScrollPadding),
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
                            child: LearnMethodBadge(
                              method: learnMethod,
                              level: levelLearned,
                              compact: true,
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
                            Text(
                              description,
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 12),
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

  void _showItemPickerForStats(StatsCalculator notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final items = HeldItemsData.allItems
              .where((i) =>
                  i.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  i.category.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5, expand: false,
            builder: (ctx, sc) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    autofocus: true,
                    onChanged: (v) => setSheet(() => searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search held items...',
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
                        title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13)),
                        subtitle: Text(item.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        onTap: () { notifier.updateHeldItem(item.name); Navigator.pop(ctx); },
                      );
                    },
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  void _showAbilityDetailsFromDetailScreen(
    BuildContext context,
    int abilityId,
    String abilityName,
    String abilityEffect,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbilityDetailScreen(
          abilityId: abilityId,
          abilityName: abilityName,
        ),
      ),
    );
  }

  void _showMoveDetailsFromDetailScreen(
    BuildContext context,
    int moveId,
    String moveName,
    String moveDescription,
    String moveType,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoveDetailScreen(
          moveId: moveId,
          moveName: moveName,
        ),
      ),
    );
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

  Widget _buildBiologicalDataCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final int bst = _activePokemon.baseHp +
        _activePokemon.baseAtk +
        _activePokemon.baseDef +
        _activePokemon.baseSpAtk +
        _activePokemon.baseSpDef +
        _activePokemon.baseSpd;

    final evYieldAsync = ref.watch(evYieldDatasetProvider);
    final realEvYield = evYieldAsync.hasValue ? evYieldAsync.requireValue[_activePokemon.id] : null;
    final String evYield = realEvYield?.label ?? '${PokemonDataHelpers.getEvYield(_activePokemon)} (estimated)';

    // Authoritative facts from the bundled PokeAPI dataset. While the asset is
    // still decoding we simply omit these rows rather than showing guesses.
    final datasetAsync = ref.watch(speciesDatasetProvider);
    final dataset = datasetAsync.hasValue ? datasetAsync.requireValue : null;
    final int dexNumber = _activePokemon.nationalDexNumber > 0
        ? _activePokemon.nationalDexNumber
        : _activePokemon.id;
    final FormFacts? form =
        dataset?.formFacts(_activePokemon.id, nationalDexNumber: dexNumber);
    final SpeciesFacts? species = dataset?.speciesFacts(dexNumber);

    Color bstColor = Colors.grey;
    String bstLabel = 'Standard BST';
    if (bst >= 600) {
      bstColor = Colors.purpleAccent;
      bstLabel = 'Top Tier / Legend';
    } else if (bst >= 500) {
      bstColor = Colors.tealAccent;
      bstLabel = 'Fully Evolved / High Power';
    } else if (bst >= 400) {
      bstColor = Colors.blueAccent;
      bstLabel = 'Mid Tier';
    }

    // Form-level gender locks (Indeedee-Female & co.) win over the raw
    // species ratio that PokéAPI reports.
    final gender = dataset?.genderFor(_activePokemon.id, nationalDexNumber: dexNumber) ?? species?.gender;
    final bool isGenderless = gender?.genderless ?? true;
    final double malePct = gender?.malePercent ?? 0;
    final double femalePct = gender?.femalePercent ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Breeding, Training & EV Yields',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bstLabel,
                      style: TextStyle(color: bstColor, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bstColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bstColor, width: 1.0),
                ),
                child: Text(
                  '$bst BST',
                  style: TextStyle(color: bstColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Divider(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB), height: 24),

          if (form != null) ...[
            _buildBioRow('Height', form.heightLabel, Icons.height_rounded, isDark),
            const SizedBox(height: 12),
            // Weight feeds weight-based damage gimmicks (Low Kick, Grass
            // Knot, Heavy Slam, Heat Crash) — those are resolved live in the
            // damage calculator, so this row just reports the weight itself.
            _buildBioRow('Weight', form.weightLabel, Icons.monitor_weight_rounded, isDark),
            const SizedBox(height: 12),
            _buildBioRow(
              'Base EXP',
              '${form.baseExp} EXP when defeated',
              Icons.military_tech_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
          ],

          _buildBioRow('EV Yield', evYield, Icons.fitness_center_rounded, isDark),
          const SizedBox(height: 12),

          if (species != null) ...[
            _buildBioRow('Egg Groups', species.eggGroupLabel, Icons.egg_rounded, isDark),
            const SizedBox(height: 12),
            if (species.canBreed) ...[
              _buildBioRow(
                'Hatch Time',
                '${species.eggCycles} cycles (~${species.eggSteps} steps)',
                Icons.timelapse_rounded,
                isDark,
              ),
              const SizedBox(height: 12),
            ],
            _buildBioRow(
              'Catch Rate',
              species.captureRateLabel,
              Icons.catching_pokemon_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildBioRow(
              'Growth Rate',
              '${species.growthRate} '
                  '(${_formatExp(species.growthTotalExp)} EXP to Lv. 100)',
              Icons.trending_up_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildBioRow(
              'Base Friendship',
              '${species.baseHappiness}',
              Icons.favorite_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
            _buildBioRow(
              'Generation',
              'Introduced in Gen ${species.generation}',
              Icons.public_rounded,
              isDark,
            ),
            const SizedBox(height: 12),
          ],

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wc_rounded, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Gender Ratio',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isGenderless)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Genderless (100% N/A)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                )
              else
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: [
                            if (malePct > 0)
                              Expanded(
                                flex: (malePct * 10).round(),
                                child: Container(color: Colors.blueAccent),
                              ),
                            if (femalePct > 0)
                              Expanded(
                                flex: (femalePct * 10).round(),
                                child: Container(color: Colors.pinkAccent),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '♂ ${GenderRatio.formatPercent(malePct)}% Male',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        Text(
                          '♀ ${GenderRatio.formatPercent(femalePct)}% Female',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats large experience totals as e.g. "1,059,860".
  String _formatExp(int value) => value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );

  Widget _buildBioRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

}
