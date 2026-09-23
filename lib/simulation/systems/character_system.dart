import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

class CharacterSystem implements SimulationSystem {
  @override
  String get id => 'character';

  @override
  int get priority => SystemPriority.character.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final age = state.player.ageAt(
      state.clock.currentYear,
    );

    final event = SimulationEvent(
      id: 'character-aged-${state.clock.currentYear}',
      type: SimulationEventType.characterAged,
      year: state.clock.currentYear,
      title: 'Another year passes',
      description:
          '${state.player.name} is now $age years old.',
    );

    return state.addEvent(event);
  }
}
