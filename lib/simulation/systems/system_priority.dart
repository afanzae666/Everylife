enum SystemPriority {
  time(100),
  parentEconomy(150),
  npcEconomy(155),
  familyMortality(160),
  character(200),
  education(250),
  career(300),
  mortality(800),
  event(900);

  const SystemPriority(this.value);

  final int value;
}
