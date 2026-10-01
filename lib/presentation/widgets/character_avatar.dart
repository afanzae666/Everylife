import 'package:flutter/material.dart';

import '../../domain/character/character.dart';
import '../../domain/character/life_stage.dart';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    required this.character,
    required this.currentYear,
    required this.size,
    required this.skinColor,
    required this.eyeColor,
    required this.hairColor,
    super.key,
  });

  final Character character;
  final int currentYear;
  final double size;

  final Color skinColor;
  final Color eyeColor;
  final Color hairColor;

  @override
  Widget build(BuildContext context) {
    final stage = character.lifeStageAt(currentYear);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          _layer(
            _headAsset(stage),
            color: skinColor,
          ),
          _layer(
            _eyesAsset(stage),
            color: eyeColor,
          ),
          _layer(
            _eyebrowAsset(stage),
            color: hairColor,
          ),
          _layer(
            _mouthAsset(stage),
          ),
          _layer(
            _hairAsset(character),
            color: hairColor,
          ),
        ],
      ),
    );
  }

  Widget _layer(
    String assetPath, {
    Color? color,
  }) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (color == null) {
      return image;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.modulate,
      ),
      child: image,
    );
  }

  String _headAsset(LifeStage stage) {
    return switch (stage) {
      LifeStage.infant =>
        'assets/character/head_base/infant_head_base.png',
      LifeStage.toddler =>
        'assets/character/head_base/toddler_head_base.png',
      LifeStage.child =>
        'assets/character/head_base/child_head_base.png',
      LifeStage.teen =>
        'assets/character/head_base/teen_head_base.png',
      LifeStage.youngAdult =>
        'assets/character/head_base/young_adult_head_base.png',
      LifeStage.adult =>
        'assets/character/head_base/adult_head_base.png',
      LifeStage.senior =>
        'assets/character/head_base/senior_head_base.png',
    };
  }

  String _eyesAsset(LifeStage stage) {
    return switch (stage) {
      LifeStage.infant =>
        'assets/character/eyes/infant_eyes.png',
      LifeStage.toddler =>
        'assets/character/eyes/toddler_eyes.png',
      LifeStage.child =>
        'assets/character/eyes/child_eyes.png',
      LifeStage.teen ||
      LifeStage.youngAdult ||
      LifeStage.adult ||
      LifeStage.senior =>
        'assets/character/eyes/adult_eyes.png',
    };
  }

  String _eyebrowAsset(LifeStage stage) {
    return switch (stage) {
      LifeStage.infant =>
        'assets/character/eyebrows/infant_eyebrow_01.png',
      LifeStage.toddler =>
        'assets/character/eyebrows/toddler_eyebrow_01.png',
      LifeStage.child =>
        'assets/character/eyebrows/child_eyebrow_01.png',
      LifeStage.teen ||
      LifeStage.youngAdult ||
      LifeStage.adult ||
      LifeStage.senior =>
        'assets/character/eyebrows/adult_eyebrow.png',
    };
  }

  String _mouthAsset(LifeStage stage) {
    return switch (stage) {
      LifeStage.infant =>
        'assets/character/mouth/infant_mouth.png',
      LifeStage.toddler =>
        'assets/character/mouth/toddler_mouth.png',
      LifeStage.child =>
        'assets/character/mouth/child_mouth.png',
      LifeStage.teen ||
      LifeStage.youngAdult ||
      LifeStage.adult ||
      LifeStage.senior =>
        'assets/character/mouth/adult_mouth.png',
    };
  }

  String _hairAsset(Character character) {
    final hair = character.appearance.hair;

    if (character.gender.name == 'female' &&
        RegExp(r'^female_hair_0[1-3]$').hasMatch(hair)) {
      return 'assets/character/hair/$hair.png';
    }

    if (character.gender.name == 'male' &&
        RegExp(r'^male_hair_0[1-4]$').hasMatch(hair)) {
      return 'assets/character/hair/$hair.png';
    }

    return character.gender.name == 'female'
        ? 'assets/character/hair/female_hair_01.png'
        : 'assets/character/hair/male_hair_01.png';
  }
}
