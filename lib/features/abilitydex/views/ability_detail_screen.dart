import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/core/utils/ability_properties.dart';
import 'package:libredex/core/utils/pokemon_properties.dart';

import 'package:flutter/services.dart';

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
  bool _hasError = false;
  String _errorMessage = '';
  Ability? _abilityDetails;

  final TextEditingController _pokemonSearchController = TextEditingController();
  String _pokemonQuery = '';
  String _pokemonType = 'All';
  int? _selectedGen;
  String _pokemonForm = 'All';

  @override
  void dispose() {
    _pokemonSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visiblePokemons {
    final q = _pokemonQuery.trim().toLowerCase();
    return _pokemons.where((row) {
      final p = row['pokemon'] as Pokemon;
      final text = '${p.name} ${p.form} ${p.type1} ${p.type2 ?? ''}'.toLowerCase();
      
      final matchesQuery = q.isEmpty || text.contains(q);
      final matchesType = _pokemonType == 'All' || p.type1 == _pokemonType || p.type2 == _pokemonType;
      final matchesGen = _selectedGen == null || p.generation == _selectedGen;
      
      bool matchesForm = true;
      if (_pokemonForm != 'All') {
        final f = p.form.toLowerCase();
        if (_pokemonForm == 'Mega') {
          matchesForm = f.contains('mega') || p.isLegendsZA;
        } else if (_pokemonForm == 'Regional') {
          matchesForm = f.contains('alolan') || f.contains('galarian') || f.contains('hisuian') || f.contains('paldean');
        } else if (_pokemonForm == 'Standard') {
          matchesForm = f == 'normal' || f.isEmpty;
        }
      }

      return matchesQuery && matchesType && matchesGen && matchesForm;
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
      
      // Fetch ability details
      _abilityDetails = await (db.select(db.abilityTable)..where((tbl) => tbl.id.equals(widget.abilityId))).getSingleOrNull();
      if (_abilityDetails == null) {
        throw Exception('Ability reference not found in local database.');
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

  void _copyAbilityDetailsToClipboard() {
    if (_abilityDetails == null) return;
    final a = _abilityDetails!;
    final text = 'ABILITY: ${a.name.toUpperCase()}\n'
        'Introduced in: ${a.introducedIn} | Source: ${a.sourceGames}\n'
        '${a.description}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ability info copied to clipboard.')),
    );
  }

  void _shareAbilityInfo() {
    if (_abilityDetails == null) return;
    final a = _abilityDetails!;
    final text = 'Check out ${a.name} in LibreDex!\n'
        'Source: ${a.sourceGames} | ${a.description}';
    Clipboard.setData(ClipboardData(text: text)); // fallback
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ability info shared to clipboard!')),
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
          widget.abilityName.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_abilityDetails != null) ...[
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share ability info',
              onPressed: _shareAbilityInfo,
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'Copy ability info',
              onPressed: _copyAbilityDetailsToClipboard,
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
                    if (_abilityDetails != null) ...[
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('ABILITY EFFECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                if (_abilityDetails!.isChampionsAbility)
                                  _buildBadge('CHAMPIONS', Colors.orangeAccent)
                                else if (_abilityDetails!.isLegendsZAAbility)
                                  _buildBadge('LEGENDS Z-A', Colors.purpleAccent)
                                else
                                  _buildBadge(_abilityDetails!.introducedInLabel, Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _abilityDetails!.description,
                              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            
                            // Effect tags list
                            const Text('CLASSIFICATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _abilityDetails!.effectTagsList.map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.pokemonRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.3), width: 1),
                                ),
                                child: Text(
                                  tag.toUpperCase(),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Pokemon learners
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.catching_pokemon, size: 20, color: AppTheme.pokemonRed.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              const Text(
                                'POKÉMON WITH THIS ABILITY',
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

                    // Filter search input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _pokemonSearchController,
                        onChanged: (value) => setState(() => _pokemonQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Filter Pokémon by name, form, or type...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
                          suffixIcon: _pokemonQuery.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _pokemonSearchController.clear(); setState(() => _pokemonQuery = ''); }),
                          isDense: true,
                        ),
                      ),
                    ),

                    _buildFilterChipsRow(),

                    Expanded(
                      child: _visiblePokemons.isEmpty
                          ? const Center(child: Text('No Pokémon found with this ability.'))
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _visiblePokemons.length,
                              itemBuilder: (context, index) {
                                final item = _visiblePokemons[index];
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    final hasActiveFilter = _pokemonType != 'All' || _selectedGen != null || _pokemonForm != 'All';
    const types = ['normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDropdownFilterChip(
              label: _pokemonType == 'All' ? 'Type: All' : 'Type: ${_pokemonType.toUpperCase()}',
              isActive: _pokemonType != 'All',
              color: _pokemonType == 'All' ? null : _getTypeColor(_pokemonType),
              onTap: () => _showPickerBottomSheet(
                title: 'SELECT ELEMENTAL TYPE',
                options: ['All', ...types],
                selected: _pokemonType,
                itemLabel: (t) => t.toUpperCase(),
                onSelect: (val) => setState(() => _pokemonType = val),
                colorBuilder: (t) => t == 'All' ? null : _getTypeColor(t),
              ),
            ),
            const SizedBox(width: 8),
            _buildDropdownFilterChip(
              label: _selectedGen == null ? 'Gen: All' : 'Gen $_selectedGen',
              isActive: _selectedGen != null,
              onTap: () => _showPickerBottomSheet(
                title: 'SELECT GENERATION',
                options: ['All', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
                selected: _selectedGen?.toString() ?? 'All',
                itemLabel: (g) => g == 'All' ? 'ALL GENS' : 'GEN $g',
                onSelect: (val) => setState(() => _selectedGen = val == 'All' ? null : int.parse(val)),
              ),
            ),
            const SizedBox(width: 8),
            _buildDropdownFilterChip(
              label: _pokemonForm == 'All' ? 'Form: All' : 'Form: ${_pokemonForm.toUpperCase()}',
              isActive: _pokemonForm != 'All',
              onTap: () => _showPickerBottomSheet(
                title: 'SELECT FORM',
                options: ['All', 'Standard', 'Mega', 'Regional'],
                selected: _pokemonForm,
                itemLabel: (f) => f.toUpperCase(),
                onSelect: (val) => setState(() => _pokemonForm = val),
              ),
            ),
            if (hasActiveFilter) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _pokemonType = 'All';
                    _selectedGen = null;
                    _pokemonForm = 'All';
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, size: 14, color: AppTheme.pokemonRed),
                      SizedBox(width: 4),
                      Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.pokemonRed)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilterChip({
    required String label,
    required bool isActive,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? (isActive ? AppTheme.pokemonRed : Colors.grey);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? chipColor.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? chipColor : Colors.grey.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? chipColor : Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: isActive ? chipColor : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  void _showPickerBottomSheet({
    required String title,
    required List<String> options,
    required String selected,
    required String Function(String) itemLabel,
    required ValueChanged<String> onSelect,
    Color? Function(String)? colorBuilder,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141414) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: options.map((opt) {
                      final isSel = selected == opt;
                      final customColor = colorBuilder?.call(opt);
                      final activeColor = customColor ?? AppTheme.pokemonRed;

                      return InkWell(
                        onTap: () {
                          onSelect(opt);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel
                                ? activeColor
                                : (customColor != null
                                    ? customColor.withValues(alpha: 0.12)
                                    : (isDark ? const Color(0xFF222222) : const Color(0xFFF1F5F9))),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? activeColor : (customColor ?? (isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0))),
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            itemLabel(opt),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSel
                                  ? Colors.white
                                  : (customColor ?? (isDark ? Colors.white70 : Colors.black87)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              'Could not load ability details',
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
