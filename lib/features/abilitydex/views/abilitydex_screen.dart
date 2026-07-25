import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
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

  void _filterAbilities(String query) {
    setState(() {
      _searchQuery = query;
      _filteredAbilities = _allAbilities.where((a) {
        return a.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
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

                  // Abilities List
                  Expanded(
                    child: _filteredAbilities.isEmpty
                        ? const Center(child: Text('No abilities found.', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
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
