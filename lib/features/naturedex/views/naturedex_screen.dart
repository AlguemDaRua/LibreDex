import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/core/widgets/dex_filter_bar.dart';
import 'package:libredex/core/widgets/dex_sort_menu.dart';
import 'package:libredex/core/widgets/dex_filter_sheet.dart';
import 'package:libredex/core/widgets/active_filter_summary.dart';
import 'package:libredex/core/widgets/result_count_label.dart';

class NaturedexScreen extends StatefulWidget {
  const NaturedexScreen({super.key});
  @override State<NaturedexScreen> createState() => _NaturedexScreenState();
}

class _NaturedexScreenState extends State<NaturedexScreen> {
  String _query = '';
  
  // Filters
  String _neutralFilter = 'All'; // All, Neutral, Stat-changing
  String? _selectedIncreasedStat;
  String? _selectedDecreasedStat;

  String _sortOption = 'name_asc';

  static const List<String> _statsList = [
    'Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed'
  ];

  static const List<Map<String, String>> natures = [
    {'name': 'Adamant', 'increased': 'Attack', 'decreased': 'Sp. Atk'},
    {'name': 'Bashful', 'increased': '—', 'decreased': '—'},
    {'name': 'Bold', 'increased': 'Defense', 'decreased': 'Attack'},
    {'name': 'Brave', 'increased': 'Attack', 'decreased': 'Speed'},
    {'name': 'Calm', 'increased': 'Sp. Def', 'decreased': 'Attack'},
    {'name': 'Careful', 'increased': 'Sp. Def', 'decreased': 'Sp. Atk'},
    {'name': 'Docile', 'increased': '—', 'decreased': '—'},
    {'name': 'Gentle', 'increased': 'Sp. Def', 'decreased': 'Defense'},
    {'name': 'Hardy', 'increased': '—', 'decreased': '—'},
    {'name': 'Hasty', 'increased': 'Speed', 'decreased': 'Defense'},
    {'name': 'Impish', 'increased': 'Defense', 'decreased': 'Sp. Atk'},
    {'name': 'Jolly', 'increased': 'Speed', 'decreased': 'Sp. Atk'},
    {'name': 'Lax', 'increased': 'Defense', 'decreased': 'Sp. Def'},
    {'name': 'Lonely', 'increased': 'Attack', 'decreased': 'Defense'},
    {'name': 'Mild', 'increased': 'Sp. Atk', 'decreased': 'Defense'},
    {'name': 'Modest', 'increased': 'Sp. Atk', 'decreased': 'Attack'},
    {'name': 'Naive', 'increased': 'Speed', 'decreased': 'Sp. Def'},
    {'name': 'Naughty', 'increased': 'Attack', 'decreased': 'Sp. Def'},
    {'name': 'Quiet', 'increased': 'Sp. Atk', 'decreased': 'Speed'},
    {'name': 'Quirky', 'increased': '—', 'decreased': '—'},
    {'name': 'Rash', 'increased': 'Sp. Atk', 'decreased': 'Sp. Def'},
    {'name': 'Relaxed', 'increased': 'Defense', 'decreased': 'Speed'},
    {'name': 'Sassy', 'increased': 'Sp. Def', 'decreased': 'Speed'},
    {'name': 'Serious', 'increased': '—', 'decreased': '—'},
    {'name': 'Timid', 'increased': 'Speed', 'decreased': 'Attack'},
  ];

  void _clearAllFilters() {
    setState(() {
      _neutralFilter = 'All';
      _selectedIncreasedStat = null;
      _selectedDecreasedStat = null;
      _sortOption = 'name_asc';
    });
  }

  bool get _hasActiveFilters {
    return _neutralFilter != 'All' ||
        _selectedIncreasedStat != null ||
        _selectedDecreasedStat != null ||
        _sortOption != 'name_asc';
  }

  List<ActiveFilterItem> _buildActiveFilterItems() {
    final list = <ActiveFilterItem>[];

    if (_neutralFilter != 'All') {
      list.add(ActiveFilterItem(
        label: _neutralFilter,
        onDeleted: () => setState(() => _neutralFilter = 'All'),
      ));
    }
    if (_selectedIncreasedStat != null) {
      list.add(ActiveFilterItem(
        label: 'Inc: $_selectedIncreasedStat',
        onDeleted: () => setState(() => _selectedIncreasedStat = null),
      ));
    }
    if (_selectedDecreasedStat != null) {
      list.add(ActiveFilterItem(
        label: 'Dec: $_selectedDecreasedStat',
        onDeleted: () => setState(() => _selectedDecreasedStat = null),
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
              title: 'Nature Filters',
              hasActiveFilters: _hasActiveFilters,
              onReset: () {
                _clearAllFilters();
                setModalState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Neutral filter
                  const Text('CLASSIFICATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Neutral', 'Stat-changing'].map((type) {
                      final isSel = _neutralFilter == type;
                      return ChoiceChip(
                        label: Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _neutralFilter = type; });
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Increased Stat
                  const Text('INCREASED STAT (+10%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _statsList.map((stat) {
                      final isSel = _selectedIncreasedStat == stat;
                      return ChoiceChip(
                        label: Text(stat.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: Colors.teal[600],
                        onSelected: (selected) {
                          setState(() { _selectedIncreasedStat = selected ? stat : null; });
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Decreased Stat
                  const Text('DECREASED STAT (-10%)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _statsList.map((stat) {
                      final isSel = _selectedDecreasedStat == stat;
                      return ChoiceChip(
                        label: Text(stat.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: Colors.red[600],
                        onSelected: (selected) {
                          setState(() { _selectedDecreasedStat = selected ? stat : null; });
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
                      DropdownMenuItem(value: 'increased', child: Text('INCREASED STAT')),
                      DropdownMenuItem(value: 'decreased', child: Text('DECREASED STAT')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() { _sortOption = val; });
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    // Filter list
    var visibleNatures = natures.where((nature) {
      final matchesText = nature.values.join(" ").toLowerCase().contains(_query.toLowerCase());
      final isNeutral = nature['increased'] == '—';

      bool matchesNeutral = true;
      if (_neutralFilter == 'Neutral') matchesNeutral = isNeutral;
      if (_neutralFilter == 'Stat-changing') matchesNeutral = !isNeutral;

      bool matchesInc = _selectedIncreasedStat == null || nature['increased'] == _selectedIncreasedStat;
      bool matchesDec = _selectedDecreasedStat == null || nature['decreased'] == _selectedDecreasedStat;

      return matchesText && matchesNeutral && matchesInc && matchesDec;
    }).toList();

    // Sort list
    visibleNatures.sort((a, b) {
      switch (_sortOption) {
        case 'name_desc':
          return b['name']!.compareTo(a['name']!);
        case 'increased':
          return a['increased']!.compareTo(b['increased']!);
        case 'decreased':
          return a['decreased']!.compareTo(b['decreased']!);
        case 'name_asc':
        default:
          return a['name']!.compareTo(b['name']!);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('NatureDex', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'natures'),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banners for Rules (Champions Alignment & Legends Z-A)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    _buildRuleCard(
                      title: 'Standard Modifiers',
                      desc: 'Increased stats grow 10% faster (x1.1), decreased stats grow 10% slower (x0.9). Neutral Natures have no effect.',
                      color: AppTheme.pokemonRed,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildRuleCard(
                      title: 'Champions Alignments',
                      desc: 'Supports Champions custom Alignment Stat Points, optimizing physical, special, or balanced bulk distributions.',
                      color: Colors.amber,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildRuleCard(
                      title: 'Legends: Z-A Rules',
                      desc: 'Effort Level speeds and stat growths scale with Effort Grit levels rather than raw direct stat values.',
                      color: Colors.purple,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              DexFilterBar(
                searchHint: 'Search natures or stats...',
                initialSearchValue: _query,
                onSearchChanged: (val) => setState(() => _query = val),
                onClearSearch: () => setState(() => _query = ''),
                onFilterPressed: _openFilterSheet,
                hasActiveFilters: _hasActiveFilters,
              ),

              if (_hasActiveFilters)
                ActiveFilterSummary(
                  items: _buildActiveFilterItems(),
                  onClearAll: _clearAllFilters,
                ),

              ResultCountLabel(count: visibleNatures.length, label: 'natures found'),

              const SizedBox(height: 8),
              
              // Responsive layouts for Mobile (compact cards) and Tablets (table view)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Tablet Layout: GORGEOUS TABLE
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF141414) : const Color(0xFFEDF2F7),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text('NATURE NAME', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 11))),
                                Expanded(flex: 2, child: Text('INCREASED (+10%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 11))),
                                Expanded(flex: 2, child: Text('DECREASED (-10%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 11))),
                                Expanded(flex: 3, child: Text('CHAMPIONS ALIGNMENT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 11))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: visibleNatures.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0)),
                              itemBuilder: (context, index) {
                                final nature = visibleNatures[index];
                                final inc = nature['increased']!;
                                final dec = nature['decreased']!;
                                final isNeutral = inc == '—';

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  color: isDark ? Colors.transparent : Colors.white,
                                  child: Row(
                                    children: [
                                      Expanded(flex: 2, child: Text(nature['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          inc,
                                          style: TextStyle(
                                            fontWeight: isNeutral ? FontWeight.normal : FontWeight.bold,
                                            color: isNeutral ? Colors.grey : (isDark ? Colors.tealAccent : Colors.teal[700]),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          dec,
                                          style: TextStyle(
                                            fontWeight: isNeutral ? FontWeight.normal : FontWeight.bold,
                                            color: isNeutral ? Colors.grey : (isDark ? Colors.redAccent : Colors.red[700]),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          isNeutral ? 'Neutral Alignment' : '${inc} Focused',
                                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Compact Card Layout for Mobile Phones
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: visibleNatures.length,
                        itemBuilder: (context, index) {
                          final nature = visibleNatures[index];
                          final inc = nature['increased']!;
                          final dec = nature['decreased']!;
                          final isNeutral = inc == '—';

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF101010) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isNeutral
                                    ? Colors.grey.withValues(alpha: 0.2)
                                    : (isDark ? Colors.tealAccent.withValues(alpha: 0.2) : Colors.teal.withValues(alpha: 0.2)),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nature['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('INC:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text(
                                      inc,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isNeutral ? FontWeight.normal : FontWeight.bold,
                                        color: isNeutral ? Colors.grey : (isDark ? Colors.tealAccent : Colors.teal[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('DEC:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text(
                                      dec,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isNeutral ? FontWeight.normal : FontWeight.bold,
                                        color: isNeutral ? Colors.grey : (isDark ? Colors.redAccent : Colors.red[700]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String desc,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule_folder, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.35),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
