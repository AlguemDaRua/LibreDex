import 'package:flutter/material.dart';

/// Small, consistent icon for the primary effect category of an Ability.
class AbilityEffectIcon extends StatelessWidget {
  final List<String> effectTags;
  final double size;
  final Color? color;

  const AbilityEffectIcon({
    super.key,
    required this.effectTags,
    this.size = 20,
    this.color,
  });

  String get _primaryTag {
    const priority = [
      'Immunity',
      'Defense',
      'Damage',
      'Weather',
      'Terrain',
      'Healing',
      'Status',
      'Stats',
      'Type',
      'Switching',
      'Hazards',
      'Items',
      'Speed',
      'Accuracy',
      'Priority',
      'Contact',
    ];
    final tags = effectTags.map((tag) => tag.toLowerCase()).toSet();
    for (final candidate in priority) {
      if (tags.contains(candidate.toLowerCase())) return candidate;
    }
    return effectTags.isEmpty ? 'Ability' : effectTags.first;
  }

  IconData get _icon => switch (_primaryTag.toLowerCase()) {
    'immunity' || 'defense' || 'contact' => Icons.shield_rounded,
    'damage' => Icons.bolt_rounded,
    'weather' => Icons.wb_sunny_rounded,
    'terrain' => Icons.landscape_rounded,
    'healing' => Icons.healing_rounded,
    'status' => Icons.sick_rounded,
    'stats' => Icons.trending_up_rounded,
    'type' => Icons.category_rounded,
    'switching' => Icons.swap_horiz_rounded,
    'hazards' => Icons.warning_amber_rounded,
    'items' => Icons.inventory_2_rounded,
    'speed' => Icons.speed_rounded,
    'accuracy' => Icons.center_focus_strong_rounded,
    'priority' => Icons.priority_high_rounded,
    _ => Icons.auto_awesome_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _primaryTag == 'Ability' ? 'Ability effect' : _primaryTag,
      child: Icon(
        _icon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
