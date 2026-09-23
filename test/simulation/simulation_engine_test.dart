import 'package:flutter_test/flutter_test.dart';

import 'package:life_simulation_game/core/result/result.dart';
import 'package:life_simulation_game/data/repositories/save_repository.dart';
import 'package:life_simulation_game/domain/character/character.dart';
import 'package:life_simulation_game/simulation/engine/simulation_engine.dart';
import 'package:life_simulation_game/simulation/systems/character_system.dart';
import 'package:life_simulation_game/simulation/systems/event_system.dart';
import 'package:life_simulation_game/simulation/systems/time_system.dart';

void main() {
  SimulationEngine createEngine() {
    final player = Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: 2026,
    );

    final engine = SimulationEngine.create(
      player: player,
      seed: 12345,
      saveRepository: InMemorySaveRepository(),
    );

    engine.registerSystem(TimeSystem());
    engine.registerSystem(CharacterSystem());
    engine.registerSystem(
      EventSystem(
        random: engine.random,
      ),
    );

    return engine;
  }

  test('new life starts at age zero', () {
    final engine = createEngine();

    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      0,
    );
  });

  test('age up advances exactly one year', () {
    final engine = createEngine();

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
  });

  test('age up can be repeated', () {
    final engine = createEngine();

    for (var i = 0; i < 10; i++) {
      final result = engine.ageUp();

      expect(
        result,
        isA<Success<void>>(),
      );
    }

    expect(
      engine.state.clock.currentYear,
      2036,
    );

    expect(
      engine.state.player.ageAt(
        engine.state.clock.currentYear,
      ),
      10,
    );
  });

  test('simulation creates character aging events', () {
    final engine = createEngine();

    engine.ageUp();

    expect(
      engine.state.events.any(
        (event) =>
            event.type.name == 'characterAged',
      ),
      isTrue,
    );
  });

  test('save and load restore simulation state', () async {
    final repository = InMemorySaveRepository();

    final player = Character.create(
      id: 'player-1',
      name: 'Save Test',
      birthYear: 2026,
    );

    final engine = SimulationEngine.create(
      player: player,
      seed: 999,
      saveRepository: repository,
    );

    engine.registerSystem(TimeSystem());
    engine.registerSystem(CharacterSystem());
    engine.registerSystem(
      EventSystem(
        random: engine.random,
      ),
    );

    engine.ageUp();
    await engine.save();

    engine.ageUp();

    expect(
      engine.state.clock.currentYear,
      2028,
    );

    await engine.load();

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
  });
}
