import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/app/app.dart';
import '../../lib/presentation/screens/character_creation_screen.dart';

void main() {
  group('LifeSimulationApp startup', () {
    testWidgets(
      'starts on character creation screen',
      (tester) async {
        await tester.pumpWidget(
          const LifeSimulationApp(),
        );

        await tester.pump();

        expect(
          find.text('Create Character'),
          findsOneWidget,
        );

        expect(
          find.text('Create Your Character'),
          findsOneWidget,
        );

        expect(
          find.byType(CharacterCreationScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'creates a character and opens the game',
      (tester) async {
        await tester.pumpWidget(
          const LifeSimulationApp(),
        );

        await tester.pump();

        await tester.enterText(
          find.byType(TextField),
          'Marshall Royce',
        );

        await tester.tap(
          find.text('CREATE CHARACTER'),
        );

        await tester.pump();

        expect(
          find.text('Life Simulation'),
          findsOneWidget,
        );

        expect(
          find.text('Marshall Royce'),
          findsOneWidget,
        );

        expect(
          find.text('Age 18'),
          findsOneWidget,
        );

        expect(
          find.text('Year 2026'),
          findsOneWidget,
        );
      },
    );
  });
}
