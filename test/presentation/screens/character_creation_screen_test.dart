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
          find.text('First Name'),
          findsOneWidget,
        );

        expect(
          find.text('Last Name / Family Name'),
          findsOneWidget,
        );

        expect(
          find.text('Gender'),
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
          find.text('Birth Year'),
          findsOneWidget,
        );

        expect(
          find.text('2026'),
          findsOneWidget,
        );

        expect(
          find.text(
            'Your character will begin life as a newborn in 2026.',
          ),
          findsOneWidget,
        );

        expect(
          find.text('BEGIN LIFE'),
          findsOneWidget,
        );

        expect(created, isFalse);
      },
    );

    testWidgets(
      'creates a newborn character with first and last name',
      (tester) async {
        String? createdName;
        String? createdFirstName;
        String? createdLastName;
        Gender? createdGender;
        int? createdBirthYear;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (character) {
                createdName = character.name;
                createdFirstName =
                    character.firstName;
                createdLastName =
                    character.lastName;
                createdGender =
                    character.gender;
                createdBirthYear =
                    character.birthYear;
              },
            ),
          ),
        );

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

        await tester.tap(
          find.text('BEGIN LIFE'),
        );

        await tester.pump();

        expect(
          createdName,
          'Marshall Royce',
        );

        expect(
          createdFirstName,
          'Marshall',
        );

        expect(
          createdLastName,
          'Royce',
        );

        expect(
          createdGender,
          Gender.male,
        );

        expect(
          createdBirthYear,
          2026,
        );

        expect(
          2026 - createdBirthYear!,
          0,
        );
      },
    );

    testWidgets(
      'allows birth year to be changed to 1900',
      (tester) async {
        int? createdBirthYear;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (character) {
                createdBirthYear =
                    character.birthYear;
              },
            ),
          ),
        );

        final textFields =
            find.byType(TextField);

        await tester.enterText(
          textFields.at(0),
          'Test',
        );

        await tester.enterText(
          textFields.at(1),
          'Character',
        );

        final slider =
            find.byType(Slider);

        expect(
          slider,
          findsOneWidget,
        );

        await tester.drag(
          slider,
          const Offset(-1000, 0),
        );

        await tester.pump();

        expect(
          find.text('1900'),
          findsWidgets,
        );

        await tester.tap(
          find.text('BEGIN LIFE'),
        );

        await tester.pump();

        expect(
          createdBirthYear,
          1900,
        );

        expect(
          2026 - createdBirthYear!,
          126,
        );
      },
    );

    testWidgets(
      'requires a first name before creating character',
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

        await tester.enterText(
          find.byType(TextField).at(1),
          'Royce',
        );

        await tester.tap(
          find.text('BEGIN LIFE'),
        );

        await tester.pump();

        expect(
          created,
          isFalse,
        );

        expect(
          find.text(
            'Please enter your first name.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'requires a family name before creating character',
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

        await tester.enterText(
          find.byType(TextField).at(0),
          'Marshall',
        );

        await tester.tap(
          find.text('BEGIN LIFE'),
        );

        await tester.pump();

        expect(
          created,
          isFalse,
        );

        expect(
          find.text(
            'Please enter your family name.',
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
                createdGender =
                    character.gender;
              },
            ),
          ),
        );

        await tester.tap(
          find.text('Female'),
        );

        final textFields =
            find.byType(TextField);

        await tester.enterText(
          textFields.at(0),
          'Test',
        );

        await tester.enterText(
          textFields.at(1),
          'Character',
        );

        await tester.tap(
          find.text('BEGIN LIFE'),
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
