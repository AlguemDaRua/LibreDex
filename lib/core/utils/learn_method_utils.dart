import 'package:flutter/material.dart';

/// Canonical learn-method ids used by the UI filters.
///
/// PokéAPI has changed public-facing machine names over the years (TM/HM/TR),
/// but stores them under the internal `machine` method. Keeping this mapping in
/// one place prevents small wording differences from breaking filters.
enum LearnMethodKind { level, machine, egg, tutor, formChange, other }

LearnMethodKind learnMethodKind(String raw) {
  final value = raw.trim().toLowerCase();
  switch (value) {
    case 'level':
    case 'level-up':
      return LearnMethodKind.level;
    case 'machine':
    case 'tm':
    case 'tr':
    case 'tm-tr':
    case 'tm/hm':
      return LearnMethodKind.machine;
    case 'egg':
      return LearnMethodKind.egg;
    case 'tutor':
      return LearnMethodKind.tutor;
    case 'form-change':
      return LearnMethodKind.formChange;
    default:
      return LearnMethodKind.other;
  }
}

String learnMethodLabel(String raw) {
  switch (learnMethodKind(raw)) {
    case LearnMethodKind.level:
      return 'Level';
    case LearnMethodKind.machine:
      return 'TM/TR';
    case LearnMethodKind.egg:
      return 'Egg';
    case LearnMethodKind.tutor:
      return 'Tutor';
    case LearnMethodKind.formChange:
      return 'Form Change';
    case LearnMethodKind.other:
      if (raw.trim().isEmpty) return 'Other';
      return raw
          .split(RegExp('[-_ ]+'))
          .where((part) => part.isNotEmpty)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
          .join(' ');
  }
}

Color learnMethodColor(String raw) {
  switch (learnMethodKind(raw)) {
    case LearnMethodKind.level:
      return const Color(0xFF22C55E);
    case LearnMethodKind.machine:
      return const Color(0xFFF59E0B);
    case LearnMethodKind.egg:
      return const Color(0xFFEC4899);
    case LearnMethodKind.tutor:
      return const Color(0xFF3B82F6);
    case LearnMethodKind.formChange:
      return const Color(0xFF8B5CF6);
    case LearnMethodKind.other:
      return const Color(0xFF94A3B8);
  }
}
