import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/presentation/screens/character_profile_screen.dart';

void main() {
  testWidgets(
    'displays compact character information and wealth',
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
        find.text('Character Information'),
        findsOneWidget,
      );

      expect(
        find.text('Marshall Royce'),
        findsOneWidget,
      );

      expect(
        find.text('Age 7 • 2033'),
        findsOneWidget,
      );

      expect(
        find.text('Basic Information'),
        findsOneWidget,
      );

      expect(
        find.text('Personality'),
        findsOneWidget,
      );

      expect(
        find.text('Born'),
        findsOneWidget,
      );

      expect(
        find.text('2026'),
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
        find.text('Life Stage'),
        findsOneWidget,
      );

      expect(
        find.text('Child'),
        findsOneWidget,
      );

      expect(
        find.text('Occupation'),
        findsOneWidget,
      );

      expect(
        find.text('Not assigned'),
        findsOneWidget,
      );

      expect(
        find.text('Relationship'),
        findsOneWidget,
      );

      expect(
        find.text('Single'),
        findsOneWidget,
      );

      expect(
        find.text('Education'),
        findsOneWidget,
      );

      expect(
        find.text('Not specified'),
        findsOneWidget,
      );

      for (final personality in [
        'Discipline',
        'Sociability',
        'Ambition',
        'Empathy',
        'Honesty',
        'Patience',
        'Risk Taking',
        'Aggressiveness',
      ]) {
        expect(
          find.text(personality),
          findsOneWidget,
        );
      }

      expect(
        find.text('Medium'),
        findsNWidgets(8),
      );

      expect(
        find.text('WEALTH'),
        findsOneWidget,
      );

      expect(
        find.text('Total Assets'),
        findsOneWidget,
      );

      expect(
        find.text('Debt'),
        findsOneWidget,
      );

      expect(
        find.text('Net Worth'),
        findsOneWidget,
      );

      expect(
        find.text('\$0.00'),
        findsNWidgets(3),
      );

      expect(
        find.text('View Assets →'),
        findsOneWidget,
      );

      expect(
        find.text('Identity'),
        findsNothing,
      );

      expect(
        find.text('First Name'),
        findsNothing,
      );

      expect(
        find.text('Last Name / Family Name'),
        findsNothing,
      );

      expect(
        find.text('Full Name'),
        findsNothing,
      );

      expect(
        find.text('Birth Year'),
        findsNothing,
      );

      expect(
        find.text('Age'),
        findsNothing,
      );

      expect(
        find.text('Year'),
        findsNothing,
      );

      expect(
        find.text('Money'),
        findsNothing,
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

      expect(
        find.text('Appearance'),
        findsNothing,
      );

      expect(
        find.text('Milestones'),
        findsNothing,
      );

      expect(
        find.text('Biography'),
        findsNothing,
      );

      expect(
        find.text('Life History'),
        findsNothing,
      );

      expect(
        find.text('Legacy'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'View Assets navigates through the existing Assets tab',
    (tester) async {
      var viewedAssets = false;

      final character = Character.create(
        id: 'assets-test',
        firstName: 'Alex',
        lastName: 'Anderson',
        birthYear: 2007,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterProfileScreen(
            character: character,
            currentYear: 2026,
            onViewAssets: () {
              viewedAssets = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.text('View Assets →'),
      );

      await tester.pumpAndSettle();

      expect(
        viewedAssets,
        isTrue,
      );
    },
  );
}
