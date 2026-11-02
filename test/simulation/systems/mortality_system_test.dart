import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/systems/mortality_system.dart';

void main() {
  test('death chance never decreases with age at full health', () {
    var previous = 0;

    for (var age = 1; age <= 120; age++) {
      final chance = MortalitySystem.deathChancePer10000(age: age, health: 100);

      expect(chance, greaterThanOrEqualTo(previous), reason: 'age $age');
      previous = chance;
    }
  });

  test('worse health never lowers the death chance', () {
    for (final age in [5, 25, 45, 65, 85, 105]) {
      var previous = 0;

      for (var health = 100; health >= 0; health -= 5) {
        final chance = MortalitySystem.deathChancePer10000(
          age: age,
          health: health,
        );

        expect(chance, greaterThanOrEqualTo(previous), reason: 'age $age');
        previous = chance;
      }
    }
  });

  test('death is certain from age 115', () {
    expect(
      MortalitySystem.deathChancePer10000(age: 115, health: 100),
      10000,
    );
  });

  WorldState stateAtAge(int age, {LifeProgress? progress}) {
    return WorldState(
      clock: SimulationClock(currentYear: 1900 + age),
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 1900,
      ),
      events: const [],
      lifeProgress: progress ?? const LifeProgress(),
    );
  }

  test('a certain death records the ending and a death event', () {
    final system = MortalitySystem(random: SeededRandom(1));

    final next = system.process(
      state: stateAtAge(115),
      command: const AgeUpCommand(),
    );

    final ending = next.lifeProgress.ending;

    expect(ending, isNotNull);
    expect(ending!.age, 115);
    expect(ending.year, 2015);
    expect(next.events.single.id, 'death-2015');
    expect(next.events.single.type, SimulationEventType.death);
  });

  test('an ended life is not processed again', () {
    final system = MortalitySystem(random: SeededRandom(1));
    const ending = LifeEnding(year: 2000, age: 100, cause: 'old age');
    final state = stateAtAge(
      115,
      progress: const LifeProgress(ending: ending),
    );

    final next = system.process(
      state: state,
      command: const AgeUpCommand(),
    );

    expect(next.events, isEmpty);
    expect(next.lifeProgress.ending, same(ending));
  });
}
