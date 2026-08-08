import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/abilitydex/views/ability_detail_screen.dart';
import 'package:libredex/core/widgets/dex_filter_bar.dart';
import 'package:libredex/core/widgets/dex_sort_menu.dart';
import 'package:libredex/core/widgets/dex_filter_sheet.dart';
import 'package:libredex/core/widgets/active_filter_summary.dart';
import 'package:libredex/core/widgets/result_count_label.dart';
import 'package:libredex/core/utils/ability_properties.dart';

class AbilitydexScreen extends ConsumerStatefulWidget {
  const AbilitydexScreen({super.key});

  @override
  ConsumerState<AbilitydexScreen> createState() => _AbilitydexScreenState();
}

class _AbilitydexScreenState extends ConsumerState<AbilitydexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Ability> _allAbilities = [];
  List<Ability> _filteredAbilities = [];
  bool _isLoading = true;

  // Sorting & Filters
  String _sortOption = 'name_asc';
  int? _selectedGeneration;
  String? _selectedEffectTag;
  
  bool _filterChampions = false;
  bool _filterLegendsZA = false;
  bool _filterHidden = false;

  static const List<String> _effectTags = [
    'Weather', 'Terrain', 'Stats', 'Status', 'Damage', 'Immunity', 'Type',
    'Speed', 'Items', 'Switching', 'Hazards', 'Healing', 'Critical Hits',
    'Accuracy', 'Priority'
  ];

  @override
  void initState() {
    super.initState();
    _loadAbilities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAbilities() async {
    try {
      final db = ref.read(databaseProvider);
      final abilities = await db.select(db.abilityTable).get();
      if (mounted) {
        setState(() {
          _allAbilities = abilities;
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedGeneration = null;
      _selectedEffectTag = null;
      _filterChampions = false;
      _filterLegendsZA = false;
      _filterHidden = false;
      _sortOption = 'name_asc';
    });
    _applyFilters();
  }

  bool get _hasActiveFilters {
    return _selectedGeneration != null ||
        _selectedEffectTag != null ||
        _filterChampions ||
        _filterLegendsZA ||
        _filterHidden ||
        _sortOption != 'name_asc';
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();
    var list = _allAbilities.where((a) {
      if (query.isNotEmpty) {
        final matchesQuery = a.name.toLowerCase().contains(query) ||
            a.description.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      if (_selectedGeneration != null && a.generation != _selectedGeneration) return false;

      if (_filterChampions && !a.isChampionsAbility) return false;
      if (_filterLegendsZA && !a.isLegendsZAAbility) return false;
      if (_filterHidden && !a.isHiddenAbility) return false;

      if (_selectedEffectTag != null) {
        final tags = a.effectTagsList.map((t) => t.toLowerCase()).toList();
        if (!tags.contains(_selectedEffectTag!.toLowerCase())) return false;
      }

      return true;
    }).toList();

    // Sort
    list.sort((a, b) {
      switch (_sortOption) {
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'gen_desc':
          return b.generation.compareTo(a.generation);
        case 'gen_asc':
          return a.generation.compareTo(b.generation);
        case 'champions_first':
          if (a.isChampionsAbility && !b.isChampionsAbility) return -1;
          if (!a.isChampionsAbility && b.isChampionsAbility) return 1;
          return a.name.compareTo(b.name);
        case 'legends_first':
          if (a.isLegendsZAAbility && !b.isLegendsZAAbility) return -1;
          if (!a.isLegendsZAAbility && b.isLegendsZAAbility) return 1;
          return a.name.compareTo(b.name);
        case 'name_asc':
        default:
          return a.name.compareTo(b.name);
      }
    });

    setState(() {
      _filteredAbilities = list;
    });
  }

  List<ActiveFilterItem> _buildActiveFilterItems() {
    final list = <ActiveFilterItem>[];

    if (_selectedGeneration != null) {
      list.add(ActiveFilterItem(
        label: 'Gen: $_selectedGeneration',
        onDeleted: () => setState(() { _selectedGeneration = null; _applyFilters(); }),
      ));
    }
    if (_selectedEffectTag != null) {
      list.add(ActiveFilterItem(
        label: 'Affects: $_selectedEffectTag',
        onDeleted: () => setState(() { _selectedEffectTag = null; _applyFilters(); }),
      ));
    }
    if (_filterChampions) {
      list.add(ActiveFilterItem(
        label: 'Champions',
        onDeleted: () => setState(() { _filterChampions = false; _applyFilters(); }),
      ));
    }
    if (_filterLegendsZA) {
      list.add(ActiveFilterItem(
        label: 'Legends Z-A',
        onDeleted: () => setState(() { _filterLegendsZA = false; _applyFilters(); }),
      ));
    }
    if (_filterHidden) {
      list.add(ActiveFilterItem(
        label: 'Hidden Abilities',
        onDeleted: () => setState(() { _filterHidden = false; _applyFilters(); }),
      ));
    }

    return list;
  }

  void _openFilterSheet() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return DexFilterSheet(
              title: 'Ability Filters',
              hasActiveFilters: _hasActiveFilters,
              onReset: () {
                _clearAllFilters();
                setModalState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generation
                  const Text('GENERATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: List.generate(7, (idx) => idx + 3).map((gen) {
                      final isSel = _selectedGeneration == gen;
                      return ChoiceChip(
                        label: Text('GEN $gen', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedGeneration = selected ? gen : null; });
                          _applyFilters();
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Effects tags
                  const Text('ABILITIES AFFECTING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _effectTags.map((tag) {
                      final isSel = _selectedEffectTag == tag;
                      return ChoiceChip(
                        label: Text(tag.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedEffectTag = selected ? tag : null; });
                          _applyFilters();
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Custom filters
                  const Text('SPECIAL RULES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
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
                        _buildSwitchRow('Pokémon Champions', _filterChampions, (val) {
                          setState(() => _filterChampions = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Legends: Z-A', _filterLegendsZA, (val) {
                          setState(() => _filterLegendsZA = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Hidden Ability', _filterHidden, (val) {
                          setState(() => _filterHidden = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sorting
                  DexSortMenu<String>(
                    currentValue: _sortOption,
                    items: const [
                      DropdownMenuItem(value: 'name_asc', child: Text('NAME (A - Z)')),
                      DropdownMenuItem(value: 'name_desc', child: Text('NAME (Z - A)')),
                      DropdownMenuItem(value: 'gen_desc', child: Text('GENERATION (LATEST FIRST)')),
                      DropdownMenuItem(value: 'gen_asc', child: Text('GENERATION (EARLIEST FIRST)')),
                      DropdownMenuItem(value: 'champions_first', child: Text('CHAMPIONS FIRST')),
                      DropdownMenuItem(value: 'legends_first', child: Text('LEGENDS: Z-A FIRST')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() { _sortOption = val; });
                        _applyFilters();
                        setModalState(() {});
                      }
                    },
                  ),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('AbilityDex', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'abilities'),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DexFilterBar(
                    searchHint: 'Search abilities by name or desc...',
                    initialSearchValue: _searchQuery,
                    onSearchChanged: (val) {
                      setState(() { _searchQuery = val; });
                      _applyFilters();
                    },
                    onClearSearch: () {
                      setState(() { _searchQuery = ''; });
                      _applyFilters();
                    },
                    onFilterPressed: _openFilterSheet,
                    hasActiveFilters: _hasActiveFilters,
                  ),

                  if (_hasActiveFilters)
                    ActiveFilterSummary(
                      items: _buildActiveFilterItems(),
                      onClearAll: _clearAllFilters,
                    ),

                  ResultCountLabel(count: _filteredAbilities.length, label: 'abilities found'),

                  Expanded(
                    child: _filteredAbilities.isEmpty
                        ? const Center(child: Text('No abilities found.', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: 8, bottom: AppSpacing.bottomScrollPadding),
                            itemCount: _filteredAbilities.length,
                            separatorBuilder: (context, index) => Divider(
                              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final ab = _filteredAbilities[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                title: Row(
                                  children: [
                                    Text(
                                      ab.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                                    ),
                                    if (ab.isChampionsAbility) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('CHAMP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    if (ab.isLegendsZAAbility) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('LZA', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    ab.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                onTap: () => _showAbilityDetails(context, ab),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAbilityDetails(BuildContext context, Ability ab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbilityDetailScreen(
          abilityId: ab.id,
          abilityName: ab.name,
        ),
      ),
    );
  }
}
