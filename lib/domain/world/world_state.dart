import '../character/character.dart';
import '../event/simulation_event.dart';
import '../time/simulation_clock.dart';

class WorldState {
  const WorldState({
    required this.clock,
    required this.player,
    required this.events,
  });

  final SimulationClock clock;
  final Character player;
  final List<SimulationEvent> events;

  WorldState copyWith({
    SimulationClock? clock,
    Character? player,
    List<SimulationEvent>? events,
  }) {
    return WorldState(
      clock: clock ?? this.clock,
      player: player ?? this.player,
      events: List.unmodifiable(
        events ?? this.events,
      ),
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
