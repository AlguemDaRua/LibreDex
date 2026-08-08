import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/learn_method_badge.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

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

  // Learnset filters (Multi-select)
  final TextEditingController _pokemonSearchController = TextEditingController();
  String _pokemonQuery = '';
  final Set<String> _selectedTypes = {};
  final Set<int> _selectedGens = {};
  final Set<String> _selectedMethods = {};

  /// Derives available Pokémon types from the loaded learnset.
  List<String> get _types {
    final types = <String>{};
    for (final row in _pokemons) {
      final p = row['pokemon'] as Pokemon;
      types.add(p.type1);
      if (p.type2 != null) types.add(p.type2!);
    }
    final sorted = types.toList()..sort();
    return sorted;
  }

  @override
  void dispose() {
    _pokemonSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visiblePokemons {
    final q = _pokemonQuery.trim().toLowerCase();
    return _pokemons.where((row) {
      final p = row['pokemon'] as Pokemon;
      final String method = (row['learnMethod'] ?? 'level-up').toString();
      final text = '${p.name} ${p.form} ${p.type1} ${p.type2 ?? ''}'.toLowerCase();

      final matchesQuery = q.isEmpty || text.contains(q);
      final matchesType = _selectedTypes.isEmpty ||
          _selectedTypes.contains(p.type1.toLowerCase()) ||
          (p.type2 != null && _selectedTypes.contains(p.type2!.toLowerCase()));
      final matchesGen = _selectedGens.isEmpty || _selectedGens.contains(p.generation);
      final matchesMethod = _selectedMethods.isEmpty ||
          _selectedMethods.any((m) => m.toLowerCase() == method.toLowerCase());

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

  void _copyMoveDetailsToClipboard() {
    if (_moveDetails == null) return;
    final m = _moveDetails!;
    final text = 'MOVE: ${m.name.toUpperCase()}\n'
        'Type: ${m.type.toUpperCase()} | Class: ${m.damageClass.toUpperCase()}\n'
        'Power: ${m.power?.toString() ?? "—"} | Acc: ${m.accuracy != null ? "${m.accuracy}%" : "—"} | PP: ${m.pp}\n'
        'Priority: ${m.priority} | Contact: ${m.isContact ? "Yes" : "No"}\n'
        '${m.description ?? "No description available."}';
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
    Clipboard.setData(ClipboardData(text: text));
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
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Move Card Header (Scrolls away cleanly!)
                    if (_moveDetails != null)
                      SliverToBoxAdapter(
                        child: _buildMoveHeaderCard(isDark),
                      ),

                    // Section Title: Learned By
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
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
                    ),

                    // Sticky Filter & Search Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _MoveFilterHeaderDelegate(
                        child: Container(
                          color: isDark ? Colors.black : const Color(0xFFF9FAFB),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _pokemonSearchController,
                                onChanged: (value) => setState(() => _pokemonQuery = value),
                                decoration: InputDecoration(
                                  hintText: 'Filter learned-by Pokémon...',
                                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
                                  suffixIcon: _pokemonQuery.isEmpty
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _pokemonSearchController.clear();
                                            setState(() => _pokemonQuery = '');
                                          },
                                        ),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildFilterChipsRow(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // List of learned-by Pokémon
                    _visiblePokemons.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No Pokémon match this filter.',
                                style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
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
                                    side: BorderSide(
                                        color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFE2E8F0)),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PokemonDetailScreen(forms: [p])),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Hero(
                                            tag: 'move_${widget.moveId}_pokemon_${p.id}',
                                            child: SizedBox(
                                              width: 54,
                                              height: 54,
                                              child: p.spriteUrl.isNotEmpty
                                                  ? PokemonSprite(
                                                      imageUrl: p.spriteUrl,
                                                      fallbackUrl: PokemonSprite.homeArtworkUrl(
                                                          p.nationalDexNumber > 0
                                                              ? p.nationalDexNumber
                                                              : p.id),
                                                      loadingIndicatorSize: 20,
                                                      errorIconColor: typeColor.withValues(alpha: 0.3),
                                                      errorIconSize: 24,
                                                    )
                                                  : Icon(Icons.catching_pokemon,
                                                      color: typeColor.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '#${p.nationalDexNumber > 0 ? p.nationalDexNumber.toString().padLeft(3, '0') : p.id}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        p.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (p.form.isNotEmpty && p.form != 'normal')
                                                  Text(
                                                    p.form.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _buildTypeBadge(p.type1),
                                                    if (p.type2 != null) ...[
                                                      const SizedBox(width: 4),
                                                      _buildTypeBadge(p.type2!),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildLearnMethodBadge(method, level),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _visiblePokemons.length,
                            ),
                          ),
                  ],
                ),
    );
  }

  Widget _buildMoveHeaderCard(bool isDark) {
    return Container(
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
                  style: TextStyle(
                    color: _getTypeColor(_moveDetails!.type),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildStatBadge('BP', _moveDetails!.power?.toString() ?? '—', Colors.redAccent),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                      'ACC', _moveDetails!.accuracy != null ? '${_moveDetails!.accuracy}%' : '—', Colors.blueAccent),
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
          const Text('MOVE PROPERTIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPropertyBadge('Priority: ${_moveDetails!.priority}', Colors.orangeAccent, icon: Icons.priority_high),
              _buildPropertyBadge('Contact: ${_moveDetails!.isContact ? "Yes" : "No"}', Colors.blueAccent,
                  icon: Icons.pan_tool_outlined),
              if (_moveDetails!.isHealing) _buildPropertyBadge('Healing', Colors.green, icon: Icons.healing),
              if (_moveDetails!.isSound) _buildPropertyBadge('Sound-Based', Colors.purple, icon: Icons.volume_up),
              if (_moveDetails!.isPunching) _buildPropertyBadge('Punching', Colors.red, icon: Icons.sports_mma),
              if (_moveDetails!.isBiting) _buildPropertyBadge('Biting', Colors.deepOrange, icon: Icons.pets),
              if (_moveDetails!.isPowder) _buildPropertyBadge('Powder', Colors.lime, icon: Icons.blur_on),
              if (_moveDetails!.isPulse)
                _buildPropertyBadge('Pulse/Aura', Colors.indigo, icon: Icons.radio_button_unchecked),
              if (_moveDetails!.isBallistic) _buildPropertyBadge('Ballistic', Colors.blueGrey, icon: Icons.gps_fixed),
              if (_moveDetails!.isSlicing) _buildPropertyBadge('Slicing', Colors.teal, icon: Icons.content_cut),
              if (_moveDetails!.isWind) _buildPropertyBadge('Wind-Based', Colors.cyan, icon: Icons.air),
              if (_moveDetails!.isDance) _buildPropertyBadge('Dance', Colors.pink, icon: Icons.music_note),
              if (_moveDetails!.isMultiHit) _buildPropertyBadge('Multi-Hit', Colors.brown, icon: Icons.repeat),
              if (_moveDetails!.isProtective) _buildPropertyBadge('Protective', Colors.green, icon: Icons.security),
              if (_moveDetails!.isSwitching) _buildPropertyBadge('Switching', Colors.deepPurple, icon: Icons.swap_horiz),
              if (_moveDetails!.isRecharge)
                _buildPropertyBadge('Recharge Required', Colors.red, icon: Icons.battery_charging_full),
              if (_moveDetails!.isRecoil) _buildPropertyBadge('Recoil', Colors.blue, icon: Icons.keyboard_return),
              if (_moveDetails!.isDraining)
                _buildPropertyBadge('Draining', Colors.green, icon: Icons.add_circle_outline),
              _buildPropertyBadge(_moveDetails!.introducedIn ?? 'Unknown', Colors.grey, icon: Icons.calendar_today),
              if (_moveDetails!.isChampionsMove)
                _buildPropertyBadge('Pokémon Champions', Colors.amber, icon: Icons.emoji_events),
              if (_moveDetails!.isLegendsZAMove)
                _buildPropertyBadge('Legends: Z-A', Colors.purple, icon: Icons.auto_awesome),
              if (_moveDetails!.isDLCMove) _buildPropertyBadge('DLC Content', Colors.indigoAccent, icon: Icons.extension),
              if (_moveDetails!.isSignatureMove)
                _buildPropertyBadge('Signature Move', Colors.amber, icon: Icons.workspace_premium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    final hasActiveFilter = _selectedTypes.isNotEmpty || _selectedGens.isNotEmpty || _selectedMethods.isNotEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDropdownFilterChip(
            label: _selectedTypes.isEmpty
                ? 'Type: All'
                : 'Type (${_selectedTypes.length}): ${_selectedTypes.map((t) => t.toUpperCase()).join(", ")}',
            isActive: _selectedTypes.isNotEmpty,
            onTap: _openTypeMultiSelectSheet,
          ),
          const SizedBox(width: 8),
          _buildDropdownFilterChip(
            label: _selectedGens.isEmpty
                ? 'Gen: All'
                : 'Gen (${_selectedGens.length}): ${_selectedGens.map((g) => "G$g").join(", ")}',
            isActive: _selectedGens.isNotEmpty,
            onTap: _openGenMultiSelectSheet,
          ),
          const SizedBox(width: 8),
          _buildDropdownFilterChip(
            label: _selectedMethods.isEmpty
                ? 'Method: All'
                : 'Method (${_selectedMethods.length}): ${_selectedMethods.join(", ")}',
            isActive: _selectedMethods.isNotEmpty,
            onTap: _openMethodMultiSelectSheet,
          ),
          if (hasActiveFilter) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedTypes.clear();
                  _selectedGens.clear();
                  _selectedMethods.clear();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.pokemonRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.clear, size: 14, color: AppTheme.pokemonRed),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.pokemonRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openTypeMultiSelectSheet() {
    final availableTypes = _types;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER BY ELEMENTAL TYPE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _selectedTypes.clear());
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: AppTheme.pokemonRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTypes.map((t) {
                      final lower = t.toLowerCase();
                      final isSelected = _selectedTypes.contains(lower);
                      final typeColor = _getTypeColor(t);

                      return FilterChip(
                        selected: isSelected,
                        label: Text(t.toUpperCase()),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: typeColor,
                        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            if (val) {
                              _selectedTypes.add(lower);
                            } else {
                              _selectedTypes.remove(lower);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openGenMultiSelectSheet() {
    final gens = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER BY GENERATION',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _selectedGens.clear());
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: AppTheme.pokemonRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gens.map((g) {
                      final isSelected = _selectedGens.contains(g);

                      return FilterChip(
                        selected: isSelected,
                        label: Text('GEN $g'),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: AppTheme.pokemonRed,
                        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            if (val) {
                              _selectedGens.add(g);
                            } else {
                              _selectedGens.remove(g);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openMethodMultiSelectSheet() {
    final methods = ['level-up', 'machine', 'egg', 'tutor', 'evolution'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FILTER BY LEARN METHOD',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() => _selectedMethods.clear());
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: AppTheme.pokemonRed, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: methods.map((m) {
                      final isSelected = _selectedMethods.contains(m);

                      return FilterChip(
                        selected: isSelected,
                        label: Text(m.toUpperCase()),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        selectedColor: AppTheme.pokemonRed,
                        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6),
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            if (val) {
                              _selectedMethods.add(m);
                            } else {
                              _selectedMethods.remove(m);
                            }
                          });
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pokemonRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.pokemonRed.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.pokemonRed : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? AppTheme.pokemonRed
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isActive ? AppTheme.pokemonRed : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPropertyBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    final color = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildLearnMethodBadge(String method, int? level) {
    return LearnMethodBadge(method: method, level: level, compact: true);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'Move details could not be loaded.',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pokemonRed),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _MoveFilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 108;

  @override
  double get minExtent => 108;

  @override
  bool shouldRebuild(covariant _MoveFilterHeaderDelegate oldDelegate) {
    return true;
  }
}
