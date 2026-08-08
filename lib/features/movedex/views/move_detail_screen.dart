import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/learn_method_badge.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/core/widgets/result_count_label.dart';
import 'package:libredex/core/utils/move_properties.dart';
import 'package:libredex/core/utils/pokemon_properties.dart';

import 'package:flutter/services.dart';

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
  bool _hasError = false;
  String _errorMessage = '';
  Move? _moveDetails;

  // Learnset filters
  final TextEditingController _pokemonSearchController = TextEditingController();
  String _pokemonQuery = '';
  String _pokemonType = 'All';
  int? _selectedGen;
  String _selectedMethod = 'All';

  @override
  void dispose() {
    _pokemonSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visiblePokemons {
    final q = _pokemonQuery.trim().toLowerCase();
    return _pokemons.where((row) {
      final p = row['pokemon'] as Pokemon;
      final String method = row['learnMethod'] ?? 'level-up';
      final text = '${p.name} ${p.form} ${p.type1} ${p.type2 ?? ''}'.toLowerCase();
      
      final matchesQuery = q.isEmpty || text.contains(q);
      final matchesType = _pokemonType == 'All' || p.type1 == _pokemonType || p.type2 == _pokemonType;
      final matchesGen = _selectedGen == null || p.generation == _selectedGen;
      final matchesMethod = _selectedMethod == 'All' || method.toLowerCase() == _selectedMethod.toLowerCase();

      return matchesQuery && matchesType && matchesGen && matchesMethod;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final db = ref.read(databaseProvider);

      // Fetch move details
      _moveDetails = await (db.select(db.moveTable)..where((tbl) => tbl.id.equals(widget.moveId))).getSingleOrNull();
      if (_moveDetails == null) {
        throw Exception('Move reference not found in local database.');
      }

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
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Color _getTypeColor(String type) {
    return CombatUtils.typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  void _copyMoveDetailsToClipboard() {
    if (_moveDetails == null) return;
    final m = _moveDetails!;
    final text = '${m.name.toUpperCase()} (${m.type.toUpperCase()}, ${m.damageClass.toUpperCase()})\n'
        'Power: ${m.power ?? '—'} | Accuracy: ${m.accuracy != null ? '${m.accuracy}%' : '—'} | PP: ${m.pp}\n'
        'Priority: ${m.priority} | Contact: ${m.isContact ? "Yes" : "No"}\n'
        'Introduced in: ${m.introducedIn}\n'
        '${m.description ?? ''}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move details copied to clipboard.')),
    );
  }

  void _shareMoveDetails() {
    if (_moveDetails == null) return;
    final m = _moveDetails!;
    final text = 'Check out ${m.name} in LibreDex!\n'
        'Type: ${m.type.toUpperCase()} | Pwr: ${m.power ?? "Status"} | Acc: ${m.accuracy ?? "—"}\n'
        '${m.description ?? ""}';
    Clipboard.setData(ClipboardData(text: text)); // fallback for share
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move details shared to clipboard!')),
    );
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
        actions: [
          if (_moveDetails != null) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share move info',
              onPressed: _shareMoveDetails,
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'Copy move info',
              onPressed: _copyMoveDetailsToClipboard,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed))
          : _hasError
              ? _buildErrorState()
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
                            const SizedBox(height: 4),
                            Text(
                              _moveDetails!.description ?? 'No description available.',
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            
                            // Property Badges & Flags
                            const Text('MOVE PROPERTIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildPropertyBadge('Priority: ${_moveDetails!.priority}', Colors.orangeAccent, icon: Icons.priority_high),
                                _buildPropertyBadge('Contact: ${_moveDetails!.isContact ? "Yes" : "No"}', Colors.blueAccent, icon: Icons.pan_tool_outlined),
                                if (_moveDetails!.isHealing) _buildPropertyBadge('Healing', Colors.green, icon: Icons.healing),
                                if (_moveDetails!.isSound) _buildPropertyBadge('Sound-Based', Colors.purple, icon: Icons.volume_up),
                                if (_moveDetails!.isPunching) _buildPropertyBadge('Punching', Colors.red, icon: Icons.sports_mma),
                                if (_moveDetails!.isBiting) _buildPropertyBadge('Biting', Colors.deepOrange, icon: Icons.comb_room),
                                if (_moveDetails!.isPowder) _buildPropertyBadge('Powder', Colors.lime, icon: Icons.blur_on),
                                if (_moveDetails!.isPulse) _buildPropertyBadge('Pulse/Aura', Colors.indigo, icon: Icons.star_border_purple_500_outlined),
                                if (_moveDetails!.isBallistic) _buildPropertyBadge('Ballistic', Colors.blueGrey, icon: Icons.gps_fixed),
                                if (_moveDetails!.isSlicing) _buildPropertyBadge('Slicing', Colors.teal, icon: Icons.content_cut),
                                if (_moveDetails!.isWind) _buildPropertyBadge('Wind-Based', Colors.cyan, icon: Icons.air),
                                if (_moveDetails!.isDance) _buildPropertyBadge('Dance', Colors.pink, icon: Icons.music_note),
                                if (_moveDetails!.isMultiHit) _buildPropertyBadge('Multi-Hit', Colors.brown, icon: Icons.repeat),
                                if (_moveDetails!.isProtective) _buildPropertyBadge('Protective', Colors.green, icon: Icons.security),
                                if (_moveDetails!.isSwitching) _buildPropertyBadge('Switching', Colors.deepPurple, icon: Icons.swap_horiz),
                                if (_moveDetails!.isRecharge) _buildPropertyBadge('Recharge Required', Colors.red, icon: Icons.battery_charging_full),
                                if (_moveDetails!.isRecoil) _buildPropertyBadge('Recoil', Colors.blue, icon: Icons.keyboard_return),
                                if (_moveDetails!.isDraining) _buildPropertyBadge('Draining', Colors.green, icon: Icons.add_circle_outline),
                                
                                // Source / Game rules
                                _buildPropertyBadge(_moveDetails!.introducedIn, Colors.grey, icon: Icons.calendar_today),
                                if (_moveDetails!.isChampionsMove) _buildPropertyBadge('Pokémon Champions', Colors.amber, icon: Icons.emoji_events),
                                if (_moveDetails!.isLegendsZAMove) _buildPropertyBadge('Legends: Z-A', Colors.purple, icon: Icons.auto_awesome),
                                if (_moveDetails!.isDLCMove) _buildPropertyBadge('DLC Content', Colors.indigoAccent, icon: Icons.extension),
                                if (_moveDetails!.isSignatureMove) _buildPropertyBadge('Signature Move', Colors.amber, icon: Icons.workspace_premium),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Section: Who learns this move?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school_outlined, size: 20, color: AppTheme.pokemonRed.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              const Text(
                                'LEARNED BY',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            '${_visiblePokemons.length} matches',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Search field inside details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _pokemonSearchController,
                        onChanged: (value) => setState(() => _pokemonQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Filter learned-by Pokémon...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
                          suffixIcon: _pokemonQuery.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _pokemonSearchController.clear(); setState(() => _pokemonQuery = ''); }),
                          isDense: true,
                        ),
                      ),
                    ),

                    // Relational Quick Filters (Type, Generation, Learn Method)
                    Container(
                      height: 38,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Type quick chips
                          _buildFilterCategoryLabel('TYPE:'),
                          ...['All', ..._types].map((type) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(type.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  selected: _pokemonType == type,
                                  onSelected: (_) => setState(() => _pokemonType = type),
                                ),
                              )),
                              
                          _buildFilterCategoryLabel('GEN:'),
                          ...['All', '1', '2', '3', '4', '5', '6', '7', '8', '9'].map((gen) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(gen == 'All' ? 'ALL GENS' : 'GEN $gen', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  selected: (gen == 'All' && _selectedGen == null) || (_selectedGen?.toString() == gen),
                                  onSelected: (_) => setState(() => _selectedGen = gen == 'All' ? null : int.parse(gen)),
                                ),
                              )),

                          _buildFilterCategoryLabel('METHOD:'),
                          ...['All', 'level-up', 'machine', 'egg', 'tutor', 'evolution'].map((method) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(method.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  selected: _selectedMethod == method,
                                  onSelected: (_) => setState(() => _selectedMethod = method),
                                ),
                              )),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _visiblePokemons.isEmpty
                          ? const Center(child: Text('No Pokémon match this filter.'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _visiblePokemons.length,
                              itemBuilder: (context, index) {
                                final item = _visiblePokemons[index];
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
                                                  ? PokemonSprite(
                                                      imageUrl: p.spriteUrl,
                                                      fallbackUrl: PokemonSprite.homeArtworkUrl(p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id),
                                                      loadingIndicatorSize: 20,
                                                      errorIconColor: typeColor.withValues(alpha: 0.3),
                                                      errorIconSize: 24,
                                                    )
                                                  : Icon(Icons.catching_pokemon, color: typeColor.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      p.name,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                    ),
                                                    if (p.isChampions) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(4)),
                                                        child: const Text('CHAMP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                    if (p.isLegendsZA) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                        decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(4)),
                                                        child: const Text('LZA', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  p.form != 'normal' ? 'Form: ${p.form}' : p.generationLabel,
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                                const SizedBox(height: 6),
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

  Widget _buildFilterCategoryLabel(String label) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildPropertyBadge(String text, Color color, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
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
    return LearnMethodBadge(method: method, level: level, compact: true);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.pokemonRed),
            const SizedBox(height: 16),
            const Text(
              'Could not load move details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.sync),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pokemonRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
