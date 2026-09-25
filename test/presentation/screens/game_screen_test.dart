import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/random/seeded_random.dart';
import '../../../lib/data/repositories/save_repository.dart';
import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/time/simulation_clock.dart';
import '../../../lib/domain/world/world_state.dart';
import '../../../lib/presentation/screens/game_screen.dart';
import '../../../lib/simulation/engine/simulation_engine.dart';

SimulationEngine createTestEngine(
  InMemorySaveRepository repository,
) {
  final state = WorldState(
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

  return SimulationEngine(
    initialState: state,
    random: SeededRandom(12345),
    saveRepository: repository,
  );
}

void main() {
  group('GameScreen autosave', () {
    testWidgets(
      'age up automatically saves the new year',
      (tester) async {
        final repository = InMemorySaveRepository();

        final engine = createTestEngine(
          repository,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Year 2026'),
          findsOneWidget,
        );

        expect(
          find.text('Age 0'),
          findsOneWidget,
        );

        await tester.tap(
          find.text('AGE UP'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Year 2027'),
          findsOneWidget,
        );

        expect(
          find.text('Age 1'),
          findsOneWidget,
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
          saved.state.player.ageAt(
            saved.state.clock.currentYear,
          ),
          1,
        );

        expect(
          saved.nextTickId,
          2,
        );
      },
    );

    testWidgets(
      'age up autosave preserves random state',
      (tester) async {
        final repository = InMemorySaveRepository();

        final engine = createTestEngine(
          repository,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        engine.random.nextInt(1000);

        final expectedRandomState =
            engine.random.state;

        await tester.tap(
          find.text('AGE UP'),
        );

        await tester.pumpAndSettle();

        final saved = await repository.load();

        expect(
          saved,
          isNotNull,
        );

        expect(
          saved!.randomState,
          expectedRandomState,
        );
      },
    );

    testWidgets(
      'prevents repeated age up while autosaving',
      (tester) async {
        final repository = InMemorySaveRepository();

        final engine = createTestEngine(
          repository,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final ageUpButton = find.text('AGE UP');

        await tester.tap(ageUpButton);

        await tester.pump();

        await tester.pumpAndSettle();

        expect(
          engine.state.clock.currentYear,
          2027,
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
      },
    );
  });
}
