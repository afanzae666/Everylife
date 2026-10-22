
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/simulation/generation/country_economic_profile.dart';
import 'package:everylife/simulation/generation/family_household_generator.dart';

void main() {
  group('CountryEconomicProfile', () {
    test('normalizes country codes before lookup', () {
      final lowerCase =
          CountryEconomicProfile.forCountryCode('id');
      final padded =
          CountryEconomicProfile.forCountryCode(' ID ');

      expect(lowerCase.countryCode, 'ID');
      expect(
        lowerCase.costOfLivingBasisPoints,
        padded.costOfLivingBasisPoints,
      );
    });

    test('uses neutral index for an unknown country', () {
      final profile =
          CountryEconomicProfile.forCountryCode('XX');

      expect(profile.countryCode, 'XX');
      expect(
        profile.costOfLivingBasisPoints,
        CountryEconomicProfile.neutralBasisPoints,
      );
      expect(profile.scaleAmount(12345), 12345);
    });

    test('scales amounts with integer arithmetic', () {
      final indonesia =
          CountryEconomicProfile.forCountryCode('ID');
      final switzerland =
          CountryEconomicProfile.forCountryCode('CH');

      expect(indonesia.scaleAmount(10000), 5500);
      expect(switzerland.scaleAmount(10000), 16500);
    });

    test('scales both ends of a range in the same order', () {
      final profile =
          CountryEconomicProfile.forCountryCode('SG');

      final scaled = profile.scaleRange((100000, 200000));

      expect(scaled.$1, 140000);
      expect(scaled.$2, 280000);
      expect(scaled.$1, lessThanOrEqualTo(scaled.$2));
    });

    test('rejects negative amounts', () {
      final profile =
          CountryEconomicProfile.forCountryCode('ID');

      expect(
        () => profile.scaleAmount(-1),
        throwsArgumentError,
      );
    });
  });

  group('Country-aware household generation', () {
    test('same seed and country produce the same living costs', () {
      FamilyHouseholdGenerator.generate(
        random: SeededRandom(42),
        birthYear: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        familyName: 'Santoso',
        countryCode: 'ID',
      );

      final first = FamilyHouseholdGenerator.generate(
        random: SeededRandom(42),
        birthYear: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        familyName: 'Santoso',
        countryCode: 'ID',
      );

      final second = FamilyHouseholdGenerator.generate(
        random: SeededRandom(42),
        birthYear: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        familyName: 'Santoso',
        countryCode: 'ID',
      );

      expect(
        first.annualLivingCosts.minorUnits,
        second.annualLivingCosts.minorUnits,
      );
    });

    test('higher-index countries have higher average living costs', () {
      const sampleCount = 250;
      var indonesiaTotal = 0;
      var monacoTotal = 0;

      for (var seed = 0; seed < sampleCount; seed++) {
        final indonesia = FamilyHouseholdGenerator.generate(
          random: SeededRandom(seed),
          birthYear: 2026,
          background: const StartingBackground(
            tier: StartingBackgroundTier.middleClass,
          ),
          familyName: 'Santoso',
          countryCode: 'ID',
        );

        final monaco = FamilyHouseholdGenerator.generate(
          random: SeededRandom(seed),
          birthYear: 2026,
          background: const StartingBackground(
            tier: StartingBackgroundTier.middleClass,
          ),
          familyName: 'Martin',
          countryCode: 'MC',
        );

        indonesiaTotal += indonesia.annualLivingCosts.minorUnits;
        monacoTotal += monaco.annualLivingCosts.minorUnits;
      }

      final indonesiaAverage = indonesiaTotal / sampleCount;
      final monacoAverage = monacoTotal / sampleCount;

      expect(
        monacoAverage,
        greaterThan(indonesiaAverage),
        reason: 'The higher gameplay cost index should produce higher '
            'average household living costs for the same background tier.',
      );
    });

    test('unknown countries still generate valid living costs', () {
      final household = FamilyHouseholdGenerator.generate(
        random: SeededRandom(123),
        birthYear: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.workingClass,
        ),
        familyName: 'Family',
        countryCode: 'XX',
      );

      expect(
        household.annualLivingCosts.minorUnits,
        greaterThanOrEqualTo(0),
      );
      expect(household.parents, isNotEmpty);
    });
  });
}
