import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

/// Lightweight, icon-first helpers shared across calculator tabs.
/// Extracted from damage_calculator_screen.dart to keep the 3.8k-line screen
/// modular and instantly loadable. No redundant storytelling — icon + label suffices.

class DropdownHeader extends StatelessWidget {
  final String label;
  const DropdownHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class CardWrapper extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const CardWrapper({super.key, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

class CalculatorSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const CalculatorSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        value: value,
        activeThumbColor: AppTheme.pokemonRed,
        onChanged: onChanged,
      ),
    );
  }
}
