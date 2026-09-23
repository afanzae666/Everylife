enum SystemPriority {
  time(100),
  character(200),
  event(900);

  const SystemPriority(this.value);

  final int value;
}
