import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:libredex/core/theme/app_theme.dart';
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
  
  bool _filterHeldItem = false;
  bool _filterBattleItem = false;
  bool _filterEvolutionItem = false;
  bool _filterDLCItem = false;
  bool _filterChampionsItem = false;
  bool _filterLegendsZAItem = false;

  String? _selectedEffectKeyword;
  String _sortOption = 'name_asc';

  // Download State
  bool _isDownloadingAll = false;
  double _downloadProgress = 0.0;
  int _downloadedCount = 0;
  int _totalToDownload = 0;

  static const List<String> _categories = [
    'Berry', 'Held Item', 'Battle-Item', 'Pokeball', 'Key Item',
    'Medicine', 'TM', 'Mega Stone', 'Z-Crystal', 'Dynamax', 'Tera Item'
  ];

  static const List<String> _subcategories = [
    'Healing', 'Status Recovery', 'Stat Boost', 'Evolution', 'Epower-Up',
    'Plate', 'Apricorn', 'Choice Item', 'Incense', 'Gem', 'Vitamin', 'Mail'
  ];

  static const List<String> _keywords = [
    'Heal', 'Boost', 'Attack', 'Defense', 'Speed', 'Evolve', 'Catch', 'Recovers',
    'Stat', 'Critical', 'EXP', 'Money', 'Accuracy', 'Immunity'
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
      _filterHeldItem = false;
      _filterBattleItem = false;
      _filterEvolutionItem = false;
      _filterDLCItem = false;
      _filterChampionsItem = false;
      _filterLegendsZAItem = false;
      _selectedEffectKeyword = null;
      _sortOption = 'name_asc';
    });
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _selectedSubcategory != null ||
        _filterHeldItem ||
        _filterBattleItem ||
        _filterEvolutionItem ||
        _filterDLCItem ||
        _filterChampionsItem ||
        _filterLegendsZAItem ||
        _selectedEffectKeyword != null ||
        _sortOption != 'name_asc';
  }

  List<ActiveFilterItem> _buildActiveFilterItems() {
    final list = <ActiveFilterItem>[];

    if (_selectedCategory != null) {
      list.add(ActiveFilterItem(
        label: 'Cat: $_selectedCategory',
        onDeleted: () => setState(() => _selectedCategory = null),
      ));
    }
    if (_selectedSubcategory != null) {
      list.add(ActiveFilterItem(
        label: 'Subcat: $_selectedSubcategory',
        onDeleted: () => setState(() => _selectedSubcategory = null),
      ));
    }
    if (_filterHeldItem) {
      list.add(ActiveFilterItem(label: 'Held Items', onDeleted: () => setState(() => _filterHeldItem = false)));
    }
    if (_filterBattleItem) {
      list.add(ActiveFilterItem(label: 'Battle Items', onDeleted: () => setState(() => _filterBattleItem = false)));
    }
    if (_filterEvolutionItem) {
      list.add(ActiveFilterItem(label: 'Evolution Items', onDeleted: () => setState(() => _filterEvolutionItem = false)));
    }
    if (_filterDLCItem) {
      list.add(ActiveFilterItem(label: 'DLC Items', onDeleted: () => setState(() => _filterDLCItem = false)));
    }
    if (_filterChampionsItem) {
      list.add(ActiveFilterItem(label: 'Champions Items', onDeleted: () => setState(() => _filterChampionsItem = false)));
    }
    if (_filterLegendsZAItem) {
      list.add(ActiveFilterItem(label: 'Legends Z-A', onDeleted: () => setState(() => _filterLegendsZAItem = false)));
    }
    if (_selectedEffectKeyword != null) {
      list.add(ActiveFilterItem(
        label: 'Effect: $_selectedEffectKeyword',
        onDeleted: () => setState(() => _selectedEffectKeyword = null),
      ));
    }

    return list;
  }

  void _openFilterSheet(List<ItemDexEntry> allItems) {
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
                  // Category
                  const Text('CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _categories.map((cat) {
                      final isSel = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedCategory = selected ? cat : null; });
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Subcategory
                  const Text('SUBCATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _subcategories.map((sub) {
                      final isSel = _selectedSubcategory == sub;
                      return ChoiceChip(
                        label: Text(sub.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedSubcategory = selected ? sub : null; });
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Battle properties
                  const Text('ITEM TYPES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
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
                        _buildSwitchRow('Held Item Compat', _filterHeldItem, (val) {
                          setState(() => _filterHeldItem = val);
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Battle Usage Only', _filterBattleItem, (val) {
                          setState(() => _filterBattleItem = val);
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Evolution Stone/Item', _filterEvolutionItem, (val) {
                          setState(() => _filterEvolutionItem = val);
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Scarlet/Violet DLC', _filterDLCItem, (val) {
                          setState(() => _filterDLCItem = val);
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Champions Custom', _filterChampionsItem, (val) {
                          setState(() => _filterChampionsItem = val);
                          setModalState(() {});
                        }),
                        _buildSwitchRow('Legends: Z-A Mega Stones', _filterLegendsZAItem, (val) {
                          setState(() => _filterLegendsZAItem = val);
                          setModalState(() {});
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Keywords
                  const Text('EFFECT KEYWORDS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _keywords.map((key) {
                      final isSel = _selectedEffectKeyword == key;
                      return ChoiceChip(
                        label: Text(key.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        selected: isSel,
                        selectedColor: AppTheme.pokemonRed,
                        onSelected: (selected) {
                          setState(() { _selectedEffectKeyword = selected ? key : null; });
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
                      DropdownMenuItem(value: 'category', child: Text('CATEGORY')),
                      DropdownMenuItem(value: 'generation', child: Text('GENERATION (NEWEST FIRST)')),
                      DropdownMenuItem(value: 'id', child: Text('ITEM ID')),
                      DropdownMenuItem(value: 'held_first', child: Text('HELD ITEMS FIRST')),
                      DropdownMenuItem(value: 'battle_first', child: Text('BATTLE ITEMS FIRST')),
                      DropdownMenuItem(value: 'evolution_first', child: Text('EVOLUTION ITEMS FIRST')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() { _sortOption = val; });
                        setModalState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bulk download settings inside filter panel
                  const Text('OFFLINE CACHE UTILITIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDownloadingAll ? null : () {
                            Navigator.pop(context);
                            _bulkDownloadIcons(allItems);
                          },
                          icon: const Icon(Icons.download_for_offline_rounded, size: 16),
                          label: Text(_isDownloadingAll ? 'Downloading...' : 'Bulk Download Icons'),
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
                              const SnackBar(content: Text('Offline item artwork cache cleared.')),
                            );
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.delete_sweep_rounded, size: 16),
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

  Future<void> _bulkDownloadIcons(List<ItemDexEntry> items) async {
    setState(() {
      _isDownloadingAll = true;
      _downloadedCount = 0;
      _totalToDownload = items.length;
      _downloadProgress = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk download of item artwork started...')),
    );

    for (final item in items) {
      if (!_isDownloadingAll) break;
      try {
        await OfflineArtworkStore.instance.downloadArtwork(
          sourceUrl: item.iconUrl,
          remoteUrl: item.iconUrl,
          quality: 'standard',
        );
      } catch (_) {}
      
      if (mounted) {
        setState(() {
          _downloadedCount++;
          _downloadProgress = _downloadedCount / _totalToDownload;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isDownloadingAll = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Finished downloading $_downloadedCount items successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemDexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ItemDex', style: TextStyle(fontWeight: FontWeight.bold)),
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
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed)),
        error: (error, _) => AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Item data could not load',
          message: '$error',
        ),
        data: (items) {
          final filtered = items.where((item) {
            final q = _query.trim().toLowerCase();
            if (q.isNotEmpty) {
              final matchesQuery = item.name.toLowerCase().contains(q) ||
                  item.category.toLowerCase().contains(q) ||
                  item.subcategory.toLowerCase().contains(q) ||
                  item.tags.any((tag) => tag.toLowerCase().contains(q));
              if (!matchesQuery) return false;
            }

            if (_selectedCategory != null && item.category != _selectedCategory) return false;
            if (_selectedSubcategory != null && item.subcategory != _selectedSubcategory) return false;

            if (_filterHeldItem && !item.isHeldItem) return false;
            if (_filterBattleItem && !item.isBattleItem) return false;
            if (_filterEvolutionItem && !item.isEvolutionItem) return false;
            if (_filterDLCItem && !item.isDLCItem) return false;
            if (_filterChampionsItem && !item.isChampionsItem) return false;
            if (_filterLegendsZAItem && !item.isLegendsZAItem) return false;

            if (_selectedEffectKeyword != null) {
              final text = '${item.name} ${item.shortEffect} ${item.description}'.toLowerCase();
              if (!text.contains(_selectedEffectKeyword!.toLowerCase())) return false;
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
                return b.generation.compareTo(a.generation);
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
                  setState(() { _query = val; });
                },
                onClearSearch: () {
                  setState(() { _query = ''; });
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
                        message: 'Try a broader search such as “recovery”, “choice”, “weather”, or “damage”.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 8, AppSpacing.pagePadding, AppSpacing.bottomScrollPadding),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _ItemCard(item: filtered[index]),
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

  const _ItemCard({required this.item});

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
              color: isDark ? const Color(0xFF101010) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withValues(alpha: isDark ? 0.35 : 0.20)),
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
                  child: _ItemIconWidget(item: item, accent: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                          if (item.isChampionsItem) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(4)),
                              child: const Text('CHAMP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                          if (item.isLegendsZAItem && !item.name.toLowerCase().contains('mega')) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(4)),
                              child: const Text('LZA', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.shortEffect,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.25),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Tag(label: item.category, color: accent),
                          _Tag(label: item.subcategory, color: accent),
                          _Tag(label: item.introducedIn, color: Colors.blueGrey),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: isDark ? const Color(0xFF0C0C0C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                        decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(18)),
                        child: _ItemIconWidget(item: item, accent: accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('${item.category} · ${item.subcategory} · ${item.introducedIn}', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(item.shortEffect, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1.35)),
                  const SizedBox(height: 10),
                  Text(item.description, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.45)),
                  const SizedBox(height: 16),
                  Wrap(spacing: 8, runSpacing: 8, children: item.tags.map((tag) => _Tag(label: tag, color: accent)).toList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ItemIconWidget extends StatelessWidget {
  final ItemDexEntry item;
  final Color accent;

  const _ItemIconWidget({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: OfflineArtworkStore.instance.fileForUrl(item.iconUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          // 1. Check durable offline artwork first
          return Image.file(
            snapshot.data!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildCachedNetworkImage(),
          );
        }
        // 2 & 3. Check cached network artwork or remote
        return _buildCachedNetworkImage();
      },
    );
  }

  Widget _buildCachedNetworkImage() {
    return CachedNetworkImage(
      imageUrl: item.iconUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.pokemonRed),
        ),
      ),
      // 6. Show category fallback icon if network/remote fails or is missing
      errorWidget: (context, url, error) => Icon(_itemIcon(item.category), color: accent),
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
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(9)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
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
