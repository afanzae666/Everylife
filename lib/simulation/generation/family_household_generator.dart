
import '../../domain/career/job_catalog.dart';
import '../economy/npc_economy.dart';
import 'dart:math' as math;

import 'package:everylife/core/money/money.dart';

import '../../core/random/seeded_random.dart';
import '../../domain/character/appearance.dart';
import '../../domain/character/character_hair.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import '../../domain/character/gender.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';
import 'country_economic_profile.dart';

class FamilyHouseholdGenerator {
  const FamilyHouseholdGenerator._();

  /// A normal household: two living parents with random jobs and money,
  /// a random home and 0-3 siblings. There are no starting backgrounds.
  static FamilyHousehold generate({
    required SeededRandom random,
    required int birthYear,
    required String familyName,
    String countryCode = 'ID',
    CharacterAppearance? childAppearance,
  }) {
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
      childAppearance: childAppearance,
    );

    final siblings = _generateSiblings(
      random: random,
      birthYear: birthYear,
      familyName: normalizedFamilyName,
      countryCode: countryCode,
      parents: parents,
      hasStepParent: false,
      childAppearance: childAppearance,
    );

    final housingStatus = _generateHousingStatus(random: random);

    // New lives begin without accumulated savings or modeled living costs.
    // Keep legacy fields at zero so older save schemas remain compatible.
    const annualLivingCosts = Money.zero();

    const totalDebt = Money.zero();

    final countryEconomicProfile =
        CountryEconomicProfile.forCountryCode(countryCode);
    var unowned = 0;
    final assets = _generateAssets(
      random: random,
      householdId: householdId,
      housingStatus: housingStatus,
      countryEconomicProfile: countryEconomicProfile,
    ).map((asset) {
      if (asset.ownerNpcId != null) return asset;

      // Things nobody owns yet are shared out between the two parents, so
      // one parent is not rich on paper while the other owns nothing.
      final owner = parents[unowned % parents.length];

      unowned++;

      return FamilyAsset(
        id: asset.id,
        name: asset.name,
        type: asset.type,
        value: asset.value,
        ownerNpcId: owner.id,
      );
    }).toList(growable: false);
    final financiallyInitializedParents = parents.map((parent) {
      final personalAssets = assets
          .where((asset) => asset.ownerNpcId == parent.id)
          .toList(growable: false);

      // A working parent has been saving since their early twenties.
      final yearsWorked = (birthYear - parent.birthYear - 20).clamp(0, 45);
      final savings = parent.annualIncome.minorUnits *
          NpcEconomy.savingsPercent ~/
          100 *
          yearsWorked;

      return parent.copyWith(
        cashBalance: Money.fromMinorUnits(savings),
        annualExpenses: Money.zero(),
        assets: personalAssets,
        countryCode: countryCode,
        // Parents share their estate with the player's siblings.
        siblingCount: siblings.length,
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
    CharacterAppearance? childAppearance,
  }) {
    return [
      _generateParent(
        random: random,
        birthYear: birthYear,
        familyName: familyName,
        countryCode: countryCode,
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
        childAppearance: childAppearance,
        gender: Gender.female,
        role: FamilyRole.mother,
        id: 'parent-mother-$birthYear',
      ),
    ];
  }

  static List<SiblingNpc> _generateSiblings({
    required SeededRandom random,
    required int birthYear,
    required String familyName,
    required String countryCode,
    required List<ParentNpc> parents,
    required bool hasStepParent,
    CharacterAppearance? childAppearance,
    int? latestAllowedBirthYear,
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
      final joinsTwinBirth = i > 0 && random.nextInt(100) < 12;
      // A twin always shares the previous sibling's relationship so the
      // pair has the same parents and the same plausible birth window.
      final effectiveRelationship =
          joinsTwinBirth ? siblings.last.relationship : relationship;
      final siblingBirthYear = joinsTwinBirth
          ? siblings.last.birthYear
          : _pickSiblingBirthYear(
              random: random,
              playerBirthYear: birthYear,
              relationship: effectiveRelationship,
              parents: parents,
              latestAllowedBirthYear: latestAllowedBirthYear,
            );
      final siblingLastName = effectiveRelationship == SiblingRelationship.stepSibling ||
              (effectiveRelationship == SiblingRelationship.halfSibling &&
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
        relationship: effectiveRelationship,
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

    // Adult older siblings already have a job (or not) and savings.
    for (var i = 0; i < siblings.length; i++) {
      final sibling = siblings[i];
      final age = birthYear - sibling.birthYear;

      if (age >= 18) {
        siblings[i] = sibling.copyWith(
          finance: NpcEconomy.forSibling(
            id: sibling.id,
            age: age,
            countryCode: sibling.countryCode,
          ),
        );
      }
    }

    return siblings;
  }

  /// Youngest age at which a parent can plausibly have a child.
  static const int _minParentAge = 18;

  /// Oldest plausible age at which a mother or father has a child.
  static const int _maxMotherAge = 45;
  static const int _maxFatherAge = 60;

  /// Returns the inclusive birth-year window in which [parent] could have
  /// had a child.
  static (int, int) _parentBirthWindow(ParentNpc parent) {
    final maxAge = parent.gender == Gender.female
        ? _maxMotherAge
        : _maxFatherAge;

    return (
      parent.birthYear + _minParentAge,
      parent.birthYear + maxAge,
    );
  }

  /// Picks a sibling birth year that is biologically plausible.
  ///
  /// Full siblings must fit the birth window of every biological parent.
  /// Half and step siblings are bound by the step-parent when one exists.
  /// The year is within 18 years of the player and is never the player's
  /// own birth year (same-year siblings are generated explicitly as twins).
  static int _pickSiblingBirthYear({
    required SeededRandom random,
    required int playerBirthYear,
    required SiblingRelationship relationship,
    required List<ParentNpc> parents,
    int? latestAllowedBirthYear,
  }) {
    final Iterable<ParentNpc> bindingParents;
    if (relationship == SiblingRelationship.fullSibling) {
      bindingParents = parents.where(
        (parent) =>
            parent.role == FamilyRole.father ||
            parent.role == FamilyRole.mother,
      );
    } else {
      final stepParents = parents.where(
        (parent) =>
            parent.role == FamilyRole.stepMother ||
            parent.role == FamilyRole.stepFather,
      );
      bindingParents = stepParents.isNotEmpty ? stepParents : parents;
    }

    var earliest = playerBirthYear - 18;
    var latest = playerBirthYear + 18;

    for (final parent in bindingParents) {
      final window = _parentBirthWindow(parent);
      if (window.$1 > earliest) earliest = window.$1;
      if (window.$2 < latest) latest = window.$2;
    }

    if (latestAllowedBirthYear != null && latestAllowedBirthYear < latest) {
      latest = latestAllowedBirthYear;
    }

    final olderYears = <int>[
      for (var year = earliest; year < playerBirthYear && year <= latest; year++)
        year,
    ];
    final youngerYears = <int>[
      for (var year = playerBirthYear + 1; year <= latest; year++)
        if (year >= earliest) year,
    ];

    final preferOlder = random.nextBool();
    final pool = preferOlder
        ? (olderYears.isNotEmpty ? olderYears : youngerYears)
        : (youngerYears.isNotEmpty ? youngerYears : olderYears);

    if (pool.isEmpty) {
      // Defensive fallback: parents are generated at least 22 years old, so
      // the four years before the player are always inside the window.
      return playerBirthYear - 1 - random.nextInt(4);
    }

    return pool[random.nextInt(pool.length)];
  }

  static ParentNpc _generateParent({
    required SeededRandom random,
    required int birthYear,
    required String familyName,
    required String countryCode,
    required Gender gender,
    required FamilyRole role,
    required String id,
    CharacterAppearance? childAppearance,
  }) {
    final ageAtChildBirth = 22 + random.nextInt(24);
    final employmentStatus = _generateEmploymentStatus(random);

    final hasIncome = employmentStatus == EmploymentStatus.employed ||
        employmentStatus == EmploymentStatus.selfEmployed;

    final countryIncomeRange = CountryEconomicProfile.forCountryCode(
      countryCode,
    ).scaleRange(_annualIncomeRange);
    final annualIncome = hasIncome
        ? _wideMoney(
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

  static EmploymentStatus _generateEmploymentStatus(SeededRandom random) {
    final roll = random.nextInt(100);

    if (roll < 10) return EmploymentStatus.unemployed;
    if (roll < 30) return EmploymentStatus.selfEmployed;
    if (roll < 90) return EmploymentStatus.employed;

    return EmploymentStatus.homemaker;
  }

  static HousingStatus _generateHousingStatus({
    required SeededRandom random,
  }) {
    final roll = random.nextInt(100);

    if (roll < 40) return HousingStatus.rented;
    if (roll < 70) return HousingStatus.ownedWithMortgage;

    return HousingStatus.familyOwned;
  }

  static List<FamilyAsset> _generateAssets({
    required SeededRandom random,
    required String householdId,
    required HousingStatus housingStatus,
    required CountryEconomicProfile countryEconomicProfile,
  }) {
    final assets = <FamilyAsset>[];

    if (housingStatus == HousingStatus.familyOwned ||
        housingStatus == HousingStatus.ownedWithMortgage) {
      final propertyRange = countryEconomicProfile.scaleRange(
        _propertyValueRange,
      );

      assets.add(
        FamilyAsset(
          id: '$householdId-property',
          name: 'Family home',
          type: FamilyAssetType.property,
          value: _wideMoney(
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
    // Parents only have jobs that exist in the game's job list.
    final selfEmployedIds = JobCatalog.selfEmployedJobIds;

    return switch (status) {
      EmploymentStatus.employed =>
        JobCatalog.all[random.nextInt(JobCatalog.all.length)].title,
      EmploymentStatus.selfEmployed => JobCatalog.byId(
          selfEmployedIds[random.nextInt(selfEmployedIds.length)],
        )!
            .title,
      _ => null,
    };
  }

  /// Yearly income of a working parent: anywhere from very poor to very rich.
  static const (int, int) _annualIncomeRange = (720000, 36000000);

  /// Value of the family home: anywhere from a hut to a mansion.
  static const (int, int) _propertyValueRange = (5000000, 2000000000);

  /// A random amount between [minimum] and [maximum] on a log scale, so every
  /// level from poor to rich is about equally likely.
  static Money _wideMoney(
    SeededRandom random,
    int minimum,
    int maximum,
  ) {
    final u = random.nextInt(10001) / 10000;
    final value = minimum * math.pow(maximum / minimum, u);

    return Money.fromMinorUnits(value.round());
  }
}
