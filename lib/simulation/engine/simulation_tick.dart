class SimulationTick {
  const SimulationTick({
    required this.id,
    required this.fromYear,
    required this.toYear,
  });

  final int id;
  final int fromYear;
  final int toYear;

  bool get isValid =>
      id >= 1 &&
      fromYear > 0 &&
      toYear == fromYear + 1;
}
