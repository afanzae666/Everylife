
import 'dart:math';

import 'gender.dart';
import 'life_stage.dart';

/// Single source of truth for character hair identifiers, stage rules,
/// gender rules, and asset resolution.
abstract final class CharacterHair {
  static const String bald = 'bald';

  /// Infant hair is gender-neutral. Bald is a valid random option.
  static const List<String> infantStyles = <String>[
    bald,
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
  /// Infant can randomly be bald or receive an infant hairstyle.
  /// Toddler and child use gender-specific pools without bald.
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

  /// Resolves the hairstyle displayed at the current life stage.
  ///
  /// A player-selected bald hairstyle remains bald at every stage.
  /// Random infant baldness does not affect later stages.
  /// Missing stage-specific hair in older saves uses a stable fallback.
  static String resolveHairForStage({
    required String playerHair,
    required String? infantHair,
    required String? toddlerHair,
    required String? childHair,
    required Gender gender,
    required LifeStage stage,
  }) {
    if (playerHair == bald) {
      return bald;
    }

    switch (stage) {
      case LifeStage.infant:
        return infantHair ??
            _fallbackStyle(
              stylesFor(
                gender: gender,
                stage: LifeStage.infant,
              ),
            );

      case LifeStage.toddler:
        return toddlerHair ??
            _fallbackStyle(
              stylesFor(
                gender: gender,
                stage: LifeStage.toddler,
              ),
            );

      case LifeStage.child:
        return childHair ??
            _fallbackStyle(
              stylesFor(
                gender: gender,
                stage: LifeStage.child,
              ),
            );

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return playerHair;
    }
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
  /// Bald produces no hair layer.
  /// Infant assets: assets/character/hair/
  /// Toddler assets: assets/character/hair/toddler/
  /// Child assets: assets/character/hair/child/
  /// Teen through senior assets: assets/character/hair/
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

    final String selected = styles.contains(hair)
        ? hair
        : _fallbackStyle(styles);

    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/hair/$selected.png';

      case LifeStage.toddler:
        return 'assets/character/hair/toddler/$selected.png';

      case LifeStage.child:
        return 'assets/character/hair/child/$selected.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/hair/$selected.png';
    }
  }

  /// Returns a safe non-bald fallback from a valid stage pool.
  static String _fallbackStyle(List<String> styles) {
    for (final style in styles) {
      if (style != bald) {
        return style;
      }
    }

    return bald;
  }
}
