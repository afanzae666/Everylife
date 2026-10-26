
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
  }) =>
      FamilyHouseholdGenerator.generate(
        random: SeededRandom(seed),
        birthYear: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        familyName: familyName,
        countryCode: countryCode,
      );

  test('generates stable parent identities and personal financial records',
      () {
    final first = generate();
    final second = generate();

    expect(
      first.parents.map((parent) => parent.id).toList(),
      second.parents.map((parent) => parent.id).toList(),
    );
    expect(
      first.parents.map((parent) => parent.fullName).toList(),
      second.parents.map((parent) => parent.fullName).toList(),
    );
    expect(first.cashSavings.minorUnits, 0);
    expect(first.parents, isNotEmpty);

    for (final parent in first.parents) {
      if (parent.role == FamilyRole.guardian) {
        expect(parent.lastName, isNot('Santoso'));
        expect(parent.siblingCount, 0);
      } else {
        expect(parent.lastName, 'Santoso');
      }

      expect(parent.countryCode, 'ID');
      expect(parent.cashBalance.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.annualExpenses.minorUnits, greaterThanOrEqualTo(0));
      expect(
        parent.assets.every((asset) => asset.ownerNpcId == parent.id),
        isTrue,
      );
    }
  });

  test('generates stable siblings with varied relationship and age data',
      () {
    final first = generate(seed: 99);
    final second = generate(seed: 99);

    expect(
      first.siblings.map((sibling) => sibling.id).toList(),
      second.siblings.map((sibling) => sibling.id).toList(),
    );
    expect(
      first.siblings.map((sibling) => sibling.birthYear).toList(),
      second.siblings.map((sibling) => sibling.birthYear).toList(),
    );
    expect(first.siblings.length, lessThanOrEqualTo(3));

    for (final sibling in first.siblings) {
      expect(sibling.firstName, isNotEmpty);
      expect(sibling.lastName, isNotEmpty);
      expect(sibling.birthYear, isNot(2026));
      expect(SiblingRelationship.values, contains(sibling.relationship));
    }
  });


  test('generates unique full names for siblings in one household', () {
    for (var seed = 0; seed < 300; seed++) {
      final household = generate(seed: seed);
      final names = household.siblings
          .map((sibling) => sibling.fullName.toLowerCase())
          .toList();
      expect(
        names.toSet().length,
        names.length,
        reason: 'Sibling names collided for seed $seed: $names',
      );
    }
  });

  test('can generate explicitly marked twin siblings', () {
    var foundTwinBirth = false;

    for (var seed = 0; seed < 1000 && !foundTwinBirth; seed++) {
      final household = generate(seed: seed);
      final twins = household.siblings.where((sibling) => sibling.isTwin);
      if (twins.length >= 2) {
        foundTwinBirth = true;
        expect(twins.map((sibling) => sibling.birthYear).toSet(), hasLength(1));
      }
    }

    expect(
      foundTwinBirth,
      isTrue,
      reason: 'Expected the seeded generator range to include a twin birth.',
    );
  });

  test('orphanage scenarios have one guardian and no siblings', () {
    var orphanageScenariosFound = 0;

    for (var seed = 0; seed < 300; seed++) {
      final household = generate(seed: seed);
      final guardians = household.parents
          .where((parent) => parent.role == FamilyRole.guardian)
          .toList();

      if (guardians.isEmpty) {
        continue;
      }

      orphanageScenariosFound++;

      expect(household.parents, hasLength(1));
      expect(household.parents.single.role, FamilyRole.guardian);
      expect(household.siblings, isEmpty);
      expect(household.parents.single.siblingCount, 0);
      expect(household.housingStatus, HousingStatus.providedByOthers);
      expect(
        household.parents.single.lastName.toLowerCase(),
        isNot('santoso'),
      );
    }

    expect(
      orphanageScenariosFound,
      greaterThan(0),
      reason: 'The seed range should include orphanage scenarios.',
    );
  });

  test('does not generate half or step siblings without a step-parent context',
      () {
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

  test('mother who died in childbirth has no later-born siblings', () {
    var foundScenario = false;

    for (var seed = 0; seed < 1000; seed++) {
      final household = generate(seed: seed);
      final deceasedMother = household.parents.where(
        (parent) =>
            parent.role == FamilyRole.mother &&
            !parent.isAlive &&
            parent.deathYear == 2026,
      );

      if (deceasedMother.isEmpty) continue;
      foundScenario = true;

      expect(
        household.siblings.every((sibling) => sibling.birthYear <= 2026),
        isTrue,
        reason: 'Seed $seed generated a sibling after the mother died: '
            '${household.siblings.map((sibling) => sibling.birthYear).toList()}',
      );
    }

    expect(
      foundScenario,
      isTrue,
      reason: 'The seed range should include the mother-died scenario.',
    );
  });

  test('uses family-name-first formatting for China and Japan', () {
    for (final countryCode in ['CN', 'JP']) {
      final household = generate(
        countryCode: countryCode,
        familyName: 'Wang',
      );

      for (final parent in household.parents) {
        if (parent.role == FamilyRole.guardian) {
          expect(parent.lastName, isNot('Wang'));
        } else {
          expect(parent.fullName, 'Wang ${parent.firstName}');
        }

        expect(
          parent.fullName,
          CulturalNameCatalog.formatFullName(
            countryCode,
            parent.firstName,
            parent.lastName,
          ),
        );
      }
    }
  });

  test('generates a culturally appropriate surname when none is provided',
      () {
    final household = generate(familyName: '');

    expect(
      household.parents.every((parent) => parent.lastName.isNotEmpty),
      isTrue,
    );
    expect(
      household.parents.every((parent) => parent.lastName != 'Family'),
      isTrue,
    );
  });
}
