import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/movedex/views/move_detail_screen.dart';
import 'package:libredex/core/widgets/dex_filter_bar.dart';
import 'package:libredex/core/widgets/dex_sort_menu.dart';
import 'package:libredex/core/widgets/dex_filter_sheet.dart';
import 'package:libredex/core/widgets/active_filter_summary.dart';
import 'package:libredex/core/widgets/result_count_label.dart';
import 'package:libredex/core/utils/move_properties.dart';

class MovedexScreen extends ConsumerStatefulWidget {
  const MovedexScreen({super.key});

  @override
  ConsumerState<MovedexScreen> createState() => _MovedexScreenState();
}

class _MovedexScreenState extends ConsumerState<MovedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Move> _allMoves = [];
  List<Move> _filteredMoves = [];
  bool _isLoading = true;

  // Sorting
  String _sortOption = 'name_asc';

  // Filters
  String? _selectedType;
  String? _selectedClass;
  int? _selectedGeneration;

  double _minPower = 0.0;
  double _maxPower = 250.0;
  double _minAccuracy = 0.0;
  double _maxAccuracy = 100.0;
  double _minPp = 0.0;
  double _maxPp = 40.0;

  // Property filter flags
  bool _filterPriority = false;
  bool _filterNegativePriority = false;
  bool _filterContact = false;
  bool _filterNonContact = false;
  bool _filterStatus = false;
  bool _filterDamaging = false;
  bool _filterMultiHit = false;
  bool _filterRecoil = false;
  bool _filterDraining = false;
  bool _filterHealing = false;
  bool _filterSwitching = false;
  bool _filterProtecting = false;
  bool _filterRecharge = false;
  bool _filterSound = false;
  bool _filterPunching = false;
  bool _filterBiting = false;
  bool _filterPowder = false;
  bool _filterPulse = false;
  bool _filterBallistic = false;
  bool _filterSlicing = false;
  bool _filterWind = false;
  bool _filterDance = false;

  // Source filters
  bool _filterChampions = false;
  bool _filterLegendsZA = false;
  bool _filterDLC = false;
  bool _filterSignature = false;

  // Effect filters
  String? _selectedEffect;

  static const List<String> _types = [
    'normal', 'fire', 'water', 'electric', 'grass', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
  ];

  static const List<String> _effects = [
    'Burn', 'Freeze', 'Paralysis', 'Poison', 'Toxic', 'Sleep', 'Confusion', 'Flinch',
    'Stat boost', 'Stat drop', 'Weather', 'Terrain', 'Trick Room', 'Entry hazards',
    'Healing', 'Recovery', 'Substitute', 'Protection', 'Type change'
  ];

  @override
  void initState() {
    super.initState();
    _loadMoves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMoves() async {
    try {
      final db = ref.read(databaseProvider);
      final moves = await db.select(db.moveTable).get();
      if (mounted) {
        setState(() {
          _allMoves = moves;
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
      _selectedType = null;
      _selectedClass = null;
      _selectedGeneration = null;
      _minPower = 0.0;
      _maxPower = 250.0;
      _minAccuracy = 0.0;
      _maxAccuracy = 100.0;
      _minPp = 0.0;
      _maxPp = 40.0;
      _filterPriority = false;
      _filterNegativePriority = false;
      _filterContact = false;
      _filterNonContact = false;
      _filterStatus = false;
      _filterDamaging = false;
      _filterMultiHit = false;
      _filterRecoil = false;
      _filterDraining = false;
      _filterHealing = false;
      _filterSwitching = false;
      _filterProtecting = false;
      _filterRecharge = false;
      _filterSound = false;
      _filterPunching = false;
      _filterBiting = false;
      _filterPowder = false;
      _filterPulse = false;
      _filterBallistic = false;
      _filterSlicing = false;
      _filterWind = false;
      _filterDance = false;
      _filterChampions = false;
      _filterLegendsZA = false;
      _filterDLC = false;
      _filterSignature = false;
      _selectedEffect = null;
      _sortOption = 'name_asc';
    });
    _applyFilters();
  }

  bool get _hasActiveFilters {
    return _selectedType != null ||
        _selectedClass != null ||
        _selectedGeneration != null ||
        _minPower > 0.0 ||
        _maxPower < 250.0 ||
        _minAccuracy > 0.0 ||
        _maxAccuracy < 100.0 ||
        _minPp > 0.0 ||
        _maxPp < 40.0 ||
        _filterPriority ||
        _filterNegativePriority ||
        _filterContact ||
        _filterNonContact ||
        _filterStatus ||
        _filterDamaging ||
        _filterMultiHit ||
        _filterRecoil ||
        _filterDraining ||
        _filterHealing ||
        _filterSwitching ||
        _filterProtecting ||
        _filterRecharge ||
        _filterSound ||
        _filterPunching ||
        _filterBiting ||
        _filterPowder ||
        _filterPulse ||
        _filterBallistic ||
        _filterSlicing ||
        _filterWind ||
        _filterDance ||
        _filterChampions ||
        _filterLegendsZA ||
        _filterDLC ||
        _filterSignature ||
        _selectedEffect != null ||
        _sortOption != 'name_asc';
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();
    var list = _allMoves.where((m) {
      if (query.isNotEmpty) {
        final matchesQuery = m.name.toLowerCase().contains(query) ||
            m.type.toLowerCase().contains(query) ||
            (m.description ?? '').toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      if (_selectedType != null && m.type.toLowerCase() != _selectedType!.toLowerCase()) return false;
      if (_selectedClass != null && m.damageClass.toLowerCase() != _selectedClass!.toLowerCase()) return false;
      if (_selectedGeneration != null && m.generation != _selectedGeneration) return false;

      // Stats range
      final power = m.power ?? 0;
      if (power < _minPower || power > _maxPower) return false;

      final acc = m.accuracy ?? 100;
      if (acc < _minAccuracy || acc > _maxAccuracy) return false;

      if (m.pp < _minPp || m.pp > _maxPp) return false;

      // Property flags
      if (_filterPriority && m.priority <= 0) return false;
      if (_filterNegativePriority && m.priority >= 0) return false;
      if (_filterContact && !m.isContact) return false;
      if (_filterNonContact && m.isContact) return false;
      if (_filterStatus && !m.isStatusMove) return false;
      if (_filterDamaging && !m.isDamagingMove) return false;
      if (_filterMultiHit && !m.isMultiHit) return false;
      if (_filterRecoil && !m.isRecoil) return false;
      if (_filterDraining && !m.isDraining) return false;
      if (_filterHealing && !m.isHealing) return false;
      if (_filterSwitching && !m.isSwitching) return false;
      if (_filterProtecting && !m.isProtective) return false;
      if (_filterRecharge && !m.isRecharge) return false;
      if (_filterSound && !m.isSound) return false;
      if (_filterPunching && !m.isPunching) return false;
      if (_filterBiting && !m.isBiting) return false;
      if (_filterPowder && !m.isPowder) return false;
      if (_filterPulse && !m.isPulse) return false;
      if (_filterBallistic && !m.isBallistic) return false;
      if (_filterSlicing && !m.isSlicing) return false;
      if (_filterWind && !m.isWind) return false;
      if (_filterDance && !m.isDance) return false;

      // Source flags
      if (_filterChampions && !m.isChampionsMove) return false;
      if (_filterLegendsZA && !m.isLegendsZAMove) return false;
      if (_filterDLC && !m.isDLCMove) return false;
      if (_filterSignature && !m.isSignatureMove) return false;

      // Effect keyword
      if (_selectedEffect != null) {
        final desc = (m.description ?? '').toLowerCase();
        final eff = _selectedEffect!.toLowerCase();
        if (!desc.contains(eff)) return false;
      }

      return true;
    }).toList();

    // Sort
    list.sort((a, b) {
      switch (_sortOption) {
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'power_desc':
          return (b.power ?? -1).compareTo(a.power ?? -1);
        case 'power_asc':
          return (a.power ?? -1).compareTo(b.power ?? -1);
        case 'acc_desc':
          return (b.accuracy ?? -1).compareTo(a.accuracy ?? -1);
        case 'acc_asc':
          return (a.accuracy ?? -1).compareTo(b.accuracy ?? -1);
        case 'pp_desc':
          return b.pp.compareTo(a.pp);
        case 'pp_asc':
          return a.pp.compareTo(b.pp);
        case 'priority_desc':
          return b.priority.compareTo(a.priority);
        case 'type':
          return a.type.compareTo(b.type);
        case 'class':
          return a.damageClass.compareTo(b.damageClass);
        case 'gen':
          return a.generation.compareTo(b.generation);
        case 'name_asc':
        default:
          return a.name.compareTo(b.name);
      }
    });

    setState(() {
      _filteredMoves = list;
    });
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
      case 'flying': return const Color(0xFFA98FEE);
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

  List<ActiveFilterItem> _buildActiveFilterItems() {
    final list = <ActiveFilterItem>[];

    if (_selectedType != null) {
      list.add(ActiveFilterItem(
        label: 'Type: ${_selectedType!.toUpperCase()}',
        color: _getTypeColor(_selectedType!),
        onDeleted: () => setState(() { _selectedType = null; _applyFilters(); }),
      ));
    }
    if (_selectedClass != null) {
      list.add(ActiveFilterItem(
        label: 'Class: ${_selectedClass!.toUpperCase()}',
        onDeleted: () => setState(() { _selectedClass = null; _applyFilters(); }),
      ));
    }
    if (_selectedGeneration != null) {
      list.add(ActiveFilterItem(
        label: 'Gen: $_selectedGeneration',
        onDeleted: () => setState(() { _selectedGeneration = null; _applyFilters(); }),
      ));
    }
    if (_minPower > 0.0 || _maxPower < 250.0) {
      list.add(ActiveFilterItem(
        label: 'Power: ${_minPower.round()}–${_maxPower.round()}',
        onDeleted: () => setState(() { _minPower = 0.0; _maxPower = 250.0; _applyFilters(); }),
      ));
    }
    if (_minAccuracy > 0.0 || _maxAccuracy < 100.0) {
      list.add(ActiveFilterItem(
        label: 'Acc: ${_minAccuracy.round()}%–${_maxAccuracy.round()}%',
        onDeleted: () => setState(() { _minAccuracy = 0.0; _maxAccuracy = 100.0; _applyFilters(); }),
      ));
    }
    if (_minPp > 0.0 || _maxPp < 40.0) {
      list.add(ActiveFilterItem(
        label: 'PP: ${_minPp.round()}–${_maxPp.round()}',
        onDeleted: () => setState(() { _minPp = 0.0; _maxPp = 40.0; _applyFilters(); }),
      ));
    }
    if (_filterPriority) {
      list.add(ActiveFilterItem(label: 'Priority', onDeleted: () => setState(() { _filterPriority = false; _applyFilters(); })));
    }
    if (_filterContact) {
      list.add(ActiveFilterItem(label: 'Contact', onDeleted: () => setState(() { _filterContact = false; _applyFilters(); })));
    }
    if (_filterHealing) {
      list.add(ActiveFilterItem(label: 'Healing', onDeleted: () => setState(() { _filterHealing = false; _applyFilters(); })));
    }
    if (_filterSound) {
      list.add(ActiveFilterItem(label: 'Sound', onDeleted: () => setState(() { _filterSound = false; _applyFilters(); })));
    }
    if (_filterDLC) {
      list.add(ActiveFilterItem(label: 'DLC', onDeleted: () => setState(() { _filterDLC = false; _applyFilters(); })));
    }
    if (_filterChampions) {
      list.add(ActiveFilterItem(label: 'Champions', onDeleted: () => setState(() { _filterChampions = false; _applyFilters(); })));
    }
    if (_filterLegendsZA) {
      list.add(ActiveFilterItem(label: 'Legends Z-A', onDeleted: () => setState(() { _filterLegendsZA = false; _applyFilters(); })));
    }
    if (_selectedEffect != null) {
      list.add(ActiveFilterItem(
        label: 'Effect: $_selectedEffect',
        onDeleted: () => setState(() { _selectedEffect = null; _applyFilters(); }),
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
            final primaryColor = isDark ? Colors.white : Colors.black;

            return DexFilterSheet(
              title: 'Move Filters',
              hasActiveFilters: _hasActiveFilters,
              onReset: () {
                _clearAllFilters();
                setModalState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type selection
                  const Text('ELEMENTAL TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _types.map((type) {
                      final isSel = _selectedType == type;
                      final col = _getTypeColor(type);
                      return ChoiceChip(
                        label: Text(type.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : col)),
                        selected: isSel,
                        selectedColor: col,
                        backgroundColor: col.withValues(alpha: 0.1),
                        onSelected: (selected) {
                          setState(() { _selectedType = selected ? type : null; });
                          _applyFilters();
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Damage Class
                  const Text('DAMAGE CLASS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['physical', 'special', 'status'].map((cls) {
                      final isSel = _selectedClass == cls;
                      return ChoiceChip(
                        label: Text(cls.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.grey)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedClass = selected ? cls : null; });
                          _applyFilters();
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Generation
                  const Text('GENERATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: List.generate(9, (idx) => idx + 1).map((gen) {
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

                  // Range sliders (Power, Acc, PP)
                  _buildSliderLabel('MINIMUM POWER', _minPower, 250),
                  Slider(
                    value: _minPower,
                    min: 0,
                    max: 250,
                    divisions: 50,
                    activeColor: AppTheme.pokemonRed,
                    onChanged: (val) {
                      setState(() { _minPower = val; });
                      _applyFilters();
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildSliderLabel('MINIMUM ACCURACY', _minAccuracy, 100),
                  Slider(
                    value: _minAccuracy,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppTheme.pokemonRed,
                    onChanged: (val) {
                      setState(() { _minAccuracy = val; });
                      _applyFilters();
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildSliderLabel('MINIMUM PP', _minPp, 40),
                  Slider(
                    value: _minPp,
                    min: 0,
                    max: 40,
                    divisions: 8,
                    activeColor: AppTheme.pokemonRed,
                    onChanged: (val) {
                      setState(() { _minPp = val; });
                      _applyFilters();
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  // Battle properties
                  const Text('BATTLE PROPERTIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
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
                        _buildSwitchRow('Priority Moves', _filterPriority, (val) {
                          setState(() => _filterPriority = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Negative Priority Moves', _filterNegativePriority, (val) {
                          setState(() => _filterNegativePriority = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Makes Contact', _filterContact, (val) {
                          setState(() => _filterContact = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Healing Moves', _filterHealing, (val) {
                          setState(() => _filterHealing = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Sound-Based', _filterSound, (val) {
                          setState(() => _filterSound = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Punching Moves', _filterPunching, (val) {
                          setState(() => _filterPunching = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Biting Moves', _filterBiting, (val) {
                          setState(() => _filterBiting = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Powder Moves', _filterPowder, (val) {
                          setState(() => _filterPowder = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Pulse / Aura Moves', _filterPulse, (val) {
                          setState(() => _filterPulse = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Slicing Moves', _filterSlicing, (val) {
                          setState(() => _filterSlicing = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Wind Moves', _filterWind, (val) {
                          setState(() => _filterWind = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Source filters
                  const Text('SOURCE & RULES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
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
                        _buildSwitchRow('DLC Exclusives', _filterDLC, (val) {
                          setState(() => _filterDLC = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Signature Moves', _filterSignature, (val) {
                          setState(() => _filterSignature = val);
                          _applyFilters();
                          setModalState(() {});
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Effects
                  const Text('ADDITIONAL EFFECTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _effects.map((eff) {
                      final isSel = _selectedEffect == eff;
                      return ChoiceChip(
                        label: Text(eff.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedEffect = selected ? eff : null; });
                          _applyFilters();
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Sorting
                  DexSortMenu<String>(
                    currentValue: _sortOption,
                    items: const [
                      DropdownMenuItem(value: 'name_asc', child: Text('NAME (A - Z)')),
                      DropdownMenuItem(value: 'name_desc', child: Text('NAME (Z - A)')),
                      DropdownMenuItem(value: 'power_desc', child: Text('POWER (HIGHEST FIRST)')),
                      DropdownMenuItem(value: 'power_asc', child: Text('POWER (LOWEST FIRST)')),
                      DropdownMenuItem(value: 'acc_desc', child: Text('ACCURACY (HIGHEST FIRST)')),
                      DropdownMenuItem(value: 'acc_asc', child: Text('ACCURACY (LOWEST FIRST)')),
                      DropdownMenuItem(value: 'pp_desc', child: Text('PP (HIGHEST FIRST)')),
                      DropdownMenuItem(value: 'pp_asc', child: Text('PP (LOWEST FIRST)')),
                      DropdownMenuItem(value: 'priority_desc', child: Text('PRIORITY (HIGHEST FIRST)')),
                      DropdownMenuItem(value: 'type', child: Text('TYPE')),
                      DropdownMenuItem(value: 'class', child: Text('DAMAGE CLASS')),
                      DropdownMenuItem(value: 'gen', child: Text('GENERATION')),
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

  Widget _buildSliderLabel(String label, double val, double max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
        Text(val > 0 ? '${val.round()}+' : 'Any', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.pokemonRed)),
      ],
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
        title: Text('MoveDex', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'moves'),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DexFilterBar(
                    searchHint: 'Search moves by name, type, or desc...',
                    initialSearchValue: _searchQuery,
                    onSearchChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      _applyFilters();
                    },
                    onClearSearch: () {
                      setState(() {
                        _searchQuery = '';
                      });
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

                  ResultCountLabel(count: _filteredMoves.length, label: 'moves found'),

                  Expanded(
                    child: _filteredMoves.isEmpty
                        ? const Center(child: Text('No moves found.', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: 8, bottom: AppSpacing.bottomScrollPadding),
                            itemCount: _filteredMoves.length,
                            separatorBuilder: (context, index) => Divider(
                              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final move = _filteredMoves[index];
                              final color = _getTypeColor(move.type);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                title: Row(
                                  children: [
                                    Text(
                                      move.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                                    ),
                                    if (move.isChampionsMove) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('CHAMP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    if (move.isLegendsZAMove) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('LZA', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                    if (move.isDLCMove) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('DLC', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        move.type.toUpperCase(),
                                        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      move.damageClass.toUpperCase(),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      move.power != null && move.power! > 0 ? 'Pwr: ${move.power}' : 'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'PP: ${move.pp}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ],
                                ),
                                onTap: () => _showMoveDetails(context, move),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showMoveDetails(BuildContext context, Move move) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoveDetailScreen(
          moveId: move.id,
          moveName: move.name,
        ),
      ),
    );
  }
}
