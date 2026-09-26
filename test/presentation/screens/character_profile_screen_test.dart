import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/presentation/screens/character_profile_screen.dart';

void main() {
  testWidgets(
    'displays character profile information',
    (tester) async {
      final character = Character.create(
        id: 'profile-test',
        firstName: 'Marshall',
        lastName: 'Royce',
        birthYear: 2026,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterProfileScreen(
            character: character,
            currentYear: 2033,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Character'),
        findsOneWidget,
      );

      expect(
        find.text('Marshall Royce'),
        findsNWidgets(2),
      );

      expect(
        find.text('Identity'),
        findsOneWidget,
      );

      expect(
        find.text('First Name'),
        findsOneWidget,
      );

      expect(
        find.text('Marshall'),
        findsOneWidget,
      );

      expect(
        find.text('Last Name / Family Name'),
        findsOneWidget,
      );

      expect(
        find.text('Royce'),
        findsOneWidget,
      );

      expect(
        find.text('Full Name'),
        findsOneWidget,
      );

      expect(
        find.text('Basic Information'),
        findsOneWidget,
      );

      expect(
        find.text('Gender'),
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
        find.text('Age'),
        findsOneWidget,
      );

      expect(
        find.text('7'),
        findsOneWidget,
      );

      expect(
        find.text('Year'),
        findsOneWidget,
      );

      expect(
        find.text('2033'),
        findsOneWidget,
      );

      expect(
        find.text('Life Stage'),
        findsOneWidget,
      );

      expect(
        find.text('Child'),
        findsOneWidget,
      );

      expect(
        find.text('Money'),
        findsOneWidget,
      );

      expect(
        find.text('Character Information'),
        findsOneWidget,
      );

      expect(
        find.text('Core Stats'),
        findsNothing,
      );

      expect(
        find.text('Health'),
        findsNothing,
      );

      expect(
        find.text('Intelligence'),
        findsNothing,
      );

      expect(
        find.text('Fitness'),
        findsNothing,
      );

      expect(
        find.text('Happiness'),
        findsNothing,
      );

      expect(
        find.text('Willpower'),
        findsNothing,
      );

      expect(
        find.text('Charisma'),
        findsNothing,
      );

      expect(
        find.text('Creativity'),
        findsNothing,
      );

      expect(
        find.text('Luck'),
        findsNothing,
      );
    },
  );
}
