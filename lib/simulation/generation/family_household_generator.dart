import 'dart:math' as math;

import 'package:everylife/core/money/money.dart';

import '../../core/random/seeded_random.dart';
import '../../domain/character/appearance.dart';
import '../../domain/character/character_hair.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/starting_background.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
import 'country_economic_profile.dart';

class FamilyHouseholdGenerator {
  const FamilyHouseholdGenerator._();

  static FamilyHousehold generate({
    required SeededRandom random,
    required int birthYear,
    required StartingBackground background,
    required String familyName,
    String countryCode = 'ID',
    CharacterAppearance? childAppearance,
  }) {
    final tier = background.tier;
    final householdId = 'family-household-$birthYear';
    final normalizedFamilyName = familyName.trim().isEmpty
        ? CulturalRandomizerCatalog.randomLastName(
            countryCode: countryCode,
            random: math.Random(random.nextInt(0x7fffffff)),
          )
        : familyName.trim();

    final parents = _generateParents(
      random: random,
      birthYear: birthYear,
      familyName: normalizedFamilyName,
      countryCode: countryCode,
      tier: tier,
      childAppearance: childAppearance,
    );

    final housingStatus = _generateHousingStatus(
      random: random,
      tier: tier,
    );

    final cashSavings = _moneyBetween(
      random,
      _savingsRange(tier).$1,
      _savingsRange(tier).$2,
    );

        final countryEconomicProfile =
        CountryEconomicProfile.forCountryCode(countryCode);
    final countryLivingCostRange =
        countryEconomicProfile.scaleRange(_annualLivingCostRange(tier));

    final annualLivingCosts = _moneyBetween(
      random,
      countryLivingCostRange.$1,
      countryLivingCostRange.$2,
    );

    const totalDebt = Money.zero();

    final assets = _generateAssets(
      random: random,
      householdId: householdId,
      parents: parents,
      tier: tier,
      housingStatus: housingStatus,
    ).map((asset) => asset.ownerNpcId == null
        ? FamilyAsset(
            id: asset.id, name: asset.name, type: asset.type,
            value: asset.value, ownerNpcId: parents.first.id,
          )
        : asset).toList(growable: false);
    final savingsPerParent = cashSavings.minorUnits ~/ parents.length;
    final financiallyInitializedParents = parents.map((parent) {
      final personalAssets = assets
          .where((asset) => asset.ownerNpcId == parent.id)
          .toList(growable: false);
      return parent.copyWith(
        cashBalance: Money.fromMinorUnits(savingsPerParent),
        annualExpenses: Money.fromMinorUnits(
          parent.annualIncome.minorUnits *
              (parent.incomeStability == IncomeStability.stable ? 70 : 85) ~/ 100,
        ),
        assets: personalAssets,
        countryCode: countryCode,
        siblingCount: 0,
      );
    }).toList(growable: false);

    return FamilyHousehold(
      id: householdId,
      parents: financiallyInitializedParents,
      // Aggregate savings are migrated into individual parent balances.
      cashSavings: const Money.zero(),
      assets: assets,
      housingStatus: housingStatus,
      annualLivingCosts: annualLivingCosts,
      totalDebt: totalDebt,
    );
  }

  static List<ParentNpc> _generateParents({
    required SeededRandom random,
    required int birthYear,
    required String familyName,
    required String countryCode,
    required StartingBackgroundTier tier,
    CharacterAppearance? childAppearance,
  }) {
    final singleParent = random.nextInt(100) < 15;

    if (singleParent) {
      final gender = random.nextBool() ? Gender.male : Gender.female;
      final role = gender == Gender.male
          ? FamilyRole.father
          : FamilyRole.mother;

      return [
        _generateParent(
          random: random,
          birthYear: birthYear,
          familyName: familyName,
          countryCode: countryCode,
          tier: tier,
          childAppearance: childAppearance,
          gender: gender,
          role: role,
          id: 'parent-${role.name}-$birthYear',
        ),
      ];
    }

    return [
      _generateParent(
        random: random,
        birthYear: birthYear,
        familyName: familyName,
        countryCode: countryCode,
        tier: tier,
        childAppearance: childAppearance,
        gender: Gender.male,
        role: FamilyRole.father,
        id: 'parent-father-$birthYear',
      ),
      _generateParent(
        random: random,
        birthYear: birthYear,
        familyName: familyName,
        countryCode: countryCode,
        tier: tier,
        childAppearance: childAppearance,
        gender: Gender.female,
        role: FamilyRole.mother,
        id: 'parent-mother-$birthYear',
      ),
    ];
  }

  static ParentNpc _generateParent({
    required SeededRandom random,
    required int birthYear,
    required String familyName,
    required String countryCode,
    required StartingBackgroundTier tier,
    required Gender gender,
    required FamilyRole role,
    required String id,
    CharacterAppearance? childAppearance,
  }) {
    final ageAtChildBirth = 22 + random.nextInt(24);
    final employmentStatus = _generateEmploymentStatus(
      random: random,
      tier: tier,
    );

    final hasIncome = employmentStatus == EmploymentStatus.employed ||
        employmentStatus == EmploymentStatus.selfEmployed;

    final incomeRange = _annualIncomeRange(tier);
    final annualIncome = hasIncome
        ? _moneyBetween(
            random,
            incomeRange.$1,
            incomeRange.$2,
          )
        : const Money.zero();

    final incomeStability = switch (employmentStatus) {
      EmploymentStatus.employed => random.nextInt(100) < 75
          ? IncomeStability.stable
          : IncomeStability.variable,
      EmploymentStatus.selfEmployed => random.nextInt(100) < 70
          ? IncomeStability.variable
          : IncomeStability.seasonal,
      _ => IncomeStability.none,
    };

    return ParentNpc(
      id: id,
      firstName: _firstName(
        random,
        gender,
        countryCode,
      ),
      lastName: familyName,
      gender: gender,
      birthYear: birthYear - ageAtChildBirth,
      role: role,
      employmentStatus: employmentStatus,
      occupation: _occupation(
        random,
        employmentStatus,
      ),
      annualIncome: annualIncome,
      incomeStability: incomeStability,
      appearance: _generateAppearance(
        random: random,
        gender: gender,
        childAppearance: childAppearance,
      ),
    );
  }

  static CharacterAppearance _generateAppearance({
    required SeededRandom random,
    required Gender gender,
    CharacterAppearance? childAppearance,
  }) {
    const skinTones = <String>[
      'pale', 'very_light', 'light', 'light_medium', 'medium',
      'medium_tan', 'tan', 'deep_tan', 'brown', 'deep_brown',
      'dark', 'very_dark',
    ];
    const eyeColors = <String>[
      'light_blue', 'deep_blue', 'gray', 'blue_green', 'green',
      'hazel', 'amber', 'brown', 'dark_brown', 'black',
    ];
    const hairColors = <String>[
      'black', 'blue_black', 'dark_brown', 'chocolate_brown',
      'chestnut_brown', 'warm_brown', 'ash_brown', 'auburn',
      'copper', 'ginger', 'dark_red', 'burgundy', 'honey_blonde',
      'golden_blonde', 'ash_blonde', 'platinum_blonde', 'silver',
      'gray', 'white',
    ];
    const eyebrowStyles = <String>[
      'bold_straight', 'comma', 'feathered', 'high_arch', 'rounded',
      'short_straight', 'slight_angle', 'soft_arch', 'straight',
      'textured_wild', 'thick_natural', 'thin_defined',
    ];
    final hairStyles = CharacterHair.masterStylesFor(gender);
    final adultHair = hairStyles[random.nextInt(hairStyles.length)];
    final infantHair = CharacterHair.infantStyles[
      random.nextInt(CharacterHair.infantStyles.length)
    ];
    final toddlerHairStyles = gender == Gender.female
        ? CharacterHair.femaleToddlerStyles
        : CharacterHair.maleToddlerStyles;
    final childHairStyles = gender == Gender.female
        ? CharacterHair.femaleChildStyles
        : CharacterHair.maleChildStyles;
    final childSkinIndex = childAppearance == null
        ? -1
        : skinTones.indexOf(childAppearance.skinTone);
    final skinTone = childSkinIndex < 0
        ? skinTones[random.nextInt(skinTones.length)]
        : skinTones[(childSkinIndex + random.nextInt(5) - 2)
            .clamp(0, skinTones.length - 1).toInt()];
    final inheritsEyeColor = childAppearance != null && random.nextBool();
    final inheritsHairColor = childAppearance != null && random.nextBool();

    return CharacterAppearance(
      base: 'default',
      skinTone: skinTone,
      hair: adultHair,
      infantHair: infantHair,
      toddlerHair: toddlerHairStyles[
        random.nextInt(toddlerHairStyles.length)
      ],
      childHair: childHairStyles[
        random.nextInt(childHairStyles.length)
      ],
      hairColor: inheritsHairColor &&
              hairColors.contains(childAppearance.hairColor)
          ? childAppearance.hairColor
          : hairColors[random.nextInt(hairColors.length)],
      eyes: 'default',
      eyeColor: inheritsEyeColor &&
              eyeColors.contains(childAppearance.eyeColor)
          ? childAppearance.eyeColor
          : eyeColors[random.nextInt(eyeColors.length)],
      eyebrows: eyebrowStyles[random.nextInt(eyebrowStyles.length)],
      beard: gender == Gender.male && random.nextInt(100) < 35
          ? 'beard_0${1 + random.nextInt(5)}'
          : 'none',
    );
  }

  static EmploymentStatus _generateEmploymentStatus({
    required SeededRandom random,
    required StartingBackgroundTier tier,
  }) {
    final roll = random.nextInt(100);

    return switch (tier) {
      StartingBackgroundTier.struggling => roll < 35
          ? EmploymentStatus.unemployed
          : roll < 55
              ? EmploymentStatus.selfEmployed
              : roll < 90
                  ? EmploymentStatus.employed
                  : EmploymentStatus.homemaker,
      StartingBackgroundTier.workingClass => roll < 15
          ? EmploymentStatus.unemployed
          : roll < 30
              ? EmploymentStatus.selfEmployed
              : roll < 90
                  ? EmploymentStatus.employed
                  : EmploymentStatus.homemaker,
      StartingBackgroundTier.middleClass => roll < 8
          ? EmploymentStatus.unemployed
          : roll < 18
              ? EmploymentStatus.selfEmployed
              : roll < 85
                  ? EmploymentStatus.employed
                  : EmploymentStatus.homemaker,
      StartingBackgroundTier.upperMiddleClass => roll < 5
          ? EmploymentStatus.unemployed
          : roll < 20
              ? EmploymentStatus.selfEmployed
              : roll < 90
                  ? EmploymentStatus.employed
                  : EmploymentStatus.homemaker,
      StartingBackgroundTier.wealthy => roll < 5
          ? EmploymentStatus.unemployed
          : roll < 30
              ? EmploymentStatus.selfEmployed
              : roll < 85
                  ? EmploymentStatus.employed
                  : EmploymentStatus.homemaker,
      StartingBackgroundTier.veryWealthy => roll < 5
          ? EmploymentStatus.unemployed
          : roll < 40
              ? EmploymentStatus.selfEmployed
              : roll < 90
                  ? EmploymentStatus.employed
                  : EmploymentStatus.homemaker,
    };
  }

  static HousingStatus _generateHousingStatus({
    required SeededRandom random,
    required StartingBackgroundTier tier,
  }) {
    final roll = random.nextInt(100);

    return switch (tier) {
      StartingBackgroundTier.struggling => roll < 45
          ? HousingStatus.rented
          : roll < 70
              ? HousingStatus.temporary
              : roll < 85
                  ? HousingStatus.providedByOthers
                  : roll < 97
                      ? HousingStatus.familyOwned
                      : HousingStatus.homeless,
      StartingBackgroundTier.workingClass => roll < 60
          ? HousingStatus.rented
          : roll < 80
              ? HousingStatus.ownedWithMortgage
              : roll < 90
                  ? HousingStatus.familyOwned
                  : HousingStatus.temporary,
      StartingBackgroundTier.middleClass => roll < 30
          ? HousingStatus.rented
          : roll < 65
              ? HousingStatus.ownedWithMortgage
              : roll < 95
                  ? HousingStatus.familyOwned
                  : HousingStatus.temporary,
      StartingBackgroundTier.upperMiddleClass => roll < 15
          ? HousingStatus.rented
          : roll < 50
              ? HousingStatus.ownedWithMortgage
              : HousingStatus.familyOwned,
      StartingBackgroundTier.wealthy => roll < 5
          ? HousingStatus.rented
          : roll < 20
              ? HousingStatus.ownedWithMortgage
              : HousingStatus.familyOwned,
      StartingBackgroundTier.veryWealthy => roll < 2
          ? HousingStatus.rented
          : roll < 10
              ? HousingStatus.ownedWithMortgage
              : HousingStatus.familyOwned,
    };
  }

  static List<FamilyAsset> _generateAssets({
    required SeededRandom random,
    required String householdId,
    required List<ParentNpc> parents,
    required StartingBackgroundTier tier,
    required HousingStatus housingStatus,
  }) {
    final assets = <FamilyAsset>[];

    if (housingStatus == HousingStatus.familyOwned ||
        housingStatus == HousingStatus.ownedWithMortgage) {
      final propertyRange = _propertyValueRange(tier);

      assets.add(
        FamilyAsset(
          id: '$householdId-property',
          name: 'Family home',
          type: FamilyAssetType.property,
          value: _moneyBetween(
            random,
            propertyRange.$1,
            propertyRange.$2,
          ),
        ),
      );
    }

    final countRange = _additionalAssetCountRange(tier);
    final count = countRange.$1 +
        random.nextInt(countRange.$2 - countRange.$1 + 1);

    for (var index = 0; index < count; index++) {
      final type = _randomAssetType(random);
      final valueRange = _assetValueRange(tier, type);
      final owner = random.nextInt(100) < 60
          ? null
          : parents[random.nextInt(parents.length)].id;

      assets.add(
        FamilyAsset(
          id: '$householdId-asset-$index',
          name: _assetName(type),
          type: type,
          value: _moneyBetween(
            random,
            valueRange.$1,
            valueRange.$2,
          ),
          ownerNpcId: owner,
        ),
      );
    }

    return assets;
  }

  static FamilyAssetType _randomAssetType(SeededRandom random) {
    const types = [
      FamilyAssetType.vehicle,
      FamilyAssetType.business,
      FamilyAssetType.investment,
      FamilyAssetType.valuable,
      FamilyAssetType.other,
    ];

    return types[random.nextInt(types.length)];
  }

  static String _assetName(FamilyAssetType type) {
    return switch (type) {
      FamilyAssetType.property => 'Property',
      FamilyAssetType.vehicle => 'Vehicle',
      FamilyAssetType.business => 'Family business',
      FamilyAssetType.investment => 'Investment portfolio',
      FamilyAssetType.valuable => 'Valuables',
      FamilyAssetType.other => 'Other family asset',
    };
  }

  static String _firstName(
    SeededRandom random,
    Gender gender,
    String countryCode,
  ) {
    return CulturalRandomizerCatalog.randomFirstName(
      countryCode: countryCode,
      gender: gender,
      random: math.Random(
        random.nextInt(0x7fffffff),
      ),
    );
  }

  static String? _occupation(
    SeededRandom random,
    EmploymentStatus status,
  ) {
    const employedOccupations = [
      'Teacher',
      'Office worker',
      'Technician',
      'Nurse',
      'Driver',
      'Sales worker',
      'Engineer',
      'Administrator',
    ];

    const selfEmployedOccupations = [
      'Shop owner',
      'Freelancer',
      'Food seller',
      'Contractor',
      'Small business owner',
    ];

    return switch (status) {
      EmploymentStatus.employed =>
        employedOccupations[random.nextInt(employedOccupations.length)],
      EmploymentStatus.selfEmployed => selfEmployedOccupations[
          random.nextInt(selfEmployedOccupations.length)
        ],
      _ => null,
    };
  }

  static (int, int) _annualIncomeRange(StartingBackgroundTier tier) {
    return switch (tier) {
      StartingBackgroundTier.struggling => (720000, 2160000),
      StartingBackgroundTier.workingClass => (1200000, 3600000),
      StartingBackgroundTier.middleClass => (2160000, 6000000),
      StartingBackgroundTier.upperMiddleClass => (3600000, 9600000),
      StartingBackgroundTier.wealthy => (6000000, 18000000),
      StartingBackgroundTier.veryWealthy => (9600000, 36000000),
    };
  }

  static (int, int) _savingsRange(StartingBackgroundTier tier) {
    return switch (tier) {
      StartingBackgroundTier.struggling => (0, 100000),
      StartingBackgroundTier.workingClass => (0, 500000),
      StartingBackgroundTier.middleClass => (200000, 2500000),
      StartingBackgroundTier.upperMiddleClass => (1000000, 10000000),
      StartingBackgroundTier.wealthy => (5000000, 50000000),
      StartingBackgroundTier.veryWealthy => (20000000, 200000000),
    };
  }

  static (int, int) _annualLivingCostRange(StartingBackgroundTier tier) {
    return switch (tier) {
      StartingBackgroundTier.struggling => (960000, 3000000),
      StartingBackgroundTier.workingClass => (1800000, 4200000),
      StartingBackgroundTier.middleClass => (3000000, 7200000),
      StartingBackgroundTier.upperMiddleClass => (4800000, 10800000),
      StartingBackgroundTier.wealthy => (8400000, 21600000),
      StartingBackgroundTier.veryWealthy => (14400000, 48000000),
    };
  }

  static (int, int) _propertyValueRange(StartingBackgroundTier tier) {
    return switch (tier) {
      StartingBackgroundTier.struggling => (5000000, 15000000),
      StartingBackgroundTier.workingClass => (10000000, 40000000),
      StartingBackgroundTier.middleClass => (30000000, 100000000),
      StartingBackgroundTier.upperMiddleClass => (80000000, 250000000),
      StartingBackgroundTier.wealthy => (200000000, 1000000000),
      StartingBackgroundTier.veryWealthy => (500000000, 5000000000),
    };
  }

  static (int, int) _additionalAssetCountRange(
    StartingBackgroundTier tier,
  ) {
    return switch (tier) {
      StartingBackgroundTier.struggling => (0, 1),
      StartingBackgroundTier.workingClass => (0, 2),
      StartingBackgroundTier.middleClass => (1, 3),
      StartingBackgroundTier.upperMiddleClass => (1, 4),
      StartingBackgroundTier.wealthy => (2, 5),
      StartingBackgroundTier.veryWealthy => (3, 7),
    };
  }

  static (int, int) _assetValueRange(
    StartingBackgroundTier tier,
    FamilyAssetType type,
  ) {
    final multiplier = switch (type) {
      FamilyAssetType.vehicle => 1,
      FamilyAssetType.business => 4,
      FamilyAssetType.investment => 3,
      FamilyAssetType.valuable => 1,
      FamilyAssetType.other => 1,
      FamilyAssetType.property => 5,
    };

    final baseRange = switch (tier) {
      StartingBackgroundTier.struggling => (10000, 100000),
      StartingBackgroundTier.workingClass => (30000, 300000),
      StartingBackgroundTier.middleClass => (100000, 1000000),
      StartingBackgroundTier.upperMiddleClass => (300000, 3000000),
      StartingBackgroundTier.wealthy => (1000000, 10000000),
      StartingBackgroundTier.veryWealthy => (5000000, 50000000),
    };

    return (
      baseRange.$1 * multiplier,
      baseRange.$2 * multiplier,
    );
  }

  static Money _moneyBetween(
    SeededRandom random,
    int minimum,
    int maximum,
  ) {
    return Money.fromMinorUnits(
      minimum + random.nextInt(maximum - minimum + 1),
    );
  }
}
