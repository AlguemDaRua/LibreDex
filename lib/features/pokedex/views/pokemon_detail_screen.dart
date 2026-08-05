import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/storage/offline_artwork_store.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/features/pokedex/repositories/deep_sync_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/stats_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:libredex/features/pokedex/widgets/pokemon_detail_general_tab.dart';
import 'package:libredex/features/pokedex/widgets/pokemon_detail_moves_tab.dart';
import 'package:libredex/features/pokedex/widgets/pokemon_detail_stats_tab.dart';

/// Static dictionary of Pokémon Natures in alphabetical order.
const Map<String, Map<String, dynamic>> alphabeticalNatures = {
  'adamant': {'name': 'Adamant', 'up': 'Attack', 'down': 'Sp. Atk'},
  'bashful': {'name': 'Bashful', 'up': null, 'down': null},
  'bold': {'name': 'Bold', 'up': 'Defense', 'down': 'Attack'},
  'brave': {'name': 'Brave', 'up': 'Attack', 'down': 'Speed'},
  'calm': {'name': 'Calm', 'up': 'Sp. Def', 'down': 'Attack'},
  'careful': {'name': 'Careful', 'up': 'Sp. Def', 'down': 'Sp. Atk'},
  'docile': {'name': 'Docile', 'up': null, 'down': null},
  'gentle': {'name': 'Gentle', 'up': 'Sp. Def', 'down': 'Defense'},
  'hardy': {'name': 'Hardy', 'up': null, 'down': null},
  'hasty': {'name': 'Hasty', 'up': 'Speed', 'down': 'Defense'},
  'impish': {'name': 'Impish', 'up': 'Defense', 'down': 'Sp. Atk'},
  'jolly': {'name': 'Jolly', 'up': 'Speed', 'down': 'Sp. Atk'},
  'lax': {'name': 'Lax', 'up': 'Defense', 'down': 'Sp. Def'},
  'lonely': {'name': 'Lonely', 'up': 'Attack', 'down': 'Defense'},
  'mild': {'name': 'Mild', 'up': 'Sp. Atk', 'down': 'Defense'},
  'modest': {'name': 'Modest', 'up': 'Sp. Atk', 'down': 'Attack'},
  'naive': {'name': 'Naive', 'up': 'Speed', 'down': 'Sp. Def'},
  'naughty': {'name': 'Naughty', 'up': 'Attack', 'down': 'Sp. Def'},
  'quiet': {'name': 'Quiet', 'up': 'Sp. Atk', 'down': 'Speed'},
  'quirky': {'name': 'Quirky', 'up': null, 'down': null},
  'rash': {'name': 'Rash', 'up': 'Sp. Atk', 'down': 'Sp. Def'},
  'relaxed': {'name': 'Relaxed', 'up': 'Defense', 'down': 'Speed'},
  'sassy': {'name': 'Sassy', 'up': 'Sp. Def', 'down': 'Speed'},
  'serious': {'name': 'Serious', 'up': null, 'down': null},
  'timid': {'name': 'Timid', 'up': 'Speed', 'down': 'Attack'},
};

/// Modular, clean controller screen for viewing Pokémon details.
/// Delegates UI tabs to [PokemonDetailGeneralTab], [PokemonDetailStatsTab],
/// and [PokemonDetailMovesTab].
class PokemonDetailScreen extends ConsumerStatefulWidget {
  final List<Pokemon> forms;
  final int initialFormIndex;

  const PokemonDetailScreen({
    super.key,
    required this.forms,
    this.initialFormIndex = 0,
  });

  @override
  ConsumerState<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends ConsumerState<PokemonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedFormIndex;
  var _isSavingArtwork = false;
  var _isArtworkDownloaded = false;

  Pokemon get _activePokemon => widget.forms[_selectedFormIndex];

  @override
  void initState() {
    super.initState();
    if (widget.forms.isNotEmpty) {
      _selectedFormIndex = widget.initialFormIndex.clamp(0, widget.forms.length - 1);
    } else {
      _selectedFormIndex = 0;
    }
    _tabController = TabController(length: 3, vsync: this);
    if (widget.forms.isNotEmpty) {
      _resetStatsForActiveForm();
      _checkArtworkDownloaded();
    }
  }

  void _checkArtworkDownloaded() async {
    if (widget.forms.isEmpty) return;
    final isDownloaded = await OfflineArtworkStore.instance.isPokemonArtworkDownloaded(_activePokemon);
    if (mounted) {
      setState(() => _isArtworkDownloaded = isDownloaded);
    }
  }

  /// Resets the EV/IV sliders whenever the displayed form changes.
  void _resetStatsForActiveForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(statsCalculatorProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addActivePokemonToTeam() async {
    final added = await ref.read(teamBuilderProvider.notifier).addPokemon(_activePokemon.id);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${_activePokemon.name} is on your team.'
              : 'Your team is full. Open Team Builder to replace a slot.',
        ),
      ),
    );
  }

  Future<void> _downloadActiveArtwork() async {
    if (_isSavingArtwork) return;
    setState(() => _isSavingArtwork = true);
    HapticFeedback.lightImpact();

    var failed = false;
    try {
      final store = OfflineArtworkStore.instance;
      for (final url in {
        _activePokemon.spriteUrl,
        _activePokemon.shinySpriteUrl,
      }) {
        if (url.isEmpty) continue;
        try {
          await store.downloadArtwork(
            sourceUrl: url,
            remoteUrl: DeepSyncController.resolveUrl(url, SpriteQuality.standard),
            quality: SpriteQuality.standard.name,
          );
        } catch (_) {
          failed = true;
        }
      }
      store.notifyLibraryChanged();
      ref.invalidate(offlineArtworkSummaryProvider);
    } finally {
      if (mounted) {
        setState(() => _isSavingArtwork = false);
        _checkArtworkDownloaded();
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed
              ? 'Some artwork could not be downloaded. Check your connection and try again.'
              : '${_activePokemon.name} artwork is available offline.',
        ),
      ),
    );
  }

  Future<void> _confirmDeleteArtwork() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Delete Offline Artwork?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Text(
          'Remove saved offline artwork for ${_activePokemon.name}? You can download it again anytime.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await OfflineArtworkStore.instance.deletePokemonArtwork(_activePokemon);
      ref.invalidate(offlineArtworkSummaryProvider);
      _checkArtworkDownloaded();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Offline artwork for ${_activePokemon.name} deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forms.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pokémon Details')),
        body: const Center(child: Text('No Pokémon data available.')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final dexNumber = _activePokemon.nationalDexNumber > 0 ? _activePokemon.nationalDexNumber : _activePokemon.id;
    final isFavorite = ref.watch(favoritePokemonProvider).contains(dexNumber);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          '#${_activePokemon.nationalDexNumber > 0 ? _activePokemon.nationalDexNumber.toString().padLeft(3, '0') : _activePokemon.id.toString().padLeft(3, '0')} ${_activePokemon.name.toUpperCase()}',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: primaryColor, fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSavingArtwork
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                  )
                : Icon(
                    _isArtworkDownloaded
                        ? Icons.check_circle_rounded
                        : Icons.download_for_offline_outlined,
                    color: _isArtworkDownloaded ? Colors.greenAccent : primaryColor,
                  ),
            tooltip: _isSavingArtwork
                ? 'Downloading artwork...'
                : _isArtworkDownloaded
                    ? 'Artwork downloaded (tap to delete)'
                    : 'Download this artwork for offline use',
            onPressed: _isSavingArtwork
                ? null
                : (_isArtworkDownloaded ? _confirmDeleteArtwork : _downloadActiveArtwork),
          ),
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            color: primaryColor,
            tooltip: 'Add to team',
            onPressed: () => _addActivePokemonToTeam(),
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
            color: isFavorite ? Colors.amber : primaryColor,
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(favoritePokemonProvider.notifier).toggle(dexNumber);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.pokemonRed,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            dividerColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
            tabs: const [
              Tab(text: 'GENERAL', icon: Icon(Icons.info_outline, size: 20)),
              Tab(text: 'STATS', icon: Icon(Icons.analytics_outlined, size: 20)),
              Tab(text: 'MOVES', icon: Icon(Icons.flash_on_outlined, size: 20)),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.forms.length > 1)
            Container(
              height: 48,
              color: isDark ? Colors.black : const Color(0xFFF9FAFB),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: widget.forms.length,
                itemBuilder: (context, index) {
                  final p = widget.forms[index];
                  final isSelected = index == _selectedFormIndex;
                  String label = p.form;
                  if (label == 'normal') label = 'Normal';
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedFormIndex = index;
                        _resetStatsForActiveForm();
                        _checkArtworkDownloaded();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.pokemonRed : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5)),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFD1D5DB)),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PokemonDetailGeneralTab(
                  activePokemon: _activePokemon,
                  forms: widget.forms,
                ),
                PokemonDetailStatsTab(
                  activePokemon: _activePokemon,
                ),
                PokemonDetailMovesTab(
                  activePokemon: _activePokemon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
