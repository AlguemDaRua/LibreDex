import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:libredex/core/widgets/app_drawer.dart';

/// Highly-polished Grid View Pokedex Screen.
/// Includes support for dynamic searching, Poké-type colored badges, and custom glassmorphic empty-state components.
class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Maps standard Pokémon types to their vibrant color tags for visual harmony.
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFF08030);
      case 'water':
        return const Color(0xFF6890F0);
      case 'grass':
        return const Color(0xFF78C850);
      case 'electric':
        return const Color(0xFFF8D030);
      case 'ice':
        return const Color(0xFF98D8D8);
      case 'fighting':
        return const Color(0xFFC03028);
      case 'poison':
        return const Color(0xFFA040A0);
      case 'ground':
        return const Color(0xFFE0C068);
      case 'flying':
        return const Color(0xFFA890F0);
      case 'psychic':
        return const Color(0xFFF85888);
      case 'bug':
        return const Color(0xFFA8B820);
      case 'rock':
        return const Color(0xFFB8A038);
      case 'ghost':
        return const Color(0xFF705898);
      case 'dragon':
        return const Color(0xFF7038F8);
      case 'dark':
        return const Color(0xFF705848);
      case 'steel':
        return const Color(0xFFB8B8D0);
      case 'fairy':
        return const Color(0xFFEE99AC);
      default:
        return const Color(0xFFA8A878);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(pokedexProvider);
    final syncState = ref.watch(pokedexSyncNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LibreDex',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        actions: [
          // Quick Sync Button in App Bar if database is populated
          listAsync.when(
            data: (list) => list.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).syncPokedex(),
                    tooltip: 'Force Sync Data',
                  )
                : const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'pokedex'),
      body: SafeArea(
        bottom: true,
        child: syncState.isLoading
            ? _buildLoadingState()
            : syncState.hasError
                ? _buildErrorState(syncState.error.toString())
                : listAsync.when(
                    data: (pokemonList) {
                      if (pokemonList.isEmpty) {
                        return _buildEmptyState();
                      }

                      // Search Filter Logic
                      final filteredList = pokemonList.where((pokemon) {
                        final query = _searchQuery.toLowerCase();
                        return pokemon.name.toLowerCase().contains(query) ||
                            pokemon.id.toString().contains(query) ||
                            pokemon.type1.toLowerCase().contains(query) ||
                            (pokemon.type2?.toLowerCase().contains(query) ?? false);
                      }).toList();

                      return Column(
                        children: [
                          // Search Bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search Pokémon by Name, ID or Type...',
                                prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                          });
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

                          // Pokémon Grid View
                          Expanded(
                            child: filteredList.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No Pokémon matched your search.',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 80),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.95,
                                    ),
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index) {
                                      final pokemon = filteredList[index];
                                      return _buildPokemonCard(pokemon, isDark);
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                    loading: () => _buildLoadingState(),
                    error: (error, _) => _buildErrorState(error.toString()),
                  ),
      ),
    );
  }

  /// Grid Card representing each Pokémon
  Widget _buildPokemonCard(Pokemon pokemon, bool isDark) {
    final typeColor = _getTypeColor(pokemon.type1);

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailScreen(pokemon: pokemon),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: ID and name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pokemon.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: typeColor.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Badges for Types
              Row(
                children: [
                  _buildTypeBadge(pokemon.type1, typeColor),
                  if (pokemon.type2 != null) ...[
                    const SizedBox(width: 4),
                    _buildTypeBadge(pokemon.type2!, _getTypeColor(pokemon.type2!)),
                  ],
                ],
              ),

              // Hero Center Image
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'pokemon_${pokemon.id}',
                    child: pokemon.spriteUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pokemon.spriteUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.grey)),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          )
                        : const Icon(Icons.catching_pokemon, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tiny Type Capsule Indicator
  Widget _buildTypeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        type[0].toUpperCase() + type.substring(1),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Gorgeous Loading screen with custom spinning PokeBall
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: const AlwaysStoppedAnimation(0.25), // Mock spin, custom rotation handled natively by CircularProgress
            child: Icon(
              Icons.catching_pokemon,
              size: 80,
              color: AppTheme.pokemonRed.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Syncing Kanto Pokémon details...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.0),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.pokemonRed),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Downloading sprites, moves, stats and forms offline.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Error display layout
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.pokemonRed),
            const SizedBox(height: 16),
            const Text(
              'Sync Error Occurred',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).syncPokedex(),
              icon: const Icon(Icons.sync),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Premium Empty State Card
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.catching_pokemon,
              size: 110,
              color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 24),
            const Text(
              'LibreDex is Empty',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your offline database currently contains no Pokémon. Sync details from PokeAPI to begin.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(pokedexSyncNotifierProvider.notifier).syncPokedex(),
              icon: const Icon(Icons.cloud_download),
              label: const Text('Sync Generation 1 (151 Pokémon)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppTheme.pokemonRed.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
