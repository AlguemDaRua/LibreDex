import 'package:flutter/material.dart';
import 'package:libredex/core/utils/learn_method_utils.dart';

class LearnMethodBadge extends StatelessWidget {
  final String method;
  final int? level;
  final bool compact;

  const LearnMethodBadge({
    super.key,
    required this.method,
    this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final kind = learnMethodKind(method);
    final color = learnMethodColor(method);
    final label = kind == LearnMethodKind.level && level != null
        ? 'Lv. $level'
        : learnMethodLabel(method);

    return Semantics(
      label: 'Learn method: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(compact ? 6 : 8),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: compact ? 9 : 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
