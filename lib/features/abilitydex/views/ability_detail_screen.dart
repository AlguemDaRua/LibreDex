import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AbilityDetailScreen extends ConsumerStatefulWidget {
  final int abilityId;
  final String abilityName;

  const AbilityDetailScreen({
    super.key,
    required this.abilityId,
    required this.abilityName,
  });

  @override
  ConsumerState<AbilityDetailScreen> createState() => _AbilityDetailScreenState();
}

class _AbilityDetailScreenState extends ConsumerState<AbilityDetailScreen> {
  List<Map<String, dynamic>> _pokemons = [];
  bool _isLoading = true;
  String? _abilityDescription;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final db = ref.read(databaseProvider);
      
      // Fetch ability description
      final ability = await (db.select(db.abilityTable)..where((tbl) => tbl.id.equals(widget.abilityId))).getSingleOrNull();
      if (ability != null) {
        _abilityDescription = ability.description;
      }

      // Fetch all pokemons with this ability
      final results = await db.getPokemonsForAbility(widget.abilityId);
      
      if (mounted) {
        setState(() {
          _pokemons = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      case 'flying': return const Color(0xFFA98FF3);
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
        title: Text(
          widget.abilityName.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed))
          : Column(
              children: [
                if (_abilityDescription != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ABILITY EFFECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          _abilityDescription!,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.catching_pokemon, size: 20, color: AppTheme.pokemonRed.withValues(alpha: 0.8)),
                      const SizedBox(width: 8),
                      Text(
                        'LEARNED BY ${_pokemons.length} POKÉMON',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _pokemons.isEmpty
                      ? const Center(child: Text('No Pokémon found with this ability.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _pokemons.length,
                          itemBuilder: (context, index) {
                            final item = _pokemons[index];
                            final Pokemon p = item['pokemon'];
                            final bool isHidden = item['isHidden'] == true;
                            final typeColor = _getTypeColor(p.type1);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 0,
                              color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE2E8F0)),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PokemonDetailScreen(forms: [p])),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: 'ability_${widget.abilityId}_pokemon_${p.id}',
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: p.spriteUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: p.spriteUrl,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                                  errorWidget: (context, url, error) => Icon(Icons.catching_pokemon, color: typeColor.withValues(alpha: 0.3)),
                                                )
                                              : Icon(Icons.catching_pokemon, color: typeColor.withValues(alpha: 0.3)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${p.name} ${p.form != 'normal' ? '(${p.form})' : ''}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            if (isHidden)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('HIDDEN ABILITY', style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('NORMAL ABILITY', style: TextStyle(color: Colors.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
