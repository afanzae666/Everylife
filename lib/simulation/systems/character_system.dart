import '../../domain/character/life_stage.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../progression/character_stat_progression.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

class CharacterSystem implements SimulationSystem {
  CharacterSystem({
    CharacterStatProgression progression =
        const CharacterStatProgression(),
  }) : _progression = progression;

  final CharacterStatProgression _progression;

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

    final updatedStats = _progression.apply(
      stats: state.player.stats,
      stage: currentStage,
    );

    var nextState = state.copyWith(
      player: state.player.copyWith(
        stats: updatedStats,
      ),
    );

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

    final household = state.familyHousehold;
    if (household != null) {
      for (final sibling in household.siblings.where(
        (sibling) => sibling.birthYear == currentYear &&
            sibling.birthYear > state.player.birthYear,
      )) {
        final relation = sibling.gender.name == 'male' ? 'brother' : 'sister';
        nextState = nextState.addEvent(
          SimulationEvent(
            id: 'sibling-born-${sibling.id}',
            type: SimulationEventType.randomEvent,
            year: currentYear,
            title: 'A new sibling is born',
            description: 'My $relation, ${sibling.fullName}, was born in $currentYear.',
          ),
        );
      }
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
