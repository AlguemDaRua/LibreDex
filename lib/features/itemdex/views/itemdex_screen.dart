import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/data/champions_regulation.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/content_badge.dart';
import 'package:libredex/core/widgets/item_artwork_icon.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/features/itemdex/data/itemdex_data.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/itemdex/models/itemdex_entry.dart';
import 'package:libredex/core/widgets/dex_filter_bar.dart';
import 'package:libredex/core/widgets/dex_sort_menu.dart';
import 'package:libredex/core/widgets/dex_filter_sheet.dart';
import 'package:libredex/core/widgets/active_filter_summary.dart';
import 'package:libredex/core/widgets/result_count_label.dart';
import 'package:libredex/core/storage/offline_artwork_store.dart';

class ItemDexScreen extends ConsumerStatefulWidget {
  const ItemDexScreen({super.key});

  @override
  ConsumerState<ItemDexScreen> createState() => _ItemDexScreenState();
}

class _ItemDexScreenState extends ConsumerState<ItemDexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Filters
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedTag;

  bool _filterHeldItem = false;
  bool _filterBattleItem = false;
  bool _filterEvolutionItem = false;
  bool _filterDLCItem = false;
  bool _filterMCAvailable = false;
  bool _filterNewInMC = false;
  bool _filterChampionsOrigin = false;
  bool _filterLegendsZAItem = false;
  bool _includeAliases = false;

  String? _selectedEffectKeyword;
  String _sortOption = 'name_asc';

  // Download State
  bool _isDownloadingAll = false;
  double _downloadProgress = 0.0;
  int _processedDownloadCount = 0;
  int _totalToDownload = 0;

  static const List<String> _keywords = [
    'Heal',
    'Boost',
    'Attack',
    'Defense',
    'Speed',
    'Evolve',
    'Catch',
    'Recovers',
    'Stat',
    'Critical',
    'EXP',
    'Money',
    'Accuracy',
    'Immunity',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedSubcategory = null;
      _selectedTag = null;
      _filterHeldItem = false;
      _filterBattleItem = false;
      _filterEvolutionItem = false;
      _filterDLCItem = false;
      _filterMCAvailable = false;
      _filterNewInMC = false;
      _filterChampionsOrigin = false;
      _filterLegendsZAItem = false;
      _includeAliases = false;
      _selectedEffectKeyword = null;
      _sortOption = 'name_asc';
    });
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _selectedSubcategory != null ||
        _selectedTag != null ||
        _filterHeldItem ||
        _filterBattleItem ||
        _filterEvolutionItem ||
        _filterDLCItem ||
        _filterMCAvailable ||
        _filterNewInMC ||
        _filterChampionsOrigin ||
        _filterLegendsZAItem ||
        _includeAliases ||
        _selectedEffectKeyword != null ||
        _sortOption != 'name_asc';
  }

  List<ActiveFilterItem> _buildActiveFilterItems() {
    final list = <ActiveFilterItem>[];

    if (_selectedCategory != null) {
      list.add(
        ActiveFilterItem(
          label: 'Cat: $_selectedCategory',
          onDeleted: () => setState(() => _selectedCategory = null),
        ),
      );
    }
    if (_selectedSubcategory != null) {
      list.add(
        ActiveFilterItem(
          label: 'Subcat: $_selectedSubcategory',
          onDeleted: () => setState(() => _selectedSubcategory = null),
        ),
      );
    }
    if (_selectedTag != null) {
      list.add(
        ActiveFilterItem(
          label: 'Tag: $_selectedTag',
          onDeleted: () => setState(() => _selectedTag = null),
        ),
      );
    }
    if (_filterHeldItem) {
      list.add(
        ActiveFilterItem(
          label: 'Held Items',
          onDeleted: () => setState(() => _filterHeldItem = false),
        ),
      );
    }
    if (_filterBattleItem) {
      list.add(
        ActiveFilterItem(
          label: 'Battle Items',
          onDeleted: () => setState(() => _filterBattleItem = false),
        ),
      );
    }
    if (_filterEvolutionItem) {
      list.add(
        ActiveFilterItem(
          label: 'Evolution Items',
          onDeleted: () => setState(() => _filterEvolutionItem = false),
        ),
      );
    }
    if (_filterDLCItem) {
      list.add(
        ActiveFilterItem(
          label: 'DLC Items',
          onDeleted: () => setState(() => _filterDLCItem = false),
        ),
      );
    }
    if (_filterMCAvailable) {
      list.add(
        ActiveFilterItem(
          label: 'Available in M-C',
          onDeleted: () => setState(() => _filterMCAvailable = false),
        ),
      );
    }
    if (_filterNewInMC) {
      list.add(
        ActiveFilterItem(
          label: 'New to M-C',
          onDeleted: () => setState(() => _filterNewInMC = false),
        ),
      );
    }
    if (_filterChampionsOrigin) {
      list.add(
        ActiveFilterItem(
          label: 'Champions-origin item',
          onDeleted: () => setState(() => _filterChampionsOrigin = false),
        ),
      );
    }
    if (_filterLegendsZAItem) {
      list.add(
        ActiveFilterItem(
          label: 'Legends Z-A',
          onDeleted: () => setState(() => _filterLegendsZAItem = false),
        ),
      );
    }
    if (_includeAliases) {
      list.add(
        ActiveFilterItem(
          label: 'Include item aliases',
          onDeleted: () => setState(() => _includeAliases = false),
        ),
      );
    }
    if (_selectedEffectKeyword != null) {
      list.add(
        ActiveFilterItem(
          label: 'Effect: $_selectedEffectKeyword',
          onDeleted: () => setState(() => _selectedEffectKeyword = null),
        ),
      );
    }
    if (_sortOption != 'name_asc') {
      list.add(
        ActiveFilterItem(
          label: 'Sort: ${_sortOption.replaceAll('_', ' ')}',
          onDeleted: () => setState(() => _sortOption = 'name_asc'),
        ),
      );
    }

    return list;
  }

  void _openFilterSheet(List<ItemDexEntry> allItems) {
    final categories =
        allItems
            .map((item) => item.category.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final subcategories =
        allItems
            .map((item) => item.subcategory.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final tags =
        allItems
            .expand((item) => item.tags)
            .map((tag) => tag.trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final hasDlcProvenance = allItems.any((item) => item.isDLCItem);
    final hasChampionsProvenance = allItems.any((item) => item.isChampionsItem);
    final hasAliases = allItems.any((item) => item.isAlias);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return DexFilterSheet(
              title: 'Item Filters',
              hasActiveFilters: _hasActiveFilters,
              onReset: () {
                _clearAllFilters();
                setModalState(() {});
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCatalogDropdown(
                    label: 'Category',
                    anyLabel: 'Any category',
                    selectedValue: _selectedCategory,
                    options: categories,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCatalogDropdown(
                    label: 'Subcategory',
                    anyLabel: 'Any subcategory',
                    selectedValue: _selectedSubcategory,
                    options: subcategories,
                    onChanged: (value) {
                      setState(() => _selectedSubcategory = value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCatalogDropdown(
                    label: 'Tag',
                    anyLabel: 'Any tag',
                    selectedValue: _selectedTag,
                    options: tags,
                    onChanged: (value) {
                      setState(() => _selectedTag = value);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  // Battle properties
                  const Text(
                    'ITEM TYPES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141414)
                          : const Color(0xFFF7FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF222222)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchRow(
                          'Held item compatibility',
                          _filterHeldItem,
                          (val) {
                            setState(() => _filterHeldItem = val);
                            setModalState(() {});
                          },
                        ),
                        _buildSwitchRow('Usable in battle', _filterBattleItem, (
                          val,
                        ) {
                          setState(() => _filterBattleItem = val);
                          setModalState(() {});
                        }),
                        _buildSwitchRow(
                          'Evolution items',
                          _filterEvolutionItem,
                          (val) {
                            setState(() => _filterEvolutionItem = val);
                            setModalState(() {});
                          },
                        ),
                        if (hasDlcProvenance)
                          _buildSwitchRow(
                            'Scarlet/Violet DLC',
                            _filterDLCItem,
                            (val) {
                              setState(() => _filterDLCItem = val);
                              setModalState(() {});
                            },
                          ),
                        _buildSwitchRow(
                          'Available in Regulation M-C',
                          _filterMCAvailable,
                          (val) {
                            setState(() => _filterMCAvailable = val);
                            setModalState(() {});
                          },
                        ),
                        _buildSwitchRow('Newly added to M-C', _filterNewInMC, (
                          val,
                        ) {
                          setState(() => _filterNewInMC = val);
                          setModalState(() {});
                        }),
                        if (hasChampionsProvenance)
                          _buildSwitchRow(
                            'Champions-origin items',
                            _filterChampionsOrigin,
                            (val) {
                              setState(() => _filterChampionsOrigin = val);
                              setModalState(() {});
                            },
                          ),
                        _buildSwitchRow(
                          'Legends: Z-A origin',
                          _filterLegendsZAItem,
                          (val) {
                            setState(() => _filterLegendsZAItem = val);
                            setModalState(() {});
                          },
                        ),
                        if (hasAliases)
                          _buildSwitchRow(
                            'Include duplicate API aliases',
                            _includeAliases,
                            (val) {
                              setState(() => _includeAliases = val);
                              setModalState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Keywords
                  const Text(
                    'EFFECT KEYWORDS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _keywords.map((key) {
                      final isSel = _selectedEffectKeyword == key;
                      return ChoiceChip(
                        label: Text(
                          key.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() {
                            _selectedEffectKeyword = selected ? key : null;
                          });
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
                      DropdownMenuItem(
                        value: 'name_asc',
                        child: Text('NAME (A - Z)'),
                      ),
                      DropdownMenuItem(
                        value: 'name_desc',
                        child: Text('NAME (Z - A)'),
                      ),
                      DropdownMenuItem(
                        value: 'category',
                        child: Text('CATEGORY'),
                      ),
                      DropdownMenuItem(
                        value: 'generation',
                        child: Text('GENERATION (NEWEST FIRST)'),
                      ),
                      DropdownMenuItem(value: 'id', child: Text('ITEM ID')),
                      DropdownMenuItem(
                        value: 'held_first',
                        child: Text('HELD ITEMS FIRST'),
                      ),
                      DropdownMenuItem(
                        value: 'battle_first',
                        child: Text('BATTLE ITEMS FIRST'),
                      ),
                      DropdownMenuItem(
                        value: 'evolution_first',
                        child: Text('EVOLUTION ITEMS FIRST'),
                      ),
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
                  const SizedBox(height: 20),

                  // Bulk download settings inside filter panel
                  const Text(
                    'OFFLINE CACHE UTILITIES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDownloadingAll
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _bulkDownloadIcons(allItems);
                                },
                          icon: const Icon(
                            Icons.download_for_offline_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _isDownloadingAll
                                ? 'Downloading $_processedDownloadCount/$_totalToDownload'
                                : 'Bulk Download Icons',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.pokemonRed,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await OfflineArtworkStore.instance.deleteAll();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Offline item artwork cache cleared.',
                                ),
                              ),
                            );
                            setModalState(() {});
                          },
                          icon: const Icon(
                            Icons.delete_sweep_rounded,
                            size: 16,
                          ),
                          label: const Text('Clear Cache'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
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
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Switch(
          value: value,
          activeThumbColor: AppTheme.pokemonRed,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCatalogDropdown({
    required String label,
    required String anyLabel,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: selectedValue ?? '',
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<String>(value: '', child: Text(anyLabel)),
        ...options.map(
          (option) => DropdownMenuItem<String>(
            value: option,
            child: Text(option, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (value) =>
          onChanged(value == null || value.isEmpty ? null : value),
    );
  }

  Future<void> _bulkDownloadIcons(List<ItemDexEntry> items) async {
    // Count actual artwork URLs, not database rows. Aliases and same-name
    // records can share one sprite and should not inflate the success total.
    final uniqueArtwork = <String, ItemDexEntry>{};
    for (final item in items) {
      if (!item.isAlias) uniqueArtwork.putIfAbsent(item.iconUrl, () => item);
    }
    final downloadableItems = uniqueArtwork.values.toList();
    if (downloadableItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no item icons to download.')),
      );
      return;
    }

    setState(() {
      _isDownloadingAll = true;
      _processedDownloadCount = 0;
      _totalToDownload = downloadableItems.length;
      _downloadProgress = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk download of item artwork started...')),
    );

    final artworkStore = OfflineArtworkStore.instance;
    var succeeded = 0;
    var failed = 0;
    var processed = 0;

    for (final item in downloadableItems) {
      if (!mounted || !_isDownloadingAll) break;
      try {
        await artworkStore.downloadArtwork(
          sourceUrl: item.iconUrl,
          remoteUrl: item.iconUrl,
          quality: 'standard',
        );
        if (await artworkStore.hasArtwork(item.iconUrl, quality: 'standard')) {
          succeeded++;
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }

      processed++;
      if (mounted) {
        setState(() {
          _processedDownloadCount = processed;
          _downloadProgress = processed / _totalToDownload;
        });
      }
    }

    if (mounted) {
      setState(() => _isDownloadingAll = false);
      final total = downloadableItems.length;
      final result = processed == total
          ? 'Offline artwork available for $succeeded of $total unique item icons; $failed failed.'
          : 'Bulk download stopped after $processed of $total unique item icons; $succeeded ready, $failed failed.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemDexProvider);
    final regulation = ref.watch(championsRegulationProvider).asData?.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'ItemDex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isDownloadingAll)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: _downloadProgress,
                    strokeWidth: 3,
                    color: AppTheme.pokemonRed,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.pokemonRed),
        ),
        error: (error, _) => AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Item data could not load',
          message: '$error',
        ),
        data: (items) {
          final filtered = items.where((item) {
            final q = _query.trim().toLowerCase();
            final idQuery = q
                .replaceFirst(RegExp(r'^(?:#|item\s*)'), '')
                .trim();
            final matchesId = idQuery == item.id.toString();
            // Keep the duplicate upstream Roseli stub in the bundled data, but
            // hide it in ordinary browsing. It remains discoverable by ID or
            // by enabling the aliases filter.
            if (item.isAlias && !_includeAliases && !matchesId) return false;
            if (q.isNotEmpty) {
              final matchesQuery =
                  item.name.toLowerCase().contains(q) ||
                  item.category.toLowerCase().contains(q) ||
                  item.subcategory.toLowerCase().contains(q) ||
                  item.tags.any((tag) => tag.toLowerCase().contains(q)) ||
                  item.id.toString() == idQuery;
              if (!matchesQuery) return false;
            }

            if (_selectedCategory != null &&
                item.category.trim().toLowerCase() !=
                    _selectedCategory!.trim().toLowerCase()) {
              return false;
            }
            if (_selectedSubcategory != null &&
                item.subcategory.trim().toLowerCase() !=
                    _selectedSubcategory!.trim().toLowerCase()) {
              return false;
            }
            if (_selectedTag != null &&
                !item.tags.any(
                  (tag) =>
                      tag.trim().toLowerCase() ==
                      _selectedTag!.trim().toLowerCase(),
                )) {
              return false;
            }

            if (_filterHeldItem && !item.isHeldItem) return false;
            if (_filterBattleItem && !item.isBattleItem) return false;
            if (_filterEvolutionItem && !item.isEvolutionItem) return false;
            if (_filterDLCItem && !item.isDLCItem) return false;
            if (_filterMCAvailable &&
                !(regulation?.isItemAvailable(item.id) ?? false)) {
              return false;
            }
            if (_filterNewInMC && !(regulation?.isNewItem(item.id) ?? false)) {
              return false;
            }
            if (_filterChampionsOrigin && !item.isChampionsItem) return false;
            if (_filterLegendsZAItem && !item.isLegendsZAItem) return false;

            if (_selectedEffectKeyword != null) {
              final text =
                  ('${item.name} ${item.category} ${item.subcategory} '
                          '${item.shortEffect} ${item.description} ${item.tags.join(' ')}')
                      .toLowerCase();
              if (!text.contains(_selectedEffectKeyword!.toLowerCase())) {
                return false;
              }
            }

            return true;
          }).toList();

          // Sort
          filtered.sort((a, b) {
            switch (_sortOption) {
              case 'name_desc':
                return b.name.compareTo(a.name);
              case 'category':
                return a.category.compareTo(b.category);
              case 'generation':
                if (a.generation == null && b.generation != null) return 1;
                if (a.generation != null && b.generation == null) return -1;
                return (b.generation ?? 0).compareTo(a.generation ?? 0);
              case 'id':
                return a.id.compareTo(b.id);
              case 'held_first':
                if (a.isHeldItem && !b.isHeldItem) return -1;
                if (!a.isHeldItem && b.isHeldItem) return 1;
                return a.name.compareTo(b.name);
              case 'battle_first':
                if (a.isBattleItem && !b.isBattleItem) return -1;
                if (!a.isBattleItem && b.isBattleItem) return 1;
                return a.name.compareTo(b.name);
              case 'evolution_first':
                if (a.isEvolutionItem && !b.isEvolutionItem) return -1;
                if (!a.isEvolutionItem && b.isEvolutionItem) return 1;
                return a.name.compareTo(b.name);
              case 'name_asc':
              default:
                return a.name.compareTo(b.name);
            }
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isDownloadingAll)
                LinearProgressIndicator(
                  value: _downloadProgress,
                  color: AppTheme.pokemonRed,
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                ),

              DexFilterBar(
                searchHint: 'Search items, tags, or roles...',
                initialSearchValue: _query,
                onSearchChanged: (val) {
                  setState(() {
                    _query = val;
                  });
                },
                onClearSearch: () {
                  setState(() {
                    _query = '';
                  });
                },
                onFilterPressed: () => _openFilterSheet(items),
                hasActiveFilters: _hasActiveFilters,
              ),

              if (_hasActiveFilters)
                ActiveFilterSummary(
                  items: _buildActiveFilterItems(),
                  onClearAll: _clearAllFilters,
                ),

              ResultCountLabel(count: filtered.length, label: 'items found'),

              Expanded(
                child: filtered.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No items found',
                        message:
                            'Try a broader search such as “recovery”, “choice”, “weather”, or “damage”.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          8,
                          AppSpacing.pagePadding,
                          AppSpacing.bottomScrollPadding,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _ItemCard(
                            item: item,
                            mCAvailable:
                                regulation?.isItemAvailable(item.id) ?? false,
                            newInMC: regulation?.isNewItem(item.id) ?? false,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemDexEntry item;
  final bool mCAvailable;
  final bool newInMC;

  const _ItemCard({
    required this.item,
    required this.mCAvailable,
    required this.newInMC,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _itemColor(item.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showDetails(context, item),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.35 : 0.20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ItemArtworkIcon(
                    imageUrl: item.iconUrl,
                    accent: accent,
                    fallbackIcon: _itemIcon(item.category),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (mCAvailable) ...[
                            const SizedBox(width: 6),
                            const ContentBadge.mC(
                              tooltip: 'Available in Regulation M-C',
                            ),
                          ],
                          if (newInMC) ...[
                            const SizedBox(width: 4),
                            const ContentBadge.mC(
                              isNew: true,
                              tooltip: 'Newly added to Regulation M-C',
                            ),
                          ],
                          if (item.isChampionsItem) ...[
                            const SizedBox(width: 4),
                            const ContentBadge(
                              label: 'CHAMP',
                              color: Colors.orangeAccent,
                              tooltip: 'Champions-origin item',
                            ),
                          ],
                          if (item.isLegendsZAItem) ...[
                            const SizedBox(width: 4),
                            const ContentBadge(
                              label: 'LZA',
                              color: Colors.purpleAccent,
                              tooltip: 'Legends: Z-A item',
                            ),
                          ],
                          if (item.isDLCItem) ...[
                            const SizedBox(width: 4),
                            ContentBadge(
                              label: 'DLC',
                              color: Colors.blueAccent,
                              tooltip: item.dlcSource == null
                                  ? 'Downloadable-content item'
                                  : 'Introduced in ${item.dlcSource}',
                            ),
                          ],
                          if (item.isAlias) ...[
                            const SizedBox(width: 4),
                            ContentBadge(
                              label: 'ALIAS',
                              color: Colors.blueGrey,
                              tooltip:
                                  'Upstream alias of item #${item.aliasOf}; the source row is preserved.',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.shortEffect,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Tag(label: item.category, color: accent),
                          _Tag(label: item.subcategory, color: accent),
                          _Tag(
                            label: item.introducedIn,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ItemDexEntry item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _itemColor(item.category);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(context),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Close item details',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ItemArtworkIcon(
                          imageUrl: item.iconUrl,
                          accent: accent,
                          fallbackIcon: _itemIcon(item.category),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '#${item.id} · ${item.category} · ${item.subcategory} · ${item.introducedIn}',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (mCAvailable ||
                                newInMC ||
                                item.isChampionsItem ||
                                item.isLegendsZAItem ||
                                item.isDLCItem ||
                                item.isAlias) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (mCAvailable)
                                    const ContentBadge.mC(
                                      tooltip: 'Available in Regulation M-C',
                                    ),
                                  if (newInMC)
                                    const ContentBadge.mC(
                                      isNew: true,
                                      tooltip: 'Newly added to Regulation M-C',
                                    ),
                                  if (item.isChampionsItem)
                                    const ContentBadge(
                                      label: 'CHAMP',
                                      color: Colors.orangeAccent,
                                      tooltip: 'Champions-origin item',
                                    ),
                                  if (item.isLegendsZAItem)
                                    const ContentBadge(
                                      label: 'LZA',
                                      color: Colors.purpleAccent,
                                    ),
                                  if (item.isDLCItem)
                                    ContentBadge(
                                      label: 'DLC',
                                      color: Colors.blueAccent,
                                      tooltip: item.dlcSource == null
                                          ? 'Downloadable-content item'
                                          : 'Introduced in ${item.dlcSource}',
                                    ),
                                  if (item.isAlias)
                                    ContentBadge(
                                      label: 'ALIAS OF #${item.aliasOf}',
                                      color: Colors.blueGrey,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    item.shortEffect,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.tags
                        .map((tag) => _Tag(label: tag, color: accent))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

Color _itemColor(String category) {
  switch (category.toLowerCase()) {
    case 'berry':
      return const Color(0xFFEC4899);
    case 'held item':
      return const Color(0xFF30A7D7);
    default:
      return AppTheme.pokemonRed;
  }
}

IconData _itemIcon(String category) {
  switch (category.toLowerCase()) {
    case 'berry':
      return Icons.spa_rounded;
    case 'held item':
      return Icons.backpack_rounded;
    default:
      return Icons.inventory_2_rounded;
  }
}
