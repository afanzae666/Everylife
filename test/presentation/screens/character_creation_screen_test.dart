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
      'creates a newborn character with selected birth year',
      (tester) async {
        String? createdName;
        Gender? createdGender;
        int? createdBirthYear;

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterCreationScreen(
              onCharacterCreated: (character) {
                createdName = character.name;
                createdGender = character.gender;
                createdBirthYear = character.birthYear;
              },
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextField),
          'Marshall Royce',
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
                createdBirthYear = character.birthYear;
              },
            ),
          ),
        );

        await tester.enterText(
          find.byType(TextField),
          'Test Character',
        );

        final slider = find.byType(Slider);

        expect(slider, findsOneWidget);

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
          find.text('BEGIN LIFE'),
        );

        await tester.pump();

        expect(
          created,
          isFalse,
        );

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
