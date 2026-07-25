import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:libredex/core/widgets/app_drawer.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Advanced Filters State
  final List<String> _selectedTypes = [];
  final Set<int> _selectedGenerations = {};
  bool _showLegendary = false;
  bool _showUltraBeast = false;
  bool _showParadox = false;
  bool _showShinyOnly = false;
  String _sortOption = 'id_asc'; // id_asc, id_desc, name_asc, name_desc, bst_asc, bst_desc

  // Advanced Formats Filter State
  final List<String> _selectedFormats = []; // 'MEGA', 'ALOLA', 'GALAR', 'HISUI', 'PALDEA'

  // Map to store active selected form index for grouped Pokémon
  // Map tracking active form index removed.

  // Static list of all 18 Pokémon types for chips selector
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
      _selectedTypes.clear();
      _selectedGenerations.clear();
      _selectedFormats.clear();
      _showLegendary = false;
      _showUltraBeast = false;
      _showParadox = false;
      _showShinyOnly = false;
      _sortOption = 'id_asc';
    });
  }

  bool get _hasActiveFilters {
    return _selectedTypes.isNotEmpty ||
        _selectedGenerations.isNotEmpty ||
        _selectedFormats.isNotEmpty ||
        _showLegendary ||
        _showUltraBeast ||
        _showParadox ||
        _showShinyOnly ||
        _sortOption != 'id_asc';
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pokedexProvider);
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
          // Clear active filters indicator
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
                    onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).syncPokedex(),
                    tooltip: 'Force Sync Data',
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

                      // Apply All Advanced Combinatory Filter Logics
                      final filteredList = pokemonList.where((pokemon) {
                        final int dexNum = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;

                        // 1. Search Query (Name, ID, type)
                        final query = _searchQuery.toLowerCase();
                        final matchesSearch = pokemon.name.toLowerCase().contains(query) ||
                            dexNum.toString().contains(query) ||
                            dexNum.toString().padLeft(3, '0').contains(query);

                        if (!matchesSearch) return false;

                        // 2. Dual Type exclusive match logic
                        if (_selectedTypes.isNotEmpty) {
                          if (_selectedTypes.length == 1) {
                            final type = _selectedTypes.first.toLowerCase();
                            final matches = pokemon.type1.toLowerCase() == type ||
                                (pokemon.type2?.toLowerCase() == type);
                            if (!matches) return false;
                          } else {
                            // Strictly exclusive dual type matching
                            final t1 = _selectedTypes[0].toLowerCase();
                            final t2 = _selectedTypes[1].toLowerCase();
                            final pt1 = pokemon.type1.toLowerCase();
                            final pt2 = pokemon.type2?.toLowerCase();
                            final matches = (pt1 == t1 && pt2 == t2) || (pt1 == t2 && pt2 == t1);
                            if (!matches) return false;
                          }
                        }

                        // 3. Generation Chips Matching
                        if (_selectedGenerations.isNotEmpty) {
                          if (!_selectedGenerations.contains(_getGeneration(dexNum))) {
                            return false;
                          }
                        }

                        // 4. Special Category Toggles
                        if (_showLegendary && !(pokemon.isLegendary || pokemon.isMythical)) {
                          return false;
                        }
                        if (_showUltraBeast && !pokemon.isUltraBeast) {
                          return false;
                        }
                        if (_showParadox && !pokemon.isParadox) {
                          return false;
                        }
                        if (_showShinyOnly && pokemon.shinySpriteUrl.isEmpty) {
                          return false;
                        }

                        // 5. Format Filters Matching
                        if (_selectedFormats.isNotEmpty) {
                          if (!_selectedFormats.any((fmt) => _matchesFormat(pokemon, fmt))) {
                            return false;
                          }
                        }

                        return true;
                      }).toList();

                      // Group the filtered individual Pokémon by nationalDexNumber / base species
                      final Map<int, List<Pokemon>> groupedMap = {};
                      for (final p in filteredList) {
                        final int dexNum = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
                        groupedMap.putIfAbsent(dexNum, () => []).add(p);
                      }

                      // Sort the grouped keys based on the active sorting option
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
                          case 'id_asc':
                          default:
                            return a.compareTo(b);
                        }
                      });

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Sticky Search & Filter Pinned Bar Header
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
                                          hintText: 'Search Name or National ID...',
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

                          // Sliver Grid rendering grouped species cards
                          sortedKeys.isEmpty
                              ? const SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'No Pokémon matched your criteria.',
                                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : SliverPadding(
                                  padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 90),
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
                                        return _buildPokemonCard(group, isDark);
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

  Widget _buildPokemonCard(List<Pokemon> group, bool isDark) {
    if (group.isEmpty) return const SizedBox.shrink();

    // The grid should always display the first form from the group (usually the 'normal' one)
    final pokemon = group.first;
    final int dexNum = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
    final typeColor = _getTypeColor(pokemon.type1);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Pass the FULL group of forms to the detail screen!
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailScreen(forms: group),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pokemon.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '#${dexNum.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildTypeBadge(pokemon.type1, typeColor),
                  if (pokemon.type2 != null) ...[
                    const SizedBox(width: 4),
                    _buildTypeBadge(pokemon.type2!, _getTypeColor(pokemon.type2!)),
                  ],
                ],
              ),
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'pokemon_${pokemon.id}',
                    child: pokemon.spriteUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: (_showShinyOnly && pokemon.shinySpriteUrl.isNotEmpty)
                                ? pokemon.shinySpriteUrl
                                : pokemon.spriteUrl,
                            fit: BoxFit.contain,
                            maxHeightDiskCache: 200,
                            maxWidthDiskCache: 200,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.grey)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.catching_pokemon, size: 40, color: typeColor.withValues(alpha: 0.3)),
                          )
                        : Icon(Icons.catching_pokemon, size: 40, color: typeColor.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesFormat(Pokemon p, String format) {
    final f = p.form.toLowerCase();
    switch (format.toUpperCase()) {
      case 'MEGA':
        return f.contains('mega');
      case 'ALOLA':
        return f.contains('alolan');
      case 'GALAR':
        return f.contains('galarian');
      case 'HISUI':
        return f.contains('hisuian');
      case 'PALDEA':
        return f.contains('paldean');
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
                            // 1. Dual Types selection
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

                            // 2. Generation Selection
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

                            // 3. Special Categories
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
                                  _buildSwitchRow('Legendary / Mythical', _showLegendary, (val) {
                                    setState(() => _showLegendary = val);
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
                                ],
                              ),
                            ),
                            // 3.5 Formats / Regional Forms
                            _buildSectionLabel('REGIONAL / SPECIAL FORMATS'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['MEGA', 'ALOLA', 'GALAR', 'HISUI', 'PALDEA'].map((fmt) {
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

                            // 4. Sorting options
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
                                    DropdownMenuItem(value: 'bst_asc', child: Text('BST TOTAL (LOWEST FIRST)')),
                                    DropdownMenuItem(value: 'bst_desc', child: Text('BST TOTAL (HIGHEST FIRST)')),
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
              'Sync Error Occurred',
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
              onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).syncPokedex(),
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
              'Your offline database currently contains no Pokémon. Sync details from PokeAPI to begin.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).syncPokedex(),
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sync Generations 1-9+ (1025 Pokémon)'),
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
