import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/gender.dart';
import '../../../lib/presentation/screens/character_creation_screen.dart';

void main() {
  group('CharacterCreationScreen', () {
    Future<void> enterNames(
      WidgetTester tester, {
      String firstName = 'Test',
      String lastName = 'Character',
    }) async {
      final textFields = find.byType(TextField);

      expect(
        textFields,
        findsNWidgets(2),
      );

      await tester.enterText(
        textFields.at(0),
        firstName,
      );

      await tester.enterText(
        textFields.at(1),
        lastName,
      );
    }

    Future<void> tapBeginLife(
      WidgetTester tester,
    ) async {
      final beginLifeButton = find.text(
        'BEGIN LIFE',
      );

      expect(
        beginLifeButton,
        findsOneWidget,
      );

      await tester.tap(
        beginLifeButton,
      );

      await tester.pump();
    }

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
          find.text('Create Character'),
          findsOneWidget,
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
          find.text('Last Name'),
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
          find.text('Birth Year'),
          findsOneWidget,
        );

        expect(
          find.text('2026'),
          findsOneWidget,
        );

        expect(
          find.text('Customize Appearance'),
          findsOneWidget,
        );

        expect(
          find.text('BEGIN LIFE'),
          findsOneWidget,
        );

        expect(
          created,
          isFalse,
        );
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

        await enterNames(
          tester,
          firstName: 'Marshall',
          lastName: 'Royce',
        );

        await tapBeginLife(
          tester,
        );

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
      'automatically capitalizes first letter of names',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (_) {},
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
          'marshall',
        );

        await tester.enterText(
          textFields.at(1),
          'royce',
        );

        await tester.pump();

        final firstNameField =
            tester.widget<TextField>(
          textFields.at(0),
        );

        final lastNameField =
            tester.widget<TextField>(
          textFields.at(1),
        );

        expect(
          firstNameField.controller!.text,
          'Marshall',
        );

        expect(
          lastNameField.controller!.text,
          'Royce',
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

        await enterNames(
          tester,
        );

        await tester.tap(
          find.text('2026'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Birth Year'),
          findsWidgets,
        );

        expect(
          find.byType(
            ListWheelScrollView,
          ),
          findsOneWidget,
        );

        final previousYearButton =
            find.byTooltip(
          'Previous year',
        );

        expect(
          previousYearButton,
          findsOneWidget,
        );

        for (int i = 0; i < 126; i++) {
          await tester.tap(
            previousYearButton,
          );
          await tester.pump();
        }

        expect(
          find.text('1900'),
          findsOneWidget,
        );

        await tester.tap(
          find.text('1900'),
        );

        await tester.pumpAndSettle();
        
        expect(
          find.text('1900'),
          findsOneWidget,
        );

        await tapBeginLife(
          tester,
        );

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

        await tapBeginLife(
          tester,
        );

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
      'requires a last name before creating character',
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

        await tapBeginLife(
          tester,
        );

        expect(
          created,
          isFalse,
        );

        expect(
          find.text(
            'Please enter your last name.',
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
          find.text('Male'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Female'),
          findsOneWidget,
        );

        await tester.tap(
          find.text('Female'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Female'),
          findsOneWidget,
        );

        await enterNames(
          tester,
        );

        await tapBeginLife(
          tester,
        );

        expect(
          createdGender,
          Gender.female,
        );
      },
    );

    testWidgets(
      'opens appearance customization dialog',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (_) {},
            ),
          ),
        );

        await tester.tap(
          find.text('Customize Appearance'),
        );

        await tester.pumpAndSettle();

        final appearanceDialog =
            find.byType(Dialog);

        expect(
          appearanceDialog,
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: appearanceDialog,
            matching: find.text(
              'Customize Appearance',
            ),
          ),
          findsOneWidget,
        );

        expect(
          find.text('Skin Tone'),
          findsOneWidget,
        );

        expect(
          find.text('Hair'),
          findsOneWidget,
        );

        expect(
          find.text('Hair Color'),
          findsOneWidget,
        );

        expect(
          find.text('Eyes'),
          findsOneWidget,
        );

        expect(
          find.text('Eye Color'),
          findsOneWidget,
        );

        expect(
          find.text('Eyebrows'),
          findsOneWidget,
        );

        expect(
          find.text('DONE'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'appearance dialog can be closed without changing identity controls',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (_) {},
            ),
          ),
        );

        await tester.tap(
          find.text('Customize Appearance'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Skin Tone'),
          findsOneWidget,
        );

        await tester.tap(
          find.byTooltip('Close'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Skin Tone'),
          findsNothing,
        );

        expect(
          find.text('First Name'),
          findsOneWidget,
        );

        expect(
          find.text('Last Name'),
          findsOneWidget,
        );

        expect(
          find.text('Customize Appearance'),
          findsOneWidget,
        );
      },
    );
  });
}
