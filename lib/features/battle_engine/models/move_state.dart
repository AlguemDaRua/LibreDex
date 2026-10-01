/// Pure Dart representation of a move being used in battle.
library;

class MoveState {
  final String name;
  final String type;
  final int basePower;
  final String damageClass; // 'physical', 'special', 'status'
  final int hits;
  /// Catalog action order; the damage engine carries it but does not simulate turns.
  final int priority;
  final bool isCritical;
  final bool isContact;
  final bool isPunching;
  final bool isBiting;
  final bool isPulse;
  final bool isSlicing;
  final bool isRecoil;
  final int rageFistHits;

  const MoveState({
    required this.name,
    required this.type,
    required this.basePower,
    required this.damageClass,
    this.hits = 1,
    this.priority = 0,
    this.isCritical = false,
    this.isContact = false,
    this.isPunching = false,
    this.isBiting = false,
    this.isPulse = false,
    this.isSlicing = false,
    this.isRecoil = false,
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
    int? priority,
    bool? isCritical,
    bool? isContact,
    bool? isPunching,
    bool? isBiting,
    bool? isPulse,
    bool? isSlicing,
    bool? isRecoil,
    int? rageFistHits,
  }) {
    return MoveState(
      name: name ?? this.name,
      type: type ?? this.type,
      basePower: basePower ?? this.basePower,
      damageClass: damageClass ?? this.damageClass,
      hits: hits ?? this.hits,
      priority: priority ?? this.priority,
      isCritical: isCritical ?? this.isCritical,
      isContact: isContact ?? this.isContact,
      isPunching: isPunching ?? this.isPunching,
      isBiting: isBiting ?? this.isBiting,
      isPulse: isPulse ?? this.isPulse,
      isSlicing: isSlicing ?? this.isSlicing,
      isRecoil: isRecoil ?? this.isRecoil,
      rageFistHits: rageFistHits ?? this.rageFistHits,
    );
  }
}
