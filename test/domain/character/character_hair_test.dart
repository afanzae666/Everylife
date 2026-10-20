
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/domain/character/character_hair.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/life_stage.dart';

void main() {
  group('CharacterHair pools', () {
    test('infant pool includes bald and all three infant styles', () {
      expect(
        CharacterHair.infantStyles,
        containsAll([
          CharacterHair.bald,
          'infant_01',
          'infant_02',
          'infant_03',
        ]),
      );
      expect(CharacterHair.infantStyles, hasLength(4));
    });

    test('toddler pools are gender-specific and never bald', () {
      expect(
        CharacterHair.stylesFor(
          gender: Gender.male,
          stage: LifeStage.toddler,
        ),
        [
          'male_hair_toddler_01',
          'male_hair_toddler_02',
          'male_hair_toddler_03',
        ],
      );

      expect(
        CharacterHair.stylesFor(
          gender: Gender.female,
          stage: LifeStage.toddler,
        ),
        [
          'female_hair_toddler_01',
          'female_hair_toddler_02',
          'female_hair_toddler_03',
        ],
      );
    });

    test('child pools are gender-specific and never bald', () {
      expect(
        CharacterHair.stylesFor(
          gender: Gender.male,
          stage: LifeStage.child,
        ),
        [
          'male_hair_child_01',
          'male_hair_child_02',
          'male_hair_child_03',
          'male_hair_child_04',
          'male_hair_child_05',
          'male_hair_child_06',
        ],
      );

      expect(
        CharacterHair.stylesFor(
          gender: Gender.female,
          stage: LifeStage.child,
        ),
        [
          'female_hair_child_01',
          'female_hair_child_02',
          'female_hair_child_03',
          'female_hair_child_04',
          'female_hair_child_05',
          'female_hair_child_06',
        ],
      );
    });

    test('adult master pools include all available hairstyles', () {
      expect(
        CharacterHair.masterStylesFor(Gender.female),
        [
          'female_hair_01',
          'female_hair_02',
          'female_hair_03',
          'female_hair_04',
          'female_hair_05',
          'female_hair_06',
          'female_hair_07',
          'female_hair_08',
          'female_hair_09',
        ],
      );

      expect(
        CharacterHair.masterStylesFor(Gender.male),
        [
          'male_hair_01',
          'male_hair_02',
          'male_hair_03',
          'male_hair_04',
          'male_hair_05',
          'male_hair_06',
          'male_hair_07',
          'male_hair_08',
        ],
      );

      expect(
        CharacterHair.masterStylesFor(Gender.female),
        hasLength(9),
      );

      expect(
        CharacterHair.masterStylesFor(Gender.male),
        hasLength(8),
      );
    });

    test('adult master pools are used from teen through senior', () {
      for (final gender in Gender.values) {
        for (final stage in [
          LifeStage.teen,
          LifeStage.youngAdult,
          LifeStage.adult,
          LifeStage.senior,
        ]) {
          expect(
            CharacterHair.stylesFor(
              gender: gender,
              stage: stage,
            ),
            CharacterHair.masterStylesFor(gender),
          );
        }
      }
    });
  });

  group('CharacterHair asset paths', () {
    test('new female hairstyles resolve to their PNG assets', () {
      expect(
        CharacterHair.assetPath(
          hair: 'female_hair_08',
          gender: Gender.female,
          stage: LifeStage.adult,
        ),
        'assets/character/hair/female_hair_08.png',
      );

      expect(
        CharacterHair.assetPath(
          hair: 'female_hair_09',
          gender: Gender.female,
          stage: LifeStage.adult,
        ),
        'assets/character/hair/female_hair_09.png',
      );
    });

    test('new male hairstyle resolves to its PNG asset', () {
      expect(
        CharacterHair.assetPath(
          hair: 'male_hair_08',
          gender: Gender.male,
          stage: LifeStage.adult,
        ),
        'assets/character/hair/male_hair_08.png',
      );
    });

    test('bald hairstyle does not produce an asset path', () {
      expect(
        CharacterHair.assetPath(
          hair: CharacterHair.bald,
          gender: Gender.male,
          stage: LifeStage.adult,
        ),
        isNull,
      );
    });
  });

  group('CharacterHair random generation', () {
    test('infant random hair always belongs to the infant pool', () {
      final random = Random(123);

      for (var i = 0; i < 100; i++) {
        final hair = CharacterHair.randomAutomaticHair(
          random: random,
          gender: Gender.male,
          stage: LifeStage.infant,
        );

        expect(CharacterHair.infantStyles, contains(hair));
      }
    });

    test('toddler and child random hair never select bald', () {
      final random = Random(456);

      for (final gender in Gender.values) {
        for (var i = 0; i < 100; i++) {
          final toddlerHair = CharacterHair.randomAutomaticHair(
            random: random,
            gender: gender,
            stage: LifeStage.toddler,
          );

          final childHair = CharacterHair.randomAutomaticHair(
            random: random,
            gender: gender,
            stage: LifeStage.child,
          );

          expect(toddlerHair, isNot(CharacterHair.bald));
          expect(childHair, isNot(CharacterHair.bald));

          expect(
            CharacterHair.stylesFor(
              gender: gender,
              stage: LifeStage.toddler,
            ),
            contains(toddlerHair),
          );

          expect(
            CharacterHair.stylesFor(
              gender: gender,
              stage: LifeStage.child,
            ),
            contains(childHair),
          );
        }
      }
    });

    test('adult random hair belongs to the correct master pool', () {
      final random = Random(789);

      for (final gender in Gender.values) {
        for (var i = 0; i < 100; i++) {
          final hair = CharacterHair.randomAutomaticHair(
            random: random,
            gender: gender,
            stage: LifeStage.adult,
          );

          expect(
            CharacterHair.masterStylesFor(gender),
            contains(hair),
          );
        }
      }
    });
  });

  group('CharacterHair stage resolution', () {
    test('player-selected bald stays bald at every life stage', () {
      for (final stage in LifeStage.values) {
        expect(
          CharacterHair.resolveHairForStage(
            playerHair: CharacterHair.bald,
            infantHair: 'infant_02',
            toddlerHair: 'male_hair_toddler_01',
            childHair: 'male_hair_child_02',
            gender: Gender.male,
            stage: stage,
          ),
          CharacterHair.bald,
        );
      }
    });

    test('random infant bald does not affect later stages', () {
      const playerHair = 'male_hair_04';

      expect(
        CharacterHair.resolveHairForStage(
          playerHair: playerHair,
          infantHair: CharacterHair.bald,
          toddlerHair: 'male_hair_toddler_02',
          childHair: 'male_hair_child_03',
          gender: Gender.male,
          stage: LifeStage.infant,
        ),
        CharacterHair.bald,
      );

      expect(
        CharacterHair.resolveHairForStage(
          playerHair: playerHair,
          infantHair: CharacterHair.bald,
          toddlerHair: 'male_hair_toddler_02',
          childHair: 'male_hair_child_03',
          gender: Gender.male,
          stage: LifeStage.toddler,
        ),
        'male_hair_toddler_02',
      );

      expect(
        CharacterHair.resolveHairForStage(
          playerHair: playerHair,
          infantHair: CharacterHair.bald,
          toddlerHair: 'male_hair_toddler_02',
          childHair: 'male_hair_child_03',
          gender: Gender.male,
          stage: LifeStage.child,
        ),
        'male_hair_child_03',
      );

      for (final stage in [
        LifeStage.teen,
        LifeStage.youngAdult,
        LifeStage.adult,
        LifeStage.senior,
      ]) {
        expect(
          CharacterHair.resolveHairForStage(
            playerHair: playerHair,
            infantHair: CharacterHair.bald,
            toddlerHair: 'male_hair_toddler_02',
            childHair: 'male_hair_child_03',
            gender: Gender.male,
            stage: stage,
          ),
          playerHair,
        );
      }
    });

    test('missing automatic hair uses a stable fallback', () {
      for (var i = 0; i < 20; i++) {
        expect(
          CharacterHair.resolveHairForStage(
            playerHair: 'male_hair_04',
            infantHair: null,
            toddlerHair: null,
            childHair: null,
            gender: Gender.male,
            stage: LifeStage.infant,
          ),
          'infant_01',
        );

        expect(
          CharacterHair.resolveHairForStage(
            playerHair: 'male_hair_04',
            infantHair: null,
            toddlerHair: null,
            childHair: null,
            gender: Gender.male,
            stage: LifeStage.toddler,
          ),
          'male_hair_toddler_01',
        );

        expect(
          CharacterHair.resolveHairForStage(
            playerHair: 'male_hair_04',
            infantHair: null,
            toddlerHair: null,
            childHair: null,
            gender: Gender.male,
            stage: LifeStage.child,
          ),
          'male_hair_child_01',
        );
      }
    });

    test('master hairstyle is preserved from teen through senior', () {
      for (final gender in Gender.values) {
        final playerHair = gender == Gender.male
            ? 'male_hair_04'
            : 'female_hair_06';

        for (final stage in [
          LifeStage.teen,
          LifeStage.youngAdult,
          LifeStage.adult,
          LifeStage.senior,
        ]) {
          expect(
            CharacterHair.resolveHairForStage(
              playerHair: playerHair,
              infantHair: 'infant_02',
              toddlerHair: null,
              childHair: null,
              gender: gender,
              stage: stage,
            ),
            playerHair,
          );
        }
      }
    });

    test('new hairstyles remain valid for adult life stages', () {
      for (final stage in [
        LifeStage.teen,
        LifeStage.youngAdult,
        LifeStage.adult,
        LifeStage.senior,
      ]) {
        expect(
          CharacterHair.isValidForStage(
            hair: 'female_hair_08',
            gender: Gender.female,
            stage: stage,
          ),
          isTrue,
        );

        expect(
          CharacterHair.isValidForStage(
            hair: 'female_hair_09',
            gender: Gender.female,
            stage: stage,
          ),
          isTrue,
        );

        expect(
          CharacterHair.isValidForStage(
            hair: 'male_hair_08',
            gender: Gender.male,
            stage: stage,
          ),
          isTrue,
        );
      }
    });
  });
}
