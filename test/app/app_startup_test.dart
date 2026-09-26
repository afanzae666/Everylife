import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/app/app.dart';
import '../../lib/app/app_dependencies.dart';
import '../../lib/data/repositories/save_repository.dart';
import '../../lib/domain/character/character.dart';
import '../../lib/domain/time/simulation_clock.dart';
import '../../lib/domain/world/world_state.dart';
import '../../lib/presentation/screens/character_creation_screen.dart';
import '../../lib/presentation/screens/game_screen.dart';

void main() {
  group('LifeSimulationApp startup', () {
    testWidgets(
      'starts on character creation when no save exists',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        await tester.pumpWidget(
          LifeSimulationApp(
            dependencies: AppDependencies(
              saveRepository: repository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Create Character'),
          findsOneWidget,
        );

        expect(
          find.text('Create Your Character'),
          findsOneWidget,
        );

        expect(
          find.byType(
            CharacterCreationScreen,
          ),
          findsOneWidget,
        );

        expect(
          find.text('Birth Year'),
          findsOneWidget,
        );

        expect(
          find.text('BEGIN LIFE'),
          findsOneWidget,
        );

        expect(
          await repository.load(),
          isNull,
        );
      },
    );

    testWidgets(
      'creates a newborn character and autosaves it',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        await tester.pumpWidget(
          LifeSimulationApp(
            dependencies: AppDependencies(
              saveRepository: repository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final textFields =
            find.byType(TextField);

        expect(
          textFields,
          findsNWidgets(2),
        );

        await tester.enterText(
          textFields.at(0),
          'Marshall',
        );

        await tester.enterText(
          textFields.at(1),
          'Royce',
        );

        final beginLifeButton =
            find.text('BEGIN LIFE');

        await tester.scrollUntilVisible(
          beginLifeButton,
          200,
          scrollable:
              find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        await tester.tap(
          beginLifeButton,
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(GameScreen),
          findsOneWidget,
        );

        expect(
          find.text('Marshall Royce'),
          findsOneWidget,
        );

        expect(
          find.text('Life Simulation'),
          findsOneWidget,
        );

        final saved =
            await repository.load();

        expect(
          saved,
          isNotNull,
        );

        expect(
          saved!.state.player.name,
          'Marshall Royce',
        );

        expect(
          saved.state.player.firstName,
          'Marshall',
        );

        expect(
          saved.state.player.lastName,
          'Royce',
        );

        expect(
          saved.state.clock.currentYear,
          saved.state.player.birthYear,
        );

        expect(
          saved.nextTickId,
          1,
        );
      },
    );

    testWidgets(
      'loads an existing save and opens the game',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final savedState =
            WorldState(
          clock: const SimulationClock(
            currentYear: 2050,
          ),
          player: Character.create(
            id: 'saved-player',
            firstName: 'Saved',
            lastName: 'Character',
            birthYear: 2030,
          ),
          events: const [],
        );

        await repository.save(
          savedState,
          randomState: 123456,
          nextTickId: 25,
        );

        await tester.pumpWidget(
          LifeSimulationApp(
            dependencies: AppDependencies(
              saveRepository: repository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(GameScreen),
          findsOneWidget,
        );

        expect(
          find.byType(
            CharacterCreationScreen,
          ),
          findsNothing,
        );

        expect(
          find.text('Saved Character'),
          findsOneWidget,
        );

        expect(
          find.text('Age 20'),
          findsOneWidget,
        );

        expect(
          find.text('Year 2050'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does not replace an existing save when startup succeeds',
      (tester) async {
        final repository =
            InMemorySaveRepository();

        final savedState =
            WorldState(
          clock: const SimulationClock(
            currentYear: 2075,
          ),
          player: Character.create(
            id: 'saved-player',
            firstName: 'Existing',
            lastName: 'Life',
            birthYear: 2025,
          ),
          events: const [],
        );

        await repository.save(
          savedState,
          randomState: 987654,
          nextTickId: 100,
        );

        await tester.pumpWidget(
          LifeSimulationApp(
            dependencies: AppDependencies(
              saveRepository: repository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final loaded =
            await repository.load();

        expect(
          loaded,
          isNotNull,
        );

        expect(
          loaded!.state.player.name,
          'Existing Life',
        );

        expect(
          loaded.state.player.firstName,
          'Existing',
        );

        expect(
          loaded.state.player.lastName,
          'Life',
        );

        expect(
          loaded.state.clock.currentYear,
          2075,
        );

        expect(
          loaded.randomState,
          987654,
        );

        expect(
          loaded.nextTickId,
          100,
        );
      },
    );
  });
}
