import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

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

  void _showAbilityDetails(BuildContext context, Ability ab) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    final db = ref.read(databaseProvider);
    final pokemonsList = await db.getPokemonsForAbility(ab.id);

    // Group pokemons by Normal and Hidden status
    final List<Pokemon> normalUsers = [];
    final List<Pokemon> hiddenUsers = [];

    for (final item in pokemonsList) {
      final Pokemon p = item['pokemon'];
      final bool isHidden = item['isHidden'] ?? false;
      if (isHidden) {
        hiddenUsers.add(p);
      } else {
        normalUsers.add(p);
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              bottom: true,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      ab.name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 12),

                    // Description Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ab.description,
                        style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pokémon possessing this ability
                    Text(
                      'Pokémon with this Ability',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 16),

                    // Normal Users
                    if (normalUsers.isNotEmpty) ...[
                      const Text(
                        'Normal Ability',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.pokemonRed),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: normalUsers.map((p) {
                          final pColor = _getTypeColor(p.type1);
                          return ActionChip(
                            backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
                            side: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            label: Text(
                              p.name,
                              style: TextStyle(color: pColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PokemonDetailScreen(pokemon: p)),
                                );
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Hidden Users
                    if (hiddenUsers.isNotEmpty) ...[
                      const Text(
                        'Hidden Ability (HIDDEN)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purpleAccent),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hiddenUsers.map((p) {
                          final pColor = _getTypeColor(p.type1);
                          return ActionChip(
                            backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
                            side: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            label: Text(
                              p.name,
                              style: TextStyle(color: pColor, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PokemonDetailScreen(pokemon: p)),
                                );
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
