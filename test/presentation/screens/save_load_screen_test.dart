import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/result/result.dart';
import '../../../lib/data/repositories/save_repository.dart';
import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/time/simulation_clock.dart';
import '../../../lib/domain/world/world_state.dart';
import '../../../lib/presentation/screens/save_load_screen.dart';

WorldState createTestState({
  int year = 2026,
}) {
  return WorldState(
    clock: SimulationClock(
      currentYear: year,
    ),
    player: Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: 2026,
    ),
    events: const [],
  );
}

Future<void> pumpSaveLoadScreen(
  WidgetTester tester, {
  required ValueNotifier<bool> autoSaveController,
  required Future<SaveData?> Function(SaveSlot slot) onRead,
  required Future<Result<void>> Function(SaveSlot slot) onSave,
  required Future<Result<void>> Function(SaveSlot slot) onLoad,
  required Future<Result<void>> Function(SaveSlot slot) onDelete,
  VoidCallback? onGameStateChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SaveLoadScreen(
        zoom: 1.0,
        autoSaveController: autoSaveController,
        onRead: onRead,
        onSave: onSave,
        onLoad: onLoad,
        onDelete: onDelete,
        onGameStateChanged:
            onGameStateChanged ?? () {},
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> finishLifeFeedback(
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
  group('SaveLoadScreen', () {
    late InMemorySaveRepository repository;
    late WorldState state;
    late ValueNotifier<bool> autoSaveController;

    setUp(() {
      repository = InMemorySaveRepository();
      state = createTestState();
      autoSaveController = ValueNotifier<bool>(true);
    });

    tearDown(() {
      autoSaveController.dispose();
    });

    testWidgets(
      'shows autosave and all four manual slots',
      (tester) async {
        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Failure(
              'Not used in this test.',
            );
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        expect(
          find.text('Save / Load'),
          findsOneWidget,
        );

        expect(
          find.text('Auto Save'),
          findsOneWidget,
        );

        expect(
          find.text('Manual Saves'),
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
          find.text('Empty'),
          findsNWidgets(5),
        );
      },
    );

    testWidgets(
      'empty manual slots show save actions only',
      (tester) async {
        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Failure(
              'Not used in this test.',
            );
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
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
          find.byTooltip('Overwrite'),
          findsNothing,
        );

        expect(
          find.byTooltip('Delete'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'saving Manual 1 shows feedback and fills the slot',
      (tester) async {
        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Failure(
              'Not used in this test.',
            );
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        final manual1 = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        expect(
          manual1,
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Save'),
          ),
        );

        await tester.pump();

        expect(
          find.text('LIFE SAVED'),
          findsOneWidget,
        );

        expect(
          find.text(
            'Your story has been safely preserved.',
          ),
          findsOneWidget,
        );

        await finishLifeFeedback(tester);

        expect(
          find.text('LIFE SAVED'),
          findsNothing,
        );

        final saved =
            await repository.load(
          slot: SaveSlot.manual1,
        );

        expect(
          saved,
          isNotNull,
        );
      },
    );

    testWidgets(
      'filled manual slot shows load overwrite and delete',
      (tester) async {
        await repository.save(
          state,
          randomState: 12345,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        final manual1 = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        expect(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Save'),
          ),
          findsNothing,
        );

        expect(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Load'),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Overwrite'),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Delete'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'filled slot displays age year money and saved metadata',
      (tester) async {
        await repository.save(
          state,
          randomState: 12345,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        expect(
          find.textContaining('Age 0'),
          findsOneWidget,
        );

        expect(
          find.textContaining('Year 2026'),
          findsOneWidget,
        );

        expect(
          find.textContaining('Money'),
          findsOneWidget,
        );

        expect(
          find.textContaining('Saved '),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'loading a manual save calls load callback and returns feedback',
      (tester) async {
        await repository.save(
          state,
          randomState: 12345,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        var loadCalled = false;
        var gameStateChanged = false;

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (slot) async {
            loadCalled = true;

            final data =
                await repository.load(
              slot: slot,
            );

            if (data == null) {
              return const Failure(
                'No save data exists.',
              );
            }

            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
          onGameStateChanged: () {
            gameStateChanged = true;
          },
        );

        final manual1 = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Load'),
          ),
        );

        await tester.pump();

        expect(
          loadCalled,
          isTrue,
        );

        expect(
          gameStateChanged,
          isTrue,
        );

        expect(
          find.text('LIFE RESTORED'),
          findsOneWidget,
        );

        expect(
          find.text('Your story continues.'),
          findsOneWidget,
        );

        await finishLifeFeedback(tester);

        expect(
          find.text('LIFE RESTORED'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'delete confirmation removes the manual save',
      (tester) async {
        await repository.save(
          state,
          randomState: 12345,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        final manual1 = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Delete'),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Delete Save?'),
          findsOneWidget,
        );

        expect(
          find.text(
            'Delete Manual 1 permanently?',
          ),
          findsOneWidget,
        );

        final dialogDelete =
            find.byTooltip('Delete').last;

        await tester.tap(dialogDelete);

        await tester.pumpAndSettle();

        expect(
          await repository.load(
            slot: SaveSlot.manual1,
          ),
          isNull,
        );

        expect(
          find.text('Empty'),
          findsNWidgets(5),
        );
      },
    );

    testWidgets(
      'canceling delete keeps the manual save',
      (tester) async {
        await repository.save(
          state,
          randomState: 12345,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        final manual1 = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Delete'),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Delete Save?'),
          findsOneWidget,
        );

        await tester.tap(
          find.byTooltip('Cancel'),
        );

        await tester.pumpAndSettle();

        expect(
          await repository.load(
            slot: SaveSlot.manual1,
          ),
          isNotNull,
        );

        expect(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Load'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'autosave switch can be turned off without affecting manual saves',
      (tester) async {
        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

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
      },
    );

    testWidgets(
      'manual saves remain independent from each other',
      (tester) async {
        await repository.save(
          state,
          randomState: 111,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        await repository.save(
          createTestState(year: 2030),
          randomState: 222,
          nextTickId: 5,
          slot: SaveSlot.manual2,
        );

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        expect(
          find.byTooltip('Load'),
          findsNWidgets(2),
        );

        expect(
          find.byTooltip('Overwrite'),
          findsNWidgets(2),
        );

        expect(
          find.byTooltip('Delete'),
          findsNWidgets(2),
        );

        final manual1 =
            await repository.load(
          slot: SaveSlot.manual1,
        );

        final manual2 =
            await repository.load(
          slot: SaveSlot.manual2,
        );

        expect(
          manual1!.state.clock.currentYear,
          2026,
        );

        expect(
          manual2!.state.clock.currentYear,
          2030,
        );

        expect(
          manual1.randomState,
          111,
        );

        expect(
          manual2.randomState,
          222,
        );
      },
    );

    testWidgets(
      'save failure keeps the screen open',
      (tester) async {
        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (_) async {
            return const Failure(
              'Save failed.',
            );
          },
          onLoad: (_) async {
            return const Success(null);
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        await tester.tap(
          find.byTooltip('Save').first,
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Save / Load'),
          findsOneWidget,
        );

        expect(
          find.text('Save failed.'),
          findsOneWidget,
        );

        expect(
          find.text('LIFE SAVED'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'load failure keeps the screen open',
      (tester) async {
        await repository.save(
          state,
          randomState: 12345,
          nextTickId: 1,
          slot: SaveSlot.manual1,
        );

        await pumpSaveLoadScreen(
          tester,
          autoSaveController: autoSaveController,
          onRead: repository.load,
          onSave: (slot) async {
            await repository.save(
              state,
              randomState: 12345,
              nextTickId: 1,
              slot: slot,
            );

            return const Success(null);
          },
          onLoad: (_) async {
            return const Failure(
              'Load failed.',
            );
          },
          onDelete: (slot) async {
            await repository.delete(
              slot: slot,
            );

            return const Success(null);
          },
        );

        final manual1 = find.ancestor(
          of: find.text('Manual 1'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: manual1,
            matching: find.byTooltip('Load'),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Save / Load'),
          findsOneWidget,
        );

        expect(
          find.text('Load failed.'),
          findsOneWidget,
        );

        expect(
          find.text('LIFE RESTORED'),
          findsNothing,
        );
      },
    );
  });
}
