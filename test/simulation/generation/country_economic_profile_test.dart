
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/simulation/generation/country_economic_profile.dart';
import 'package:everylife/simulation/generation/family_household_generator.dart';

void main() {
  group('CountryEconomicProfile', () {

    test('starting economic weights cover game countries and total 100', () {
      for (final code in [
        'AE','AR','AT','AU','BE','BR','CA','CH','CL','CN','CO','CU','DE',
        'DK','EG','ES','ET','FJ','FR','GB','GH','GR','ID','IE','IN','IT',
        'JP','KE','KR','MA','MC','MX','MY','NG','NL','NP','NO','NZ','PK',
        'PL','PT','RU','SA','SE','SG','TH','TR','UA','US','VN','ZA','TZ',
        'PE','PH',
      ]) {
        final weights = CountryEconomicProfile.forCountryCode(code)
            .startingBackgroundWeights;
        expect(weights.length, 6, reason: code);
        expect(weights.every((weight) => weight > 0), isTrue, reason: code);
        expect(weights.reduce((a, b) => a + b), 100, reason: code);
      }
    });

    test('higher-poverty profile weights struggling above wealthy classes', () {
      final weights = CountryEconomicProfile.forCountryCode('TZ')
          .startingBackgroundWeights;
      expect(weights[0], greaterThan(weights[4]));
      expect(weights[0], greaterThan(weights[5]));
    });

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

    test('rejects negative range minimum', () {
      final profile =
          CountryEconomicProfile.forCountryCode('ID');

      expect(
        () => profile.scaleRange((-1, 100)),
        throwsArgumentError,
      );
    });

    test('rejects negative range maximum', () {
      final profile =
          CountryEconomicProfile.forCountryCode('ID');

      expect(
        () => profile.scaleRange((0, -1)),
        throwsArgumentError,
      );
    });

    test('rejects inverted ranges', () {
      final profile =
          CountryEconomicProfile.forCountryCode('ID');

      expect(
        () => profile.scaleRange((200, 100)),
        throwsArgumentError,
      );
    });
  });

  group('Country-aware household generation', () {
    test('same seed and country produce deterministic household generation', () {
      final first = FamilyHouseholdGenerator.generate(
        random: SeededRandom(42), birthYear: 2026,
        background: const StartingBackground(tier: StartingBackgroundTier.middleClass),
        familyName: 'Santoso', countryCode: 'ID',
      );
      final second = FamilyHouseholdGenerator.generate(
        random: SeededRandom(42), birthYear: 2026,
        background: const StartingBackground(tier: StartingBackgroundTier.middleClass),
        familyName: 'Santoso', countryCode: 'ID',
      );
      expect(first.parents.map((p) => p.id).toList(), second.parents.map((p) => p.id).toList());
      expect(first.cashSavings.minorUnits, 0);
      expect(first.annualLivingCosts.minorUnits, 0);
      expect(first.parents.every((p) => p.cashBalance.minorUnits == 0), isTrue);
      expect(first.parents.every((p) => p.annualExpenses.minorUnits == 0), isTrue);
    });

    test('home value scales by country and rises with economic tier', () {
      FamilyHousehold ownedHome({required String countryCode, required StartingBackgroundTier tier}) {
        for (var seed = 0; seed < 1000; seed++) {
          final household = FamilyHouseholdGenerator.generate(
            random: SeededRandom(seed), birthYear: 2026,
            background: StartingBackground(tier: tier),
            familyName: 'Test', countryCode: countryCode,
          );
          if (household.assets.any((asset) => asset.type.name == 'property')) return household;
        }
        throw StateError('No owned home generated for $countryCode / $tier');
      }
      final struggling = ownedHome(countryCode: 'ID', tier: StartingBackgroundTier.struggling);
      final veryWealthy = ownedHome(countryCode: 'ID', tier: StartingBackgroundTier.veryWealthy);
      final swissMiddle = ownedHome(countryCode: 'CH', tier: StartingBackgroundTier.middleClass);
      final indoMiddle = ownedHome(countryCode: 'ID', tier: StartingBackgroundTier.middleClass);
      expect(veryWealthy.assets.single.value.minorUnits, greaterThan(struggling.assets.single.value.minorUnits));
      expect(swissMiddle.assets.single.value.minorUnits, greaterThan(indoMiddle.assets.single.value.minorUnits));
    });

    test('only creates a home asset and only for owned housing', () {
      for (var seed = 0; seed < 300; seed++) {
        final household = FamilyHouseholdGenerator.generate(
          random: SeededRandom(seed), birthYear: 2026,
          background: const StartingBackground(tier: StartingBackgroundTier.workingClass),
          familyName: 'Test', countryCode: 'ID',
        );
        expect(household.assets.every((asset) => asset.type.name == 'property'), isTrue);
        expect(household.assets.length, lessThanOrEqualTo(1));
        expect(household.assets.isNotEmpty,
            household.housingStatus == HousingStatus.familyOwned || household.housingStatus == HousingStatus.ownedWithMortgage);
      }
    });
  });
}
