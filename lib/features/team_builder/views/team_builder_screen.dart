import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/core/widgets/app_drawer.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

class TeamBuilderScreen extends ConsumerWidget {
  const TeamBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokedexProvider);
    final slots = ref.watch(teamBuilderProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Team Builder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (slots.any((id) => id != null))
            IconButton(
              tooltip: 'Clear team',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => ref.read(teamBuilderProvider.notifier).clear(),
            ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'team'),
      body: pokemonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Team data could not load',
          message: '$error',
        ),
        data: (pokemon) {
          final byId = {for (final p in pokemon) p.id: p};
          final team = slots.map((id) => id == null ? null : byId[id]).toList();
          final selected = team.whereType<Pokemon>().toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _TeamHeader(count: selected.length),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.builder(
                  itemCount: TeamBuilderNotifier.teamSize,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    return _TeamSlotCard(
                      index: index,
                      pokemon: team[index],
                      onAdd: () => _showPokemonPicker(context, ref, pokemon, index),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                sliver: SliverToBoxAdapter(
                  child: selected.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.groups_rounded,
                          title: 'Start your team',
                          message: 'Add up to six Pokémon, then LibreDex will summarize defensive gaps and type spread.',
                        )
                      : _TeamAnalysis(team: selected),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPokemonPicker(
    BuildContext context,
    WidgetRef ref,
    List<Pokemon> pokemon,
    int slotIndex,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PokemonPickerSheet(pokemon: pokemon, slotIndex: slotIndex),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final int count;

  const _TeamHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B102F), const Color(0xFF090909)]
              : [AppTheme.pokemonRed.withValues(alpha: 0.14), Colors.white],
        ),
        border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppTheme.pokemonRed, size: 34),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count / 6 selected',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan a balanced squad before jumping into the calculator.',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSlotCard extends ConsumerWidget {
  final int index;
  final Pokemon? pokemon;
  final VoidCallback onAdd;

  const _TeamSlotCard({
    required this.index,
    required this.pokemon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = pokemon;
    if (p == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onAdd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101010) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline_rounded, color: AppTheme.pokemonRed, size: 34),
                const SizedBox(height: 8),
                Text('Slot ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                const Text('Add Pokémon', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    final typeColor = pokemonTypeColor(p.type1);
    final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PokemonDetailScreen(forms: [p])),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark
                ? [Color.alphaBlend(typeColor.withValues(alpha: 0.22), const Color(0xFF090909)), const Color(0xFF101010)]
                : [typeColor.withValues(alpha: 0.18), Colors.white],
          ),
          border: Border.all(color: typeColor.withValues(alpha: 0.28)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Remove from team',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () => ref.read(teamBuilderProvider.notifier).setSlot(index, null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${dex.toString().padLeft(3, '0')}', style: TextStyle(color: typeColor, fontWeight: FontWeight.w900)),
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  Expanded(
                    child: Center(
                      child: p.spriteUrl.isEmpty
                          ? Icon(Icons.catching_pokemon, color: typeColor.withValues(alpha: 0.45), size: 54)
                          : CachedNetworkImage(
                              imageUrl: p.spriteUrl,
                              fit: BoxFit.contain,
                              errorWidget: (_, _, _) => Icon(Icons.catching_pokemon, color: typeColor.withValues(alpha: 0.45)),
                            ),
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      _TypePill(type: p.type1),
                      if (p.type2 != null) _TypePill(type: p.type2!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamAnalysis extends StatelessWidget {
  final List<Pokemon> team;

  const _TeamAnalysis({required this.team});

  @override
  Widget build(BuildContext context) {
    final weaknessCounts = <String, int>{for (final type in pokemonTypes) type: 0};
    final resistCounts = <String, int>{for (final type in pokemonTypes) type: 0};
    final immuneCounts = <String, int>{for (final type in pokemonTypes) type: 0};
    final ownedTypes = <String>{};

    for (final pokemon in team) {
      ownedTypes.add(pokemon.type1);
      if (pokemon.type2 != null) ownedTypes.add(pokemon.type2!);
      final effectiveness = TypeEfficiencyCalculator.getCombinedEffectiveness(pokemon.type1, pokemon.type2);
      for (final type in pokemonTypes) {
        final value = effectiveness[type] ?? 1.0;
        if (value == 0) immuneCounts[type] = immuneCounts[type]! + 1;
        if (value > 1) weaknessCounts[type] = weaknessCounts[type]! + 1;
        if (value > 0 && value < 1) resistCounts[type] = resistCounts[type]! + 1;
      }
    }

    final pressure = weaknessCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final gaps = pressure.where((e) => e.value >= 2 && resistCounts[e.key] == 0 && immuneCounts[e.key] == 0).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Team readout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: gaps.isEmpty ? 'Defensive shape looks solid' : 'Watch these matchups',
          icon: gaps.isEmpty ? Icons.verified_rounded : Icons.warning_amber_rounded,
          child: gaps.isEmpty
              ? const Text('No attacking type currently hits multiple team members with zero resist or immunity support.')
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gaps.map((e) => _CountPill(type: e.key, count: e.value, label: 'weak')).toList(),
                ),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Type spread',
          icon: Icons.bubble_chart_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemonTypes.map((type) {
              final owned = ownedTypes.contains(type);
              return Opacity(
                opacity: owned ? 1 : 0.42,
                child: _TypePill(type: type),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PokemonPickerSheet extends ConsumerStatefulWidget {
  final List<Pokemon> pokemon;
  final int slotIndex;

  const _PokemonPickerSheet({required this.pokemon, required this.slotIndex});

  @override
  ConsumerState<_PokemonPickerSheet> createState() => _PokemonPickerSheetState();
}

class _PokemonPickerSheetState extends ConsumerState<_PokemonPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritePokemonProvider);
    final teamSlots = ref.watch(teamBuilderProvider).whereType<int>().toSet();
    final query = _query.trim().toLowerCase();
    final options = widget.pokemon.where((pokemon) {
      final dex = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
      if (teamSlots.contains(pokemon.id)) return false;
      if (query.isEmpty) return true;
      return pokemon.name.toLowerCase().contains(query) ||
          pokemon.type1.toLowerCase().contains(query) ||
          (pokemon.type2?.toLowerCase().contains(query) ?? false) ||
          dex.toString().contains(query);
    }).toList()
      ..sort((a, b) {
        final aDex = a.nationalDexNumber > 0 ? a.nationalDexNumber : a.id;
        final bDex = b.nationalDexNumber > 0 ? b.nationalDexNumber : b.id;
        final favCompare = (favorites.contains(bDex) ? 1 : 0).compareTo(favorites.contains(aDex) ? 1 : 0);
        return favCompare != 0 ? favCompare : aDex.compareTo(bDex);
      });

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C0C0C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(99))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  autofocus: true,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search Pokémon, type, or #',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final pokemon = options[index];
                    final dex = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
                    final color = pokemonTypeColor(pokemon.type1);
                    return ListTile(
                      leading: SizedBox(
                        width: 48,
                        height: 48,
                        child: pokemon.spriteUrl.isEmpty
                            ? Icon(Icons.catching_pokemon, color: color)
                            : CachedNetworkImage(imageUrl: pokemon.spriteUrl, fit: BoxFit.contain),
                      ),
                      title: Text(pokemon.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('#${dex.toString().padLeft(3, '0')} · ${titleCasePokemonText(pokemon.type1)}${pokemon.type2 == null ? '' : ' / ${titleCasePokemonText(pokemon.type2!)}'}'),
                      trailing: favorites.contains(dex) ? const Icon(Icons.star_rounded, color: Colors.amber) : null,
                      onTap: () {
                        ref.read(teamBuilderProvider.notifier).setSlot(widget.slotIndex, pokemon.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AnalysisCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101010) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppTheme.pokemonRed), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w900))]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String type;
  final int count;
  final String label;

  const _CountPill({required this.type, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = pokemonTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Text('${titleCasePokemonText(type)} · $count $label', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;

  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = pokemonTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(9)),
      child: Text(titleCasePokemonText(type), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }
}
