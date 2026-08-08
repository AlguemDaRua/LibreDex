import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/ability_properties.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

class AbilityDetailScreen extends ConsumerStatefulWidget {
  final int abilityId;
  final String abilityName;

  const AbilityDetailScreen({
    super.key,
    required this.abilityId,
    required this.abilityName,
  });

  @override
  ConsumerState<AbilityDetailScreen> createState() => _AbilityDetailScreenState();
}

class _AbilityDetailScreenState extends ConsumerState<AbilityDetailScreen> {
  List<Map<String, dynamic>> _pokemons = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Ability? _abilityDetails;

  // Learnset / Ability filters (Multi-select)
  final TextEditingController _pokemonSearchController = TextEditingController();
  String _pokemonQuery = '';
  final Set<String> _selectedTypes = {};
  final Set<int> _selectedGens = {};
  final Set<String> _selectedForms = {};

  /// Derives available Pokémon types from the loaded learnset.
  List<String> get _types {
    final types = <String>{};
    for (final row in _pokemons) {
      final p = row['pokemon'] as Pokemon;
      types.add(p.type1);
      if (p.type2 != null) types.add(p.type2!);
    }
    final sorted = types.toList()..sort();
    return sorted;
  }

  @override
  void dispose() {
    _pokemonSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visiblePokemons {
    final q = _pokemonQuery.trim().toLowerCase();
    return _pokemons.where((row) {
      final p = row['pokemon'] as Pokemon;
      final text = '${p.name} ${p.form} ${p.type1} ${p.type2 ?? ''}'.toLowerCase();

      final matchesQuery = q.isEmpty || text.contains(q);
      final matchesType = _selectedTypes.isEmpty ||
          _selectedTypes.contains(p.type1.toLowerCase()) ||
          (p.type2 != null && _selectedTypes.contains(p.type2!.toLowerCase()));
      final matchesGen = _selectedGens.isEmpty || _selectedGens.contains(p.generation);

      bool matchesForm = true;
      if (_selectedForms.isNotEmpty) {
        final f = p.form.toLowerCase();
        matchesForm = _selectedForms.any((sf) {
          if (sf == 'Mega') return f.contains('mega') || p.isLegendsZA;
          if (sf == 'Regional') return f.contains('alolan') || f.contains('galarian') || f.contains('hisuian') || f.contains('paldean');
          if (sf == 'Standard') return f == 'normal' || f.isEmpty;
          return false;
        });
      }

      return matchesQuery && matchesType && matchesGen && matchesForm;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final db = ref.read(databaseProvider);

      // Fetch ability details
      _abilityDetails = await (db.select(db.abilityTable)..where((tbl) => tbl.id.equals(widget.abilityId))).getSingleOrNull();
      if (_abilityDetails == null) {
        throw Exception('Ability reference not found in local database.');
      }

      // Fetch all pokemons with this ability
      final results = await db.getPokemonsForAbility(widget.abilityId);

      if (mounted) {
        setState(() {
          _pokemons = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal': return const Color(0xFFA8A77A);
      case 'fire': return const Color(0xFFEE8130);
      case 'water': return const Color(0xFF6390F0);
      case 'electric': return const Color(0xFFF7D02C);
      case 'grass': return const Color(0xFF7AC74C);
      case 'ice': return const Color(0xFF96D9D6);
      case 'fighting': return const Color(0xFFC22E28);
      case 'poison': return const Color(0xFFA33EA1);
      case 'ground': return const Color(0xFFE2BF65);
      case 'flying': return const Color(0xFFA98FF3);
      case 'psychic': return const Color(0xFFF95587);
      case 'bug': return const Color(0xFFA6B91A);
      case 'rock': return const Color(0xFFB6A136);
      case 'ghost': return const Color(0xFF735797);
      case 'dragon': return const Color(0xFF6F35FC);
      case 'dark': return const Color(0xFF705746);
      case 'steel': return const Color(0xFFB7B7CE);
      case 'fairy': return const Color(0xFFD685AD);
      default: return Colors.grey;
    }
  }

  void _copyAbilityDetailsToClipboard() {
    if (_abilityDetails == null) return;
    final a = _abilityDetails!;
    final text = 'ABILITY: ${a.name.toUpperCase()}\n'
        'Introduced in: ${a.introducedIn} | Source: ${a.sourceGames}\n'
        '${a.description}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ability info copied to clipboard.')),
    );
  }

  void _shareAbilityInfo() {
    if (_abilityDetails == null) return;
    final a = _abilityDetails!;
    final text = 'Check out the ${a.name} ability in LibreDex!\n${a.description}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ability info shared to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.abilityName.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_abilityDetails != null) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share ability info',
              onPressed: _shareAbilityInfo,
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'Copy ability info',
              onPressed: _copyAbilityDetailsToClipboard,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed))
          : _hasError
              ? _buildErrorState()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Ability Header Card (Scrolls away cleanly!)
                    if (_abilityDetails != null)
                      SliverToBoxAdapter(
                        child: _buildAbilityHeaderCard(isDark),
                      ),

                    // Section Title: Pokémon with this ability
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.catching_pokemon_outlined,
                                    size: 20, color: AppTheme.pokemonRed.withValues(alpha: 0.8)),
                                const SizedBox(width: 8),
                                const Text(
                                  'POKÉMON WITH THIS ABILITY',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            Text(
                              '${_visiblePokemons.length} matches',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sticky Search & Multi-Filter Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _AbilityFilterHeaderDelegate(
                        child: Container(
                          color: isDark ? Colors.black : const Color(0xFFF9FAFB),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _pokemonSearchController,
                                onChanged: (value) => setState(() => _pokemonQuery = value),
                                decoration: InputDecoration(
                                  hintText: 'Filter Pokémon by name, form or type...',
                                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
                                  suffixIcon: _pokemonQuery.isEmpty
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _pokemonSearchController.clear();
                                            setState(() => _pokemonQuery = '');
                                          },
                                        ),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildFilterChipsRow(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // List of Pokémon
                    _visiblePokemons.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No Pokémon match this filter.',
                                style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _visiblePokemons[index];
                                final Pokemon p = item['pokemon'];
                                final bool isHidden = item['isHidden'] ?? false;
                                final typeColor = _getTypeColor(p.type1);

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 0,
                                  color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                        color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE2E8F0)),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PokemonDetailScreen(forms: [p])),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Hero(
                                            tag: 'ability_${widget.abilityId}_pokemon_${p.id}',
                                            child: SizedBox(
                                              width: 54,
                                              height: 54,
                                              child: p.spriteUrl.isNotEmpty
                                                  ? PokemonSprite(
                                                      imageUrl: p.spriteUrl,
                                                      fallbackUrl: PokemonSprite.homeArtworkUrl(
                                                          p.nationalDexNumber > 0
                                                              ? p.nationalDexNumber
                                                              : p.id),
                                                      loadingIndicatorSize: 20,
                                                      errorIconColor: typeColor.withValues(alpha: 0.3),
                                                      errorIconSize: 24,
                                                    )
                                                  : Icon(Icons.catching_pokemon,
                                                      color: typeColor.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '#${p.nationalDexNumber > 0 ? p.nationalDexNumber.toString().padLeft(3, '0') : p.id}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        p.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (p.form.isNotEmpty && p.form != 'normal')
                                                  Text(
                                                    p.form.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _buildTypeBadge(p.type1),
                                                    if (p.type2 != null) ...[
                                                      const SizedBox(width: 4),
                                                      _buildTypeBadge(p.type2!),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isHidden)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                                              ),
                                              child: const Text(
                                                'HIDDEN',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.purple,
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
                                              ),
                                              child: const Text(
                                                'STANDARD',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _visiblePokemons.length,
                            ),
                          ),
                  ],
                ),
    );
  }

  Widget _buildAbilityHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ABILITY EFFECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              if (_abilityDetails!.isChampionsAbility)
                _buildBadge('CHAMPIONS', Colors.orangeAccent)
              else if (_abilityDetails!.isLegendsZAAbility)
                _buildBadge('LEGENDS Z-A', Colors.purpleAccent)
              else
                _buildBadge(_abilityDetails!.introducedInLabel, Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _abilityDetails!.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPropertyBadge('Introduced: ${_abilityDetails!.introducedInLabel}', Colors.blue, icon: Icons.history),
              _buildPropertyBadge('Games: ${_abilityDetails!.sourceGames}', Colors.grey, icon: Icons.sports_esports),
              if (_abilityDetails!.isChampionsAbility)
                _buildPropertyBadge('Pokémon Champions Format', Colors.amber, icon: Icons.emoji_events),
              if (_abilityDetails!.isLegendsZAAbility)
                _buildPropertyBadge('Legends: Z-A Overlay', Colors.purple, icon: Icons.auto_awesome),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    final hasActiveFilter = _selectedTypes.isNotEmpty || _selectedGens.isNotEmpty || _selectedForms.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDropdownFilterChip(
            label: _selectedTypes.isEmpty
                ? 'Type: All'
                : 'Type (${_selectedTypes.length}): ${_selectedTypes.map((t) => t.toUpperCase()).join(", ")}',
            isActive: _selectedTypes.isNotEmpty,
            onTap: _openTypeMultiSelectSheet,
          ),
          const SizedBox(width: 8),
          _buildDropdownFilterChip(
            label: _selectedGens.isEmpty
                ? 'Gen: All'
                : 'Gen (${_selectedGens.length}): ${_selectedGens.map((g) => "G$g").join(", ")}',
            isActive: _selectedGens.isNotEmpty,
            onTap: _openGenMultiSelectSheet,
          ),
          const SizedBox(width: 8),
          _buildDropdownFilterChip(
            label: _selectedForms.isEmpty
                ? 'Form: All'
                : 'Form (${_selectedForms.length}): ${_selectedForms.join(", ")}',
            isActive: _selectedForms.isNotEmpty,
            onTap: _openFormMultiSelectSheet,
          ),
          if (hasActiveFilter) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedTypes.clear();
                  _selectedGens.clear();
                  _selectedForms.clear();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.pokemonRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.clear, size: 14, color: AppTheme.pokemonRed),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.pokemonRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openTypeMultiSelectSheet() {
    final availableTypes = _types;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER BY ELEMENTAL TYPE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _selectedTypes.clear());
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: AppTheme.pokemonRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTypes.map((t) {
                      final lower = t.toLowerCase();
                      final isSelected = _selectedTypes.contains(lower);
                      final typeColor = _getTypeColor(t);

                      return FilterChip(
                        selected: isSelected,
                        label: Text(t.toUpperCase()),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: typeColor,
                        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            if (val) {
                              _selectedTypes.add(lower);
                            } else {
                              _selectedTypes.remove(lower);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openGenMultiSelectSheet() {
    final gens = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER BY GENERATION',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _selectedGens.clear());
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: AppTheme.pokemonRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gens.map((g) {
                      final isSelected = _selectedGens.contains(g);

                      return FilterChip(
                        selected: isSelected,
                        label: Text('GEN $g'),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: AppTheme.pokemonRed,
                        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            if (val) {
                              _selectedGens.add(g);
                            } else {
                              _selectedGens.remove(g);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openFormMultiSelectSheet() {
    final forms = ['Standard', 'Mega', 'Regional'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER BY FORM CATEGORY',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _selectedForms.clear());
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: AppTheme.pokemonRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: forms.map((f) {
                      final isSelected = _selectedForms.contains(f);

                      return FilterChip(
                        selected: isSelected,
                        label: Text(f.toUpperCase()),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: AppTheme.pokemonRed,
                        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            if (val) {
                              _selectedForms.add(f);
                            } else {
                              _selectedForms.remove(f);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.pokemonRed.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.pokemonRed : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? AppTheme.pokemonRed
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isActive ? AppTheme.pokemonRed : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildPropertyBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final color = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'Ability details could not be loaded.',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pokemonRed),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbilityFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _AbilityFilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 108;

  @override
  double get minExtent => 108;

  @override
  bool shouldRebuild(covariant _AbilityFilterHeaderDelegate oldDelegate) {
    return true;
  }
}
