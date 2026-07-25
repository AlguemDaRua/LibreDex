class EvolutionStep {
  final int fromId;
  final String fromName;
  final String? fromSprite;
  final int toId;
  final String toName;
  final String? toSprite;
  final String trigger;
  final String form;

  EvolutionStep({
    required this.fromId,
    required this.fromName,
    this.fromSprite,
    required this.toId,
    required this.toName,
    this.toSprite,
    required this.trigger,
    this.form = 'normal',
  });
}
