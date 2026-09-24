import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

WorldState createTestState() {
  return WorldState(
    clock: const SimulationClock(
      currentYear: 2026,
    ),
    player: Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: 2026,
    ),
    events: const [],
  );
}

SimulationEngine createTestEngine({
  required SaveRepository saveRepository,
  int seed = 12345,
}) {
  return SimulationEngine(
    initialState: createTestState(),
    random: SeededRandom(seed),
    saveRepository: saveRepository,
  );
}

void main() {
  group('SimulationEngine', () {
    test(
      'creates engine with initial world state',
      () {
        final engine = createTestEngine(
          saveRepository: InMemorySaveRepository(),
        );

        expect(
          engine.state.clock.currentYear,
          2026,
        );

        expect(
          engine.state.player.id,
          'player-1',
        );

        expect(
          engine.state.player.name,
          'Test Player',
        );

        expect(
          engine.nextTickId,
          1,
        );
      },
    );

    test(
      'ageUp advances simulation by exactly one year',
      () {
        final engine = createTestEngine(
          saveRepository: InMemorySaveRepository(),
        );

        final result = engine.ageUp();

        expect(
          result,
          isA<Success<void>>(),
        );

        expect(
          engine.state.clock.currentYear,
          2027,
        );
      },
    );

    test(
      'multiple age ups advance one year at a time',
      () {
        final engine = createTestEngine(
          saveRepository: InMemorySaveRepository(),
        );

        final firstResult = engine.ageUp();
        final secondResult = engine.ageUp();
        final thirdResult = engine.ageUp();

        expect(
          firstResult,
          isA<Success<void>>(),
        );

        expect(
          secondResult,
          isA<Success<void>>(),
        );

        expect(
          thirdResult,
          isA<Success<void>>(),
        );

        expect(
          engine.state.clock.currentYear,
          2029,
        );
      },
    );

    test(
      'tick id increments after successful age up',
      () {
        final engine = createTestEngine(
          saveRepository: InMemorySaveRepository(),
        );

        expect(
          engine.nextTickId,
          1,
        );

        final firstResult = engine.ageUp();

        expect(
          firstResult,
          isA<Success<void>>(),
        );

        expect(
          engine.nextTickId,
          2,
        );

        final secondResult = engine.ageUp();

        expect(
          secondResult,
          isA<Success<void>>(),
        );

        expect(
          engine.nextTickId,
          3,
        );
      },
    );

    test(
      'save stores the current world and engine state',
      () async {
        final repository = InMemorySaveRepository();

        final engine = createTestEngine(
          saveRepository: repository,
        );

        final ageUpResult = engine.ageUp();

        expect(
          ageUpResult,
          isA<Success<void>>(),
        );

        final randomValue = engine.random.nextInt(1000);

        final saveResult = await engine.save();

        expect(
          saveResult,
          isA<Success<void>>(),
        );

        final saved = await repository.load();

        expect(
          saved,
          isNotNull,
        );

        expect(
          saved!.state.clock.currentYear,
          2027,
        );

        expect(
          saved.nextTickId,
          2,
        );

        expect(
          saved.randomState,
          engine.random.state,
        );

        expect(
          randomValue,
          greaterThanOrEqualTo(0),
        );
      },
    );

    test(
      'load restores the saved world and engine metadata',
      () async {
        final repository = InMemorySaveRepository();

        final firstEngine = createTestEngine(
          saveRepository: repository,
        );

        final ageUpResult = firstEngine.ageUp();

        expect(
          ageUpResult,
          isA<Success<void>>(),
        );

        firstEngine.random.nextInt(1000);

        final saveResult = await firstEngine.save();

        expect(
          saveResult,
          isA<Success<void>>(),
        );

        final secondEngine = createTestEngine(
          saveRepository: repository,
          seed: 54321,
        );

        expect(
          secondEngine.state.clock.currentYear,
          2026,
        );

        expect(
          secondEngine.nextTickId,
          1,
        );

        final loadResult = await secondEngine.load();

        expect(
          loadResult,
          isA<Success<void>>(),
        );

        expect(
          secondEngine.state.clock.currentYear,
          2027,
        );

        expect(
          secondEngine.nextTickId,
          firstEngine.nextTickId,
        );

        expect(
          secondEngine.random.state,
          firstEngine.random.state,
        );
      },
    );

    test(
      'load restores random sequence continuation',
      () async {
        final repository = InMemorySaveRepository();

        final firstEngine = createTestEngine(
          saveRepository: repository,
          seed: 12345,
        );

        firstEngine.random.nextInt(1000);

        final saveResult = await firstEngine.save();

        expect(
          saveResult,
          isA<Success<void>>(),
        );

        final secondEngine = createTestEngine(
          saveRepository: repository,
          seed: 99999,
        );

        final loadResult = await secondEngine.load();

        expect(
          loadResult,
          isA<Success<void>>(),
        );

        final firstNextValue =
            firstEngine.random.nextInt(1000000);

        final secondNextValue =
            secondEngine.random.nextInt(1000000);

        expect(
          secondNextValue,
          firstNextValue,
        );
      },
    );

    test(
      'load fails when no save exists',
      () async {
        final repository = InMemorySaveRepository();

        final engine = createTestEngine(
          saveRepository: repository,
        );

        final result = await engine.load();

        expect(
          result,
          isA<Failure<void>>(),
        );
      },
    );
  });
}
