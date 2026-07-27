import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/features/itemdex/data/itemdex_data.dart';
import 'package:libredex/features/itemdex/models/itemdex_entry.dart';

class ItemDexScreen extends ConsumerStatefulWidget {
  const ItemDexScreen({super.key});

  @override
  ConsumerState<ItemDexScreen> createState() => _ItemDexScreenState();
}

class _ItemDexScreenState extends ConsumerState<ItemDexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemDexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ItemDex'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'items'),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Item data could not load',
          message: '$error',
        ),
        data: (items) {
          final categories = ['All', ...{for (final item in items) item.category}];
          final filtered = items.where((item) {
            final q = _query.trim().toLowerCase();
            final matchesCategory = _category == 'All' || item.category == _category;
            if (!matchesCategory) return false;
            if (q.isEmpty) return true;
            return item.name.toLowerCase().contains(q) ||
                item.category.toLowerCase().contains(q) ||
                item.subcategory.toLowerCase().contains(q) ||
                item.tags.any((tag) => tag.toLowerCase().contains(q));
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search items, tags, or roles...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    );
                  },
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No items found',
                        message: 'Try a broader search such as “recovery”, “choice”, “weather”, or “damage”.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
                  child: Icon(_itemIcon(item.category), color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
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
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(18)),
                      child: Icon(_itemIcon(item.category), color: accent, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('${item.category} · ${item.subcategory}', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
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
