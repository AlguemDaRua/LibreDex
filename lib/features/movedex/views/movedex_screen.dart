import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/movedex/views/move_detail_screen.dart';

class MovedexScreen extends ConsumerStatefulWidget {
  const MovedexScreen({super.key});

  @override
  ConsumerState<MovedexScreen> createState() => _MovedexScreenState();
}

class _MovedexScreenState extends ConsumerState<MovedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Move> _allMoves = [];
  List<Move> _filteredMoves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMoves() async {
    final db = ref.read(databaseProvider);
    final moves = await db.select(db.moveTable).get();
    moves.sort((a, b) => a.name.compareTo(b.name));
    if (mounted) {
      setState(() {
        _allMoves = moves;
        _filteredMoves = moves;
        _isLoading = false;
      });
    }
  }

  void _filterMoves(String query) {
    setState(() {
      _searchQuery = query;
      _filteredMoves = _allMoves.where((m) {
        final q = query.toLowerCase();
        return m.name.toLowerCase().contains(q) || m.type.toLowerCase().contains(q);
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
        title: Text('MoveDex', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(currentRoute: 'moves'),
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
                      onChanged: _filterMoves,
                      decoration: InputDecoration(
                        hintText: 'Search moves by name or type...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.pokemonRed),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterMoves('');
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

                  // Moves List
                  Expanded(
                    child: _filteredMoves.isEmpty
                        ? const Center(child: Text('No moves found.', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: 8, bottom: AppSpacing.bottomScrollPadding),
                            itemCount: _filteredMoves.length,
                            separatorBuilder: (context, index) => Divider(
                              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final move = _filteredMoves[index];
                              final color = _getTypeColor(move.type);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                title: Text(
                                  move.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                                ),
                                subtitle: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        move.type.toUpperCase(),
                                        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      move.damageClass.toUpperCase(),
                                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      move.power != null && move.power! > 0 ? 'Pwr: ${move.power}' : 'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'PP: ${move.pp}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                                    ),
                                  ],
                                ),
                                onTap: () => _showMoveDetails(context, move),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showMoveDetails(BuildContext context, Move move) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoveDetailScreen(
          moveId: move.id,
          moveName: move.name,
        ),
      ),
    );
  }

}

