import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_spacing.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/learn_method_utils.dart';
import 'package:libredex/core/widgets/app_state_widgets.dart';
import 'package:libredex/core/widgets/learn_method_badge.dart';
import 'package:libredex/features/calculator/utils/combat_utils.dart';
import 'package:libredex/features/movedex/views/move_detail_screen.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/features/pokedex/viewmodels/pokedex_viewmodel.dart';

/// Moves tab for the Pokémon Detail view.
/// Contains move learnset lists, learn method filter chips (Level, TM, Tutor, Egg, Train),
/// and navigation to full move learner screens.
class PokemonDetailMovesTab extends ConsumerStatefulWidget {
  final Pokemon activePokemon;

  const PokemonDetailMovesTab({
    super.key,
    required this.activePokemon,
  });

  @override
  ConsumerState<PokemonDetailMovesTab> createState() => _PokemonDetailMovesTabState();
}

class _PokemonDetailMovesTabState extends ConsumerState<PokemonDetailMovesTab> {
  String _moveFilter = 'all';

  Color _getTypeColor(String type) => CombatUtils.typeColors[type.toLowerCase()] ?? Colors.grey;

  Widget _buildFallbackNote(String message, {required String source, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$message ($source)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.amber[200] : Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterId, String label) {
    final isSelected = _moveFilter == filterId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _moveFilter = filterId);
        }
      },
      selectedColor: AppTheme.pokemonRed,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.grey[700]),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTheme.pokemonRed
              : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final movesAsync = ref.watch(pokemonMovesStreamProvider(widget.activePokemon.id));

    final movesValue = movesAsync.asData?.value;
    String? fallbackFrom;
    if (movesValue != null) {
      for (final m in movesValue) {
        if (m['learnsetFallbackFrom'] != null) {
          fallbackFrom = m['learnsetFallbackFrom'] as String?;
          break;
        }
      }
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildFilterChip('all', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('level', 'Level'),
              const SizedBox(width: 8),
              _buildFilterChip('tm', learnMethodLabel('machine')),
              const SizedBox(width: 8),
              _buildFilterChip('tutor', 'Tutor'),
              const SizedBox(width: 8),
              _buildFilterChip('egg', 'Egg'),
              const SizedBox(width: 8),
              _buildFilterChip('train', learnMethodLabel('train')),
            ],
          ),
        ),
        if (fallbackFrom != null)
          _buildFallbackNote(
            'Using base species learnset for this form.',
            source: fallbackFrom,
            isDark: isDark,
          ),
        Expanded(
          child: movesAsync.when(
            data: (movesList) {
              if (movesList.isEmpty) {
                return AppEmptyState(
                  icon: Icons.flash_off_rounded,
                  title: 'No moves linked yet',
                  message: 'Rebuild the bundled links now, or open Settings and use “Fix Moves & Abilities Links”.',
                  actionLabel: 'Fix links now',
                  onAction: () => ref.read(pokedexSyncNotifierProvider.notifier).reseed(),
                );
              }

              final filteredMoves = movesList.where((item) {
                if (_moveFilter == 'all') return true;
                final kind = learnMethodKind((item['learnMethod'] ?? '').toString());
                switch (_moveFilter) {
                  case 'level':
                    return kind == LearnMethodKind.level;
                  case 'tm':
                    return kind == LearnMethodKind.machine;
                  case 'tutor':
                    return kind == LearnMethodKind.tutor;
                  case 'egg':
                    return kind == LearnMethodKind.egg;
                  case 'train':
                    return (item['learnMethod'] ?? '').toString() == 'train';
                  default:
                    return false;
                }
              }).toList();

              if (filteredMoves.isEmpty) {
                return AppEmptyState(
                  icon: Icons.filter_alt_off_rounded,
                  title: 'No ${_moveFilter == "tm" ? learnMethodLabel("machine") : _moveFilter} moves',
                  message: 'This Pokémon has no bundled moves for the selected learn method.',
                  actionLabel: 'Show all moves',
                  onAction: () => setState(() => _moveFilter = 'all'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(left: AppSpacing.pagePadding, right: AppSpacing.pagePadding, top: 4, bottom: AppSpacing.bottomScrollPadding),
                itemCount: filteredMoves.length,
                separatorBuilder: (context, index) => Divider(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE5E7EB),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final move = filteredMoves[index];
                  final String name = move['name'] ?? '';
                  final String moveType = move['type'] ?? 'normal';
                  final String damageClass = move['damageClass'] ?? 'physical';
                  final int? power = move['power'];
                  final int pp = move['pp'] ?? 15;
                  final int? accuracy = move['accuracy'];
                  final String description = move['description'] ?? 'No information available.';
                  final String learnMethod = move['learnMethod'] ?? 'level';
                  final int? levelLearned = move['levelLearned'];

                  final color = _getTypeColor(moveType);
                  final hasPower = power != null && power > 0;

                  return ExpansionTile(
                    collapsedBackgroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
                    tilePadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: LearnMethodBadge(
                              method: learnMethod,
                              level: levelLearned,
                              compact: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      moveType.toUpperCase(),
                                      style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: damageClass.toLowerCase() == 'physical'
                                          ? const Color(0xFFF87171).withValues(alpha: 0.15)
                                          : damageClass.toLowerCase() == 'special'
                                              ? const Color(0xFF60A5FA).withValues(alpha: 0.15)
                                              : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      damageClass.toUpperCase(),
                                      style: TextStyle(
                                        color: damageClass.toLowerCase() == 'physical'
                                            ? const Color(0xFFF87171)
                                            : damageClass.toLowerCase() == 'special'
                                                ? const Color(0xFF60A5FA)
                                                : Colors.grey,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hasPower ? 'Power: $power' : 'Status',
                              style: TextStyle(
                                color: hasPower
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PP: $pp',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Color(0xFF2D2D2D), height: 12),
                            Text(
                              description,
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Accuracy: ${accuracy != null ? "$accuracy%" : "—"}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                Text(
                                  'PP: $pp/$pp',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                Text(
                                  'Category: ${damageClass[0].toUpperCase() + damageClass.substring(1)}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                                  foregroundColor: AppTheme.pokemonRed,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE2E8F0)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.catching_pokemon, size: 16),
                                label: const Text(
                                  'Who Else Learns This Move?',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  final int? moveId = move['id'];
                                  if (moveId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => MoveDetailScreen(moveId: moveId, moveName: name)),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.pokemonRed)),
                ),
              ),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error loading moves: $err',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
