
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/presentation/screens/life_screen.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/appearance.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/presentation/widgets/character_avatar.dart';

void main() {
  testWidgets('Life screen renders a character avatar for each parent', (
    tester,
  ) async {
    final parent = ParentNpc(
      id: 'parent-test',
      firstName: 'Test',
      lastName: 'Parent',
      gender: Gender.male,
      birthYear: 1980,
      role: FamilyRole.father,
      employmentStatus: EmploymentStatus.employed,
      occupation: 'Worker',
      annualIncome: Money.fromMinorUnits(10000),
      incomeStability: IncomeStability.stable,
      appearance: const CharacterAppearance(
        skinTone: 'medium',
        hair: 'male_hair_01',
        hairColor: 'black',
        eyeColor: 'brown',
        eyebrows: 'straight',
        beard: 'none',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LifeScreen(
          zoom: 1,
          currentYear: 2026,
          parents: [parent],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CharacterAvatar), findsOneWidget);
  });

  testWidgets('Life screen shows all requested categories without Family Tree', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LifeScreen(zoom: 1)),
    );

    expect(find.text('Love'), findsOneWidget);
    expect(find.text('Children'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Enemies'), findsOneWidget);

    expect(find.text('Partner'), findsNothing);
    expect(find.text('Family Tree'), findsNothing);
    expect(find.text('Family History'), findsNothing);
  });
}
