import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/core/widgets/analysis_card.dart';
import 'package:libredex/core/widgets/type_pill.dart';
import 'package:libredex/core/widgets/stat_tile.dart';
import 'package:libredex/core/widgets/section_header.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

import 'package:libredex/features/team_builder/utils/showdown_parser.dart';
import 'package:libredex/features/team_builder/widgets/team_defense_matrix.dart';
import 'package:libredex/features/team_comparison/views/team_comparison_screen.dart';

class TeamBuilderScreen extends ConsumerWidget {
  const TeamBuilderScreen({super.key});

  void _showExportDialog(BuildContext context, List<Pokemon?> team) {
    final text = ShowdownParser.exportTeam(team);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.import_export_rounded, color: AppTheme.pokemonRed),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Export Showdown Team',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SelectableText(
          text.isEmpty ? 'Add Pokémon to export your team.' : text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(
    BuildContext context,
    WidgetRef ref,
    List<Pokemon> catalog,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.paste_rounded, color: AppTheme.pokemonRed),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Import Showdown Paste',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText:
                'Paste Showdown team text here...\ne.g.\nPikachu @ Light Ball\nAbility: Static\n- Volt Tackle',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final imported = await ShowdownParser.parseShowdownText(
                controller.text,
                db,
              );
              final notifier = ref.read(teamBuilderProvider.notifier);
              for (int i = 0; i < imported.length; i++) {
                await notifier.setSlot(i, imported[i]?.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.pokemonRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokedexProvider);
    final slots = ref.watch(teamBuilderProvider);
    final format = ref.watch(teamFormatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Team Builder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          pokemonAsync.maybeWhen(
            data: (pokemon) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Import Showdown Paste',
                  icon: const Icon(Icons.file_upload_outlined),
                  onPressed: () => _showImportDialog(context, ref, pokemon),
                ),
                IconButton(
                  tooltip: 'Export Showdown Text',
                  icon: const Icon(Icons.file_download_outlined),
                  onPressed: () {
                    final byId = {for (final p in pokemon) p.id: p};
                    final team = slots
                        .map((id) => id == null ? null : byId[id])
                        .toList();
                    _showExportDialog(context, team);
                  },
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          if (slots.any((id) => id != null))
            IconButton(
              tooltip: 'Clear team',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => ref.read(teamBuilderProvider.notifier).clear(),
            ),
        ],
      ),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.topContentGap,
                  AppSpacing.pagePadding,
                  8,
                ),
                sliver: SliverToBoxAdapter(
                  child: _TeamHeader(
                    count: selected.length,
                    format: format,
                    onFormatChanged: (next) =>
                        ref.read(teamFormatProvider.notifier).setFormat(next),
                  ),
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
                      format: format,
                      onAdd: () =>
                          _showPokemonPicker(context, ref, pokemon, index),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  20,
                  AppSpacing.pagePadding,
                  AppSpacing.bottomScrollPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: selected.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.groups_rounded,
                          title: 'Start your team',
                          message:
                              'Add up to six Pokémon, then LibreDex will summarize defensive gaps and type spread.',
                        )
                      : _TeamAnalysis(team: selected, format: format),
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
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          _PokemonPickerSheet(pokemon: pokemon, slotIndex: slotIndex),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final int count;
  final TeamFormat format;
  final ValueChanged<TeamFormat> onFormatChanged;

  const _TeamHeader({
    required this.count,
    required this.format,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isChampions = format == TeamFormat.champions;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isChampions ? Icons.emoji_events_rounded : Icons.groups_rounded,
                color: isChampions
                    ? Colors.deepPurpleAccent
                    : AppTheme.pokemonRed,
                size: 34,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count / 6',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isChampions
                              ? Icons.emoji_events_rounded
                              : Icons.science_outlined,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isChampions
                              ? 'Champions · Lv.50 · 66 SP'
                              : 'Balanced squad',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: isChampions
                              ? 'Champions: Lv.50, perfect IVs, 66 Stat Points (max 32 per stat).'
                              : 'Assemble 6 Pokémon — defensive & offensive coverage below is Pokédex math, not a battle sim.',
                          triggerMode: TooltipTriggerMode.tap,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            height: 1.35,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // "Mainline Team / Champions Team" — which game this squad is for.
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                for (final option in TeamFormat.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onFormatChanged(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: format == option
                              ? (option == TeamFormat.champions
                                    ? Colors.deepPurpleAccent
                                    : AppTheme.pokemonRed)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: format == option
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
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
  final TeamFormat format;
  final VoidCallback onAdd;

  const _TeamSlotCard({
    required this.index,
    required this.pokemon,
    required this.format,
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
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppTheme.pokemonRed,
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  'Slot ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Add Pokémon',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
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
                ? [
                    Color.alphaBlend(
                      typeColor.withValues(alpha: 0.22),
                      const Color(0xFF090909),
                    ),
                    const Color(0xFF121212),
                  ]
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
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    ref.read(teamBuilderProvider.notifier).setSlot(index, null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${dex.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: p.spriteUrl.isEmpty
                          ? Icon(
                              Icons.catching_pokemon,
                              color: typeColor.withValues(alpha: 0.45),
                              size: 54,
                            )
                          : PokemonSprite(
                              imageUrl: p.spriteUrl,
                              fallbackUrl: PokemonSprite.homeArtworkUrl(dex),
                              errorIconSize: 54,
                              errorIconColor: typeColor.withValues(alpha: 0.45),
                            ),
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      TypePill(type: p.type1),
                      if (p.type2 != null) TypePill(type: p.type2!),
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
  final TeamFormat format;

  const _TeamAnalysis({required this.team, required this.format});

  @override
  Widget build(BuildContext context) {
    final weaknessCounts = <String, int>{
      for (final type in pokemonTypes) type: 0,
    };
    final resistCounts = <String, int>{
      for (final type in pokemonTypes) type: 0,
    };
    final immuneCounts = <String, int>{
      for (final type in pokemonTypes) type: 0,
    };
    final ownedTypes = <String>{};
    // Offensive: which defending types can this team hit super-effectively?
    final offensiveHits = <String, int>{
      for (final type in pokemonTypes) type: 0,
    };

    for (final pokemon in team) {
      ownedTypes.add(pokemon.type1);
      if (pokemon.type2 != null) ownedTypes.add(pokemon.type2!);
      final effectiveness = TypeEfficiencyCalculator.getCombinedEffectiveness(
        pokemon.type1,
        pokemon.type2,
      );
      for (final type in pokemonTypes) {
        final value = effectiveness[type] ?? 1.0;
        if (value == 0) immuneCounts[type] = immuneCounts[type]! + 1;
        if (value > 1) weaknessCounts[type] = weaknessCounts[type]! + 1;
        if (value > 0 && value < 1) {
          resistCounts[type] = resistCounts[type]! + 1;
        }
      }
      // Offensive: this Pokémon's STAB types as attackers
      for (final atkType in [
        pokemon.type1,
        if (pokemon.type2 != null) pokemon.type2!,
      ]) {
        final atkMap = CombatUtils.effectivenessMap[atkType.toLowerCase()];
        if (atkMap == null) continue;
        for (final defType in (atkMap['double'] ?? const [])) {
          offensiveHits[defType.toLowerCase()] =
              (offensiveHits[defType.toLowerCase()] ?? 0) + 1;
        }
      }
    }

    final pressure = weaknessCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final gaps = pressure
        .where(
          (e) =>
              e.value >= 2 &&
              resistCounts[e.key] == 0 &&
              immuneCounts[e.key] == 0,
        )
        .take(4)
        .toList();

    final offensiveSorted =
        offensiveHits.entries.where((e) => e.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final uncoveredOffense = pokemonTypes
        .where((t) => (offensiveHits[t] ?? 0) == 0)
        .toList();

    // Snapshot stats — purely informational, no simulation
    final totalBst = team.fold<int>(
      0,
      (s, p) =>
          s +
          p.baseHp +
          p.baseAtk +
          p.baseDef +
          p.baseSpAtk +
          p.baseSpDef +
          p.baseSpd,
    );
    final avgBst = team.isEmpty ? 0 : (totalBst / team.length).round();
    final avgSpeed = team.isEmpty
        ? 0
        : (team.fold<int>(0, (s, p) => s + p.baseSpd) / team.length).round();
    final fastest = team.isEmpty
        ? null
        : team.reduce((a, b) => a.baseSpd > b.baseSpd ? a : b);
    final slowest = team.isEmpty
        ? null
        : team.reduce((a, b) => a.baseSpd < b.baseSpd ? a : b);

    final isChampions = format == TeamFormat.champions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.shield_rounded,
          title: 'Defense',
          hint: 'How your team soaks hits — Pokédex math, no simulation.',
        ),
        const SizedBox(height: 10),
        TeamDefenseMatrix(team: team),
        const SizedBox(height: 16),

        // ── READOUT ──
        const SectionHeader(
          icon: Icons.insights_rounded,
          title: 'Readout',
          hint: 'Info only — no turns simulated.',
        ),
        const SizedBox(height: 10),
        if (isChampions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 14,
                  color: Colors.deepPurpleAccent,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Champions · Lv.50 · 66 SP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
                Tooltip(
                  message:
                      'Lv.50, perfect IVs, 66 Stat Points (max 32/stat). Tune spreads in Stat Comparison.',
                  triggerMode: TooltipTriggerMode.tap,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.35,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
            ),
          ),
        if (isChampions) const SizedBox(height: 12),
        AnalysisCard(
          title: gaps.isEmpty
              ? 'Defensive shape looks solid'
              : 'Watch these matchups',
          icon: gaps.isEmpty
              ? Icons.verified_rounded
              : Icons.warning_amber_rounded,
          child: gaps.isEmpty
              ? const Text(
                  'No attacking type currently hits multiple team members with zero resist or immunity support.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gaps
                      .map(
                        (e) => CountPill(
                          type: e.key,
                          count: e.value,
                          label: 'weak',
                        ),
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        // Offensive coverage — what can your STABs hit?
        AnalysisCard(
          title: offensiveSorted.isEmpty
              ? 'Offensive coverage — add members'
              : 'Offensive coverage (STAB super-effective)',
          icon: Icons.flash_on_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offensiveSorted.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: offensiveSorted
                      .take(12)
                      .map(
                        (e) => CountPill(
                          type: e.key,
                          count: e.value,
                          label: 'hit',
                        ),
                      )
                      .toList(),
                ),
              if (uncoveredOffense.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'No STAB super-effective vs: ${uncoveredOffense.map((t) => t.toUpperCase()).take(6).join(', ')}${uncoveredOffense.length > 6 ? '…' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ] else if (offensiveSorted.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Covers every type super-effectively with STAB.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AnalysisCard(
          title: 'Type spread',
          icon: Icons.bubble_chart_rounded,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pokemonTypes.map((type) {
              final owned = ownedTypes.contains(type);
              return Opacity(
                opacity: owned ? 1 : 0.42,
                child: TypePill(type: type),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Snapshot — averages, no simulation
        AnalysisCard(
          title: 'Snapshot (info only)',
          icon: Icons.analytics_outlined,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Avg BST',
                      value: '$avgBst',
                      sub: 'team ${team.length}/6',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Avg Speed',
                      value: '$avgSpeed',
                      sub: 'fastest ${fastest?.name ?? '-'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Slowest',
                      value: slowest?.name ?? '-',
                      sub: 'base ${slowest?.baseSpd ?? '-'} Spe',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Weak ≥3',
                      value: '${pressure.where((e) => e.value >= 3).length}',
                      sub: 'types',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          icon: Icons.compare_arrows_rounded,
          title: 'Team Comparison',
          hint: 'Side-by-side type & stat overview — Pokédex math only.',
        ),
        const SizedBox(height: 10),
        _TeamCompareButton(team: team, format: format),
      ],
    );
  }
}

class _TeamCompareButton extends ConsumerWidget {
  final List<Pokemon> team;
  final TeamFormat format;
  const _TeamCompareButton({required this.team, required this.format});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.compare_rounded, size: 18),
          label: const Text(
            'Compare Teams',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.pokemonRed,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    TeamComparisonScreen(myTeam: team, format: format),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PokemonPickerSheet extends ConsumerStatefulWidget {
  final List<Pokemon> pokemon;
  final int slotIndex;

  const _PokemonPickerSheet({required this.pokemon, required this.slotIndex});

  @override
  ConsumerState<_PokemonPickerSheet> createState() =>
      _PokemonPickerSheetState();
}

class _PokemonPickerSheetState extends ConsumerState<_PokemonPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritePokemonProvider);
    final teamSlots = ref.watch(teamBuilderProvider).whereType<int>().toSet();
    final query = _query.trim().toLowerCase();
    final options =
        widget.pokemon.where((pokemon) {
          final dex = pokemon.nationalDexNumber > 0
              ? pokemon.nationalDexNumber
              : pokemon.id;
          if (teamSlots.contains(pokemon.id)) return false;
          if (query.isEmpty) return true;
          return pokemon.name.toLowerCase().contains(query) ||
              pokemon.type1.toLowerCase().contains(query) ||
              (pokemon.type2?.toLowerCase().contains(query) ?? false) ||
              dex.toString().contains(query);
        }).toList()..sort((a, b) {
          final aDex = a.nationalDexNumber > 0 ? a.nationalDexNumber : a.id;
          final bDex = b.nationalDexNumber > 0 ? b.nationalDexNumber : b.id;
          final favCompare = (favorites.contains(bDex) ? 1 : 0).compareTo(
            favorites.contains(aDex) ? 1 : 0,
          );
          return favCompare != 0 ? favCompare : aDex.compareTo(bDex);
        });

    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add to Team',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
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
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final pokemon = options[index];
                  final dex = pokemon.nationalDexNumber > 0
                      ? pokemon.nationalDexNumber
                      : pokemon.id;
                  final color = pokemonTypeColor(pokemon.type1);
                  return ListTile(
                    leading: SizedBox(
                      width: 48,
                      height: 48,
                      child: pokemon.spriteUrl.isEmpty
                          ? Icon(Icons.catching_pokemon, color: color)
                          : PokemonSprite(
                              imageUrl: pokemon.spriteUrl,
                              fallbackUrl: PokemonSprite.homeArtworkUrl(dex),
                              errorIconColor: color,
                              errorIconSize: 24,
                            ),
                    ),
                    title: Text(
                      pokemon.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '#${dex.toString().padLeft(3, '0')} · ${titleCasePokemonText(pokemon.type1)}${pokemon.type2 == null ? '' : ' / ${titleCasePokemonText(pokemon.type2!)}'}',
                    ),
                    trailing: favorites.contains(dex)
                        ? const Icon(Icons.star_rounded, color: Colors.amber)
                        : null,
                    onTap: () {
                      ref
                          .read(teamBuilderProvider.notifier)
                          .setSlot(widget.slotIndex, pokemon.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
