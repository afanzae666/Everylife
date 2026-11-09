import 'dart:math' as math;

import '../../domain/career/school_npc.dart';
import '../../domain/character/appearance.dart';
import '../../domain/character/character.dart';
import '../../domain/character/character_hair.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import '../../domain/character/gender.dart';
import '../../domain/love/love_state.dart';

/// The look of a school NPC, made from the same avatar assets as every other
/// character. It only depends on the NPC itself, so nothing needs saving and
/// older saves get faces too.
abstract final class SchoolAppearance {
  static const _skin = <String>[
    'pale', 'very_light', 'light', 'light_medium', 'medium',
    'medium_tan', 'tan', 'deep_tan', 'brown', 'deep_brown',
    'dark', 'very_dark',
  ];
  static const _eyes = <String>[
    'light_blue', 'deep_blue', 'gray', 'blue_green', 'green',
    'hazel', 'amber', 'brown', 'dark_brown', 'black',
  ];
  static const _hair = <String>[
    'black', 'blue_black', 'dark_brown', 'chocolate_brown',
    'chestnut_brown', 'warm_brown', 'ash_brown', 'auburn',
    'copper', 'ginger', 'dark_red', 'burgundy', 'honey_blonde',
    'golden_blonde', 'ash_blonde', 'platinum_blonde', 'silver',
    'gray', 'white',
  ];
  static const _brows = <String>[
    'bold_straight', 'comma', 'feathered', 'high_arch', 'rounded',
    'short_straight', 'slight_angle', 'soft_arch', 'straight',
    'textured_wild', 'thick_natural', 'thin_defined',
  ];

  static CharacterAppearance forNpc(SchoolNpc npc) {
    var seed = 7;

    for (final unit in '${npc.id}|${npc.firstName}|${npc.lastName}'.codeUnits) {
      seed = (seed * 31 + unit) & 0x3fffffff;
    }

    final random = math.Random(seed);
    final gender = npc.gender;

    String color(AppearanceFeature feature, List<String> ids) =>
        CulturalRandomizerCatalog.randomAppearanceColor(
          countryCode: npc.countryCode,
          feature: feature,
          availableIds: ids,
          random: random,
        );

    String pick(List<String> list) => list[random.nextInt(list.length)];

    final masters = CharacterHair.masterStylesFor(gender);
    final toddler = gender == Gender.female
        ? CharacterHair.femaleToddlerStyles
        : CharacterHair.maleToddlerStyles;
    final child = gender == Gender.female
        ? CharacterHair.femaleChildStyles
        : CharacterHair.maleChildStyles;

    return CharacterAppearance(
      base: 'default',
      skinTone: color(AppearanceFeature.skin, _skin),
      hair: pick(masters),
      infantHair: pick(CharacterHair.infantStyles),
      toddlerHair: pick(toddler),
      childHair: pick(child),
      hairColor: color(AppearanceFeature.hair, _hair),
      eyes: 'default',
      eyeColor: color(AppearanceFeature.eyes, _eyes),
      eyebrows: pick(_brows),
      beard: gender == Gender.male &&
              !npc.role.isStudent &&
              random.nextInt(100) < 30
          ? 'beard_0${1 + random.nextInt(5)}'
          : 'none',
    );
  }

  /// A character built from the NPC so the shared avatar can draw it.
  static Character characterFor(SchoolNpc npc) => Character.create(
        id: npc.id,
        firstName: npc.firstName,
        lastName: npc.lastName,
        gender: npc.gender,
        birthYear: npc.birthYear,
        appearance: forNpc(npc),
      );

  /// A child's look: the inherited skin, hair colour, eyes and brows, with
  /// hairstyles picked from the child's id.
  static Character characterForChild(ChildNpc child) {
    var seed = 11;

    for (final unit in child.id.codeUnits) {
      seed = (seed * 31 + unit) & 0x3fffffff;
    }

    final random = math.Random(seed);
    final gender = child.gender;

    String pick(List<String> list) => list[random.nextInt(list.length)];

    final masters = CharacterHair.masterStylesFor(gender);
    final toddler = gender == Gender.female
        ? CharacterHair.femaleToddlerStyles
        : CharacterHair.maleToddlerStyles;
    final kid = gender == Gender.female
        ? CharacterHair.femaleChildStyles
        : CharacterHair.maleChildStyles;

    return Character.create(
      id: child.id,
      firstName: child.firstName,
      lastName: child.lastName,
      gender: gender,
      birthYear: child.birthYear,
      appearance: CharacterAppearance(
        base: 'default',
        skinTone: child.skinTone,
        hair: pick(masters),
        infantHair: pick(CharacterHair.infantStyles),
        toddlerHair: pick(toddler),
        childHair: pick(kid),
        hairColor: child.hairColor,
        eyes: 'default',
        eyeColor: child.eyeColor,
        eyebrows: child.eyebrows,
        beard: 'none',
      ),
    );
  }
}
