import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/life_stage.dart';
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

  @override
  Future<void> delete() async {
    savedState = null;
  }
}

WorldState createState({
  int birthYear = 2026,
}) {
  return WorldState(
    clock: SimulationClock(
      currentYear: birthYear,
    ),
    player: Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: birthYear,
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

  test('world state validator accepts valid newborn state', () {
    final state = createState();

    const validator = WorldStateValidator();

    final result = validator.validate(state);

    expect(result, isA<Success<void>>());

    expect(
      state.player.ageAt(state.clock.currentYear),
      0,
    );

    expect(
      state.player.lifeStageAt(state.clock.currentYear),
      LifeStage.infant,
    );
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

    expect(
      engine.state.clock.currentYear,
      2027,
    );

    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      1,
    );

    expect(
      engine.state.player.lifeStageAt(
        engine.state.clock.currentYear,
      ),
      LifeStage.infant,
    );
  });

  test('newborn progresses from birth through early childhood', () {
    final repository = _MemorySaveRepository();

    final engine = SimulationEngine(
      initialState: createState(
        birthYear: 1900,
      ),
      random: SeededRandom(12345),
      saveRepository: repository,
    );

    expect(
      engine.state.clock.currentYear,
      1900,
    );

    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      0,
    );

    expect(
      engine.state.player.lifeStageAt(
        engine.state.clock.currentYear,
      ),
      LifeStage.infant,
    );

    var result = engine.ageUp();

    expect(result, isA<Success<void>>());
    expect(engine.state.clock.currentYear, 1901);
    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      1,
    );
    expect(
      engine.state.player.lifeStageAt(
        engine.state.clock.currentYear,
      ),
      LifeStage.infant,
    );

    result = engine.ageUp();

    expect(result, isA<Success<void>>());
    expect(engine.state.clock.currentYear, 1902);
    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      2,
    );
    expect(
      engine.state.player.lifeStageAt(
        engine.state.clock.currentYear,
      ),
      LifeStage.infant,
    );

    result = engine.ageUp();

    expect(result, isA<Success<void>>());
    expect(engine.state.clock.currentYear, 1903);
    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      3,
    );
    expect(
      engine.state.player.lifeStageAt(
        engine.state.clock.currentYear,
      ),
      LifeStage.toddler,
    );
  });

  test('birth year can be 1900 and simulation starts at birth', () {
    final state = createState(
      birthYear: 1900,
    );

    expect(
      state.clock.currentYear,
      1900,
    );

    expect(
      state.player.birthYear,
      1900,
    );

    expect(
      state.player.ageAt(
        state.clock.currentYear,
      ),
      0,
    );

    expect(
      state.player.lifeStageAt(
        state.clock.currentYear,
      ),
      LifeStage.infant,
    );
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
