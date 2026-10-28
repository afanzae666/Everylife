class NpcInteractionOutcome {
  const NpcInteractionOutcome({
    required this.npcId,
    required this.action,
    required this.narrative,
    required this.relationshipPercent,
    required this.year,
    required this.age,
  });

  final String npcId;
  final String action;
  final String narrative;
  final int relationshipPercent;
  final int year;
  final int age;
}
