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
        name: 'Marshall Royce',
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
        find.text('Basic Information'),
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
        find.text('Core Stats'),
        findsOneWidget,
      );
    },
  );
}
