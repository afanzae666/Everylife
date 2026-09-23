import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/result/result.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/engine/simulation_scheduler.dart';
import 'package:everylife/simulation/systems/simulation_system.dart';

class _TestSystem implements SimulationSystem {
  _TestSystem({
    required this.systemId,
    required this.systemPriority,
    required this.onProcess,
  });

  final String systemId;
  final int systemPriority;
  final WorldState Function(WorldState state) onProcess;

  @override
  String get id => systemId;

  @override
  int get priority => systemPriority;

  @override
  WorldState process({
    required WorldState state,
    required command,
  }) {
    return onProcess(state);
  }
}

WorldState createState() {
  return WorldState(
    clock: const SimulationClock(currentYear: 2026),
    player: Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: 2026,
    ),
    events: const [],
  );
}

void main() {
  test('systems execute according to priority', () {
    final executionOrder = <String>[];

    final scheduler = SimulationScheduler(
      systems: [
        _TestSystem(
          systemId: 'second',
          systemPriority: 200,
          onProcess: (state) {
            executionOrder.add('second');
            return state;
          },
        ),
        _TestSystem(
          systemId: 'first',
          systemPriority: 100,
          onProcess: (state) {
            executionOrder.add('first');
            return state;
          },
        ),
      ],
    );

    final result = scheduler.execute(
      state: createState(),
      command: const AgeUpCommand(),
    );

    expect(result, isA<Success<WorldState>>());

    expect(
      executionOrder,
      ['first', 'second'],
    );
  });

  test('duplicate system ids are rejected', () {
    final scheduler = SimulationScheduler(
      systems: [
        _TestSystem(
          systemId: 'duplicate',
          systemPriority: 100,
          onProcess: (state) => state,
        ),
      ],
    );

    expect(
      () => scheduler.registerSystem(
        _TestSystem(
          systemId: 'duplicate',
          systemPriority: 200,
          onProcess: (state) => state,
        ),
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('successful execution returns a new state', () {
    final initialState = createState();

    final scheduler = SimulationScheduler(
      systems: [
        _TestSystem(
          systemId: 'change-year',
          systemPriority: 100,
          onProcess: (state) {
            return state.copyWith(
              clock: state.clock.advanceYear(),
            );
          },
        ),
      ],
    );

    final result = scheduler.execute(
      state: initialState,
      command: const AgeUpCommand(),
    );

    expect(result, isA<Success<WorldState>>());

    final success = result as Success<WorldState>;

    expect(
      success.value.clock.currentYear,
      2027,
    );

    expect(
      initialState.clock.currentYear,
      2026,
    );
  });

  test('failed system does not return a partially committed state', () {
    final initialState = createState();

    final scheduler = SimulationScheduler(
      systems: [
        _TestSystem(
          systemId: 'successful-system',
          systemPriority: 100,
          onProcess: (state) {
            return state.copyWith(
              clock: state.clock.advanceYear(),
            );
          },
        ),
        _TestSystem(
          systemId: 'failing-system',
          systemPriority: 200,
          onProcess: (state) {
            throw StateError('Intentional test failure');
          },
        ),
      ],
    );

    final result = scheduler.execute(
      state: initialState,
      command: const AgeUpCommand(),
    );

    expect(result, isA<Failure<WorldState>>());

    expect(
      initialState.clock.currentYear,
      2026,
    );
  });
}
