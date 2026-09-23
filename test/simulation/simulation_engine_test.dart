import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/random/seeded_random.dart';
import '../../lib/core/result/result.dart';
import '../../lib/data/repositories/save_repository.dart';
import '../../lib/domain/character/character.dart';
import '../../lib/domain/time/simulation_clock.dart';
import '../../lib/domain/world/world_state.dart';
import '../../lib/simulation/engine/simulation_engine.dart';

class _MemorySaveRepository implements SaveRepository {
  WorldState? savedState;

  @override
  Future<void> save(WorldState state) async {
    savedState = state;
  }

  @override
  Future<WorldState?> load() async {
    return savedState;
  }

  @override
  Future<void> delete() async {
    savedState = null;
  }
}

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

SimulationEngine createTestEngine() {
  return SimulationEngine(
    initialState: createTestState(),
    random: SeededRandom(12345),
    saveRepository: _MemorySaveRepository(),
  );
}

void main() {
  group('SimulationEngine', () {
    test('creates engine with initial world state', () {
      final engine = createTestEngine();

      expect(engine.state.clock.currentYear, 2026);
      expect(engine.state.player.id, 'player-1');
      expect(engine.state.player.name, 'Test Player');
    });

    test('ageUp advances simulation by exactly one year', () {
      final engine = createTestEngine();

      final result = engine.ageUp();

      expect(result, isA<Success<void>>());
      expect(engine.state.clock.currentYear, 2027);
    });

    test('multiple age ups advance one year at a time', () {
      final engine = createTestEngine();

      final firstResult = engine.ageUp();
      final secondResult = engine.ageUp();
      final thirdResult = engine.ageUp();

      expect(firstResult, isA<Success<void>>());
      expect(secondResult, isA<Success<void>>());
      expect(thirdResult, isA<Success<void>>());

      expect(engine.state.clock.currentYear, 2029);
    });

    test('tick id increments after successful age up', () {
      final engine = createTestEngine();

      expect(engine.nextTickId, 1);

      final firstResult = engine.ageUp();

      expect(firstResult, isA<Success<void>>());
      expect(engine.nextTickId, 2);

      final secondResult = engine.ageUp();

      expect(secondResult, isA<Success<void>>());
      expect(engine.nextTickId, 3);
    });

    test('save stores the current world state', () async {
      final repository = _MemorySaveRepository();

      final engine = SimulationEngine(
        initialState: createTestState(),
        random: SeededRandom(12345),
        saveRepository: repository,
      );

      final ageUpResult = engine.ageUp();

      expect(ageUpResult, isA<Success<void>>());
      expect(engine.state.clock.currentYear, 2027);

      final saveResult = await engine.save();

      expect(saveResult, isA<Success<void>>());
      expect(repository.savedState, isNotNull);
      expect(repository.savedState!.clock.currentYear, 2027);
    });

    test('load restores a valid saved world state', () async {
      final repository = _MemorySaveRepository();

      final firstEngine = SimulationEngine(
        initialState: createTestState(),
        random: SeededRandom(12345),
        saveRepository: repository,
      );

      final ageUpResult = firstEngine.ageUp();

      expect(ageUpResult, isA<Success<void>>());

      final saveResult = await firstEngine.save();

      expect(saveResult, isA<Success<void>>());

      final secondEngine = SimulationEngine(
        initialState: createTestState(),
        random: SeededRandom(54321),
        saveRepository: repository,
      );

      expect(secondEngine.state.clock.currentYear, 2026);

      final loadResult = await secondEngine.load();

      expect(loadResult, isA<Success<void>>());
      expect(secondEngine.state.clock.currentYear, 2027);
    });

    test('load fails when no save exists', () async {
      final repository = _MemorySaveRepository();

      final engine = SimulationEngine(
        initialState: createTestState(),
        random: SeededRandom(12345),
        saveRepository: repository,
      );

      final result = await engine.load();

      expect(result, isA<Failure<void>>());
    });
  });
}
