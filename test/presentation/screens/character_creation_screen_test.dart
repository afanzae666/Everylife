import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/gender.dart';
import '../../../lib/presentation/screens/character_creation_screen.dart';

void main() {
  group('CharacterCreationScreen', () {
    Future<void> scrollToBeginLife(
      WidgetTester tester,
    ) async {
      final beginLifeButton = find.text(
        'BEGIN LIFE',
      );

      await tester.scrollUntilVisible(
        beginLifeButton,
        300,
        scrollable:
            find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();
    }

    Future<void> enterNames(
      WidgetTester tester, {
      String firstName = 'Test',
      String lastName = 'Character',
    }) async {
      final textFields =
          find.byType(TextField);

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

    testWidgets(
      'shows character creation controls',
      (tester) async {
        var created = false;

        await tester.pumpWidget(
          MaterialApp(
            home:
                CharacterCreationScreen(
              onCharacterCreated: (_) {
                created = true;
              },
            ),
          ),
        );

        expect(
          find.text(
            'Create Your Character',
          ),
          findsOneWidget,
        );

        expect(
          find.text('First Name'),
          findsOneWidget,
        );

        expect(
          find.text(
            'Last Name / Family Name',
          ),
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
            'Tap the year to choose '
            'your character\'s birth year.',
          ),
          findsOneWidget,
        );

        await scrollToBeginLife(
          tester,
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
            home:
                CharacterCreationScreen(
              onCharacterCreated:
                  (character) {
                createdName =
                    character.name;
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

        await scrollToBeginLife(
          tester,
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
            home:
                CharacterCreationScreen(
              onCharacterCreated:
                  (character) {
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
          find.text(
            'Select Birth Year',
          ),
          findsOneWidget,
        );

        final dialogScrollable =
            find.byType(Scrollable).last;

        await tester.scrollUntilVisible(
          find.text('1900'),
          500,
          scrollable: dialogScrollable,
        );

        await tester.pumpAndSettle();

        expect(
          find.text('1900'),
          findsOneWidget,
        );

        await tester.tap(
          find.text('1900'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text(
            'Select Birth Year',
          ),
          findsNothing,
        );

        expect(
          find.text('1900'),
          findsOneWidget,
        );

        await scrollToBeginLife(
          tester,
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
            home:
                CharacterCreationScreen(
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

        await scrollToBeginLife(
          tester,
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
            home:
                CharacterCreationScreen(
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

        await scrollToBeginLife(
          tester,
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
            home:
                CharacterCreationScreen(
              onCharacterCreated:
                  (character) {
                createdGender =
                    character.gender;
              },
            ),
          ),
        );

        await tester.tap(
          find.text('Female'),
        );

        await enterNames(
          tester,
        );

        await scrollToBeginLife(
          tester,
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
