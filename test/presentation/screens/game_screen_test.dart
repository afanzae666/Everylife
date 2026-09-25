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

Finder ageUpButtonFinder() {
  return find.widgetWithText(
    FilledButton,
    'AGE UP',
  );
}

Future<void> scrollToBottom(
  WidgetTester tester,
) async {
  final screenSize = tester.view.physicalSize /
      tester.view.devicePixelRatio;

  final center = Offset(
    screenSize.width / 2,
    screenSize.height / 2,
  );

  for (var i = 0; i < 5; i++) {
    await tester.drag(
      find.byType(Scaffold),
      const Offset(0, -700),
    );

    await tester.pumpAndSettle();
  }

  // Keep the helper deterministic even if the test
  // environment uses a different viewport size.
  await tester.dragFrom(
    center,
    const Offset(0, -300),
  );

  await tester.pumpAndSettle();
}

Future<void> scrollToAgeUp(
  WidgetTester tester,
) async {
  await scrollToBottom(tester);

  expect(
    ageUpButtonFinder(),
    findsOneWidget,
  );
}

Future<void> scrollToLifeEvents(
  WidgetTester tester,
) async {
  await scrollToBottom(tester);

  expect(
    find.text('Life Events'),
    findsOneWidget,
  );
}

void main() {
  group('GameScreen', () {
    testWidgets(
      'displays character information',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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
          find.text('Test Player'),
          findsOneWidget,
        );

        expect(
          find.text('Age 0'),
          findsOneWidget,
        );

        expect(
          find.text('Year 2026'),
          findsOneWidget,
        );

        expect(
          find.text('Life Stage: Infant'),
          findsOneWidget,
        );

        expect(
          find.text('\$0.00'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays all 8 core stats in separate card',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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
          find.text('Core Stats'),
          findsOneWidget,
        );

        expect(
          find.text('Health'),
          findsOneWidget,
        );

        expect(
          find.text('Intelligence'),
          findsOneWidget,
        );

        expect(
          find.text('Fitness'),
          findsOneWidget,
        );

        expect(
          find.text('Happiness'),
          findsOneWidget,
        );

        expect(
          find.text('Willpower'),
          findsOneWidget,
        );

        expect(
          find.text('Charisma'),
          findsOneWidget,
        );

        expect(
          find.text('Creativity'),
          findsOneWidget,
        );

        expect(
          find.text('Luck'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'character avatar is clickable',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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

        final avatar = find.byKey(
          const Key('character-avatar'),
        );

        expect(
          avatar,
          findsOneWidget,
        );

        await tester.tap(avatar);

        await tester.pumpAndSettle();

        expect(
          find.text('Basic Information'),
          findsOneWidget,
        );

        expect(
          find.text('Test Player'),
          findsNWidgets(2),
        );

        expect(
          find.text('Birth Year'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'game data button opens save and load menu',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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

        final gameDataButton = find.byTooltip(
          'Game Data',
        );

        expect(
          gameDataButton,
          findsOneWidget,
        );

        await tester.tap(gameDataButton);

        await tester.pumpAndSettle();

        expect(
          find.text('Save Game'),
          findsOneWidget,
        );

        expect(
          find.text('Load Game'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'life events is a separate card',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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

        await scrollToLifeEvents(tester);

        expect(
          find.text('Life Events'),
          findsOneWidget,
        );

        expect(
          find.text('Life Panel'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'age up automatically saves the new year',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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

        await scrollToAgeUp(tester);

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        await tester.tap(ageUpButton);

        await tester.pumpAndSettle();

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

        final saved =
            await repository.load();

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
        final repository =
            InMemorySaveRepository();

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

        await scrollToAgeUp(tester);

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        await tester.tap(ageUpButton);

        await tester.pumpAndSettle();

        final saved =
            await repository.load();

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
      'does not show autosave success notification',
      (tester) async {
        final repository =
            InMemorySaveRepository();

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

        await scrollToAgeUp(tester);

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        await tester.tap(ageUpButton);

        await tester.pumpAndSettle();

        expect(
          find.text(
            'Year advanced and game saved.',
          ),
          findsNothing,
        );
      },
    );
  });
}
