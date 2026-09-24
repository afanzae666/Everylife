import '../../domain/character/life_stage.dart';
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

    final currentYear = state.clock.currentYear;
    final age = state.player.ageAt(currentYear);
    final previousAge = age - 1;

    final currentStage = LifeStageAge.fromAge(age);

    final previousStage = previousAge >= 0
        ? LifeStageAge.fromAge(previousAge)
        : null;

    var nextState = state;

    if (previousStage != null && previousStage != currentStage) {
      nextState = nextState.addEvent(
        SimulationEvent(
          id: 'life-stage-changed-$currentYear',
          type: SimulationEventType.lifeStageChanged,
          year: currentYear,
          title: 'A new life stage begins',
          description:
              '${state.player.name} entered ${currentStage.name}.',
        ),
      );
    }

    final event = SimulationEvent(
      id: 'character-aged-$currentYear',
      type: SimulationEventType.characterAged,
      year: currentYear,
      title: 'Another year passes',
      description:
          '${state.player.name} is now $age years old.',
    );

    return nextState.addEvent(event);
  }
}
