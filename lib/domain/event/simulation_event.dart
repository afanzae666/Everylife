enum SimulationEventType {
  lifeCreated,
  yearAdvanced,
  characterAged,
  lifeStageChanged,
  randomEvent,
}

class SimulationEvent {
  const SimulationEvent({
    required this.id,
    required this.type,
    required this.year,
    required this.title,
    required this.description,
  });

  final String id;
  final SimulationEventType type;
  final int year;
  final String title;
  final String description;
}
