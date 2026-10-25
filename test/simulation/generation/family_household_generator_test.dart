import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/cultural_name_catalog.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/family/sibling_npc.dart';
import 'package:everylife/simulation/generation/family_household_generator.dart';

void main() {
  FamilyHousehold generate({
    int seed = 42,
    String countryCode = 'ID',
    String familyName = 'Santoso',
  }) => FamilyHouseholdGenerator.generate(
    random: SeededRandom(seed),
    birthYear: 2026,
    background: const StartingBackground(tier: StartingBackgroundTier.middleClass),
    familyName: familyName,
    countryCode: countryCode,
  );

  test('generates stable parent identities and personal financial records', () {
    final first = generate();
    final second = generate();
    expect(first.parents.map((p) => p.id).toList(),
        second.parents.map((p) => p.id).toList());
    expect(first.parents.map((p) => p.fullName).toList(),
        second.parents.map((p) => p.fullName).toList());
    expect(first.cashSavings.minorUnits, 0);
    expect(first.parents, isNotEmpty);
    for (final parent in first.parents) {
      expect(parent.lastName, 'Santoso');
      expect(parent.countryCode, 'ID');
      expect(parent.cashBalance.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.annualExpenses.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.assets.every((asset) => asset.ownerNpcId == parent.id), isTrue);
    }
  });

  test('generates only the four agreed birth-family scenarios', () {
    var intact = 0;
    var singleMother = 0;
    var motherDied = 0;
    var orphanage = 0;

    for (var seed = 0; seed < 500; seed++) {
      final household = generate(seed: seed);
      final father = household.parents.where((p) => p.role == FamilyRole.father);
      final mother = household.parents.where((p) => p.role == FamilyRole.mother);
      final guardians = household.parents.where((p) => p.role == FamilyRole.guardian);

      if (guardians.isNotEmpty) {
        orphanage++;
        expect(household.parents, hasLength(1));
        expect(guardians.single.gender, anyOf(Gender.male, Gender.female));
        expect(household.housingStatus, HousingStatus.providedByOthers);
        expect(household.assets, isEmpty);
        expect(father, isEmpty);
        expect(mother, isEmpty);
      } else if (mother.isNotEmpty && !mother.single.isAlive) {
        motherDied++;
        expect(father, hasLength(1));
        expect(mother.single.deathYear, 2026);
        expect(father.single.isAlive, isTrue);
      } else if (mother.isNotEmpty && father.isEmpty) {
        singleMother++;
        expect(mother, hasLength(1));
      } else {
        intact++;
        expect(father, hasLength(1));
        expect(mother, hasLength(1));
        expect(father.single.isAlive, isTrue);
        expect(mother.single.isAlive, isTrue);
      }

      expect(
        household.parents.every((p) =>
            p.role != FamilyRole.stepFather && p.role != FamilyRole.stepMother),
        isTrue,
      );
    }

    expect(intact, inInclusiveRange(190, 310));
    expect(singleMother, inInclusiveRange(55, 145));
    expect(motherDied, inInclusiveRange(20, 80));
    expect(orphanage, inInclusiveRange(55, 145));
  });

  test('generates stable siblings with varied relationship and age data', () {
    final first = generate(seed: 99);
    final second = generate(seed: 99);
    expect(first.siblings.map((sibling) => sibling.id).toList(),
        second.siblings.map((sibling) => sibling.id).toList());
    expect(first.siblings.map((sibling) => sibling.birthYear).toList(),
        second.siblings.map((sibling) => sibling.birthYear).toList());
    expect(first.siblings.length, lessThanOrEqualTo(3));
    for (final sibling in first.siblings) {
      expect(sibling.firstName, isNotEmpty);
      expect(sibling.lastName, isNotEmpty);
      expect(sibling.birthYear, isNot(2026));
      expect(SiblingRelationship.values, contains(sibling.relationship));
    }
  });


  test('does not generate half or step siblings without a step-parent context', () {
    for (var seed = 0; seed < 100; seed++) {
      final household = generate(seed: seed);
      final hasStepParent = household.parents.any(
        (parent) =>
            parent.role == FamilyRole.stepFather ||
            parent.role == FamilyRole.stepMother,
      );

      if (!hasStepParent) {
        expect(
          household.siblings.every(
            (sibling) =>
                sibling.relationship == SiblingRelationship.fullSibling,
          ),
          isTrue,
          reason: 'Unexpected half/step sibling for seed $seed',
        );
      }
    }
  });

  test('uses family-name-first formatting for China and Japan', () {
    for (final countryCode in ['CN', 'JP']) {
      final household = generate(countryCode: countryCode, familyName: 'Wang');
      for (final parent in household.parents) {
        expect(parent.fullName, 'Wang ${parent.firstName}');
        expect(parent.fullName, CulturalNameCatalog.formatFullName(
          countryCode, parent.firstName, parent.lastName,
        ));
      }
    }
  });

  test('generates a culturally appropriate surname when none is provided', () {
    final household = generate(familyName: '');
    expect(household.parents.every((parent) => parent.lastName.isNotEmpty), isTrue);
    expect(household.parents.every((parent) => parent.lastName != 'Family'), isTrue);
  });
}
