
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/simulation/generation/family_household_generator.dart';

void main() {
  FamilyHousehold generate({
    required int seed,
    required StartingBackgroundTier tier,
    int birthYear = 2026,
  }) {
    return FamilyHouseholdGenerator.generate(
      random: SeededRandom(seed),
      birthYear: birthYear,
      background: StartingBackground(tier: tier),
      familyName: 'Santoso',
    );
  }

  String signature(FamilyHousehold household) {
    return [
      household.id,
      household.cashSavings.minorUnits,
      household.monthlyLivingCosts.minorUnits,
      household.totalDebt.minorUnits,
      household.housingStatus.name,
      household.parents.map((parent) {
        return [
          parent.id,
          parent.firstName,
          parent.lastName,
          parent.birthYear,
          parent.gender.name,
          parent.role.name,
          parent.employmentStatus.name,
          parent.occupation,
          parent.monthlyIncome.minorUnits,
          parent.incomeStability.name,
        ].join('|');
      }).join(';'),
      household.assets.map((asset) {
        return [
          asset.id,
          asset.name,
          asset.type.name,
          asset.value.minorUnits,
          asset.ownerNpcId,
        ].join('|');
      }).join(';'),
    ].join('||');
  }

  group('FamilyHouseholdGenerator', () {
    test('generates the same household for the same seed', () {
      final first = generate(
        seed: 12345,
        tier: StartingBackgroundTier.middleClass,
      );

      final second = generate(
        seed: 12345,
        tier: StartingBackgroundTier.middleClass,
      );

      expect(signature(first), signature(second));
    });

    test('generates different outcomes from different seeds', () {
      final first = generate(
        seed: 1,
        tier: StartingBackgroundTier.middleClass,
      );

      final second = generate(
        seed: 9876,
        tier: StartingBackgroundTier.middleClass,
      );

      expect(signature(first), isNot(signature(second)));
    });

    test('generates one or two parents with valid identities', () {
      for (var seed = 0; seed < 100; seed++) {
        final household = generate(
          seed: seed,
          tier: StartingBackgroundTier.workingClass,
        );

        expect(household.parents, isNotEmpty);
        expect(household.parents.length, lessThanOrEqualTo(2));

        for (final parent in household.parents) {
          expect(parent.id, isNotEmpty);
          expect(parent.firstName, isNotEmpty);
          expect(parent.lastName, 'Santoso');
          expect(parent.fullName, isNotEmpty);
          expect(parent.birthYear, inInclusiveRange(1981, 2004));
        }
      }
    });

    test('keeps income and employment status consistent', () {
      for (final tier in StartingBackgroundTier.values) {
        for (var seed = 0; seed < 50; seed++) {
          final household = generate(
            seed: seed,
            tier: tier,
          );

          for (final parent in household.parents) {
            final earnsIncome =
                parent.employmentStatus == EmploymentStatus.employed ||
                parent.employmentStatus ==
                    EmploymentStatus.selfEmployed;

            if (earnsIncome) {
              expect(parent.hasIncome, isTrue);
              expect(
                parent.incomeStability,
                isNot(IncomeStability.none),
              );
              expect(parent.occupation, isNotNull);
            } else {
              expect(parent.hasIncome, isFalse);
              expect(parent.monthlyIncome.minorUnits, 0);
              expect(parent.incomeStability, IncomeStability.none);
              expect(parent.occupation, isNull);
            }
          }
        }
      }
    });

    test('generates non-negative financial values', () {
      for (final tier in StartingBackgroundTier.values) {
        for (var seed = 0; seed < 50; seed++) {
          final household = generate(
            seed: seed,
            tier: tier,
          );

          expect(
            household.cashSavings.minorUnits,
            greaterThanOrEqualTo(0),
          );
          expect(
            household.monthlyLivingCosts.minorUnits,
            greaterThanOrEqualTo(0),
          );
          expect(
            household.totalDebt.minorUnits,
            greaterThanOrEqualTo(0),
          );

          for (final asset in household.assets) {
            expect(
              asset.value.minorUnits,
              greaterThanOrEqualTo(0),
            );
          }
        }
      }
    });

    test('adds a property asset when the family owns its home', () {
      for (final tier in StartingBackgroundTier.values) {
        for (var seed = 0; seed < 100; seed++) {
          final household = generate(
            seed: seed,
            tier: tier,
          );

          final ownsHome =
              household.housingStatus == HousingStatus.familyOwned ||
              household.housingStatus == HousingStatus.ownedWithMortgage;

          final properties = household.assets
              .where((asset) => asset.type == FamilyAssetType.property)
              .toList();

          if (ownsHome) {
            expect(properties, hasLength(1));
            expect(properties.single.value.minorUnits, greaterThan(0));
          } else {
            expect(properties, isEmpty);
          }
        }
      }
    });

    test('asset owners refer to an existing parent', () {
      for (final tier in StartingBackgroundTier.values) {
        for (var seed = 0; seed < 50; seed++) {
          final household = generate(
            seed: seed,
            tier: tier,
          );

          final parentIds = household.parents.map((parent) => parent.id);

          for (final asset in household.assets) {
            if (asset.ownerNpcId != null) {
              expect(parentIds, contains(asset.ownerNpcId));
            }
          }
        }
      }
    });

    test('uses the requested birth year in household and parent data', () {
      const birthYear = 2010;

      final household = generate(
        seed: 456,
        tier: StartingBackgroundTier.middleClass,
        birthYear: birthYear,
      );

      expect(household.id, 'family-household-$birthYear');

      for (final parent in household.parents) {
        expect(parent.birthYear, lessThan(birthYear));
      }
    });

    test('generates a household for every background tier', () {
      for (final tier in StartingBackgroundTier.values) {
        final household = generate(
          seed: 789,
          tier: tier,
        );

        expect(household.id, isNotEmpty);
        expect(household.parents, isNotEmpty);
        expect(
          household.monthlyIncome.minorUnits,
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('scales household finances with background tier', () {
      final tiers = StartingBackgroundTier.values;
      final averageIncome = <StartingBackgroundTier, double>{};
      final averageSavings = <StartingBackgroundTier, double>{};
      final averageLivingCosts = <StartingBackgroundTier, double>{};

      const sampleCount = 250;

      for (final tier in tiers) {
        var totalIncome = 0;
        var totalSavings = 0;
        var totalLivingCosts = 0;

        for (var seed = 0; seed < sampleCount; seed++) {
          final household = generate(
            seed: seed,
            tier: tier,
          );

          totalIncome += household.monthlyIncome.minorUnits;
          totalSavings += household.cashSavings.minorUnits;
          totalLivingCosts +=
              household.monthlyLivingCosts.minorUnits;
        }

        averageIncome[tier] = totalIncome / sampleCount;
        averageSavings[tier] = totalSavings / sampleCount;
        averageLivingCosts[tier] =
            totalLivingCosts / sampleCount;
      }

      for (var index = 1; index < tiers.length; index++) {
        final previousTier = tiers[index - 1];
        final currentTier = tiers[index];

        expect(
          averageSavings[currentTier]!,
          greaterThan(averageSavings[previousTier]!),
          reason:
              'Average savings should increase from '
              '${previousTier.name} to ${currentTier.name}.',
        );

        expect(
          averageLivingCosts[currentTier]!,
          greaterThan(averageLivingCosts[previousTier]!),
          reason:
              'Average living costs should increase from '
              '${previousTier.name} to ${currentTier.name}.',
        );

        expect(
          averageIncome[currentTier]!,
          greaterThan(averageIncome[previousTier]!),
          reason:
              'Average household income should increase from '
              '${previousTier.name} to ${currentTier.name}.',
        );
      }
    });

    test('uses a fallback family name when the input is empty', () {
      final household = FamilyHouseholdGenerator.generate(
        random: SeededRandom(99),
        birthYear: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        familyName: '  ',
      );

      for (final parent in household.parents) {
        expect(parent.lastName, 'Family');
      }
    });
  });
}
