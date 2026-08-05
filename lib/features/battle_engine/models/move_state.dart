/// Pure Dart representation of a move being used in battle.
library;

class MoveState {
  final String name;
  final String type;
  final int basePower;
  final String damageClass; // 'physical', 'special', 'status'
  final int hits;
  final bool isCritical;
  final int rageFistHits;

  const MoveState({
    required this.name,
    required this.type,
    required this.basePower,
    required this.damageClass,
    this.hits = 1,
    this.isCritical = false,
    this.rageFistHits = 0,
  });

  bool get isPhysical => damageClass.toLowerCase() == 'physical';
  bool get isSpecial => damageClass.toLowerCase() == 'special';
  bool get isStatus => damageClass.toLowerCase() == 'status';

  MoveState copyWith({
    String? name,
    String? type,
    int? basePower,
    String? damageClass,
    int? hits,
    bool? isCritical,
    int? rageFistHits,
  }) {
    return MoveState(
      name: name ?? this.name,
      type: type ?? this.type,
      basePower: basePower ?? this.basePower,
      damageClass: damageClass ?? this.damageClass,
      hits: hits ?? this.hits,
      isCritical: isCritical ?? this.isCritical,
      rageFistHits: rageFistHits ?? this.rageFistHits,
    );
  }
}
