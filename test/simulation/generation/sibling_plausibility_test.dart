import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/family/sibling_npc.dart';
import 'package:everylife/simulation/generation/family_household_generator.dart';

void main() {
  const playerBirthYear = 2026;

  test('full siblings are born when both biological parents could have '
      'had a child', () {
    for (var seed = 0; seed < 3000; seed++) {
      final household = FamilyHouseholdGenerator.generate(
        random: SeededRandom(seed),
        birthYear: playerBirthYear,
        familyName: 'Santoso',
      );

      final biologicalParents = household.parents.where(
        (parent) =>
            parent.role == FamilyRole.father ||
            parent.role == FamilyRole.mother,
      );

      for (final sibling in household.siblings) {
        expect(
          (sibling.birthYear - playerBirthYear).abs(),
          lessThanOrEqualTo(18),
          reason: 'Seed $seed produced a sibling too far from the player.',
        );

        for (final parent in biologicalParents) {
          final ageAtBirth = sibling.birthYear - parent.birthYear;
          final maxAge = parent.gender == Gender.female ? 45 : 60;

          expect(
            ageAtBirth,
            inInclusiveRange(18, maxAge),
            reason: 'Seed $seed: ${parent.role.name} was $ageAtBirth when '
                'sibling ${sibling.id} was born.',
          );
        }
      }
    }
  });
}
