class NpcInteractionOutcome {
  const NpcInteractionOutcome({
    required this.npcId,
    required this.action,
    required this.narrative,
    required this.relationshipPercent,
    required this.year,
    required this.age,
    this.progressed = true,
    this.bond = 'none',
    this.prompt,
    this.romance = 'none',
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

  /// How the person relates to the player now: 'none', 'friend' or
  /// 'best friend'.
  final String bond;

  /// A question the screen should ask: 'bestFriend' asks whether to make
  /// this friend a best friend. Answer with the action
  /// [bestFriendYes] or [bestFriendNo].
  final String? prompt;

  /// 'partner' when this person is the player's boyfriend or girlfriend.
  final String romance;

  static const String bestFriendYes = 'Best Friend: yes';
  static const String bestFriendNo = 'Best Friend: no';
}
