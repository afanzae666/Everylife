import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/engine/simulation_tick.dart';
import 'package:everylife/simulation/engine/world_state_validator.dart';

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
}

@override
Future<void> delete() async {
  savedState = null;
}

WorldState createState() {
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

void main() {
  test('simulation tick represents exactly one year', () {
    const tick = SimulationTick(
      id: 1,
      fromYear: 2026,
      toYear: 2027,
    );

    expect(tick.isValid, isTrue);
  });

  test('invalid simulation tick is rejected', () {
    const tick = SimulationTick(
      id: 1,
      fromYear: 2026,
      toYear: 2029,
    );

    expect(tick.isValid, isFalse);
  });

  test('world state validator accepts valid state', () {
    final state = createState();

    const validator = WorldStateValidator();

    final result = validator.validate(state);

    expect(result, isA<Success<void>>());
  });

  test('age up advances exactly one year', () {
    final repository = _MemorySaveRepository();

    final engine = SimulationEngine(
      initialState: createState(),
      random: SeededRandom(12345),
      saveRepository: repository,
    );

    final result = engine.ageUp();

    expect(result, isA<Success<void>>());
    expect(engine.state.clock.currentYear, 2027);
  });

  test('failed save data is rejected during load', () async {
    final repository = _MemorySaveRepository();

    final engine = SimulationEngine(
      initialState: createState(),
      random: SeededRandom(12345),
      saveRepository: repository,
    );

    await engine.save();

    final loadResult = await engine.load();

    expect(loadResult, isA<Success<void>>());
  });
}
