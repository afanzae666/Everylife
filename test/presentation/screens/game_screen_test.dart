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

Finder saveLoadButtonFinder() =>
    find.byTooltip('Save / Load');

Future<void> openSaveLoadScreen(
  WidgetTester tester,
) async {
  await tester.tap(saveLoadButtonFinder());
  await tester.pumpAndSettle();

  expect(
    find.text('Save / Load'),
    findsOneWidget,
  );
}

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

        expect(
          find.text('Age 0 • 2026')
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
      'displays all 8 core stats',
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

        const statKeys = [
          'health',
          'intelligence',
          'fitness',
          'happiness',
          'willpower',
          'charisma',
          'creativity',
          'luck',
        ];

        for (final key in statKeys) {
          expect(
            find.byKey(
              Key('core-stat-$key'),
            ),
            findsOneWidget,
          );
        }

        for (final label in [
          'Health',
          'Intelligence',
          'Fitness',
          'Happiness',
          'Willpower',
          'Charisma',
          'Creativity',
          'Luck',
        ]) {
          expect(
            find.text(label),
            findsOneWidget,
          );
        }

        expect(
          find.text('Core Stats'),
          findsNothing,
        );

        expect(
          find.text('8 / 8'),
          findsNothing,
        );
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

        expect(
  find.text('Test Player'),
  findsOneWidget,
);

        expect(
  find.text('Born'),
  findsOneWidget,
);
      },
    );

    testWidgets(
      'save load button opens standalone save load screen',
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
          saveLoadButtonFinder(),
          findsOneWidget,
        );

        await openSaveLoadScreen(tester);

        for (final slot in [
          'Autosave',
          'Manual 1',
          'Manual 2',
          'Manual 3',
          'Manual 4',
        ]) {
          expect(
            find.text(slot),
            findsOneWidget,
          );
        }

        expect(
          find.text('Auto Save'),
          findsOneWidget,
        );

        expect(
          find.text('Manual Saves'),
          findsOneWidget,
        );

        expect(
          find.byTooltip('Save'),
          findsNWidgets(4),
        );

        expect(
          find.byTooltip('Load'),
          findsNothing,
        );

        expect(
          find.byTooltip('Delete'),
          findsNothing,
        );

        expect(
          find.byTooltip('Overwrite'),
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
      'manual save persists the slot and returns to Game Screen',
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

        await openSaveLoadScreen(tester);

        expect(
          find.byTooltip('Save'),
          findsNWidgets(4),
        );

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        expect(
          find.text('LIFE SAVED'),
          findsNothing,
        );

        expect(
          find.text('Save / Load'),
          findsNothing,
        );

        expect(
          saveLoadButtonFinder(),
          findsOneWidget,
        );

        final manualSave =
            await repository.load(
          slot: SaveSlot.manual1,
        );

        expect(
          manualSave,
          isNotNull,
        );

        expect(
          manualSave!.state.clock.currentYear,
          2026,
        );

        expect(
          manualSave.state.player.ageAt(
            manualSave.state.clock.currentYear,
          ),
          0,
        );

        expect(
          await repository.load(
            slot: SaveSlot.autosave,
          ),
          isNull,
        );
      },
    );

    testWidgets(
      'manual save changes slot actions to load overwrite and delete',
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

        await openSaveLoadScreen(tester);

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        await openSaveLoadScreen(tester);

        expect(
          find.byTooltip('Save'),
          findsNWidgets(3),
        );

        expect(
          find.byTooltip('Load'),
          findsOneWidget,
        );

        expect(
          find.byTooltip('Overwrite'),
          findsOneWidget,
        );

        expect(
          find.byTooltip('Delete'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'overwrite updates an existing manual slot',
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

        await openSaveLoadScreen(tester);

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        await tester.tap(
          ageUpButtonFinder(),
        );

        await tester.pumpAndSettle();

        await openSaveLoadScreen(tester);

        await tester.tap(
          find.byTooltip('Overwrite'),
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        final saved =
            await repository.load(
          slot: SaveSlot.manual1,
        );

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

    testWidgets(
      'load restores the saved state and returns to Game Screen',
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

        await openSaveLoadScreen(tester);

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        await tester.tap(
          ageUpButtonFinder(),
        );

        await tester.pumpAndSettle();

        expect(
          engine.state.clock.currentYear,
          2027,
        );

        await openSaveLoadScreen(tester);

        final manual1Card = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        expect(
          manual1Card,
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: manual1Card,
            matching: find.byTooltip('Load'),
          ),
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        expect(
          find.text('Save / Load'),
          findsNothing,
        );

        expect(
          saveLoadButtonFinder(),
          findsOneWidget,
        );

        expect(
          engine.state.clock.currentYear,
          2026,
        );

        expect(
          engine.state.player.ageAt(
            engine.state.clock.currentYear,
          ),
          0,
        );
      },
    );

    testWidgets(
      'delete removes a manual save slot',
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

        await openSaveLoadScreen(tester);

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        await openSaveLoadScreen(tester);

        await tester.tap(
          find.byTooltip('Delete'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Delete Save?'),
          findsOneWidget,
        );

        final dialogDelete =
            find.byTooltip('Delete').last;

        await tester.tap(dialogDelete);

        await tester.pumpAndSettle();

        expect(
          find.byTooltip('Save'),
          findsNWidgets(4),
        );

        expect(
          find.byTooltip('Load'),
          findsNothing,
        );

        expect(
          find.byTooltip('Overwrite'),
          findsNothing,
        );

        expect(
          find.byTooltip('Delete'),
          findsNothing,
        );

        expect(
          await repository.load(
            slot: SaveSlot.manual1,
          ),
          isNull,
        );
      },
    );

    testWidgets(
      'auto save can be turned off while manual save remains available',
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

        await openSaveLoadScreen(tester);

        final autoSaveSwitch =
            find.byType(Switch);

        expect(
          autoSaveSwitch,
          findsOneWidget,
        );

        expect(
          tester
              .widget<Switch>(
                autoSaveSwitch,
              )
              .value,
          isTrue,
        );

        await tester.tap(
          autoSaveSwitch,
        );

        await tester.pumpAndSettle();

        expect(
          tester
              .widget<Switch>(
                autoSaveSwitch,
              )
              .value,
          isFalse,
        );

        expect(
          find.byTooltip('Save'),
          findsNWidgets(4),
        );

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        await waitForLifeFeedbackToFinish(
          tester,
        );

        expect(
          await repository.load(
            slot: SaveSlot.manual1,
          ),
          isNotNull,
        );
      },
    );

    testWidgets(
      'age up does not autosave when auto save is off',
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

        await openSaveLoadScreen(tester);

        final autoSaveSwitch =
            find.byType(Switch);

        await tester.tap(
          autoSaveSwitch,
        );

        await tester.pumpAndSettle();

        await tester.pageBack();

        await tester.pumpAndSettle();

        await tester.tap(
          ageUpButtonFinder(),
        );

        await tester.pumpAndSettle();

        expect(
          engine.state.clock.currentYear,
          2027,
        );

        expect(
          await repository.load(
            slot: SaveSlot.autosave,
          ),
          isNull,
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
