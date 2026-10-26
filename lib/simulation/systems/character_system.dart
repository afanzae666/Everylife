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
      final newbornSiblings = household.siblings.where(
        (sibling) => sibling.birthYear == currentYear &&
            sibling.birthYear > state.player.birthYear,
      ).toList(growable: false);
      final reportedBirthYears = <int>{};
      for (final sibling in newbornSiblings) {
        if (!reportedBirthYears.add(sibling.birthYear)) continue;
        final sameBirth = newbornSiblings
            .where((candidate) => candidate.birthYear == sibling.birthYear)
            .toList(growable: false);
        final names = sameBirth.map((candidate) => candidate.fullName).toSet();
        final relation = sameBirth.every((candidate) => candidate.gender.name == 'male')
            ? 'brothers'
            : sameBirth.every((candidate) => candidate.gender.name != 'male')
                ? 'sisters'
                : 'siblings';
        final description = sameBirth.length > 1
            ? 'My twin $relation, ${names.join(' and ')}, were born in $currentYear.'
            : 'My ${relation == 'brothers' ? 'brother' : relation == 'sisters' ? 'sister' : 'sibling'}, ${sibling.fullName}, was born in $currentYear.';
        nextState = nextState.addEvent(
          SimulationEvent(
            id: 'siblings-born-$currentYear',
            type: SimulationEventType.randomEvent,
            year: currentYear,
            title: sameBirth.length > 1 ? 'Twins are born' : 'A new sibling is born',
            description: description,
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
