import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/domain/character/cultural_randomizer_catalog.dart';
import 'package:everylife/domain/character/gender.dart';

void main() {
final Random random = Random(42);

const List<String> countryCodes = <String>[
'AE', 'AR', 'AT', 'AU', 'BE', 'BR', 'CA', 'CH',
'CL', 'CN', 'CO', 'CU', 'DE', 'DK', 'EG', 'ES',
'ET', 'FJ', 'FR', 'GB', 'GH', 'GR', 'ID', 'IE',
'IN', 'IT', 'JP', 'KE', 'KR', 'MA', 'MC', 'MX',
'MY', 'NG', 'NL', 'NP', 'NO', 'NZ', 'PK', 'PL',
'PT', 'RU', 'SA', 'SE', 'SG', 'TH', 'TR', 'UA',
'US', 'VN', 'ZA', 'TZ', 'PE', 'PH',
];

const List<String> skinIds = <String>[
'pale',
'very_light',
'light',
'light_medium',
'medium',
'medium_tan',
'tan',
'deep_tan',
'brown',
'deep_brown',
'dark',
'very_dark',
];

const List<String> hairIds = <String>[
'black',
'blue_black',
'dark_brown',
'chocolate_brown',
'chestnut_brown',
'warm_brown',
'ash_brown',
'auburn',
'copper',
'ginger',
'dark_red',
'burgundy',
'honey_blonde',
'golden_blonde',
'ash_blonde',
'platinum_blonde',
'silver',
'gray',
'white',
];

const List<String> eyeIds = <String>[
'light_blue',
'deep_blue',
'gray',
'blue_green',
'green',
'hazel',
'amber',
'brown',
'dark_brown',
'black',
'copper',
'golden',
'chocolate',
'slate',
'chartreuse',
'violet',
'red',
'pink',
];

group('CulturalRandomizerCatalog', () {
test('supports every country in the current country catalog', () {
for (final String countryCode in countryCodes) {
expect(
CulturalRandomizerCatalog.supportsCountry(countryCode),
isTrue,
reason: 'Country $countryCode must have name and appearance profiles.',
);
}
});

test('country codes are handled without case sensitivity', () {
  expect(
    CulturalRandomizerCatalog.supportsCountry('id'),
    isTrue,
  );

  expect(
    CulturalRandomizerCatalog.supportsCountry('JP'),
    isTrue,
  );

  expect(
    CulturalRandomizerCatalog.supportsCountry(' unknown '),
    isFalse,
  );
});

test('generates non-empty names for every supported country', () {
  for (final String countryCode in countryCodes) {
    for (final Gender gender in Gender.values) {
      final String firstName =
          CulturalRandomizerCatalog.randomFirstName(
        countryCode: countryCode,
        gender: gender,
        random: random,
      );

      final String lastName =
          CulturalRandomizerCatalog.randomLastName(
        countryCode: countryCode,
        random: random,
      );

      expect(firstName.trim(), isNotEmpty);
      expect(lastName.trim(), isNotEmpty);
    }
  }
});

test('provides 30 unique candidates in every name category', () {
  for (final String countryCode in countryCodes) {
    final Map<String, int> stats =
        CulturalRandomizerCatalog.namePoolStatsForCountry(countryCode);

    expect(stats['male'], 30, reason: '$countryCode male pool size');
    expect(stats['maleUnique'], 30, reason: '$countryCode male names must be unique');
    expect(stats['female'], 30, reason: '$countryCode female pool size');
    expect(stats['femaleUnique'], 30, reason: '$countryCode female names must be unique');
    expect(stats['family'], 30, reason: '$countryCode family pool size');
    expect(stats['familyUnique'], 30, reason: '$countryCode family names must be unique');
  }
});

test('seeded random generators remain deterministic', () {
  for (final String countryCode in countryCodes) {
    final Random firstRandom = Random(2026);
    final Random secondRandom = Random(2026);

    for (int i = 0; i < 30; i++) {
      expect(
        CulturalRandomizerCatalog.randomFirstName(
          countryCode: countryCode,
          gender: Gender.male,
          random: firstRandom,
        ),
        CulturalRandomizerCatalog.randomFirstName(
          countryCode: countryCode,
          gender: Gender.male,
          random: secondRandom,
        ),
      );
    }
  }
});

test('generates only valid palette IDs for every country', () {
  for (final String countryCode in countryCodes) {
    for (int i = 0; i < 50; i++) {
      final String skin =
          CulturalRandomizerCatalog.randomAppearanceColor(
        countryCode: countryCode,
        feature: AppearanceFeature.skin,
        availableIds: skinIds,
        random: random,
      );

      final String hair =
          CulturalRandomizerCatalog.randomAppearanceColor(
        countryCode: countryCode,
        feature: AppearanceFeature.hair,
        availableIds: hairIds,
        random: random,
      );

      final String eyes =
          CulturalRandomizerCatalog.randomAppearanceColor(
        countryCode: countryCode,
        feature: AppearanceFeature.eyes,
        availableIds: eyeIds,
        random: random,
      );

      expect(skinIds, contains(skin));
      expect(hairIds, contains(hair));
      expect(eyeIds, contains(eyes));
    }
  }
});

test('rejects an empty palette', () {
  expect(
    () => CulturalRandomizerCatalog.randomAppearanceColor(
      countryCode: 'ID',
      feature: AppearanceFeature.skin,
      availableIds: const <String>[],
      random: random,
    ),
    throwsArgumentError,
  );
});

});
}
