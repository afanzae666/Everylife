import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

/// Plays many whole lives with random decisions to catch crashes, stuck
/// states, and unrealistic lifespans.
void main() {
  test('simulated lives always finish with a plausible lifespan', () {
    const lives = 120;
    final deathAges = <int>[];
    final decisionRandom = Random(7);

    for (var seed = 1; seed <= lives; seed++) {
      final engine = SimulationEngine.create(
        player: Character.create(
          id: 'player-$seed',
          name: 'Test Player',
          birthYear: 2000,
        ),
        seed: seed * 7919,
        saveRepository: InMemorySaveRepository(),
      )..registerGameplaySystems();

      var guard = 0;

      while (engine.state.lifeProgress.ending == null) {
        expect(guard++, lessThan(500), reason: 'Life $seed never ended.');

        final pending = engine.pendingLifeEvent;

        if (engine.state.lifeProgress.pending != null) {
          expect(pending, isNotNull, reason: 'Unknown pending event.');

          final affordable = pending!.choices
              .where(engine.canAffordChoice)
              .toList(growable: false);

          expect(affordable, isNotEmpty, reason: pending.id);

          final choice = affordable[decisionRandom.nextInt(affordable.length)];
          final resolved = engine.resolveLifeChoice(choice.id);

          expect(resolved.isSuccess, isTrue, reason: pending.id);
          continue;
        }

        final aged = engine.ageUp();

        expect(aged.isSuccess, isTrue, reason: 'Life $seed year $guard.');
      }

      final ending = engine.state.lifeProgress.ending!;
      final stats = engine.state.player.stats;

      expect(stats.health, inInclusiveRange(0, 100));
      expect(stats.happiness, inInclusiveRange(0, 100));
      expect(engine.state.player.money.minorUnits, greaterThanOrEqualTo(0));
      expect(engine.ageUp().isFailure, isTrue);

      deathAges.add(ending.age);
    }

    final average = deathAges.reduce((a, b) => a + b) / deathAges.length;

    expect(average, inInclusiveRange(55, 90));
    expect(deathAges.reduce(max), lessThanOrEqualTo(115));
  });
}
