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
    final LifeStage stage =
        character.lifeStageAt(currentYear);

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
            useSkinGamma: true,
          ),

          // Eye base is a fixed layer.
          // It must NOT receive eyeColor.
          _layer(
            _eyesBaseAsset(stage),
          ),

          // Iris is the only eye layer that receives eyeColor.
          _layer(
            _eyesIrisAsset(stage),
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
    bool useSkinGamma = false,
  }) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (color == null) {
      return image;
    }

    Widget colorizedImage = image;

    if (useSkinGamma) {
      colorizedImage = ColorFiltered(
        colorFilter:
            const ColorFilter.linearToSrgbGamma(),
        child: colorizedImage,
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.modulate,
      ),
      child: colorizedImage,
    );
  }

  String _headAsset(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/head_base/'
            'infant_head_base.png';

      case LifeStage.toddler:
        return 'assets/character/head_base/'
            'toddler_head_base.png';

      case LifeStage.child:
        return 'assets/character/head_base/'
            'child_head_base.png';

      case LifeStage.teen:
        return 'assets/character/head_base/'
            'teen_head_base.png';

      case LifeStage.youngAdult:
        return 'assets/character/head_base/'
            'young_adult_head_base.png';

      case LifeStage.adult:
        return 'assets/character/head_base/'
            'adult_head_base.png';

      case LifeStage.senior:
        return 'assets/character/head_base/'
            'senior_head_base.png';
    }
  }

  String _eyesBaseAsset(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/eyes/'
            'infant_eyes_base_v3.png';

      case LifeStage.toddler:
        return 'assets/character/eyes/'
            'toddler_eyes_base_v3.png';

      case LifeStage.child:
        return 'assets/character/eyes/'
            'child_eyes_base_v3.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/eyes/'
            'adult_eyes_base_v3.png';
    }
  }

  String _eyesIrisAsset(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/eyes/'
            'infant_eyes_iris_v3.png';

      case LifeStage.toddler:
        return 'assets/character/eyes/'
            'toddler_eyes_iris_v3.png';

      case LifeStage.child:
        return 'assets/character/eyes/'
            'child_eyes_iris_v3.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/eyes/'
            'adult_eyes_iris_v3.png';
    }
  }

  String _eyebrowAsset(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/eyebrows/'
            'infant_eyebrow_01.png';

      case LifeStage.toddler:
        return 'assets/character/eyebrows/'
            'toddler_eyebrow_01.png';

      case LifeStage.child:
        return 'assets/character/eyebrows/'
            'child_eyebrow_01.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/eyebrows/'
            'adult_eyebrow.png';
    }
  }

  String _mouthAsset(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/mouth/'
            'infant_mouth.png';

      case LifeStage.toddler:
        return 'assets/character/mouth/'
            'toddler_mouth.png';

      case LifeStage.child:
        return 'assets/character/mouth/'
            'child_mouth.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/mouth/'
            'adult_mouth.png';
    }
  }

  String _hairAsset(
    Character character,
  ) {
    final String hair =
        character.appearance.hair;

    if (character.gender.name == 'female' &&
        RegExp(
          r'^female_hair_0[1-3]$',
        ).hasMatch(hair)) {
      return 'assets/character/hair/'
          '$hair.png';
    }

    if (character.gender.name == 'male' &&
        RegExp(
          r'^male_hair_0[1-4]$',
        ).hasMatch(hair)) {
      return 'assets/character/hair/'
          '$hair.png';
    }

    return character.gender.name == 'female'
        ? 'assets/character/hair/'
            'female_hair_01.png'
        : 'assets/character/hair/'
            'male_hair_01.png';
  }
}
