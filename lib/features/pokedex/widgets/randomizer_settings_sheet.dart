import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/utils/type_utils.dart';
import 'package:libredex/features/pokedex/viewmodels/randomizer_settings_provider.dart';

/// Modal bottom sheet that allows users to customize their Random Pokémon parameters.
class RandomizerSettingsSheet extends ConsumerStatefulWidget {
  final VoidCallback onRollPressed;

  const RandomizerSettingsSheet({super.key, required this.onRollPressed});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRollPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => RandomizerSettingsSheet(onRollPressed: onRollPressed),
    );
  }

  @override
  ConsumerState<RandomizerSettingsSheet> createState() =>
      _RandomizerSettingsSheetState();
}

class _RandomizerSettingsSheetState
    extends ConsumerState<RandomizerSettingsSheet> {
  late RandomPoolMode _poolMode;
  late Set<String> _selectedTypes;
  late Set<int> _selectedGens;
  late double _minBst;
  late double _maxBst;
  late bool _fullyEvolvedOnly;
  late bool _instantRollOnTap;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(randomizerSettingsProvider);
    _poolMode = settings.poolMode;
    _selectedTypes = {...settings.selectedTypes};
    _selectedGens = {...settings.selectedGens};
    _minBst = settings.minBst.toDouble();
    _maxBst = settings.maxBst.toDouble();
    _fullyEvolvedOnly = settings.fullyEvolvedOnly;
    _instantRollOnTap = settings.instantRollOnTap;
  }

  void _saveAndApply() {
    final newSettings = RandomizerSettings(
      poolMode: _poolMode,
      selectedTypes: _selectedTypes,
      selectedGens: _selectedGens,
      minBst: _minBst.round(),
      maxBst: _maxBst.round(),
      fullyEvolvedOnly: _fullyEvolvedOnly,
      instantRollOnTap: _instantRollOnTap,
    );
    ref.read(randomizerSettingsProvider.notifier).updateSettings(newSettings);
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _poolMode = RandomPoolMode.all;
      _selectedTypes = {};
      _selectedGens = {};
      _minBst = 180;
      _maxBst = 780;
      _fullyEvolvedOnly = false;
      _instantRollOnTap = false;
    });
    ref.read(randomizerSettingsProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.casino_outlined,
                        color: AppTheme.pokemonRed,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Random Parameters',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Settings Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  // Quick Random Toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2B2B2B)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Material(
                      // The Container above paints a background; without
                      // a Material here the tile's ink splashes and
                      // selected colour are hidden behind it.
                      color: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SwitchListTile(
                        value: _instantRollOnTap,
                        activeTrackColor: AppTheme.pokemonRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Instant Roll on Tap',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        subtitle: const Text(
                          'Bypass parameter sheet on single tap and roll immediately',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        secondary: Icon(
                          Icons.bolt_rounded,
                          color: _instantRollOnTap
                              ? AppTheme.pokemonRed
                              : Colors.grey,
                        ),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _instantRollOnTap = val);
                        },
                      ),
                    ),
                  ),

                  // Pool Mode Choice
                  const Text(
                    'RANDOM POOL SOURCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2B2B2B)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildModeOption(
                          mode: RandomPoolMode.all,
                          title: 'Everything',
                          subtitle:
                              'Pick completely randomly from all 1000+ Pokémon',
                          icon: Icons.public_rounded,
                          isDark: isDark,
                        ),
                        _buildModeOption(
                          mode: RandomPoolMode.activeFilters,
                          title: 'Active Dex Search & Filters',
                          subtitle:
                              'Pick only from current Pokédex search/type filters',
                          icon: Icons.filter_alt_outlined,
                          isDark: isDark,
                        ),
                        _buildModeOption(
                          mode: RandomPoolMode.custom,
                          title: 'Custom Criteria Rules',
                          subtitle:
                              'Specify custom Type, Gen, and BST boundaries below',
                          icon: Icons.tune_rounded,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  // Custom Parameters Section
                  if (_poolMode == RandomPoolMode.custom) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'TYPES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: pokemonTypes.map((t) {
                        final isSelected = _selectedTypes.contains(t);
                        final typeColor = pokemonTypeColor(t);
                        return FilterChip(
                          label: Text(
                            t.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[800]),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: typeColor,
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isSelected
                                ? typeColor
                                : (isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFE2E8F0)),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (val) {
                                _selectedTypes.add(t);
                              } else {
                                _selectedTypes.remove(t);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'GENERATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(9, (idx) {
                        final gen = idx + 1;
                        final isSelected = _selectedGens.contains(gen);
                        return FilterChip(
                          label: Text('Gen $gen'),
                          selected: isSelected,
                          selectedColor: AppTheme.pokemonRed,
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[800]),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (val) {
                                _selectedGens.add(gen);
                              } else {
                                _selectedGens.remove(gen);
                              }
                            });
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BASE STAT TOTAL (BST)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '${_minBst.round()} - ${_maxBst.round()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.pokemonRed,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_minBst, _maxBst),
                      min: 180,
                      max: 780,
                      divisions: 60,
                      activeColor: AppTheme.pokemonRed,
                      inactiveColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFE2E8F0),
                      labels: RangeLabels(
                        '${_minBst.round()}',
                        '${_maxBst.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minBst = values.start;
                          _maxBst = values.end;
                        });
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.verified_outlined,
                        color: _fullyEvolvedOnly
                            ? AppTheme.pokemonRed
                            : Colors.grey,
                      ),
                      title: const Text('Fully evolved only'),
                      subtitle: const Text(
                        'Keep final evolutions and single-stage Pokémon.',
                      ),
                      value: _fullyEvolvedOnly,
                      activeTrackColor: AppTheme.pokemonRed,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _fullyEvolvedOnly = value);
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Footer Action Button
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.pokemonRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      _saveAndApply();
                      Navigator.pop(context);
                      widget.onRollPressed();
                    },
                    icon: const Icon(Icons.casino_rounded, size: 22),
                    label: const Text(
                      'ROLL RANDOM POKÉMON',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeOption({
    required RandomPoolMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _poolMode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _poolMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.pokemonRed.withValues(alpha: 0.6))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.pokemonRed : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? AppTheme.pokemonRed
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.pokemonRed : Colors.grey[500],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
