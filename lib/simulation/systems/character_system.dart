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
              '${state.player.name} entered ${_stageLabel(currentStage)}.',
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
        final description = _siblingBirthText(
          names: names.toList(growable: false),
          relation: relation,
          isTwin: sameBirth.length > 1,
          variant: currentYear + sibling.fullName.length,
        );
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
          '${state.player.name} is now $age '
          '${age == 1 ? 'year' : 'years'} old.',
    );

    return nextState.addEvent(event);
  }

  /// A short, varied birth scene for a new brother or sister (no years).
  static String _siblingBirthText({
    required List<String> names,
    required String relation,
    required bool isTwin,
    required int variant,
  }) {
    if (isTwin) {
      final both = names.join(' and ');
      final templates = <String>[
        'Double trouble! My twin $relation, $both, arrived together, and '
            'the whole house ran out of sleep in one night.',
        'Mom came home with two bundles instead of one. Meet my twin '
            '$relation, $both. Our home just got twice as loud.',
        'The doctors said "congratulations" twice. My twin $relation, '
            '$both, were born today, and nobody in the family can stop '
            'smiling (or yawning).',
      ];
      return templates[variant % templates.length];
    }

    final noun = relation == 'brothers'
        ? 'brother'
        : relation == 'sisters'
            ? 'sister'
            : 'sibling';
    final name = names.first;
    final templates = <String>[
      'Big news at home: my new little $noun, $name, just arrived! '
          'I am officially not the baby of the family anymore.',
      'Mom and Dad came home carrying a tiny blanket. Inside was my new '
          '$noun, $name. The house has never been so noisy.',
      'I got a new $noun today! $name has a very small face and a very '
          'loud cry, and everyone is already in love.',
      'The whole family crowded around the hospital bed to meet $name, my '
          'new little $noun. I promised to teach them everything.',
    ];
    return templates[variant % templates.length];
  }

  static String _stageLabel(LifeStage stage) {
    return switch (stage) {
      LifeStage.infant => 'infancy',
      LifeStage.toddler => 'toddlerhood',
      LifeStage.child => 'childhood',
      LifeStage.teen => 'the teenage years',
      LifeStage.youngAdult => 'young adulthood',
      LifeStage.adult => 'adulthood',
      LifeStage.senior => 'the senior years',
    };
  }
}
