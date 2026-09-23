class SimulationClock {
  const SimulationClock({
    required this.currentYear,
  });

  final int currentYear;

  SimulationClock advanceYear() {
    return SimulationClock(
      currentYear: currentYear + 1,
    );
  }
}
