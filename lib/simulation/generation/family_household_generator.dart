
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
import '../../domain/family/sibling_npc.dart';
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

    final isOrphanagePlacement = parents.any(
      (parent) => parent.role == FamilyRole.guardian,
    );

    // An orphanage guardian is not a biological or adoptive sibling's parent.
    // Do not generate player siblings for an orphanage starting scenario.
    final siblings = isOrphanagePlacement
        ? <SiblingNpc>[]
        : _generateSiblings(
            random: random,
            birthYear: birthYear,
            familyName: normalizedFamilyName,
            countryCode: countryCode,
            hasStepParent: false,
            childAppearance: childAppearance,
          );

    final housingStatus = isOrphanagePlacement
        ? HousingStatus.providedByOthers
        : _generateHousingStatus(
            random: random,
            tier: tier,
          );

    // New lives begin without accumulated savings or modeled living costs.
    // Keep legacy fields at zero so older save schemas remain compatible.
    const annualLivingCosts = Money.zero();

    const totalDebt = Money.zero();

    final countryEconomicProfile =
        CountryEconomicProfile.forCountryCode(countryCode);
    final assets = _generateAssets(
      random: random,
      householdId: householdId,
      tier: tier,
      housingStatus: housingStatus,
      countryEconomicProfile: countryEconomicProfile,
    ).map((asset) => asset.ownerNpcId == null
        ? FamilyAsset(
            id: asset.id,
            name: asset.name,
            type: asset.type,
            value: asset.value,
            ownerNpcId: parents.first.id,
          )
        : asset).toList(growable: false);
    final financiallyInitializedParents = parents.map((parent) {
      final personalAssets = assets
          .where((asset) => asset.ownerNpcId == parent.id)
          .toList(growable: false);
      return parent.copyWith(
        cashBalance: Money.zero(),
        annualExpenses: Money.zero(),
        assets: personalAssets,
        countryCode: countryCode,
        // Guardians are not inheritance parents; biological parents share
        // their estate with the player's generated siblings.
        siblingCount: parent.role == FamilyRole.guardian ? 0 : siblings.length,
      );
    }).toList(growable: false);

    return FamilyHousehold(
      id: householdId,
      parents: financiallyInitializedParents,
      siblings: siblings,
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
    // Starting family scenarios: intact 50%, single mother 20%,
    // mother dies in childbirth 10%, orphanage guardian 20%.
    final scenarioRoll = random.nextInt(100);

    if (scenarioRoll < 50) {
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

    if (scenarioRoll < 70) {
      return [
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

    if (scenarioRoll < 80) {
      final father = _generateParent(
        random: random,
        birthYear: birthYear,
        familyName: familyName,
        countryCode: countryCode,
        tier: tier,
        childAppearance: childAppearance,
        gender: Gender.male,
        role: FamilyRole.father,
        id: 'parent-father-$birthYear',
      );
      final mother = _generateParent(
        random: random,
        birthYear: birthYear,
        familyName: familyName,
        countryCode: countryCode,
        tier: tier,
        childAppearance: childAppearance,
        gender: Gender.female,
        role: FamilyRole.mother,
        id: 'parent-mother-$birthYear',
      ).copyWith(isAlive: false, deathYear: birthYear);
      return [father, mother];
    }

    final gender = random.nextBool() ? Gender.male : Gender.female;
    final guardianFamilyName = _guardianFamilyName(
      random: random,
      countryCode: countryCode,
      playerFamilyName: familyName,
    );

    return [
      _generateParent(
        random: random,
        birthYear: birthYear,
        familyName: guardianFamilyName,
        countryCode: countryCode,
        tier: tier,
        childAppearance: childAppearance,
        gender: gender,
        role: FamilyRole.guardian,
        id: 'parent-guardian-$birthYear',
      ),
    ];
  }

  static String _guardianFamilyName({
    required SeededRandom random,
    required String countryCode,
    required String playerFamilyName,
  }) {
    // A guardian is a separate person, so do not reuse the player's surname.
    // Retry with the country's surname pool until a different surname is found.
    for (var attempt = 0; attempt < 20; attempt++) {
      final candidate = CulturalRandomizerCatalog.randomLastName(
        countryCode: countryCode,
        random: math.Random(random.nextInt(0x7fffffff)),
      );

      if (candidate.trim().toLowerCase() !=
          playerFamilyName.trim().toLowerCase()) {
        return candidate;
      }
    }

    // Defensive fallback for unusual/custom surnames or random sequences.
    return '$playerFamilyName Guardian';
  }

  static List<SiblingNpc> _generateSiblings({
    required SeededRandom random,
    required int birthYear,
    required String familyName,
    required String countryCode,
    required bool hasStepParent,
    CharacterAppearance? childAppearance,
  }) {
    final count = random.nextInt(4); // 0–3 siblings per new life.
    final siblings = <SiblingNpc>[];
    final usedNames = <String>{};
    for (var i = 0; i < count; i++) {
      final gender = random.nextBool() ? Gender.male : Gender.female;
      final relationshipRoll = random.nextInt(100);
      final relationship = !hasStepParent
          ? SiblingRelationship.fullSibling
          : relationshipRoll < 55
              ? SiblingRelationship.halfSibling
              : SiblingRelationship.stepSibling;
      final older = random.nextBool();
      final ageDifference = 1 + random.nextInt(18);
      final joinsTwinBirth = i > 0 && random.nextInt(100) < 12;
      final siblingBirthYear = joinsTwinBirth
          ? siblings.last.birthYear
          : older
              ? birthYear - ageDifference
              : birthYear + ageDifference;
      final siblingLastName = relationship == SiblingRelationship.stepSibling ||
              (relationship == SiblingRelationship.halfSibling &&
                  random.nextBool())
          ? CulturalRandomizerCatalog.randomLastName(
              countryCode: countryCode,
              random: math.Random(random.nextInt(0x7fffffff)),
            )
          : familyName;
      var firstName = _firstName(random, gender, countryCode);
      var fullNameKey = '${firstName.toLowerCase()} ${siblingLastName.toLowerCase()}';
      var attempts = 0;
      while (usedNames.contains(fullNameKey) && attempts < 30) {
        firstName = _firstName(random, gender, countryCode);
        fullNameKey = '${firstName.toLowerCase()} ${siblingLastName.toLowerCase()}';
        attempts++;
      }
      // Extremely small/custom name catalogs may exhaust retries; suffix the
      // display first name rather than creating indistinguishable NPC cards.
      if (usedNames.contains(fullNameKey)) firstName = '$firstName ${i + 1}';
      usedNames.add('${firstName.toLowerCase()} ${siblingLastName.toLowerCase()}');
      siblings.add(SiblingNpc(
        id: 'sibling-$birthYear-$i',
        firstName: firstName,
        isTwin: joinsTwinBirth,
        lastName: siblingLastName,
        gender: gender,
        birthYear: siblingBirthYear,
        relationship: relationship,
        countryCode: countryCode,
        appearance: _generateAppearance(
          random: random,
          gender: gender,
          childAppearance: childAppearance,
        ),
      ));
    }
    final birthYearCounts = <int, int>{};
    for (final sibling in siblings) {
      birthYearCounts.update(sibling.birthYear, (count) => count + 1,
          ifAbsent: () => 1);
    }
    for (var i = 0; i < siblings.length; i++) {
      final sibling = siblings[i];
      if (birthYearCounts[sibling.birthYear]! > 1 && !sibling.isTwin) {
        siblings[i] = SiblingNpc(
          id: sibling.id,
          firstName: sibling.firstName,
          lastName: sibling.lastName,
          gender: sibling.gender,
          birthYear: sibling.birthYear,
          relationship: sibling.relationship,
          appearance: sibling.appearance,
          countryCode: sibling.countryCode,
          relationshipPercent: sibling.relationshipPercent,
          isTwin: true,
        );
      }
    }
    return siblings;
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

    final countryIncomeRange = CountryEconomicProfile.forCountryCode(
      countryCode,
    ).scaleRange(_annualIncomeRange(tier));
    final annualIncome = hasIncome
        ? _moneyBetween(
            random,
            countryIncomeRange.$1,
            countryIncomeRange.$2,
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
      // Struggling through middle class: rent, mortgage, or owned outright.
      StartingBackgroundTier.struggling => roll < 60
          ? HousingStatus.rented
          : roll < 75
              ? HousingStatus.ownedWithMortgage
              : HousingStatus.familyOwned,
      StartingBackgroundTier.workingClass => roll < 55
          ? HousingStatus.rented
          : roll < 80
              ? HousingStatus.ownedWithMortgage
              : HousingStatus.familyOwned,
      StartingBackgroundTier.middleClass => roll < 30
          ? HousingStatus.rented
          : roll < 65
              ? HousingStatus.ownedWithMortgage
              : HousingStatus.familyOwned,
      // Upper middle class: mortgage or permanently owned home only.
      StartingBackgroundTier.upperMiddleClass => roll < 40
          ? HousingStatus.ownedWithMortgage
          : HousingStatus.familyOwned,
      // Wealthy and very wealthy families always own their home outright.
      StartingBackgroundTier.wealthy => HousingStatus.familyOwned,
      StartingBackgroundTier.veryWealthy => HousingStatus.familyOwned,
    };
  }

  static List<FamilyAsset> _generateAssets({
    required SeededRandom random,
    required String householdId,
    required StartingBackgroundTier tier,
    required HousingStatus housingStatus,
    required CountryEconomicProfile countryEconomicProfile,
  }) {
    final assets = <FamilyAsset>[];

    if (housingStatus == HousingStatus.familyOwned ||
        housingStatus == HousingStatus.ownedWithMortgage) {
      final propertyRange = countryEconomicProfile.scaleRange(
        _propertyValueRange(tier),
      );

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

    // Parents' starting assets are limited to the family home.
    return assets;
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

  static (int, int) _propertyValueRange(StartingBackgroundTier tier) {
    return switch (tier) {
      StartingBackgroundTier.struggling => (5000000, 15000000),
      StartingBackgroundTier.workingClass => (15000000, 40000000),
      StartingBackgroundTier.middleClass => (40000000, 120000000),
      StartingBackgroundTier.upperMiddleClass => (120000000, 350000000),
      StartingBackgroundTier.wealthy => (350000000, 1500000000),
      StartingBackgroundTier.veryWealthy => (1500000000, 8000000000),
    };
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
