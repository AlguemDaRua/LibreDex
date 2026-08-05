/// Main Stat Comparison screen.
///
/// Lets users compare up to six Pokémon side-by-side with full build controls,
/// ruleset switching (Mainline / Champions), and display mode toggling
/// (Raw Build Stats / Effective Battle Stats).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/stat_comparison/models/comparison_entry.dart';
import 'package:libredex/features/stat_comparison/viewmodels/stat_comparison_viewmodel.dart';
import 'package:libredex/features/stat_comparison/views/comparison_table.dart';
import 'package:libredex/features/stat_comparison/views/pokemon_build_editor.dart';

class StatComparisonScreen extends ConsumerWidget {
  const StatComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final state = ref.watch(statComparisonProvider);
    final vm = ref.read(statComparisonProvider.notifier);
    final pokedexAsync = ref.watch(pokedexProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Stat Comparison', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          if (!state.isEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
              onPressed: vm.clearAll,
            ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'stat_comparison'),
      body: pokedexAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.pokemonRed)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (pokemonList) => _Body(
          pokemonList: pokemonList, state: state, vm: vm,
          isDark: isDark, ref: ref,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<Pokemon> pokemonList;
  final StatComparisonState state;
  final StatComparisonNotifier vm;
  final bool isDark;
  final WidgetRef ref;

  const _Body({
    required this.pokemonList, required this.state, required this.vm,
    required this.isDark, required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = state.sortedEntries();

    return CustomScrollView(slivers: [
      // Ruleset + display mode bar
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, AppSpacing.topContentGap, 16, 0),
        child: Column(children: [
          _RulesetBar(state: state, vm: vm, isDark: isDark),
          const SizedBox(height: 10),
          _DisplayModeBar(state: state, vm: vm, isDark: isDark),
        ]),
      )),

      // Action buttons
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          if (state.count < 6)
            _ActionChip(
              icon: Icons.add_rounded, label: 'Add Pokémon',
              onTap: () => _showPokemonPicker(context),
            ),
          _ActionChip(
            icon: Icons.groups_rounded, label: 'From Team',
            onTap: () => _loadFromTeam(context),
          ),
        ]),
      )),

      // Pokémon cards
      if (state.count > 0) SliverToBoxAdapter(
        child: SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sorted.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) => _PokemonCard(
              entry: sorted[i].entry,
              slotIndex: sorted[i].index,
              isDark: isDark,
              onEdit: () => _editEntry(context, sorted[i].index, sorted[i].entry),
              onRemove: () => vm.removeEntry(sorted[i].index),
              onDuplicate: state.count < 6 ? () => vm.duplicateEntry(sorted[i].index) : null,
            ),
          ),
        ),
      ),

      // Comparison table
      if (sorted.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, AppSpacing.bottomScrollPadding),
            child: Card(
              elevation: 0,
              color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
              ),
              child: ComparisonTable(
                rows: sorted,
                sortColumn: state.sortColumn,
                sortDirection: state.sortDirection,
                displayMode: state.displayMode,
                onSort: vm.toggleSort,
              ),
            ),
          ),
        ),

      // Empty state
      if (state.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.compare_arrows_rounded, size: 64, color: AppTheme.pokemonRed.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text('Compare up to 6 Pokémon', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              Text('Add Pokémon to see their stats side by side.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            ],
          )),
        ),
    ]);
  }

  void _showPokemonPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _PokemonPickerDialog(
        pokemonList: pokemonList,
        onPicked: (pokemon) async {
          String? ability;
          try {
            final abs = await ref.read(pokemonRepositoryProvider).getAbilitiesWithFallback(pokemon.id);
            if (abs.isNotEmpty) ability = abs.first['name'] as String?;
          } catch (_) {}
          vm.addPokemon(pokemon, ability: ability);
        },
      ),
    );
  }

  void _loadFromTeam(BuildContext context) {
    final slots = ref.read(teamBuilderProvider);
    final byId = {for (final p in pokemonList) p.id: p};
    final teamPokemon = slots.whereType<int>().map((id) => byId[id]).whereType<Pokemon>().toList();
    if (teamPokemon.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No team members found. Build a team first.')),
      );
      return;
    }
    vm.loadFromTeam(teamPokemon);
  }

  Future<void> _editEntry(BuildContext context, int index, ComparisonEntry entry) async {
    final result = await showBuildEditor(
      context, entry: entry, ruleset: state.ruleset,
      showFieldControls: state.displayMode == ComparisonDisplayMode.effectiveBattle,
    );
    if (result != null) vm.updateEntry(index, result);
  }
}

// ── Ruleset Bar ───────────────────────────────────────────────────────────────

class _RulesetBar extends StatelessWidget {
  final StatComparisonState state;
  final StatComparisonNotifier vm;
  final bool isDark;

  const _RulesetBar({required this.state, required this.vm, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: state.ruleset.isChampions
            ? Colors.deepPurpleAccent.withValues(alpha: 0.45)
            : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB))),
      ),
      child: Row(children: [
        for (final rs in BattleRuleset.values)
          Expanded(child: GestureDetector(
            onTap: () => vm.setRuleset(rs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: state.ruleset == rs
                    ? (rs.isChampions ? Colors.deepPurpleAccent : AppTheme.pokemonRed)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(rs.isChampions ? Icons.emoji_events_rounded : Icons.videogame_asset_rounded,
                  size: 14, color: state.ruleset == rs ? Colors.white : Colors.grey),
                const SizedBox(width: 6),
                Text(rs.label.toUpperCase(), style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.4,
                  color: state.ruleset == rs ? Colors.white : Colors.grey,
                )),
              ]),
            ),
          )),
      ]),
    );
  }
}

// ── Display Mode Bar ──────────────────────────────────────────────────────────

class _DisplayModeBar extends StatelessWidget {
  final StatComparisonState state;
  final StatComparisonNotifier vm;
  final bool isDark;

  const _DisplayModeBar({required this.state, required this.vm, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB)),
      ),
      child: Row(children: [
        for (final mode in ComparisonDisplayMode.values)
          Expanded(child: GestureDetector(
            onTap: () => vm.setDisplayMode(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: state.displayMode == mode ? AppTheme.pokemonRed.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.displayMode == mode ? AppTheme.pokemonRed : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Text(
                mode == ComparisonDisplayMode.rawBuild ? 'RAW BUILD' : 'EFFECTIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w900,
                  color: state.displayMode == mode ? AppTheme.pokemonRed : Colors.grey,
                ),
              ),
            ),
          )),
      ]),
    );
  }
}

// ── Pokémon Card ──────────────────────────────────────────────────────────────

class _PokemonCard extends StatelessWidget {
  final ComparisonEntry entry;
  final int slotIndex;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback? onDuplicate;

  const _PokemonCard({
    required this.entry, required this.slotIndex, required this.isDark,
    required this.onEdit, required this.onRemove, this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final p = entry.pokemon;
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: 175,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101010) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          SizedBox(
            width: 44, height: 44,
            child: p.spriteUrl.isEmpty
                ? const Icon(Icons.catching_pokemon, color: AppTheme.pokemonRed, size: 28)
                : PokemonSprite(
                    imageUrl: p.spriteUrl,
                    fallbackUrl: PokemonSprite.homeArtworkUrl(dex),
                    errorIconSize: 28, errorIconColor: AppTheme.pokemonRed,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('#${dex.toString().padLeft(3, '0')}',
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _IconBtn(Icons.tune_rounded, 'Edit', onEdit),
                if (onDuplicate != null) ...[
                  const SizedBox(width: 4),
                  _IconBtn(Icons.copy_rounded, 'Duplicate', onDuplicate!),
                ],
                const SizedBox(width: 4),
                _IconBtn(Icons.close_rounded, 'Remove', onRemove),
              ]),
            ],
          )),
        ]),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.tooltip, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Icon(icon, size: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
      ),
    ),
  );
}

// ── Action Chip ───────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 16, color: AppTheme.pokemonRed),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
    onPressed: onTap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

// ── Pokémon Picker Dialog ─────────────────────────────────────────────────────

class _PokemonPickerDialog extends StatefulWidget {
  final List<Pokemon> pokemonList;
  final ValueChanged<Pokemon> onPicked;

  const _PokemonPickerDialog({required this.pokemonList, required this.onPicked});

  @override
  State<_PokemonPickerDialog> createState() => _PokemonPickerDialogState();
}

class _PokemonPickerDialogState extends State<_PokemonPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _query.trim().toLowerCase();
    final options = widget.pokemonList.where((p) {
      if (query.isEmpty) return true;
      final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
      return p.name.toLowerCase().contains(query) ||
          p.type1.toLowerCase().contains(query) ||
          (p.type2?.toLowerCase().contains(query) ?? false) ||
          dex.toString().contains(query);
    }).toList();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF0C0C0C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(children: [
              const Text('Add Pokémon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close_rounded, size: 22), onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(hintText: 'Search by name, type, or #', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
          Flexible(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            itemCount: options.length,
            itemBuilder: (ctx, i) {
              final p = options[i];
              final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
              return ListTile(
                leading: SizedBox(width: 40, height: 40, child: p.spriteUrl.isEmpty
                    ? const Icon(Icons.catching_pokemon)
                    : PokemonSprite(imageUrl: p.spriteUrl, fallbackUrl: PokemonSprite.homeArtworkUrl(dex), errorIconSize: 20)),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                subtitle: Text('#${dex.toString().padLeft(3, '0')}', style: const TextStyle(fontSize: 11)),
                onTap: () {
                  widget.onPicked(p);
                  Navigator.pop(ctx);
                },
              );
            },
          )),
        ]),
      ),
    );
  }
}
