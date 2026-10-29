import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/world/character_location.dart';
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

      expect(find.text('Character Information'), findsOneWidget);
      expect(find.text('Marshall Royce'), findsOneWidget);
      expect(find.text('Age 7 • 2033'), findsOneWidget);
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Personality'), findsNothing);

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
        expect(find.text(personality), findsNothing);
      }

      expect(find.text('Born : 2026'), findsOneWidget);
      expect(find.text('Gender : Male'), findsOneWidget);
      expect(find.text('Life Stage : Child'), findsOneWidget);
      expect(find.text('Occupation : —'), findsOneWidget);
      expect(find.text('Relationship : —'), findsOneWidget);
      expect(find.text('Education : —'), findsOneWidget);
      expect(find.text('Location'), findsNothing);
      expect(find.text('Jakarta, Indonesia'), findsNothing);
      expect(find.text('WEALTH'), findsOneWidget);
      expect(find.text('Total Assets'), findsOneWidget);
      expect(find.text('Debt'), findsOneWidget);
      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('\$0'), findsNWidgets(3));
      expect(find.text('View Assets →'), findsOneWidget);

      for (final removedLabel in [
        'Identity',
        'First Name',
        'Last Name / Family Name',
        'Full Name',
        'Birth Year',
        'Age',
        'Year',
        'Money',
        'Core Stats',
        'Health',
        'Intelligence',
        'Fitness',
        'Happiness',
        'Willpower',
        'Charisma',
        'Creativity',
        'Luck',
        'Appearance',
        'Milestones',
        'Biography',
        'Life History',
        'Legacy',
        'Alive',
        'Deceased',
      ]) {
        expect(find.text(removedLabel), findsNothing);
      }
    },
  );

  testWidgets(
    'displays character location when location is valid',
    (tester) async {
      final character = Character.create(
        id: 'profile-location-test',
        firstName: 'Alex',
        lastName: 'Anderson',
        birthYear: 2007,
        location: const CharacterLocation(
          countryCode: 'ID',
          cityId: 'id-jakarta',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterProfileScreen(
            character: character,
            currentYear: 2026,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Jakarta, Indonesia'), findsOneWidget);
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
      await tester.tap(find.text('View Assets →'));
      await tester.pumpAndSettle();

      expect(viewedAssets, isTrue);
    },
  );
}
