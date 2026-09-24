import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/gender.dart';
import '../../../lib/presentation/screens/character_creation_screen.dart';

void main() {
  group('CharacterCreationScreen', () {
    testWidgets(
      'shows character creation controls',
      (tester) async {
        var created = false;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (_) {
                created = true;
              },
            ),
          ),
        );

        expect(
          find.text('Create Your Character'),
          findsOneWidget,
        );

        expect(
          find.text('Name'),
          findsOneWidget,
        );

        expect(
          find.text('Male'),
          findsOneWidget,
        );

        expect(
          find.text('Female'),
          findsOneWidget,
        );

        expect(
          find.text('18 years old'),
          findsOneWidget,
        );

        expect(created, isFalse);
      },
    );

    testWidgets(
      'creates character with entered name',
      (tester) async {
        String? createdName;
        Gender? createdGender;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (character) {
                createdName = character.name;
                createdGender = character.gender;
              },
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextField),
          'Marshall Royce',
        );

        await tester.tap(
          find.text('CREATE CHARACTER'),
        );

        await tester.pump();

        expect(
          createdName,
          'Marshall Royce',
        );

        expect(
          createdGender,
          Gender.male,
        );
      },
    );

    testWidgets(
      'requires a name before creating character',
      (tester) async {
        var created = false;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (_) {
                created = true;
              },
            ),
          ),
        );

        await tester.tap(
          find.text('CREATE CHARACTER'),
        );

        await tester.pump();

        expect(created, isFalse);

        expect(
          find.text(
            'Please enter your character name.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'can select female gender',
      (tester) async {
        Gender? createdGender;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (character) {
                createdGender = character.gender;
              },
            ),
          ),
        );

        await tester.tap(
          find.text('Female'),
        );

        await tester.enterText(
          find.byType(TextField),
          'Test Character',
        );

        await tester.tap(
          find.text('CREATE CHARACTER'),
        );

        await tester.pump();

        expect(
          createdGender,
          Gender.female,
        );
      },
    );
  });
}
