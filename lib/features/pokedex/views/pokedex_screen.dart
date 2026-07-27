import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/data/champions_catalog.dart';
import 'package:libredex/core/data/ev_yield_data.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/features/pokedex/utils/pokemon_data_helpers.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _globalShinyMode = false;
  String? _selectedEvYieldStat;

  final List<String> _selectedTypes = [];
  final Set<int> _selectedGenerations = {};
  bool _showLegendary = false;
  bool _showMythical = false;
  bool _showUltraBeast = false;
  bool _showParadox = false;
  bool _showShinyOnly = false;
  bool _showFavoritesOnly = false;
  bool _showTeamOnly = false;
  String _sortOption = 'id_asc';

  final List<String> _selectedFormats = [];

  double _minBst = 100.0;
  double _maxBst = 780.0;
  double _minHp = 0.0;
  double _minAtk = 0.0;
  double _minDef = 0.0;
  double _minSpAtk = 0.0;
  double _minSpDef = 0.0;
  double _minSpd = 0.0;

  static const List<String> _allTypes = [
    'normal', 'fire', 'water', 'electric', 'grass', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getGeneration(int id) {
    if (id >= 1 && id <= 151) return 1;
    if (id >= 152 && id <= 251) return 2;
    if (id >= 252 && id <= 386) return 3;
    if (id >= 387 && id <= 493) return 4;
    if (id >= 494 && id <= 649) return 5;
    if (id >= 650 && id <= 721) return 6;
    if (id >= 722 && id <= 809) return 7;
    if (id >= 810 && id <= 898) return 8;
    if (id >= 899 && id <= 1025) return 9;
    return 9;
  }

  int _getBst(Pokemon p) {
    return p.baseHp + p.baseAtk + p.baseDef + p.baseSpAtk + p.baseSpDef + p.baseSpd;
  }

  bool _isUltraBeast(Pokemon p) {
    if (p.isUltraBeast) return true;
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
    return dex >= 793 && dex <= 806;
  }

  bool _isParadox(Pokemon p) {
    if (p.isParadox) return true;
    final name = p.name.toLowerCase();
    return name.startsWith('great-tusk') || name.startsWith('scream-tail') || name.startsWith('brute-bonnet') ||
           name.startsWith('flutter-mane') || name.startsWith('slither-wing') || name.startsWith('sandy-shocks') ||
           name.startsWith('iron-treads') || name.startsWith('iron-bundle') || name.startsWith('iron-hands') ||
           name.startsWith('iron-jugulis') || name.startsWith('iron-moth') || name.startsWith('iron-thorns') ||
           name.startsWith('roaring-moon') || name.startsWith('iron-valiant') || name.startsWith('walking-wake') ||
           name.startsWith('iron-leaves') || name.startsWith('gouging-fire') || name.startsWith('raging-bolt') ||
           name.startsWith('iron-boulder') || name.startsWith('iron-crown');
  }

  bool _isLegendary(Pokemon p) {
    if (p.isLegendary) return true;
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
    const legendaries = {
      144, 145, 146, 150, 243, 244, 245, 249, 250, 377, 378, 379, 380, 381, 382, 383, 384,
      480, 481, 482, 483, 484, 485, 486, 487, 488, 638, 639, 640, 641, 642, 643, 644, 645, 646,
      716, 717, 718, 772, 773, 785, 786, 787, 788, 789, 790, 791, 792, 800,
      888, 889, 890, 891, 892, 894, 895, 896, 897, 898, 1007, 1008, 1014, 1015, 1016, 1017, 1024
    };
    return legendaries.contains(dex);
  }

  bool _isMythical(Pokemon p) {
    if (p.isMythical) return true;
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
    const mythicals = {
      151, 251, 385, 386, 489, 490, 491, 492, 493, 494, 647, 648, 649, 719, 720, 721,
      801, 802, 807, 808, 809, 893, 1025
    };
    return mythicals.contains(dex);
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return const Color(0xFFEE8130);
      case 'water': return const Color(0xFF6390F0);
      case 'grass': return const Color(0xFF7AC74C);
      case 'electric': return const Color(0xFFF7D02C);
      case 'ice': return const Color(0xFF96D9D6);
      case 'fighting': return const Color(0xFFC22E28);
      case 'poison': return const Color(0xFFA33EA1);
      case 'ground': return const Color(0xFFE2BF65);
      case 'flying': return const Color(0xFFA98FEE);
      case 'psychic': return const Color(0xFFF95587);
      case 'bug': return const Color(0xFFA6B91A);
      case 'rock': return const Color(0xFFB6A136);
      case 'ghost': return const Color(0xFF735797);
      case 'dragon': return const Color(0xFF6F35FC);
      case 'dark': return const Color(0xFF705746);
      case 'steel': return const Color(0xFFB7B7CE);
      case 'fairy': return const Color(0xFFD685AD);
      default: return const Color(0xFFA8A77A);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _globalShinyMode = false;
      _selectedEvYieldStat = null;
      _selectedTypes.clear();
      _selectedGenerations.clear();
      _selectedFormats.clear();
      _showLegendary = false;
      _showMythical = false;
      _showUltraBeast = false;
      _showParadox = false;
      _showShinyOnly = false;
      _showFavoritesOnly = false;
      _showTeamOnly = false;
      _sortOption = 'id_asc';
      _minBst = 100.0;
      _maxBst = 780.0;
      _minHp = 0.0;
      _minAtk = 0.0;
      _minDef = 0.0;
      _minSpAtk = 0.0;
      _minSpDef = 0.0;
      _minSpd = 0.0;
    });
  }

  bool get _hasActiveFilters {
    return _globalShinyMode ||
        _selectedEvYieldStat != null ||
        _selectedTypes.isNotEmpty ||
        _selectedGenerations.isNotEmpty ||
        _selectedFormats.isNotEmpty ||
        _showLegendary ||
        _showMythical ||
        _showUltraBeast ||
        _showParadox ||
        _showShinyOnly ||
        _showFavoritesOnly ||
        _showTeamOnly ||
        _minBst > 100.0 ||
        _maxBst < 780.0 ||
        _minHp > 0.0 ||
        _minAtk > 0.0 ||
        _minDef > 0.0 ||
        _minSpAtk > 0.0 ||
        _minSpDef > 0.0 ||
        _minSpd > 0.0 ||
        _sortOption != 'id_asc';
  }

  bool _matchesSearch(Pokemon pokemon, int dexNum, String query, ChampionsCatalog? champions) {
    if (query.isEmpty) return true;
    final name = pokemon.name.toLowerCase();
    final form = pokemon.form.toLowerCase();
    final type1 = pokemon.type1.toLowerCase();
    final type2 = pokemon.type2?.toLowerCase() ?? '';
    final dex = dexNum.toString();

    return name.contains(query) ||
        form.contains(query) ||
        type1.contains(query) ||
        type2.contains(query) ||
        dex.contains(query) ||
        dex.padLeft(3, '0').contains(query) ||
        // Champions / Legends Z-A forms also answer to alias searches such
        // as "champions", "mega raichu x", "raichu x", "legends za",
        // "eternal", "floette eternal" or a Champions ability name.
        (champions?.matchesSearch(pokemon.id, query) ?? false) ||
        // Order-free token search, so "floette eternal" still finds the
        // "Eternal Flower Floette" display name (and "raichu x" the Mega).
        _matchesTokens(query, name, form) ||
        _isSubsequence(query, name.replaceAll('-', ''));
  }

  bool _matchesTokens(String query, String name, String form) {
    final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.length < 2) return false;
    final haystack = '$name $form';
    return tokens.every(haystack.contains);
  }

  bool _isSubsequence(String query, String text) {
    if (query.length < 3) return false;
    var index = 0;
    for (final codeUnit in text.codeUnits) {
      if (codeUnit == query.codeUnitAt(index)) index++;
      if (index == query.length) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pokedexProvider);
    final favoriteDexNumbers = ref.watch(favoritePokemonProvider);
    final teamPokemonIds = ref.watch(teamBuilderProvider).whereType<int>().toSet();
    final championsCatalog = ref.watch(championsCatalogProvider).valueOrNull;
    final evYieldDataset = ref.watch(evYieldDatasetProvider);
    final syncState = ref.watch(pokedexSyncNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'LibreDex',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.star_rounded : Icons.star_border_rounded,
              color: _showFavoritesOnly ? Colors.amber : primaryColor,
            ),
            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            tooltip: _showFavoritesOnly ? 'Show all Pokémon' : 'Show favorites',
          ),
          IconButton(
            icon: Icon(
              _globalShinyMode ? Icons.auto_awesome : Icons.auto_awesome_outlined,
              color: _globalShinyMode ? Colors.amberAccent : primaryColor,
            ),
            onPressed: () {
              setState(() {
                _globalShinyMode = !_globalShinyMode;
              });
            },
            tooltip: _globalShinyMode ? 'Shiny Mode Active' : 'Enable Shiny Mode',
          ),

          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded, color: Colors.orangeAccent),
              onPressed: _clearAllFilters,
              tooltip: 'Clear Filters',
            ),

          listAsync.when(
            data: (list) => list.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
                    tooltip: 'Rebuild offline database',
                  )
                : const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'pokedex'),
      body: SafeArea(
        bottom: true,
        child: syncState.isLoading
            ? _buildLoadingState()
            : syncState.hasError
                ? _buildErrorState(syncState.error.toString())
                : listAsync.when(
                    data: (pokemonList) {
                      if (pokemonList.isEmpty) {
                        return _buildEmptyState();
                      }

                      final filteredList = pokemonList.where((pokemon) {
                        final int dexNum = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
                        if (_showFavoritesOnly && !favoriteDexNumbers.contains(dexNum)) {
                          return false;
                        }
                        if (_showTeamOnly && !teamPokemonIds.contains(pokemon.id)) {
                          return false;
                        }

                        final query = _searchQuery.trim().toLowerCase();
                        if (!_matchesSearch(pokemon, dexNum, query, championsCatalog)) return false;

                        if (_selectedTypes.isNotEmpty) {
                          if (_selectedTypes.length == 1) {
                            final type = _selectedTypes.first.toLowerCase();
                            final matches = pokemon.type1.toLowerCase() == type ||
                                (pokemon.type2?.toLowerCase() == type);
                            if (!matches) return false;
                          } else {
                            final t1 = _selectedTypes[0].toLowerCase();
                            final t2 = _selectedTypes[1].toLowerCase();
                            final pt1 = pokemon.type1.toLowerCase();
                            final pt2 = pokemon.type2?.toLowerCase();
                            final matches = (pt1 == t1 && pt2 == t2) || (pt1 == t2 && pt2 == t1);
                            if (!matches) return false;
                          }
                        }

                        if (_selectedGenerations.isNotEmpty) {
                          if (!_selectedGenerations.contains(_getGeneration(dexNum))) {
                            return false;
                          }
                        }

                        final hasCategoryFilter = _showLegendary || _showMythical || _showUltraBeast || _showParadox;
                        if (hasCategoryFilter) {
                          bool matchesCategory = false;
                          if (_showLegendary && _isLegendary(pokemon)) matchesCategory = true;
                          if (_showMythical && _isMythical(pokemon)) matchesCategory = true;
                          if (_showUltraBeast && _isUltraBeast(pokemon)) matchesCategory = true;
                          if (_showParadox && _isParadox(pokemon)) matchesCategory = true;
                          if (!matchesCategory) return false;
                        }

                        if (_showShinyOnly && pokemon.shinySpriteUrl.isEmpty) {
                          return false;
                        }

                        if (_selectedFormats.isNotEmpty) {
                          if (!_selectedFormats.any((fmt) => _matchesFormat(pokemon, fmt, championsCatalog))) {
                            return false;
                          }
                        }

                        final bst = _getBst(pokemon);
                        if (bst < _minBst || bst > _maxBst) return false;

                        if (pokemon.baseHp < _minHp) return false;
                        if (pokemon.baseAtk < _minAtk) return false;
                        if (pokemon.baseDef < _minDef) return false;
                        if (pokemon.baseSpAtk < _minSpAtk) return false;
                        if (pokemon.baseSpDef < _minSpDef) return false;
                        if (pokemon.baseSpd < _minSpd) return false;

                        if (_selectedEvYieldStat != null) {
                          final realEv = evYieldDataset.hasValue ? evYieldDataset.requireValue[pokemon.id] : null;
                          final evKeys = realEv?.statKeys ?? PokemonDataHelpers.getEvYieldStatKeys(pokemon);
                          if (!evKeys.contains(_selectedEvYieldStat)) return false;
                        }

                        return true;
                      }).toList();

                      final Map<int, List<Pokemon>> groupedMap = {};
                      for (final p in filteredList) {
                        final int dexNum = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
                        groupedMap.putIfAbsent(dexNum, () => []).add(p);
                      }

                      final List<int> sortedKeys = groupedMap.keys.toList();
                      sortedKeys.sort((a, b) {
                        final pA = groupedMap[a]!.first;
                        final pB = groupedMap[b]!.first;
                        switch (_sortOption) {
                          case 'id_desc':
                            return b.compareTo(a);
                          case 'name_asc':
                            return pA.name.toLowerCase().compareTo(pB.name.toLowerCase());
                          case 'name_desc':
                            return pB.name.toLowerCase().compareTo(pA.name.toLowerCase());
                          case 'bst_asc':
                            return _getBst(pA).compareTo(_getBst(pB));
                          case 'bst_desc':
                            return _getBst(pB).compareTo(_getBst(pA));
                          case 'hp_desc':
                            return pB.baseHp.compareTo(pA.baseHp);
                          case 'atk_desc':
                            return pB.baseAtk.compareTo(pA.baseAtk);
                          case 'def_desc':
                            return pB.baseDef.compareTo(pA.baseDef);
                          case 'spatk_desc':
                            return pB.baseSpAtk.compareTo(pA.baseSpAtk);
                          case 'spdef_desc':
                            return pB.baseSpDef.compareTo(pA.baseSpDef);
                          case 'spd_desc':
                            return pB.baseSpd.compareTo(pA.baseSpd);
                          case 'id_asc':
                          default:
                            return a.compareTo(b);
                        }
                      });

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickySearchHeaderDelegate(
                              height: 72,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: (val) {
                                          setState(() {
                                            _searchQuery = val;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Search name, type, form, or #...',
                                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
                                          suffixIcon: _searchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear, size: 20),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {
                                                      _searchQuery = '';
                                                    });
                                                  },
                                                )
                                              : null,
                                          filled: true,
                                          fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFEDF2F7),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(
                                              color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: AppTheme.pokemonRed, width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 52,
                                      width: 52,
                                      decoration: BoxDecoration(
                                        color: _hasActiveFilters ? Colors.orangeAccent.withValues(alpha: 0.15) : (isDark ? const Color(0xFF141414) : const Color(0xFFEDF2F7)),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _hasActiveFilters ? Colors.orangeAccent : (isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0)),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.filter_list_rounded,
                                          color: _hasActiveFilters ? Colors.orangeAccent : primaryColor,
                                        ),
                                        onPressed: () => _openAdvancedFilterBottomSheet(context),
                                        tooltip: 'Advanced Filters',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          sortedKeys.isEmpty
                              ? SliverFillRemaining(
                                  child: AppEmptyState(
                                    icon: Icons.search_off_rounded,
                                    title: 'No Pokémon found',
                                    message: _showFavoritesOnly
                                        ? 'Tap the star on any Pokémon card to build your favorites list.'
                                        : _hasActiveFilters
                                            ? 'Try clearing a filter or widening your stat ranges.'
                                            : 'Try another name, type, form, or Pokédex number.',
                                    actionLabel: _hasActiveFilters ? 'Clear filters' : null,
                                    onAction: _hasActiveFilters ? _clearAllFilters : null,
                                  ),
                                )
                              : SliverPadding(
                                  padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: 8, bottom: AppSpacing.bottomScrollPadding),
                                  sliver: SliverGrid(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.80,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final group = groupedMap[sortedKeys[index]]!;
                                        return _buildPokemonCard(group, isDark, favoriteDexNumbers);
                                      },
                                      childCount: sortedKeys.length,
                                    ),
                                  ),
                                ),
                        ],
                      );

                    },
                    loading: () => _buildLoadingState(),
                    error: (error, _) => _buildErrorState(error.toString()),
                  ),
      ),
    );
  }

  Widget _buildPokemonCard(List<Pokemon> group, bool isDark, Set<int> favoriteDexNumbers) {
    if (group.isEmpty) return const SizedBox.shrink();

    // The grid shows one species card, then passes every bundled form forward.
    final pokemon = group.first;
    final int dexNum = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
    final typeColor = _getTypeColor(pokemon.type1);
    final secondaryColor = pokemon.type2 == null ? typeColor : _getTypeColor(pokemon.type2!);
    final isFavorite = favoriteDexNumbers.contains(dexNum);
    final imageUrl = ((_showShinyOnly || _globalShinyMode) && pokemon.shinySpriteUrl.isNotEmpty)
        ? pokemon.shinySpriteUrl
        : pokemon.spriteUrl;

    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: 'Open ${pokemon.name}, number $dexNum',
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: typeColor.withValues(alpha: isDark ? 0.18 : 0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.alphaBlend(typeColor.withValues(alpha: 0.25), const Color(0xFF080808)),
                          const Color(0xFF0E0E12),
                        ]
                      : [
                          typeColor.withValues(alpha: 0.22),
                          secondaryColor.withValues(alpha: 0.10),
                          Colors.white,
                        ],
                ),
                border: Border.all(color: typeColor.withValues(alpha: isDark ? 0.35 : 0.22)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(forms: group),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Positioned(
                      right: -18,
                      bottom: -22,
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 112,
                        color: Colors.white.withValues(alpha: isDark ? 0.035 : 0.34),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                        onPressed: () => ref.read(favoritePokemonProvider.notifier).toggle(dexNum),
                        icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                          foregroundColor: isFavorite ? Colors.amber : (isDark ? Colors.white70 : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${dexNum.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pokemon.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                              fontSize: 19,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              _buildTypeBadge(pokemon.type1, typeColor),
                              if (pokemon.type2 != null) _buildTypeBadge(pokemon.type2!, secondaryColor),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Hero(
                                tag: 'pokemon_${pokemon.id}',
                                child: imageUrl.isNotEmpty
                                    ? PokemonSprite(
                                        imageUrl: imageUrl,
                                        // Shiny mode falls back to the
                                        // normal render if the shiny one
                                        // cannot be fetched.
                                        fallbackUrl: imageUrl == pokemon.spriteUrl ? null : pokemon.spriteUrl,
                                        loadingIndicatorSize: 26,
                                        errorIconSize: 58,
                                        errorIconColor: typeColor.withValues(alpha: 0.36),
                                        diskCacheSize: 240,
                                      )
                                    : Icon(
                                        Icons.catching_pokemon,
                                        size: 58,
                                        color: typeColor.withValues(alpha: 0.36),
                                      ),
                              ),
                            ),
                          ),
                          if (group.length > 1)
                            Text(
                              '${group.length} forms',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _matchesFormat(Pokemon p, String format, ChampionsCatalog? champions) {
    final f = p.form.toLowerCase();
    switch (format.toUpperCase()) {
      case 'MEGA':
        return f.contains('mega') || (champions?.isOverlayMega(p.id) ?? false);
      case 'ALOLA':
        return f.contains('alolan');
      case 'GALAR':
        return f.contains('galarian');
      case 'HISUI':
        return f.contains('hisuian');
      case 'PALDEA':
        return f.contains('paldean');
      case 'CHAMPIONS':
        return champions?.isChampionsForm(p.id) ?? false;
      case 'LEGENDS Z-A':
        return champions?.isLegendsZaForm(p.id) ?? false;
      default:
        return false;
    }
  }

  Widget _buildTypeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        type[0].toUpperCase() + type.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _openAdvancedFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final primaryColor = isDark ? Colors.white : Colors.black;

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ADVANCED FILTERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: primaryColor)),
                          TextButton(
                            onPressed: () {
                              _clearAllFilters();
                              setModalState(() {});
                            },
                            child: const Text('Reset All', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            _buildSectionLabel('TYPES SELECTOR (UP TO 2 FOR DUAL EXCLUSIVE MATCH)'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _allTypes.map((type) {
                                final bool isSel = _selectedTypes.contains(type);
                                final Color col = _getTypeColor(type);
                                return ChoiceChip(
                                  label: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? Colors.white : col,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: col,
                                  backgroundColor: col.withValues(alpha: 0.1),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        if (_selectedTypes.length < 2) {
                                          _selectedTypes.add(type);
                                        }
                                      } else {
                                        _selectedTypes.remove(type);
                                      }
                                    });
                                    setModalState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            _buildSectionLabel('GENERATIONS'),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 38,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 9,
                                itemBuilder: (context, idx) {
                                  final int gen = idx + 1;
                                  final bool isSel = _selectedGenerations.contains(gen);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(
                                        'GEN ${_toRoman(gen)}',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey),
                                      ),
                                      selected: isSel,
                                      selectedColor: AppTheme.pokemonRed,
                                      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEDF2F7),
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedGenerations.add(gen);
                                          } else {
                                            _selectedGenerations.remove(gen);
                                          }
                                        });
                                        setModalState(() {});
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 18),

                            _buildSectionLabel('SPECIAL CATEGORIES'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF141414) : const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  _buildSwitchRow('Legendary Pokémon', _showLegendary, (val) {
                                    setState(() => _showLegendary = val);
                                    setModalState(() {});
                                  }),
                                  _buildSwitchRow('Mythical Pokémon', _showMythical, (val) {
                                    setState(() => _showMythical = val);
                                    setModalState(() {});
                                  }),
                                  _buildSwitchRow('Ultra Beasts (UB)', _showUltraBeast, (val) {
                                    setState(() => _showUltraBeast = val);
                                    setModalState(() {});
                                  }),
                                  _buildSwitchRow('Paradox Pokémon', _showParadox, (val) {
                                    setState(() => _showParadox = val);
                                    setModalState(() {});
                                  }),
                                  _buildSwitchRow('Shiny Sprite Verified', _showShinyOnly, (val) {
                                    setState(() => _showShinyOnly = val);
                                    setModalState(() {});
                                  }),
                                  _buildSwitchRow('Favorites Only', _showFavoritesOnly, (val) {
                                    setState(() => _showFavoritesOnly = val);
                                    setModalState(() {});
                                  }),
                                  _buildSwitchRow('Team Members', _showTeamOnly, (val) {
                                    setState(() => _showTeamOnly = val);
                                    setModalState(() {});
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 3.5 Formats / Regional Forms
                            _buildSectionLabel('REGIONAL / SPECIAL FORMATS'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['MEGA', 'ALOLA', 'GALAR', 'HISUI', 'PALDEA', 'CHAMPIONS', 'LEGENDS Z-A'].map((fmt) {
                                final bool isSel = _selectedFormats.contains(fmt);
                                return ChoiceChip(
                                  label: Text(
                                    fmt,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: AppTheme.pokemonRed,
                                  backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEDF2F7),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedFormats.add(fmt);
                                      } else {
                                        _selectedFormats.remove(fmt);
                                      }
                                    });
                                    setModalState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 4. Base Stat Total (BST) Range Slider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionLabel('BASE STAT TOTAL (BST) RANGE'),
                                Text(
                                  '${_minBst.round()} - ${_maxBst.round()}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.pokemonRed),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            RangeSlider(
                              values: RangeValues(_minBst, _maxBst),
                              min: 100.0,
                              max: 780.0,
                              divisions: 68,
                              activeColor: AppTheme.pokemonRed,
                              inactiveColor: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
                              labels: RangeLabels('${_minBst.round()}', '${_maxBst.round()}'),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _minBst = values.start;
                                  _maxBst = values.end;
                                });
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(height: 18),

                            // 5. Individual Base Stat Filters
                            _buildSectionLabel('MINIMUM BASE STAT THRESHOLDS'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF141414) : const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  _buildStatSliderRow('HP', _minHp, (val) {
                                    setState(() => _minHp = val);
                                    setModalState(() {});
                                  }),
                                  _buildStatSliderRow('Attack', _minAtk, (val) {
                                    setState(() => _minAtk = val);
                                    setModalState(() {});
                                  }),
                                  _buildStatSliderRow('Defense', _minDef, (val) {
                                    setState(() => _minDef = val);
                                    setModalState(() {});
                                  }),
                                  _buildStatSliderRow('Sp. Atk', _minSpAtk, (val) {
                                    setState(() => _minSpAtk = val);
                                    setModalState(() {});
                                  }),
                                  _buildStatSliderRow('Sp. Def', _minSpDef, (val) {
                                    setState(() => _minSpDef = val);
                                    setModalState(() {});
                                  }),
                                  _buildStatSliderRow('Speed', _minSpd, (val) {
                                    setState(() => _minSpd = val);
                                    setModalState(() {});
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 5.5 EV Yield Stat Filter
                            _buildSectionLabel('EV YIELD STAT FILTER'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                {'label': 'ANY EV', 'key': null},
                                {'label': 'HP EV', 'key': 'hp'},
                                {'label': 'ATK EV', 'key': 'atk'},
                                {'label': 'DEF EV', 'key': 'def'},
                                {'label': 'SPA EV', 'key': 'spatk'},
                                {'label': 'SPD EV', 'key': 'spdef'},
                                {'label': 'SPE EV', 'key': 'spd'},
                              ].map((item) {
                                final String? key = item['key'];
                                final String label = item['label'] as String;
                                final bool isSel = _selectedEvYieldStat == key;
                                return ChoiceChip(
                                  label: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: AppTheme.pokemonRed,
                                  backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEDF2F7),
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedEvYieldStat = selected ? key : null;
                                    });
                                    setModalState(() {});
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // 6. Sorting options
                            _buildSectionLabel('SORTING'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF141414) : const Color(0xFFF7FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _sortOption,
                                  dropdownColor: isDark ? const Color(0xFF121212) : Colors.white,
                                  isExpanded: true,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                                  items: const [
                                    DropdownMenuItem(value: 'id_asc', child: Text('ID (ASCENDING)')),
                                    DropdownMenuItem(value: 'id_desc', child: Text('ID (DESCENDING)')),
                                    DropdownMenuItem(value: 'name_asc', child: Text('ALPHABETICAL (A - Z)')),
                                    DropdownMenuItem(value: 'name_desc', child: Text('ALPHABETICAL (Z - A)')),
                                    DropdownMenuItem(value: 'bst_desc', child: Text('BST TOTAL (HIGHEST FIRST)')),
                                    DropdownMenuItem(value: 'bst_asc', child: Text('BST TOTAL (LOWEST FIRST)')),
                                    DropdownMenuItem(value: 'hp_desc', child: Text('HIGHEST HP')),
                                    DropdownMenuItem(value: 'atk_desc', child: Text('HIGHEST ATTACK')),
                                    DropdownMenuItem(value: 'def_desc', child: Text('HIGHEST DEFENSE')),
                                    DropdownMenuItem(value: 'spatk_desc', child: Text('HIGHEST SP. ATK')),
                                    DropdownMenuItem(value: 'spdef_desc', child: Text('HIGHEST SP. DEF')),
                                    DropdownMenuItem(value: 'spd_desc', child: Text('HIGHEST SPEED')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _sortOption = val;
                                      });
                                      setModalState(() {});
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
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

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Switch(
          value: value,
          activeThumbColor: AppTheme.pokemonRed,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStatSliderRow(String label, double value, ValueChanged<double> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[800]),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 200,
              divisions: 40,
              activeColor: AppTheme.pokemonRed,
              inactiveColor: isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0),
              label: '${value.round()}',
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              value > 0 ? '${value.round()}+' : 'Any',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: value > 0 ? AppTheme.pokemonRed : Colors.grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
    );
  }

  String _toRoman(int value) {
    switch (value) {
      case 1: return 'I';
      case 2: return 'II';
      case 3: return 'III';
      case 4: return 'IV';
      case 5: return 'V';
      case 6: return 'VI';
      case 7: return 'VII';
      case 8: return 'VIII';
      case 9: return 'IX';
      default: return value.toString();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.catching_pokemon,
            size: 70,
            color: AppTheme.pokemonRed,
          ),
          const SizedBox(height: 20),
          const Text(
            'Syncing Pokedex Offline...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pokemonRed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.pokemonRed),
            const SizedBox(height: 16),
            const Text(
              'Could not load the Pokédex',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
              icon: const Icon(Icons.sync),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.catching_pokemon,
              size: 110,
              color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 24),
            const Text(
              'LibreDex is Empty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your local database is empty. Rebuild it from the data bundled inside the app — no connection needed.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Rebuild offline database'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppTheme.pokemonRed.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickySearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickySearchHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark ? Colors.black : const Color(0xFFF9FAFB),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
