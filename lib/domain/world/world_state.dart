
import '../character/character.dart';
import '../character/starting_background.dart';
import '../event/simulation_event.dart';
import '../time/simulation_clock.dart';

class WorldState {
  const WorldState({
    required this.clock,
    required this.player,
    required this.events,
    this.startingBackground,
  });

  final SimulationClock clock;
  final Character player;
  final List<SimulationEvent> events;
  final StartingBackground? startingBackground;

  WorldState copyWith({
    SimulationClock? clock,
    Character? player,
    List<SimulationEvent>? events,
    StartingBackground? startingBackground,
  }) {
    return WorldState(
      clock: clock ?? this.clock,
      player: player ?? this.player,
      events: List.unmodifiable(
        events ?? this.events,
      ),
      startingBackground:
          startingBackground ?? this.startingBackground,
    );
  }

  WorldState addEvent(SimulationEvent event) {
    return copyWith(
      events: [
        ...events,
        event,
      ],
    );
  }
}
