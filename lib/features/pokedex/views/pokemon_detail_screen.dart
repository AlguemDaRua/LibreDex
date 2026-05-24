import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/widgets/shiny_slider.dart';

/// Pokémon Details View.
/// Displays high-quality Hero artwork transitions, the interactive ShinySlider comparison,
/// type details, and beautifully scaled, color-coded base stats.
class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
  });

  /// Translates type names into standard colors for consistent background accents
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

  /// Calculates stat bar color based on base stat value for high competitive scannability.
  Color _getStatColor(int value) {
    if (value >= 130) return Colors.tealAccent.shade400; // Ultra high tier
    if (value >= 90) return Colors.greenAccent.shade700; // High tier
    if (value >= 60) return Colors.orangeAccent.shade400; // Mid tier
    return Colors.redAccent.shade400; // Low tier
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTypeColor = _getTypeColor(pokemon.type1);
    final bst = pokemon.baseHp +
        pokemon.baseAtk +
        pokemon.baseDef +
        pokemon.baseSpAtk +
        pokemon.baseSpDef +
        pokemon.baseSpd;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pokemon.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    primaryTypeColor.withValues(alpha: 0.15),
                    AppTheme.amoledBlack,
                    AppTheme.amoledBlack,
                  ]
                : [
                    primaryTypeColor.withValues(alpha: 0.1),
                    const Color(0xFFF7FAFC),
                    const Color(0xFFF7FAFC),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top tag info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: primaryTypeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Core Type Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDetailTypeBadge(pokemon.type1, primaryTypeColor),
                    if (pokemon.type2 != null) ...[
                      const SizedBox(width: 8),
                      _buildDetailTypeBadge(pokemon.type2!, _getTypeColor(pokemon.type2!)),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Top Hero Artwork
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Hero(
                    tag: 'pokemon_${pokemon.id}',
                    child: pokemon.spriteUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pokemon.spriteUrl,
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.catching_pokemon, size: 120, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // Interactive Shiny Slider Container
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Shiny Slider',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                    ),
                  ),
                ),
                ShinySlider(
                  normalImageUrl: pokemon.spriteUrl,
                  shinyImageUrl: pokemon.shinySpriteUrl,
                  height: 260,
                ),
                const SizedBox(height: 28),

                // Stats Section
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Base Stats',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryTypeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'BST: $bst',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryTypeColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),

                        _buildStatRow('HP', pokemon.baseHp, isDark),
                        _buildStatRow('Attack', pokemon.baseAtk, isDark),
                        _buildStatRow('Defense', pokemon.baseDef, isDark),
                        _buildStatRow('Sp. Atk', pokemon.baseSpAtk, isDark),
                        _buildStatRow('Sp. Def', pokemon.baseSpDef, isDark),
                        _buildStatRow('Speed', pokemon.baseSpd, isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Big pill type tag badge
  Widget _buildDetailTypeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Interactive scaled base stat row
  Widget _buildStatRow(String label, int value, bool isDark) {
    final double progress = (value / 255.0).clamp(0.0, 1.0);
    final statColor = _getStatColor(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Stat name label
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Stat value label
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 14),

          // Visual Progress Bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFEDF2F7),
                valueColor: AlwaysStoppedAnimation<Color>(statColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
