class NpcInteractionOutcome {
  const NpcInteractionOutcome({
    required this.npcId,
    required this.action,
    required this.narrative,
    required this.relationshipPercent,
    required this.year,
    required this.age,
    this.progressed = true,
  });

  final String npcId;
  final String action;
  final String narrative;
  final int relationshipPercent;
  final int year;
  final int age;

  /// False when this interaction was already used with this person this
  /// year, so the relationship did not change.
  final bool progressed;
}
