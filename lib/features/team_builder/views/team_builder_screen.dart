import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/features/calculator/models/battle_ruleset.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/stat_comparison/viewmodels/stat_comparison_viewmodel.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/favorites_provider.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/features/pokedex/views/pokemon_detail_screen.dart';

import 'package:libredex/features/team_builder/utils/showdown_parser.dart';
import 'package:libredex/features/team_builder/widgets/team_defense_matrix.dart';

/// Section index of the Damage Calculator inside HomeScreen's IndexedStack.
const int _damageCalculatorSectionIndex = 8;

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

  void _showImportDialog(BuildContext context, WidgetRef ref, List<Pokemon> catalog) async {
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
            hintText: 'Paste Showdown team text here...\ne.g.\nPikachu @ Light Ball\nAbility: Static\n- Volt Tackle',
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
              final imported = await ShowdownParser.parseShowdownText(controller.text, db);
              final notifier = ref.read(teamBuilderProvider.notifier);
              for (int i = 0; i < imported.length; i++) {
                await notifier.setSlot(i, imported[i]?.id);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pokemonRed, foregroundColor: Colors.white),
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
                    final team = slots.map((id) => id == null ? null : byId[id]).toList();
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
                padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.topContentGap, AppSpacing.pagePadding, 8),
                sliver: SliverToBoxAdapter(
                  child: _TeamHeader(
                    count: selected.length,
                    format: format,
                    onFormatChanged: (next) => ref.read(teamFormatProvider.notifier).setFormat(next),
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
                      onAdd: () => _showPokemonPicker(context, ref, pokemon, index),
                    );
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 20, AppSpacing.pagePadding, AppSpacing.bottomScrollPadding),
                sliver: SliverToBoxAdapter(
                  child: selected.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.groups_rounded,
                          title: 'Start your team',
                          message: 'Add up to six Pokémon, then LibreDex will summarize defensive gaps and type spread.',
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
      builder: (context) => _PokemonPickerSheet(pokemon: pokemon, slotIndex: slotIndex),
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
                color: isChampions ? Colors.deepPurpleAccent : AppTheme.pokemonRed,
                size: 34,
              ),
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
                      isChampions
                          ? 'Plan a Champions squad — Lv. 50 battles, perfect IVs and 66 Stat Points each.'
                          : 'Plan a balanced squad before jumping into the calculator.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
              color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.7),
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
                              ? (option == TeamFormat.champions ? Colors.deepPurpleAccent : AppTheme.pokemonRed)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: format == option ? Colors.white : Colors.grey,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: format == TeamFormat.champions
                        ? 'Open in Damage Calculator (Champions)'
                        : 'Open in Damage Calculator',
                    icon: const Icon(Icons.calculate_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      // Park a one-shot intent; the calculator applies it on
                      // its first frame, so a Champions team always lands in
                      // the Champions ruleset.
                      ref.read(calculatorLaunchIntentProvider.notifier).request(
                            CalculatorLaunchIntent(
                              attackerPokemonId: p.id,
                              ruleset: format == TeamFormat.champions ? BattleRuleset.champions : null,
                            ),
                          );
                      ref
                          .read(currentMenuIndexProvider.notifier)
                          .setIndex(_damageCalculatorSectionIndex);
                    },
                  ),
                  IconButton(
                    tooltip: 'Remove from team',
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => ref.read(teamBuilderProvider.notifier).setSlot(index, null),
                  ),
                ],
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
  final TeamFormat format;

  const _TeamAnalysis({required this.team, required this.format});

  @override
  Widget build(BuildContext context) {
    final weaknessCounts = <String, int>{for (final type in pokemonTypes) type: 0};
    final resistCounts = <String, int>{for (final type in pokemonTypes) type: 0};
    final immuneCounts = <String, int>{for (final type in pokemonTypes) type: 0};
    final ownedTypes = <String>{};
    // Offensive: which defending types can this team hit super-effectively?
    final offensiveHits = <String, int>{for (final type in pokemonTypes) type: 0};

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
      // Offensive: this Pokémon's STAB types as attackers
      for (final atkType in [pokemon.type1, if (pokemon.type2 != null) pokemon.type2!]) {
        final atkMap = CombatUtils.effectivenessMap[atkType.toLowerCase()];
        if (atkMap == null) continue;
        for (final defType in (atkMap['double'] ?? const [])) {
          offensiveHits[defType.toLowerCase()] = (offensiveHits[defType.toLowerCase()] ?? 0) + 1;
        }
      }
    }

    final pressure = weaknessCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final gaps = pressure.where((e) => e.value >= 2 && resistCounts[e.key] == 0 && immuneCounts[e.key] == 0).take(4).toList();

    final offensiveSorted = offensiveHits.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final uncoveredOffense = pokemonTypes.where((t) => (offensiveHits[t] ?? 0) == 0).toList();

    // Snapshot stats — purely informational, no simulation
    final totalBst = team.fold<int>(0, (s, p) => s + p.baseHp + p.baseAtk + p.baseDef + p.baseSpAtk + p.baseSpDef + p.baseSpd);
    final avgBst = team.isEmpty ? 0 : (totalBst / team.length).round();
    final avgSpeed = team.isEmpty ? 0 : (team.fold<int>(0, (s, p) => s + p.baseSpd) / team.length).round();
    final fastest = team.isEmpty ? null : team.reduce((a, b) => a.baseSpd > b.baseSpd ? a : b);
    final slowest = team.isEmpty ? null : team.reduce((a, b) => a.baseSpd < b.baseSpd ? a : b);

    final isChampions = format == TeamFormat.champions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SECTION: Defensive Overview ──
        _SectionHeader(icon: Icons.shield_rounded, title: 'Defensive Overview', subtitle: 'How your team soaks hits — Pokédex math, not a battle'),
        const SizedBox(height: 10),
        TeamDefenseMatrix(team: team),
        const SizedBox(height: 16),

        // ── SECTION: Readout ──
        _SectionHeader(icon: Icons.insights_rounded, title: 'Team readout', subtitle: 'Informational — no turns, no simulation'),
        const SizedBox(height: 10),
        if (isChampions) ...[
          const _AnalysisCard(
            title: 'Pokémon Champions setup',
            icon: Icons.emoji_events_rounded,
            child: Text(
              'Readout assumes Champions battles: Lv. 50 only, IVs always perfect, and 66 Stat Points (max 32 per stat) instead of EVs. Tap the calculator icon on any member to tune its spread in the Champions ruleset.',
              style: TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(height: 12),
        ],
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
        // Offensive coverage — what can your STABs hit?
        _AnalysisCard(
          title: offensiveSorted.isEmpty ? 'Offensive coverage — add members' : 'Offensive coverage (STAB super-effective)',
          icon: Icons.flash_on_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (offensiveSorted.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: offensiveSorted.take(12).map((e) => _CountPill(type: e.key, count: e.value, label: 'hit')).toList(),
                ),
              if (uncoveredOffense.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'No STAB super-effective vs: ${uncoveredOffense.map((t) => t.toUpperCase()).take(6).join(', ')}${uncoveredOffense.length > 6 ? '…' : ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
                ),
              ] else if (offensiveSorted.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Covers every type super-effectively with STAB.', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700)),
                ),
            ],
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
        const SizedBox(height: 12),
        // Snapshot — averages, no simulation
        _AnalysisCard(
          title: 'Snapshot (info only)',
          icon: Icons.analytics_outlined,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _StatTile(label: 'Avg BST', value: '$avgBst', sub: 'team ${team.length}/6')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(label: 'Avg Speed', value: '$avgSpeed', sub: 'fastest ${fastest?.name ?? '-'}')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _StatTile(label: 'Slowest', value: slowest?.name ?? '-', sub: 'base ${slowest?.baseSpd ?? '-'} Spe')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatTile(label: 'Weak ≥3', value: '${pressure.where((e) => e.value >= 3).length}', sub: 'types')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ── SECTION: Team vs Team (info comparison, not a game) ──
        _SectionHeader(icon: Icons.compare_arrows_rounded, title: 'Team vs Team', subtitle: 'Compare type matchups — not a battle simulation'),
        const SizedBox(height: 10),
        _TeamVsTeamActions(team: team),
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

    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: isDark ? const Color(0xFF0C0C0C) : Colors.white,
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
                  const Text('Add to Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    final dex = pokemon.nationalDexNumber > 0 ? pokemon.nationalDexNumber : pokemon.id;
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
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.pokemonRed.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppTheme.pokemonRed),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.3)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Divider(height: 1, color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _StatTile({required this.label, required this.value, required this.sub});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(sub, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _TeamVsTeamActions extends ConsumerWidget {
  final List<Pokemon> team;
  const _TeamVsTeamActions({required this.team});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101010) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informational comparisons — no battle is simulated. LibreDex is a Pokédex companion.', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                    label: const Text('Stat Comparison', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.pokemonRed, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      ref.read(statComparisonProvider.notifier).loadFromTeam(team);
                      ref.read(currentMenuIndexProvider.notifier).setIndex(2);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.groups_2_outlined, size: 16),
                    label: const Text('Team vs Team', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () => _showTeamVsTeamSheet(context, ref, team),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  void _showTeamVsTeamSheet(BuildContext context, WidgetRef ref, List<Pokemon> myTeam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF101010) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              const Text('Team vs Team — type matchup info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Picks a foe team and shows which STABs hit which side super-effectively (type chart only). No turns, no damage rolls — just Pokédex math.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
              const SizedBox(height: 12),
              _FoeTeamPicker(myTeam: myTeam),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoeTeamPicker extends ConsumerStatefulWidget {
  final List<Pokemon> myTeam;
  const _FoeTeamPicker({required this.myTeam});
  @override
  ConsumerState<_FoeTeamPicker> createState() => _FoeTeamPickerState();
}

class _FoeTeamPickerState extends ConsumerState<_FoeTeamPicker> {
  final List<Pokemon?> foe = List<Pokemon?>.filled(6, null, growable: false);
  @override
  Widget build(BuildContext context) {
    final pokedex = ref.watch(pokedexProvider);
    return pokedex.when(
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Could not load Pokédex: $e'),
      data: (all) {
        String foeStabHitsMe() {
          if (foe.whereType<Pokemon>().isEmpty) return '—';
          int seCount = 0;
          for (final t in pokemonTypes) {
            bool hitsMe = false;
            for (final me in widget.myTeam) {
              final eff = TypeEfficiencyCalculator.getCombinedEffectiveness(me.type1, me.type2)[t] ?? 1.0;
              if (eff > 1) { hitsMe = true; break; }
            }
            final foeHas = foe.whereType<Pokemon>().any((f) => f.type1.toLowerCase() == t || f.type2?.toLowerCase() == t);
            if (hitsMe && foeHas) seCount++;
          }
          return '$seCount types';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Foe team (tap to add)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.6, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemBuilder: (ctx, i) {
                final p = foe[i];
                if (p == null) {
                  return InkWell(
                    onTap: () async {
                      final picked = await _pickPokemon(all);
                      if (picked != null) setState(() => foe[i] = picked);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(14)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_rounded, color: Colors.grey), Text('Slot ${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.grey))]),
                    ),
                  );
                }
                final c = pokemonTypeColor(p.type1);
                return InkWell(
                  onTap: () => setState(() => foe[i] = null),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withValues(alpha: 0.28))),
                    child: Column(children: [Expanded(child: PokemonSprite(imageUrl: p.spriteUrl, fallbackUrl: PokemonSprite.homeArtworkUrl(p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id), errorIconSize: 24)), Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))]),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange.withValues(alpha: 0.25))),
              child: Row(children: [const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange), const SizedBox(width: 8), Expanded(child: Text('Info only: foe STABs that hit you SE: ${foeStabHitsMe()} • No damage calc here — use Calculator for 1vs1.', style: const TextStyle(fontSize: 11, height: 1.4)))]),
            ),
          ],
        );
      },
    );
  }

  Future<Pokemon?> _pickPokemon(List<Pokemon> all) async {
    Pokemon? result;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        String q = '';
        return StatefulBuilder(builder: (ctx, setS) {
          final filtered = all.where((p) => p.name.toLowerCase().contains(q.toLowerCase())).take(40).toList();
          return AlertDialog(
            title: const Text('Pick foe Pokémon'),
            content: SizedBox(
              width: double.maxFinite,
              height: 360,
              child: Column(children: [
                TextField(decoration: const InputDecoration(hintText: 'Search'), onChanged: (v) => setS(() => q = v)),
                Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
                  final p = filtered[i];
                  return ListTile(title: Text(p.name), subtitle: Text(p.type1 + (p.type2 == null ? '' : '/${p.type2}')), onTap: () { result = p; Navigator.pop(ctx); });
                })),
              ]),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
          );
        });
      },
    );
    return result;
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
