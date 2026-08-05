import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libredex/core/navigation/navigation_provider.dart';
import 'package:libredex/core/theme/app_theme.dart';
import 'package:libredex/core/theme/theme_provider.dart';
import 'package:libredex/core/widgets/wavy_theme_transition.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? Colors.black : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F0F) : AppTheme.pokemonRed,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.transparent,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 32,
                        color: isDark ? AppTheme.pokemonRed : Colors.white,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'LibreDex',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live artwork, local reference data',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.grid_view_rounded,
                    label: 'Pokédex',
                    route: 'pokedex',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.groups_rounded,
                    label: 'Team Builder',
                    route: 'team',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.compare_arrows_rounded,
                    label: 'Stat Comparison',
                    route: 'stat_comparison',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.flash_on_rounded,
                    label: 'MoveDex',
                    route: 'moves',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.auto_awesome_rounded,
                    label: 'AbilityDex',
                    route: 'abilities',
                    index: 4,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.inventory_2_rounded,
                    label: 'ItemDex',
                    route: 'items',
                    index: 5,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.analytics_rounded,
                    label: 'NatureDex',
                    route: 'natures',
                    index: 6,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.grid_on_rounded,
                    label: 'Type Chart',
                    route: 'type_chart',
                    index: 7,
                  ),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.calculate_rounded,
                    label: 'Damage Calculator',
                    route: 'calculator',
                    index: 8,
                  ),
                  Divider(height: 32, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
                  _buildDrawerItem(
                    context: context,
                    ref: ref,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: 'settings',
                    index: 9,
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 15,
                        color: isDark ? const Color(0xFFA78BFA) : AppTheme.pokemonRed,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'APPEARANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _ThemeChoiceButton(
                        mode: ThemeMode.system,
                        icon: Icons.settings_brightness_rounded,
                        label: 'System',
                      ),
                      const _ThemeChoiceButton(
                        mode: ThemeMode.light,
                        icon: Icons.light_mode_rounded,
                        label: 'Light',
                      ),
                      const _ThemeChoiceButton(
                        mode: ThemeMode.dark,
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark',
                      ),
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

  Widget _buildDrawerItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required String route,
    required int index,
  }) {
    final isSelected = currentRoute == route;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppTheme.pokemonRed.withValues(alpha: 0.15) : AppTheme.pokemonRed.withValues(alpha: 0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? (isDark ? AppTheme.pokemonRed : AppTheme.pokemonRed.withValues(alpha: 0.5))
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppTheme.pokemonRed
              : (isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppTheme.pokemonRed)
                : (isDark ? Colors.grey[300] : Colors.grey[800]),
            fontSize: 14,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isSelected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(currentMenuIndexProvider.notifier).setIndex(index);
            });
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// A theme choice that supplies the reveal with the exact point the user
/// touched. Keyboard and accessibility activation fall back to the control's
/// center, so the transition remains anchored to the button.
class _ThemeChoiceButton extends ConsumerStatefulWidget {
  const _ThemeChoiceButton({
    required this.mode,
    required this.icon,
    required this.label,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;

  @override
  ConsumerState<_ThemeChoiceButton> createState() => _ThemeChoiceButtonState();
}

class _ThemeChoiceButtonState extends ConsumerState<_ThemeChoiceButton> {
  Offset? _tapOrigin;
  bool _isChangingTheme = false;

  Future<void> _selectTheme() async {
    if (_isChangingTheme || ref.read(themeModeProvider) == widget.mode) return;

    setState(() => _isChangingTheme = true);
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      final origin = _tapOrigin ??
          (renderBox?.localToGlobal(renderBox.size.center(Offset.zero)) ?? Offset.zero);
      void applyTheme() => ref.read(themeModeProvider.notifier).setThemeMode(widget.mode);
      final transition = ThemeTransitionScope.maybeOf(context);

      if (transition == null) {
        applyTheme();
      } else {
        await transition.transitionTo(origin: origin, applyTheme: applyTheme);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingTheme = false;
          _tapOrigin = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = ref.watch(themeModeProvider) == widget.mode;
    final accent = switch (widget.mode) {
      ThemeMode.dark => const Color(0xFFA78BFA),
      ThemeMode.light => const Color(0xFFF59E0B),
      ThemeMode.system => AppTheme.pokemonBlue,
    };
    final unselectedBorder = isDark ? const Color(0xFF222222) : const Color(0xFFE5E7EB);

    return Expanded(
      child: Semantics(
        button: true,
        label: 'Use ${widget.label} theme',
        selected: isSelected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _isChangingTheme
              ? null
              : (details) => _tapOrigin = details.globalPosition,
          onTapCancel: () => _tapOrigin = null,
          onTap: _isChangingTheme ? null : _selectTheme,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.28),
                        AppTheme.pokemonRed.withValues(alpha: 0.12),
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? accent : unselectedBorder,
                width: 1.4,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 17,
                  color: isSelected
                      ? accent
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF111827))
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
