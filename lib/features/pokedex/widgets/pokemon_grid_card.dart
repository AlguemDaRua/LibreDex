import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/data/champions_regulation.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/core/widgets/content_badge.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

/// Single species grid card — one RepaintBoundary per card for instant 60fps
/// scrolling. Extracted from the 2.5k-line PokedexScreen to keep the screen
/// lightweight and instantly loadable. No redundant description — icon + types + M-C badge suffices.
class PokemonGridCard extends ConsumerWidget {
  final List<Pokemon> group;
  final bool isDark;
  final bool globalShinyMode;
  final bool showShinyOnly;
  final ChampionsRegulationCatalog? regulation;

  const PokemonGridCard({
    super.key,
    required this.group,
    required this.isDark,
    required this.globalShinyMode,
    required this.showShinyOnly,
    required this.regulation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (group.isEmpty) return const SizedBox.shrink();

    final pokemon = group.first;
    final dexNum = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
    final typeColor = pokemonTypeColor(pokemon.type1);
    final secondaryColor = pokemon.type2 == null ? typeColor : pokemonTypeColor(pokemon.type2!);
    final favoriteDexNumbers = ref.watch(favoritePokemonProvider);
    final isFavorite = favoriteDexNumbers.contains(dexNum);
    final isAvailableInMC = regulation != null && group.any((form) => regulation!.isPokemonEligible(form.id));
    final isNewInMC = regulation != null && group.any((form) => regulation!.isNewPokemon(form.id));
    final imageUrl = ((showShinyOnly || globalShinyMode) && pokemon.shinySpriteUrl.isNotEmpty)
        ? pokemon.shinySpriteUrl
        : pokemon.spriteUrl;

    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: 'Open ${pokemon.name}, number $dexNum',
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: typeColor.withValues(alpha: isDark ? 0.18 : 0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color.alphaBlend(typeColor.withValues(alpha: 0.25), const Color(0xFF080808)),
                          const Color(0xFF0E0E12),
                        ]
                      : [
                          typeColor.withValues(alpha: 0.22),
                          secondaryColor.withValues(alpha: 0.10),
                          Colors.white,
                        ],
                ),
                border: Border.all(color: typeColor.withValues(alpha: isDark ? 0.35 : 0.22)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PokemonDetailScreen(forms: group)));
                },
                child: Stack(
                  children: [
                    Positioned(
                      right: -18,
                      bottom: -22,
                      child: Icon(Icons.catching_pokemon, size: 112, color: Colors.white.withValues(alpha: isDark ? 0.035 : 0.34)),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                        onPressed: () => ref.read(favoritePokemonProvider.notifier).toggle(dexNum),
                        icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                          foregroundColor: isFavorite ? Colors.amber : (isDark ? Colors.white70 : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#${dexNum.toString().padLeft(3, '0')}',
                              style: TextStyle(color: typeColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.7)),
                          const SizedBox(height: 4),
                          Text(pokemon.name,
                              style: TextStyle(
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 19,
                                  letterSpacing: -0.3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              _TypeBadge(type: pokemon.type1, color: typeColor),
                              if (pokemon.type2 != null) _TypeBadge(type: pokemon.type2!, color: secondaryColor),
                              if (isAvailableInMC)
                                ContentBadge.mC(
                                  isNew: isNewInMC,
                                  tooltip: isNewInMC
                                      ? 'Newly eligible in Pokémon Champions Regulation M-C'
                                      : 'Eligible in Pokémon Champions Regulation M-C',
                                ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Hero(
                                tag: 'pokemon_${pokemon.id}',
                                child: imageUrl.isNotEmpty
                                    ? PokemonSprite(
                                        imageUrl: imageUrl,
                                        fallbackUrl: imageUrl == pokemon.spriteUrl ? null : pokemon.spriteUrl,
                                        loadingIndicatorSize: 26,
                                        errorIconSize: 58,
                                        errorIconColor: typeColor.withValues(alpha: 0.36),
                                        diskCacheSize: 240,
                                      )
                                    : Icon(Icons.catching_pokemon, size: 58, color: typeColor.withValues(alpha: 0.36)),
                              ),
                            ),
                          ),
                          if (group.length > 1)
                            Text('${group.length} forms',
                                style: TextStyle(
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final Color color;
  const _TypeBadge({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
      ),
    );
  }
}
