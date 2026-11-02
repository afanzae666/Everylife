import '../../core/random/seeded_random.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Rolls for death once per year and records the ending of the life.
class MortalitySystem implements SimulationSystem {
  MortalitySystem({
    required SeededRandom random,
  }) : _random = random;

  final SeededRandom _random;

  @override
  String get id => 'mortality';

  @override
  int get priority => SystemPriority.mortality.value;

  /// Yearly death chance out of 10000 for a person of [age] and [health].
  ///
  /// The base chance rises with age; poor health multiplies it. From age 115
  /// death is certain so a life always ends.
  static int deathChancePer10000({
    required int age,
    required int health,
  }) {
    final base = _baseChance(age);
    if (base >= 10000) return 10000;

    final chance = base * _healthPercent(health) ~/ 100;

    return chance > 10000 ? 10000 : chance;
  }

  static int _baseChance(int age) {
    if (age >= 115) return 10000;
    if (age >= 110) return 7000;
    if (age >= 100) return 4500;
    if (age >= 90) return 2400;
    if (age >= 80) return 1000;
    if (age >= 70) return 380;
    if (age >= 60) return 150;
    if (age >= 50) return 70;
    if (age >= 40) return 30;
    if (age >= 30) return 12;
    if (age >= 15) return 9;
    if (age >= 1) return 4;

    return 45;
  }

  static int _healthPercent(int health) {
    if (health >= 70) return 100;
    if (health >= 45) return 120;
    if (health >= 20) return 170;
    if (health >= 10) return 320;

    return 600;
  }

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    if (state.lifeProgress.ending != null) {
      return state;
    }

    final year = state.clock.currentYear;
    final age = state.player.ageAt(year);

    final chance = deathChancePer10000(
      age: age,
      health: state.player.stats.health,
    );

    // Always consume one roll per year so the random stream stays stable.
    final roll = _random.nextInt(10000);

    if (roll >= chance) {
      return state;
    }

    final cause = _pickCause(age: age, health: state.player.stats.health);

    final ending = LifeEnding(
      year: year,
      age: age,
      cause: cause,
      netWorthMinorUnits: state.player.netWorth.minorUnits,
    );

    return state
        .copyWith(
          lifeProgress: state.lifeProgress.copyWith(
            ending: ending,
            clearPending: true,
          ),
        )
        .addEvent(
          SimulationEvent(
            id: 'death-$year',
            type: SimulationEventType.death,
            year: year,
            title: 'My life has ended',
            description: 'I passed away at age $age from $cause.',
          ),
        );
  }

  String _pickCause({
    required int age,
    required int health,
  }) {
    final List<String> causes;

    if (age < 1) {
      causes = const ['complications in my first year'];
    } else if (age < 18) {
      causes = const [
        'a sudden illness',
        'a terrible accident',
        'a rare condition nobody saw coming',
      ];
    } else if (age < 60) {
      causes = health < 40
          ? const [
              'a long illness my body could no longer fight',
              'heart failure',
              'complications of poor health',
            ]
          : const [
              'a sudden accident',
              'an unexpected illness',
              'a heart attack that came out of nowhere',
            ];
    } else {
      causes = const [
        'old age',
        'heart failure',
        'complications after a fall',
        'natural causes, peacefully in my sleep',
      ];
    }

    return causes[_random.nextInt(causes.length)];
  }
}
