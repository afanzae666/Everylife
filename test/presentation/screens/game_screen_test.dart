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
  return find.byKey(
    const Key('bottom-nav-age-up'),
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
          find.text('Infant'),
          findsOneWidget,
        );

        expect(
          find.text('\$0.00'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays all 8 core stats in 4 by 2 layout',
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
          findsNothing,
        );

        expect(
          find.byKey(
            const Key('core-stat-health'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-intelligence'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-fitness'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-happiness'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-willpower'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-charisma'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-creativity'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const Key('core-stat-luck'),
          ),
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
      'does not display core stat count',
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
          find.text('8 / 8'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'does not display life event count',
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
          find.text('0'),
          findsNothing,
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
      'save manager button opens save manager',
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

        final saveManagerButton =
            find.byTooltip(
          'Save Manager',
        );

        expect(
          saveManagerButton,
          findsOneWidget,
        );

        await tester.tap(
          saveManagerButton,
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Save Manager'),
          findsOneWidget,
        );

        expect(
          find.text('Autosave'),
          findsOneWidget,
        );

        expect(
          find.text('Manual 1'),
          findsOneWidget,
        );

        expect(
          find.text('Manual 2'),
          findsOneWidget,
        );

        expect(
          find.text('Manual 3'),
          findsOneWidget,
        );

        expect(
          find.text('Manual 4'),
          findsOneWidget,
        );

        expect(
          find.byTooltip('Save'),
          findsNWidgets(5),
        );

        expect(
          find.byTooltip('Load'),
          findsNWidgets(5),
        );

        expect(
          find.byTooltip('Delete'),
          findsNWidgets(5),
        );
      },
    );

    testWidgets(
      'life events card does not display a title',
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
          find.text('Life Events'),
          findsNothing,
        );

        expect(
          find.text('Life Panel'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'age up button is visible without scrolling',
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

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        expect(
          tester.getBottomRight(
            ageUpButton,
          ).dy,
          lessThanOrEqualTo(
            tester.view.physicalSize.height /
                tester.view.devicePixelRatio,
          ),
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

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        await tester.tap(
          ageUpButton,
        );

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

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        await tester.tap(
          ageUpButton,
        );

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

        final ageUpButton =
            ageUpButtonFinder();

        expect(
          ageUpButton,
          findsOneWidget,
        );

        await tester.tap(
          ageUpButton,
        );

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
