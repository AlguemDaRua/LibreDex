import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoveDetailScreen extends ConsumerStatefulWidget {
  final int moveId;
  final String moveName;

  const MoveDetailScreen({
    super.key,
    required this.moveId,
    required this.moveName,
  });

  @override
  ConsumerState<MoveDetailScreen> createState() => _MoveDetailScreenState();
}

class _MoveDetailScreenState extends ConsumerState<MoveDetailScreen> {
  List<Map<String, dynamic>> _pokemons = [];
  bool _isLoading = true;
  Move? _moveDetails;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final db = ref.read(databaseProvider);

      // Fetch move details
      _moveDetails = await (db.select(db.moveTable)..where((tbl) => tbl.id.equals(widget.moveId))).getSingleOrNull();

      // Fetch all pokemons that can learn this move
      final results = await db.getPokemonsForMove(widget.moveId);

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
    return CombatUtils.typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.moveName.toUpperCase(),
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
                if (_moveDetails != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getTypeColor(_moveDetails!.type).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _moveDetails!.type.toUpperCase(),
                                style: TextStyle(color: _getTypeColor(_moveDetails!.type), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            Row(
                              children: [
                                _buildStatBadge('BP', _moveDetails!.power?.toString() ?? '—', Colors.redAccent),
                                const SizedBox(width: 8),
                                _buildStatBadge('ACC', _moveDetails!.accuracy != null ? '${_moveDetails!.accuracy}%' : '—', Colors.blueAccent),
                                const SizedBox(width: 8),
                                _buildStatBadge('PP', _moveDetails!.pp.toString(), Colors.greenAccent),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('MOVE EFFECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          _moveDetails!.description ?? 'No description available.',
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.school_outlined, size: 20, color: AppTheme.pokemonRed.withValues(alpha: 0.8)),
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
                      ? const Center(child: Text('No Pokémon found that learn this move.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _pokemons.length,
                          itemBuilder: (context, index) {
                            final item = _pokemons[index];
                            final Pokemon p = item['pokemon'];
                            final String method = item['learnMethod'];
                            final int? level = item['levelLearned'];
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
                                        tag: 'move_${widget.moveId}_pokemon_${p.id}',
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
                                            _buildLearnMethodBadge(method, level),
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

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildLearnMethodBadge(String method, int? level) {
    String label = method.toUpperCase();
    Color color = Colors.grey;
    if (method == 'level') {
      label = 'LVL ${level ?? '?'}';
      color = Colors.greenAccent;
    } else if (method == 'tm') {
      label = 'TM/HM';
      color = Colors.amber;
    } else if (method == 'egg') {
      label = 'EGG MOVE';
      color = Colors.pinkAccent;
    } else if (method == 'tutor') {
      label = 'TUTOR';
      color = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
