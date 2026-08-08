import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/database/app_database.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/widgets/pokemon_sprite.dart';
import 'package:libredex/features/calculator/viewmodels/damage_calculator_viewmodel.dart';
import 'package:libredex/features/pokedex/repositories/pokemon_repository.dart';
import 'package:libredex/core/widgets/debounced_search_field.dart';

/// Searchable modal dialog for selecting an attacker or defender Pokémon.
class PokemonPickerDialog extends ConsumerWidget {
  final List<Pokemon> pokemonList;
  final bool isAttacker;
  final DamageCalculatorViewModel viewModel;

  const PokemonPickerDialog({
    super.key,
    required this.pokemonList,
    required this.isAttacker,
    required this.viewModel,
  });

  /// Displays the Pokémon picker dialog.
  static Future<void> show(
    BuildContext context, {
    required List<Pokemon> list,
    required bool isAttacker,
    required DamageCalculatorViewModel vm,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PokemonPickerDialog(
        pokemonList: list,
        isAttacker: isAttacker,
        viewModel: vm,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    var query = '';

    return StatefulBuilder(
      builder: (ctx, setState) {
        final filtered = pokemonList.where((p) {
          final q = query.toLowerCase();
          return p.name.toLowerCase().contains(q) ||
              p.id.toString().contains(q) ||
              p.type1.toLowerCase().contains(q) ||
              (p.type2?.toLowerCase().contains(q) ?? false);
        }).toList();

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
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
                      Text(
                        'Select ${isAttacker ? 'Attacker' : 'Defender'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DebouncedSearchField(
                    hintText: 'Search Pokémon by name, ID or type...',
                    initialValue: query,
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final p = filtered[i];
                      final dexNumber = p.nationalDexNumber > 0 ? p.nationalDexNumber : p.id;
                      return ListTile(
                        leading: p.spriteUrl.isNotEmpty
                            ? SizedBox(
                                width: 40,
                                height: 40,
                                child: PokemonSprite(
                                  imageUrl: p.spriteUrl,
                                  fallbackUrl: PokemonSprite.homeArtworkUrl(dexNumber),
                                  errorIconColor: Colors.grey,
                                  errorIconSize: 24,
                                ),
                              )
                            : const Icon(Icons.catching_pokemon, color: Colors.grey),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${p.type1.toUpperCase()}${p.type2 != null ? " / ${p.type2!.toUpperCase()}" : ""}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        onTap: () async {
                          Navigator.pop(ctx);
                          try {
                            final abs = await ref.read(databaseProvider).getPokemonAbilities(p.id);
                            final defAb = abs.isNotEmpty ? abs.first.ability.name : null;
                            if (isAttacker) {
                              viewModel.setAttacker(p, defaultAbility: defAb);
                            } else {
                              viewModel.setDefender(p, defaultAbility: defAb);
                            }
                          } catch (_) {
                            if (isAttacker) {
                              viewModel.setAttacker(p);
                            } else {
                              viewModel.setDefender(p);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
