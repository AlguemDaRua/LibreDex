import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/pokedex/models/type_efficiency_calculator.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';
import 'package:libredex/features/pokedex/viewmodels/team_builder_provider.dart';

/// Team vs Team — purely informational type-chart comparison.
/// No damage rolls, no turns, no simulation. Strictly Pokédex math:
/// which STABs hit which side super-effectively, defensive gaps, and
/// snapshot averages. Modern, strictly organized.
class TeamComparisonScreen extends ConsumerStatefulWidget {
  final List<Pokemon> myTeam;
  final TeamFormat format;
  const TeamComparisonScreen({super.key, required this.myTeam, required this.format});

  @override
  ConsumerState<TeamComparisonScreen> createState() => _TeamComparisonScreenState();
}

class _TeamComparisonScreenState extends ConsumerState<TeamComparisonScreen> {
  final List<Pokemon?> foe = List<Pokemon?>.filled(6, null, growable: false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foeTeam = foe.whereType<Pokemon>().toList();
    final myTeam = widget.myTeam;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Team Comparison', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, AppSpacing.topContentGap, AppSpacing.pagePadding, 12),
            sliver: SliverToBoxAdapter(
              child: _InfoBanner(),
            ),
          ),
          // ── MY TEAM ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            sliver: SliverToBoxAdapter(child: _SectionHeader(icon: Icons.shield_rounded, title: 'Your Team', subtitle: '${myTeam.length}/6 — ${widget.format.label}')),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 8, AppSpacing.pagePadding, 0),
            sliver: SliverToBoxAdapter(child: _TeamRow(team: myTeam, isDark: isDark)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 12, AppSpacing.pagePadding, 0),
            sliver: SliverToBoxAdapter(child: _TeamStats(team: myTeam, label: 'Your team')),
          ),
          // ── FOE TEAM ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 20, AppSpacing.pagePadding, 0),
            sliver: SliverToBoxAdapter(child: _SectionHeader(icon: Icons.groups_2_outlined, title: 'Foe Team', subtitle: foeTeam.isEmpty ? 'Tap to add foe Pokémon — info only' : '${foeTeam.length}/6 foe')),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 8, AppSpacing.pagePadding, 0),
            sliver: SliverToBoxAdapter(child: _FoeGrid(foe: foe, onChanged: (i, p) => setState(() => foe[i] = p))),
          ),
          if (foeTeam.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 12, AppSpacing.pagePadding, 0),
              sliver: SliverToBoxAdapter(child: _TeamStats(team: foeTeam, label: 'Foe team')),
            ),
            // ── HEAD-TO-HEAD ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 20, AppSpacing.pagePadding, 0),
              sliver: SliverToBoxAdapter(child: _SectionHeader(icon: Icons.compare_arrows_rounded, title: 'Head-to-Head (info)', subtitle: 'Which STABs hit which side — type chart only')),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 8, AppSpacing.pagePadding, AppSpacing.bottomScrollPadding),
              sliver: SliverToBoxAdapter(child: _HeadToHead(myTeam: myTeam, foeTeam: foeTeam)),
            ),
          ] else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding, 12, AppSpacing.pagePadding, AppSpacing.bottomScrollPadding),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF101010) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0))),
                  child: const Text('Add foe Pokémon to see head-to-head type matchups. No damage calc — use Calculator for 1vs1.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.pokemonRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.22))),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.pokemonRed),
        const SizedBox(width: 8),
        Expanded(child: Text('Team Comparison is a Pokédex readout — type coverage & averages. Not a battle simulation.', style: TextStyle(fontSize: 11, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.w600))),
      ]),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.pokemonRed.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icon, size: 16, color: AppTheme.pokemonRed)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.3)),
        ])),
      ]),
      const SizedBox(height: 8),
      Divider(height: 1, color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0)),
    ]);
  }
}

class _TeamRow extends StatelessWidget {
  final List<Pokemon> team;
  final bool isDark;
  const _TeamRow({required this.team, required this.isDark});
  @override
  Widget build(BuildContext context) {
    if (team.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: team.map((p) {
        final c = pokemonTypeColor(p.type1);
        final dex = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
        return Container(
          width: 86,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withValues(alpha: 0.28))),
          child: Column(children: [
            SizedBox(height: 48, child: PokemonSprite(imageUrl: p.spriteUrl, fallbackUrl: PokemonSprite.homeArtworkUrl(dex), errorIconSize: 24)),
            const SizedBox(height: 4),
            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            Text('#${dex.toString().padLeft(3, '0')}', style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w700)),
          ]),
        );
      }).toList(),
    );
  }
}

class _TeamStats extends StatelessWidget {
  final List<Pokemon> team;
  final String label;
  const _TeamStats({required this.team, required this.label});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (team.isEmpty) return const SizedBox.shrink();
    final totalBst = team.fold<int>(0, (s, p) => s + p.baseHp + p.baseAtk + p.baseDef + p.baseSpAtk + p.baseSpDef + p.baseSpd);
    final avgBst = (totalBst / team.length).round();
    final avgSpe = (team.fold<int>(0, (s, p) => s + p.baseSpd) / team.length).round();
    // Defensive weak ≥2 and offensive STAB hits
    final weakCounts = <String, int>{for (final t in pokemonTypes) t: 0};
    final offensiveHits = <String, int>{for (final t in pokemonTypes) t: 0};
    for (final p in team) {
      final eff = TypeEfficiencyCalculator.getCombinedEffectiveness(p.type1, p.type2);
      for (final t in pokemonTypes) if ((eff[t] ?? 1.0) > 1) weakCounts[t] = (weakCounts[t] ?? 0) + 1;
      for (final atk in [p.type1, if (p.type2 != null) p.type2!]) {
        for (final def in (CombatUtils.effectivenessMap[atk.toLowerCase()]?['double'] ?? const [])) {
          offensiveHits[def.toLowerCase()] = (offensiveHits[def.toLowerCase()] ?? 0) + 1;
        }
      }
    }
    final weakGe2 = weakCounts.values.where((v) => v >= 2).length;
    final seTypes = offensiveHits.values.where((v) => v > 0).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF101010) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label — ${team.length}/6', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MiniStat(label: 'Avg BST', value: '$avgBst')),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat(label: 'Avg Spe', value: '$avgSpe')),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat(label: 'Weak ≥2', value: '$weakGe2')),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat(label: 'SE hits', value: '$seTypes/18')),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF141414) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0))),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.pokemonRed)),
      ]),
    );
  }
}

class _FoeGrid extends ConsumerWidget {
  final List<Pokemon?> foe;
  final void Function(int, Pokemon?) onChanged;
  const _FoeGrid({required this.foe, required this.onChanged});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final all = ref.watch(pokedexProvider).maybeWhen(data: (v) => v, orElse: () => <Pokemon>[]);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.55, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemBuilder: (ctx, i) {
        final p = foe[i];
        if (p == null) {
          return InkWell(
            onTap: () async {
              final picked = await _pick(all, ctx);
              if (picked != null) onChanged(i, picked);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(14)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_rounded, color: Colors.grey, size: 20), Text('Slot ${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.grey))]),
            ),
          );
        }
        final c = pokemonTypeColor(p.type1);
        return InkWell(
          onTap: () => onChanged(i, null),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withValues(alpha: 0.28))),
            child: Column(children: [
              Expanded(child: PokemonSprite(imageUrl: p.spriteUrl, fallbackUrl: PokemonSprite.homeArtworkUrl(p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id), errorIconSize: 22)),
              Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            ]),
          ),
        );
      },
    );
  }

  Future<Pokemon?> _pick(List<Pokemon> all, BuildContext context) async {
    Pokemon? result;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        String q = '';
        return StatefulBuilder(builder: (ctx, setS) {
          final filtered = all.where((p) => p.name.toLowerCase().contains(q.toLowerCase())).take(50).toList();
          return AlertDialog(
            title: const Text('Pick foe Pokémon'),
            content: SizedBox(
              width: double.maxFinite,
              height: 380,
              child: Column(children: [
                TextField(decoration: const InputDecoration(hintText: 'Search'), onChanged: (v) => setS(() => q = v)),
                const SizedBox(height: 8),
                Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
                  final p = filtered[i];
                  return ListTile(title: Text(p.name), subtitle: Text('${p.type1}${p.type2 == null ? '' : '/${p.type2}'}'), onTap: () { result = p; Navigator.pop(ctx); });
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

class _HeadToHead extends StatelessWidget {
  final List<Pokemon> myTeam;
  final List<Pokemon> foeTeam;
  const _HeadToHead({required this.myTeam, required this.foeTeam});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Count how many Pokémon on each side are weak to the other's STABs
    int myWeakToFoe = 0;
    int foeWeakToMe = 0;
    for (final me in myTeam) {
      bool weak = false;
      for (final foe in foeTeam) {
        for (final atk in [foe.type1, if (foe.type2 != null) foe.type2!]) {
          final eff = TypeEfficiencyCalculator.getCombinedEffectiveness(me.type1, me.type2)[atk.toLowerCase()] ?? 1.0;
          // Actually we want foe's attack vs my defense: need attacker type = foe's type
          // So check if foe's STAB is SE vs me
          final map = CombatUtils.effectivenessMap[atk.toLowerCase()];
          if (map != null && (map['double'] ?? const []).contains(me.type1.toLowerCase()) || (me.type2 != null && (map['double'] ?? const []).contains(me.type2!.toLowerCase()))) {
            // Simplified: if any foe STAB double-contains my type, count
          }
        }
      }
    }
    // Accurate head-to-head: count Pokémon weak to any opposing STAB
    int countWeak(List<Pokemon> defenders, List<Pokemon> attackers) {
      int c = 0;
      final atkTypes = attackers.expand((p) => [p.type1, if (p.type2 != null) p.type2!]).map((t) => t.toLowerCase()).toSet();
      for (final def in defenders) {
        final eff = TypeEfficiencyCalculator.getCombinedEffectiveness(def.type1, def.type2);
        bool isWeak = false;
        for (final atk in atkTypes) {
          if ((eff[atk] ?? 1.0) == 0) continue;
          // eff is defender's weakness to attacker type: if defender is weak to atk, then atk hits def SE
          if ((eff[atk] ?? 1.0) > 1) { isWeak = true; break; }
        }
        if (isWeak) c++;
      }
      return c;
    }

    myWeakToFoe = countWeak(myTeam, foeTeam);
    foeWeakToMe = countWeak(foeTeam, myTeam);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF101010) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? const Color(0xFF242424) : const Color(0xFFE2E8F0))),
      child: Column(children: [
        Row(children: [
          Expanded(child: _MiniStat(label: 'You weak to foe', value: '$myWeakToFoe/6', sub: 'mons')),
          const SizedBox(width: 8),
          Expanded(child: _MiniStat(label: 'Foe weak to you', value: '$foeWeakToMe/6', sub: 'mons')),
        ]),
        const SizedBox(height: 8),
        const Text('_counts how many Pokémon are weak (2×) to any opposing STAB — type chart only, no rolls.', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
      ]),
    );
  }
}
