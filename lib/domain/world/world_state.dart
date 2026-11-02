import '../character/character.dart';
import '../character/starting_background.dart';
import '../event/life_progress.dart';
import '../event/simulation_event.dart';
import '../family/family_household.dart';
import '../time/simulation_clock.dart';

class WorldState {
  const WorldState({
    required this.clock,
    required this.player,
    required this.events,
    this.startingBackground,
    this.familyHousehold,
    this.lifeProgress = const LifeProgress(),
  });

  final SimulationClock clock;
  final Character player;
  final List<SimulationEvent> events;
  final StartingBackground? startingBackground;
  final FamilyHousehold? familyHousehold;

  /// Story flags, event history, pending decision, and the ending.
  final LifeProgress lifeProgress;

  WorldState copyWith({
    SimulationClock? clock,
    Character? player,
    List<SimulationEvent>? events,
    StartingBackground? startingBackground,
    FamilyHousehold? familyHousehold,
    LifeProgress? lifeProgress,
  }) {
    return WorldState(
      clock: clock ?? this.clock,
      player: player ?? this.player,
      events: List.unmodifiable(
        events ?? this.events,
      ),
      startingBackground:
          startingBackground ?? this.startingBackground,
      familyHousehold:
          familyHousehold ?? this.familyHousehold,
      lifeProgress: lifeProgress ?? this.lifeProgress,
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
