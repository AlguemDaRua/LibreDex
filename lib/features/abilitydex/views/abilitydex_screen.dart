import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/abilitydex/views/ability_detail_screen.dart';

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
  String _sort = 'Name (A–Z)';
  String _effectFilter = 'All';

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
    final db = ref.read(databaseProvider);
    final abilities = await db.select(db.abilityTable).get();
    abilities.sort((a, b) => a.name.compareTo(b.name));
    if (mounted) {
      setState(() {
        _allAbilities = abilities;
        _filteredAbilities = abilities;
        _isLoading = false;
      });
    }
  }

  List<Ability> _sortAbilities(Iterable<Ability> values) {
    final result = values.toList();
    result.sort((a, b) => _sort == 'Name (Z–A)' ? b.name.compareTo(a.name) : a.name.compareTo(b.name));
    return result;
  }

  void _applyAbilityOptions() {
    final q = _searchQuery;
    final base = _allAbilities.where((a) { final has = a.description.trim().isNotEmpty && !a.description.toLowerCase().contains('no effect text'); return (_effectFilter == 'All' || (_effectFilter == 'With effects' && has) || (_effectFilter == 'No effect' && !has)) && (a.name.toLowerCase().contains(q.toLowerCase()) || a.description.toLowerCase().contains(q.toLowerCase())); });
    setState(() => _filteredAbilities = _sortAbilities(base));
  }

  void _filterAbilities(String query) {
    _searchQuery = query;
    _applyAbilityOptions();
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
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterAbilities,
                      decoration: InputDecoration(
                        hintText: 'Search abilities by name...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterAbilities('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF161616) : const Color(0xFFEDF2F7),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: AppTheme.pokemonRed, width: 1.5),
                        ),
                      ),
                    ),
                  ),

                  _DexControls(
                    sort: _sort,
                    filter: _effectFilter,
                    filters: const ['All', 'With effects', 'No effect'],
                    onSort: (value) { setState(() => _sort = value); _applyAbilityOptions(); },
                    onFilter: (value) { setState(() => _effectFilter = value); _applyAbilityOptions(); },
                  ),

                  // Abilities List
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
                                title: Text(
                                  ab.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
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

class _DexControls extends StatelessWidget {
  final String sort, filter; final List<String> filters; final ValueChanged<String> onSort, onFilter; final bool showSort;
  const _DexControls({required this.sort, required this.filter, required this.filters, required this.onSort, required this.onFilter, this.showSort = true});
  @override Widget build(BuildContext context) => SizedBox(height: 48, child: Row(children: [if (showSort) PopupMenuButton<String>(initialValue: sort, icon: const Icon(Icons.sort), onSelected: onSort, itemBuilder: (_) => const [PopupMenuItem(value: 'Name (A–Z)', child: Text('Name (A–Z)')), PopupMenuItem(value: 'Name (Z–A)', child: Text('Name (Z–A)'))]), Expanded(child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), itemCount: filters.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) => ChoiceChip(label: Text(filters[i]), selected: filter == filters[i], onSelected: (_) => onFilter(filters[i]))))]));
}
