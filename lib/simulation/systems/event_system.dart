import '../../core/random/seeded_random.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

class EventSystem implements SimulationSystem {
  EventSystem({
    required SeededRandom random,
  }) : _random = random;

  final SeededRandom _random;

  @override
  String get id => 'events';

  @override
  int get priority => SystemPriority.event.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final shouldGenerateEvent = _random.nextInt(3) == 0;

    if (!shouldGenerateEvent) {
      return state;
    }

    final event = SimulationEvent(
      id: 'random-${state.clock.currentYear}-${state.events.length}',
      type: SimulationEventType.randomEvent,
      year: state.clock.currentYear,
      title: 'A small moment',
      description:
          '${state.player.name} experienced an unexpected moment this year.',
    );

    return state.addEvent(event);
  }
}
