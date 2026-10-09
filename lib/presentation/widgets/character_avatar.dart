import 'package:flutter/material.dart';

import '../../domain/character/appearance.dart';
import '../../domain/character/character.dart';
import '../../domain/character/character_hair.dart';
import '../../domain/character/gender.dart';
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

  /// Senior hair uses the warm white color so aging is visible
  /// regardless of the stored hair color.
  static const Color _seniorHairColor =
      Color(0xFFE5E3D9);

  static const List<String> _eyebrowStyles = [
    'bold_straight',
    'comma',
    'feathered',
    'high_arch',
    'rounded',
    'short_straight',
    'slight_angle',
    'soft_arch',
    'straight',
    'textured_wild',
    'thick_natural',
    'thin_defined',
  ];

  static const List<String> _beardStyles = [
    'none',
    'beard_01',
    'beard_02',
    'beard_03',
    'beard_04',
    'beard_05',
  ];

  @override
  Widget build(BuildContext context) {
    final LifeStage stage = character.lifeStageAt(
      currentYear,
    );

    final CharacterAppearance appearance =
        character.appearance;

    final String? hairAsset = _hairAsset(
      appearance: appearance,
      gender: character.gender,
      stage: stage,
    );

    final String? beardAsset = _beardAsset(
      appearance: appearance,
      gender: character.gender,
      stage: stage,
    );

    final Color renderedHairColor =
        stage == LifeStage.senior
            ? _seniorHairColor
            : hairColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          _tintedLayer(
            _headAsset(stage),
            color: skinColor,
            useSkinGamma: true,
            stage: stage,
          ),

          _fixedLayer(
            _eyesBaseAsset(stage),
            scale: 1.10,
          ),

          ColorFiltered(
            colorFilter: _irisColorFilter(
              eyeColor: eyeColor,
            ),
            child: _fixedLayer(
              _eyesIrisAsset(stage),
              scale: 1.10,
            ),
          ),

          _tintedLayer(
            _eyebrowAsset(
              stage,
              appearance.eyebrows,
            ),
            color: renderedHairColor,
          ),

          _fixedLayer(
            _mouthAsset(stage),
          ),

          if (beardAsset != null)
            _tintedLayer(
              beardAsset,
              color: renderedHairColor,
            ),

          if (hairAsset != null)
            _tintedLayer(
              hairAsset,
              color: renderedHairColor,
            ),
        ],
      ),
    );
  }

  Widget _fixedLayer(
    String assetPath, {
    double scale = 1.0,
  }) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (scale == 1.0) {
      return image;
    }

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: image,
    );
  }

  Widget _tintedLayer(
    String assetPath, {
    required Color color,
    bool useSkinGamma = false,
    LifeStage? stage,
  }) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (useSkinGamma && stage != null) {
      return ColorFiltered(
        colorFilter: _skinColorFilter(
          skinColor: color,
          stage: stage,
        ),
        child: image,
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.modulate,
      ),
      child: image,
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
    String eyebrowStyle,
  ) {
    final String selectedStyle =
        _eyebrowStyles.contains(
      eyebrowStyle,
    )
            ? eyebrowStyle
            : 'straight';

    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/eyebrows/infant/'
            'infant_eyebrow_$selectedStyle.png';

      case LifeStage.toddler:
        return 'assets/character/eyebrows/toddler/'
            'toddler_eyebrow_$selectedStyle.png';

      case LifeStage.child:
        return 'assets/character/eyebrows/child/'
            'child_eyebrow_$selectedStyle.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/eyebrows/young_adult/'
            'young_adult_eyebrow_$selectedStyle.png';
    }
  }

  String _mouthAsset(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/mouth/'
            'infant_mouth_v1.png';

      case LifeStage.toddler:
        return 'assets/character/mouth/'
            'toddler_mouth_v1.png';

      case LifeStage.child:
        return 'assets/character/mouth/'
            'child_mouth_v1.png';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/mouth/'
            'adult_mouth_v1.png';
    }
  }

  String? _hairAsset({
    required CharacterAppearance appearance,
    required Gender gender,
    required LifeStage stage,
  }) {
    final String resolvedHair =
        CharacterHair.resolveHairForStage(
      playerHair: appearance.hair,
      infantHair: appearance.infantHair,
      toddlerHair: appearance.toddlerHair,
      childHair: appearance.childHair,
      gender: gender,
      stage: stage,
    );

    return CharacterHair.assetPath(
      hair: resolvedHair,
      gender: gender,
      stage: stage,
    );
  }

  String? _beardAsset({
    required CharacterAppearance appearance,
    required Gender gender,
    required LifeStage stage,
  }) {
    if (gender != Gender.male) {
      return null;
    }

    if (!_canUseBeardAtStage(stage)) {
      return null;
    }

    if (appearance.beard == 'none') {
      return null;
    }

    if (!_beardStyles.contains(
      appearance.beard,
    )) {
      return null;
    }

    return 'assets/character/beard/'
        '${appearance.beard}.png';
  }

  bool _canUseBeardAtStage(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
      case LifeStage.toddler:
      case LifeStage.child:
      case LifeStage.teen:
        return false;

      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return true;
    }
  }

  ColorFilter _irisColorFilter({
    required Color eyeColor,
  }) {
    const double luminanceRed =
        0.2126 * 1.80;

    const double luminanceGreen =
        0.7152 * 1.80;

    const double luminanceBlue =
        0.0722 * 1.80;

    final double targetRed =
        eyeColor.r;

    final double targetGreen =
        eyeColor.g;

    final double targetBlue =
        eyeColor.b;

    return ColorFilter.matrix([
      luminanceRed * targetRed,
      luminanceGreen * targetRed,
      luminanceBlue * targetRed,
      0,
      0,
      luminanceRed * targetGreen,
      luminanceGreen * targetGreen,
      luminanceBlue * targetGreen,
      0,
      0,
      luminanceRed * targetBlue,
      luminanceGreen * targetBlue,
      luminanceBlue * targetBlue,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  ColorFilter _skinColorFilter({
    required Color skinColor,
    required LifeStage stage,
  }) {
    final double referenceGray =
        switch (stage) {
      LifeStage.infant => 192.0,
      LifeStage.toddler => 188.0,
      LifeStage.child => 187.0,
      LifeStage.teen => 184.0,
      LifeStage.youngAdult => 180.0,
      LifeStage.adult => 181.0,
      LifeStage.senior => 182.0,
    };

    const double redSlope =
        0.861905;

    const double greenSlope =
        0.948850;

    const double blueSlope =
        0.886153;

    final double targetRed =
        skinColor.r * 255.0;

    final double targetGreen =
        skinColor.g * 255.0;

    final double targetBlue =
        skinColor.b * 255.0;

    return ColorFilter.matrix([
      redSlope,
      0,
      0,
      0,
      targetRed -
          redSlope * referenceGray,
      0,
      greenSlope,
      0,
      0,
      targetGreen -
          greenSlope * referenceGray,
      0,
      0,
      blueSlope,
      0,
      targetBlue -
          blueSlope * referenceGray,
      0,
      0,
      0,
      1,
      0,
    ]);
  }
}
