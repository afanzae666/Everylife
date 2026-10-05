import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/services/character_palette_service.dart';

void main() {
  group('CharacterPaletteService', () {
    test(
      'loads all character palettes from bundled assets',
      () async {
        final CharacterPaletteService palette =
            await CharacterPaletteService.load();

        expect(
          palette.skinColors.length,
          12,
        );

        expect(
          palette.eyeColors.length,
          18,
        );

        expect(
          palette.hairColors.length,
          19,
        );
      },
    );

    test(
      'loads expected skin palette identifiers and colors',
      () async {
        final CharacterPaletteService palette =
            await CharacterPaletteService.load();

        expect(
          palette.skinColors.keys,
          containsAll(<String>[
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
          ]),
        );

        expect(
          palette.skinColor('pale'),
          const Color(0xFFF6D8C5),
        );

        expect(
          palette.skinColor('medium'),
          const Color(0xFFC58161),
        );

        expect(
          palette.skinColor('very_dark'),
          const Color(0xFF321A15),
        );
      },
    );

    test(
      'loads expected eye palette identifiers and colors',
      () async {
        final CharacterPaletteService palette =
            await CharacterPaletteService.load();

        expect(
          palette.eyeColors.keys,
          containsAll(<String>[
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
          ]),
        );

        expect(
          palette.eyeColor('light_blue'),
          const Color(0xFF78B7E8),
        );

        expect(
          palette.eyeColor('brown'),
          const Color(0xFF6B4632),
        );

        expect(
          palette.eyeColor('black'),
          const Color(0xFF171412),
        );

        expect(
          palette.eyeColor('violet'),
          const Color(0xFF665A9B),
        );
      },
    );

    test(
      'loads expected hair palette identifiers and colors',
      () async {
        final CharacterPaletteService palette =
            await CharacterPaletteService.load();

        expect(
          palette.hairColors.keys,
          containsAll(<String>[
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
          ]),
        );

        expect(
          palette.hairColor('black'),
          const Color(0xFF171513),
        );

        expect(
          palette.hairColor('warm_brown'),
          const Color(0xFF7A4A32),
        );

        expect(
          palette.hairColor('platinum_blonde'),
          const Color(0xFFD9D4C5),
        );

        expect(
          palette.hairColor('white'),
          const Color(0xFFE5E3D9),
        );
      },
    );

    test(
      'returns null for unknown palette identifiers',
      () async {
        final CharacterPaletteService palette =
            await CharacterPaletteService.load();

        expect(
          palette.skinColor('does_not_exist'),
          isNull,
        );

        expect(
          palette.eyeColor('does_not_exist'),
          isNull,
        );

        expect(
          palette.hairColor('does_not_exist'),
          isNull,
        );
      },
    );

    test(
      'reuses the cached palette service instance',
      () async {
        final CharacterPaletteService first =
            await CharacterPaletteService.load();

        final CharacterPaletteService second =
            await CharacterPaletteService.load();

        expect(
          identical(first, second),
          isTrue,
        );
      },
    );
  });
}
