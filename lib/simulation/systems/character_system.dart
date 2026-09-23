import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';

class CharacterSystem implements SimulationSystem {
  @override
  String get id => 'character';

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

    final updatedPlayer = state.player.copyWith();

    final event = SimulationEvent(
      id: 'character-aged-${state.clock.currentYear}',
      type: SimulationEventType.characterAged,
      year: state.clock.currentYear,
      title: 'Another year passes',
      description:
          '${state.player.name} is now $age years old.',
    );

    return state
        .copyWith(
          player: updatedPlayer,
        )
        .addEvent(event);
  }
}
