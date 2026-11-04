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

Finder ageUpButtonFinder() =>
    find.byKey(const Key('bottom-nav-age-up'));

Future<void> waitForLifeFeedbackToFinish(
  WidgetTester tester,
) async {
  await tester.pump(
    const Duration(
      milliseconds: 1000,
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('GameScreen', () {
    testWidgets(
      'displays character information',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

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

        // Once as the life stage, once as the first bottom tab (ages 0-5).
        expect(
          find.text('Infant'),
          findsNWidgets(2),
        );

        expect(
  find.text('\$0'),
  findsOneWidget,
);
      },
    );

    testWidgets(
      'displays the four main stats and hides the rest behind a tap',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        for (final key in [
          'happiness',
          'health',
          'intelligence',
          'looks',
        ]) {
          expect(
            find.byKey(
              Key('core-stat-$key'),
            ),
            findsOneWidget,
          );
        }

        for (final label in [
          'Happiness',
          'Health',
          'Smarts',
          'Looks',
        ]) {
          expect(
            find.text(label),
            findsOneWidget,
          );
        }

        // The other traits are not on the main screen.
        for (final label in [
          'Fitness',
          'Willpower',
          'Charisma',
          'Creativity',
          'Luck',
        ]) {
          expect(
            find.text(label),
            findsNothing,
          );
        }

        await tester.tap(
          find.byKey(const Key('core-stat-happiness')),
        );
        await tester.pumpAndSettle();

        expect(find.text('My Traits'), findsOneWidget);
        expect(find.text('Fitness'), findsOneWidget);
        expect(find.text('Luck'), findsNothing);

        await tester.tap(find.text('Tap anywhere to close'));
        await tester.pumpAndSettle();

        expect(find.text('My Traits'), findsNothing);
      },
    );

    testWidgets(
      'character avatar opens character profile',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

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

        final profileName = find.descendant(
  of: find.byType(Dialog),
  matching: find.text('Test Player'),
);

expect(
  profileName,
  findsOneWidget,
);

        expect(
          find.text('Born'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'age up automatically saves the new year',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final ageUp =
            ageUpButtonFinder();

        expect(
          ageUp,
          findsOneWidget,
        );

        await tester.tap(ageUp);
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

        final engine =
            createTestEngine(repository);

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
          ageUpButtonFinder(),
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
      'autosave does not show a success notification',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(
          ageUpButtonFinder(),
        );

        await tester.pumpAndSettle();

        expect(
          find.text(
            'Year advanced and game saved.',
          ),
          findsNothing,
        );

        expect(
          find.text(
            'Year advanced, but autosave failed.',
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'age up button is visible without scrolling',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              engine: engine,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final ageUp =
            ageUpButtonFinder();

        expect(
          ageUp,
          findsOneWidget,
        );

        expect(
          tester.getBottomRight(ageUp).dy,
          lessThanOrEqualTo(
            tester.view.physicalSize.height /
                tester.view.devicePixelRatio,
          ),
        );
      },
    );

    testWidgets(
      'life events card has no title or numbering',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final engine =
            createTestEngine(repository);

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

        expect(
          find.text('No.'),
          findsNothing,
        );
      },
    );
  });
}
