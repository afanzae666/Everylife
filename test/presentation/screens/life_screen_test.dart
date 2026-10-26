import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/presentation/screens/life_screen.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/appearance.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/family/sibling_npc.dart';
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
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Siblings'), findsNothing);
  });

  testWidgets('Life screen places step-parents and step-siblings in existing cards', (
    tester,
  ) async {
    final stepParent = ParentNpc(
      id: 'step-parent-test',
      firstName: 'Alex',
      lastName: 'Morgan',
      gender: Gender.female,
      birthYear: 1980,
      role: FamilyRole.stepMother,
      employmentStatus: EmploymentStatus.unemployed,
      annualIncome: Money.zero(),
      incomeStability: IncomeStability.none,
    );
    const stepSibling = SiblingNpc(
      id: 'step-sibling-test',
      firstName: 'Jordan',
      lastName: 'Lee',
      gender: Gender.female,
      birthYear: 2030,
      relationship: SiblingRelationship.stepSibling,
    );

    await tester.pumpWidget(MaterialApp(
      home: LifeScreen(
        zoom: 1,
        currentYear: 2030,
        playerBirthYear: 2026,
        parents: [stepParent],
        siblings: const [stepSibling],
      ),
    ));
    await tester.pump();

    expect(find.text('(stepmother)'), findsOneWidget);
    expect(find.text('(younger stepsister)'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Siblings'), findsOneWidget);
  });

  testWidgets('hides unborn siblings and uses simple labels for siblings', (
    tester,
  ) async {
    const olderSibling = SiblingNpc(
      id: 'older-brother-test',
      firstName: 'Alex',
      lastName: 'Lee',
      gender: Gender.male,
      birthYear: 2010,
      relationship: SiblingRelationship.fullSibling,
    );
    const unbornSibling = SiblingNpc(
      id: 'unborn-sister-test',
      firstName: 'Jordan',
      lastName: 'Lee',
      gender: Gender.female,
      birthYear: 2030,
      relationship: SiblingRelationship.fullSibling,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: LifeScreen(
          zoom: 1,
          currentYear: 2026,
          playerBirthYear: 2020,
          siblings: [olderSibling, unbornSibling],
        ),
      ),
    );

    expect(find.text('(older brother)'), findsOneWidget);
    expect(find.text('Alex Lee'), findsOneWidget);
    expect(find.text('Jordan Lee'), findsNothing);
    expect(find.text('Full brother'), findsNothing);
    expect(find.text('Siblings'), findsOneWidget);
  });

  testWidgets('hides NPC categories that have no NPCs', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LifeScreen(zoom: 1)),
    );

    for (final category in [
      'Love',
      'Fling',
      'Children',
      'Parents',
      'Friends',
      'Enemies',
      'Siblings',
      'Grandparents',
      'Family',
    ]) {
      expect(
        find.text(category),
        findsNothing,
        reason: '$category should be hidden when empty',
      );
    }

    expect(find.text('Partner'), findsNothing);
    expect(find.text('Family Tree'), findsNothing);
    expect(find.text('Family History'), findsNothing);
  });

  testWidgets('shows the siblings category when sibling data arrives', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LifeScreen(zoom: 1)),
    );
    expect(find.text('Siblings'), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: LifeScreen(
          zoom: 1,
          currentYear: 2026,
          playerBirthYear: 2026,
          siblings: [
            SiblingNpc(
              id: 'new-sibling',
              firstName: 'Jamie',
              lastName: 'Taylor',
              gender: Gender.female,
              birthYear: 2026,
              relationship: SiblingRelationship.fullSibling,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Siblings'), findsOneWidget);
    expect(find.text('Jamie Taylor'), findsOneWidget);
  });
}
