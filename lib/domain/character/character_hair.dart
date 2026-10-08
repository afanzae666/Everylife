import 'dart:math';

import 'gender.dart';
import 'life_stage.dart';

/// Single source of truth for character hair identifiers, stage rules,
/// gender rules, and asset resolution.
///
/// Appearance stores only the identifier. Rendering code should use this
/// resolver instead of maintaining its own hair mapping.
abstract final class CharacterHair {
  static const String bald = 'bald';

  static const List<String> infantStyles = <String>[
    'infant_01',
    'infant_02',
    'infant_03',
  ];

  static const List<String> maleToddlerStyles = <String>[
    'male_hair_toddler_01',
    'male_hair_toddler_02',
    'male_hair_toddler_03',
  ];

  static const List<String> femaleToddlerStyles = <String>[
    'female_hair_toddler_01',
    'female_hair_toddler_02',
    'female_hair_toddler_03',
  ];

  static const List<String> maleChildStyles = <String>[
    'male_hair_child_01',
    'male_hair_child_02',
    'male_hair_child_03',
    'male_hair_child_04',
    'male_hair_child_05',
    'male_hair_child_06',
  ];

  static const List<String> femaleChildStyles = <String>[
    'female_hair_child_01',
    'female_hair_child_02',
    'female_hair_child_03',
    'female_hair_child_04',
    'female_hair_child_05',
    'female_hair_child_06',
  ];

  static const List<String> maleAdultStyles = <String>[
    'male_hair_01',
    'male_hair_02',
    'male_hair_03',
    'male_hair_04',
    'male_hair_05',
    'male_hair_06',
    'male_hair_07',
  ];

  static const List<String> femaleAdultStyles = <String>[
    'female_hair_01',
    'female_hair_02',
    'female_hair_03',
    'female_hair_04',
    'female_hair_05',
    'female_hair_06',
    'female_hair_07',
  ];

  /// Hair styles used by the main adult/teen selector.
  static List<String> masterStylesFor(Gender gender) {
    return List<String>.unmodifiable(
      gender == Gender.female
          ? femaleAdultStyles
          : maleAdultStyles,
    );
  }

  /// Returns the valid hair pool for a life stage and gender.
  static List<String> stylesFor({
    required Gender gender,
    required LifeStage stage,
  }) {
    switch (stage) {
      case LifeStage.infant:
        return List<String>.unmodifiable(infantStyles);

      case LifeStage.toddler:
        return List<String>.unmodifiable(
          gender == Gender.female
              ? femaleToddlerStyles
              : maleToddlerStyles,
        );

      case LifeStage.child:
        return List<String>.unmodifiable(
          gender == Gender.female
              ? femaleChildStyles
              : maleChildStyles,
        );

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return masterStylesFor(gender);
    }
  }

  /// Generates one valid automatic hairstyle.
  ///
  /// Bald is intentionally excluded because this method is used when a
  /// hairstyle must be generated automatically.
  static String randomAutomaticHair({
    required Random random,
    required Gender gender,
    required LifeStage stage,
  }) {
    final List<String> styles = stylesFor(
      gender: gender,
      stage: stage,
    );

    return styles[random.nextInt(styles.length)];
  }

  /// Checks whether a stored hairstyle is valid for the current stage.
  ///
  /// Bald is always valid because it is a global override.
  static bool isValidForStage({
    required String hair,
    required Gender gender,
    required LifeStage stage,
  }) {
    if (hair == bald) {
      return true;
    }

    return stylesFor(
      gender: gender,
      stage: stage,
    ).contains(hair);
  }

  /// Converts a stored hairstyle identifier into its PNG asset path.
  ///
  /// Invalid or legacy identifiers are normalized to the first valid style
  /// for the current stage. Bald always wins and produces no hair layer.
  static String? assetPath({
    required String hair,
    required Gender gender,
    required LifeStage stage,
  }) {
    if (hair == bald) {
      return null;
    }

    final List<String> styles = stylesFor(
      gender: gender,
      stage: stage,
    );

    final String selected =
        styles.contains(hair) ? hair : styles.first;

    return 'assets/character/hair/$selected.png';
  }
}
