enum SystemPriority {
  time(100),
  parentEconomy(150),
  character(200),
  mortality(800),
  event(900);

  const SystemPriority(this.value);

  final int value;
}
