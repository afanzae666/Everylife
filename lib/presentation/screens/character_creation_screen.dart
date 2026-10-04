import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/character/appearance.dart';
import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({
    required this.onCharacterCreated,
    this.uiScaleController,
    super.key,
  });

  final void Function(Character character) onCharacterCreated;

  final ValueNotifier<double>? uiScaleController;

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends State<CharacterCreationScreen> {
  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  static final TextInputFormatter _nameCapitalizationFormatter =
      TextInputFormatter.withFunction(
    (
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      final StringBuffer buffer =
          StringBuffer();

      bool capitalizeNext = true;

      for (final int rune
          in newValue.text.runes) {
        final String character =
            String.fromCharCode(rune);

        if (RegExp(r'\s').hasMatch(
          character,
        )) {
          buffer.write(character);
          capitalizeNext = true;
          continue;
        }

        if (capitalizeNext) {
          buffer.write(
            character.toUpperCase(),
          );
          capitalizeNext = false;
        } else {
          buffer.write(character);
        }
      }

      return newValue.copyWith(
        text: buffer.toString(),
        selection: newValue.selection,
        composing: newValue.composing,
      );
    },
  );

  Gender _gender = Gender.male;

  static const int _minimumBirthYear = 1900;
  static const int _maximumBirthYear = 2026;

  int _birthYear = _maximumBirthYear;

  CharacterAppearance _appearance =
      const CharacterAppearance(
    base: 'default',
    skinTone: 'skin_04',
    hair: 'male_hair_01',
    hairColor: 'black',
    eyes: 'adult_eyes',
    eyeColor: 'brown',
    eyebrows: 'adult_eyebrow',
  );

  static const List<String> _maleHairStyles = [
    'bald',
    'male_hair_01',
    'male_hair_02',
    'male_hair_03',
    'male_hair_04',
  ];

  static const List<String> _femaleHairStyles = [
    'bald',
    'female_hair_01',
    'female_hair_02',
    'female_hair_03',
  ];

  static const Map<String, Color> _skinToneColors = {
    'skin_01': Color(0xFFDAA787),
    'skin_02': Color(0xFFD5906A),
    'skin_03': Color(0xFFC07A56),
    'skin_04': Color(0xFFAD6445),
    'skin_05': Color(0xFF954F34),
    'skin_06': Color(0xFF6E3C27),
    'skin_07': Color(0xFF4A271C),
  };

  static const Map<String, Color> _hairColors = {
    'black': Color(0xFF211A18),
    'dark_brown': Color(0xFF3A2720),
    'brown': Color(0xFF5B3A2D),
    'warm_brown': Color(0xFF7A5039),
    'dark_blonde': Color(0xFFA77A4D),
    'gray': Color(0xFF9A9A9A),
    'white': Color(0xFFD8D8D2),
  };

  static const Map<String, Color> _eyeColors = {
    'brown': Color(0xFF5B3A2D),
    'dark_brown': Color(0xFF2B211E),
    'hazel': Color(0xFF7A6A3A),
    'green': Color(0xFF4E7048),
    'blue': Color(0xFF557FA3),
    'gray': Color(0xFF8C9398),
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _createCharacter() {
    final String firstName =
        _firstNameController.text.trim();

    final String lastName =
        _lastNameController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your first name.',
          ),
        ),
      );
      return;
    }

    if (lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your last name.',
          ),
        ),
      );
      return;
    }

    final Character character =
        Character.create(
      id:
          'player-${DateTime.now().microsecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      gender: _gender,
      birthYear: _birthYear,
      appearance: _appearance,
    );

    widget.onCharacterCreated(
      character,
    );
  }

  void _showBirthYearPicker() {
    int temporaryYear = _birthYear;

    showDialog<void>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            final int initialItem =
                _maximumBirthYear -
                    temporaryYear;

            return AlertDialog(
              title: const Text(
                'Birth Year',
              ),
              content: SizedBox(
                width: 300,
                height: 320,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        IconButton(
                          tooltip:
                              'Previous year',
                          onPressed:
                              temporaryYear >
                                      _minimumBirthYear
                                  ? () {
                                      setDialogState(
                                        () {
                                          temporaryYear--;
                                        },
                                      );
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.remove,
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Center(
                            child: Text(
                              '$temporaryYear',
                              style: Theme.of(
                                context,
                              )
                                  .textTheme
                                  .headlineMedium,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip:
                              'Next year',
                          onPressed:
                              temporaryYear <
                                      _maximumBirthYear
                                  ? () {
                                      setDialogState(
                                        () {
                                          temporaryYear++;
                                        },
                                      );
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.add,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child:
                          ListWheelScrollView.useDelegate(
                        controller:
                            FixedExtentScrollController(
                          initialItem:
                              initialItem,
                        ),
                        itemExtent: 44,
                        perspective: 0.003,
                        diameterRatio: 1.4,
                        physics:
                            const FixedExtentScrollPhysics(),
                        onSelectedItemChanged:
                            (
                          int index,
                        ) {
                          final int year =
                              _maximumBirthYear -
                                  index;

                          setDialogState(
                            () {
                              temporaryYear =
                                  year;
                            },
                          );
                        },
                        childDelegate:
                            ListWheelChildBuilderDelegate(
                          childCount:
                              _maximumBirthYear -
                                  _minimumBirthYear +
                                  1,
                          builder: (
                            BuildContext context,
                            int index,
                          ) {
                            final int year =
                                _maximumBirthYear -
                                    index;

                            final bool selected =
                                year ==
                                    temporaryYear;

                            return Center(
                              child: Text(
                                '$year',
                                style:
                                    TextStyle(
                                  fontSize:
                                      selected
                                          ? 22
                                          : 17,
                                  fontWeight:
                                      selected
                                          ? FontWeight
                                              .w600
                                          : FontWeight
                                              .normal,
                                  color: selected
                                      ? Theme.of(
                                          context,
                                        )
                                          .colorScheme
                                          .primary
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'CANCEL',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _birthYear =
                          temporaryYear;
                    });

                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'DONE',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAppearanceDialog() {
    CharacterAppearance temporaryAppearance =
        _appearance;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (
        BuildContext dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            StateSetter setDialogState,
          ) {
            void updateTemporaryAppearance(
              CharacterAppearance next,
            ) {
              setDialogState(() {
                temporaryAppearance =
                    next;
              });
            }

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 520,
                  maxHeight: 720,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Customize Appearance',
                              style: Theme.of(
                                context,
                              )
                                  .textTheme
                                  .titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Expanded(
                        child:
                            SingleChildScrollView(
                          padding:
                              const EdgeInsets.only(
                            bottom: 8,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              _buildAppearancePreviewFor(
                                context,
                                1.0,
                                temporaryAppearance,
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              _buildSkinToneSelectorFor(
                                context,
                                1.0,
                                temporaryAppearance,
                                updateTemporaryAppearance,
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              _buildAssetSelectorFor(
                                context: context,
                                zoom: 1.0,
                                title: 'Hair',
                                values:
                                    _currentHairStyles(),
                                selected:
                                    temporaryAppearance
                                        .hair,
                                assetDirectory:
                                    'assets/character/hair',
                                onSelected:
                                    (
                                  String value,
                                ) {
                                  updateTemporaryAppearance(
                                    temporaryAppearance
                                        .copyWith(
                                      hair: value,
                                    ),
                                  );
                                },
                                color:
                                    _hairColors[
                                        temporaryAppearance
                                            .hairColor],
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              _buildColorSelectorFor(
                                context: context,
                                zoom: 1.0,
                                title: 'Hair Color',
                                colors:
                                    _hairColors,
                                selected:
                                    temporaryAppearance
                                        .hairColor,
                                onSelected:
                                    (
                                  String value,
                                ) {
                                  updateTemporaryAppearance(
                                    temporaryAppearance
                                        .copyWith(
                                      hairColor:
                                          value,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              _buildColorSelectorFor(
                                context: context,
                                zoom: 1.0,
                                title: 'Eye Color',
                                colors:
                                    _eyeColors,
                                selected:
                                    temporaryAppearance
                                        .eyeColor,
                                onSelected:
                                    (
                                  String value,
                                ) {
                                  updateTemporaryAppearance(
                                    temporaryAppearance
                                        .copyWith(
                                      eyeColor:
                                          value,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _appearance =
                                  temporaryAppearance;
                            });

                            Navigator.of(
                              dialogContext,
                            ).pop();
                          },
                          child: const Text(
                            'DONE',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _currentHairStyles() {
    return _gender == Gender.female
        ? _femaleHairStyles
        : _maleHairStyles;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ValueNotifier<double>?
        controller =
        widget.uiScaleController;

    if (controller == null) {
      return _buildScaledPage(
        context,
        1.0,
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: controller,
      builder: (
        BuildContext context,
        double zoom,
        Widget? child,
      ) {
        return _buildScaledPage(
          context,
          zoom,
        );
      },
    );
  }

  Widget _buildScaledPage(
    BuildContext context,
    double zoom,
  ) {
    final MediaQueryData mediaQuery =
        MediaQuery.of(context);

    final MediaQueryData
        scaledMediaQuery =
        mediaQuery.copyWith(
      textScaler:
          TextScaler.linear(zoom),
    );

    return MediaQuery(
      data: scaledMediaQuery,
      child: _buildScaffold(
        context,
        zoom,
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Character',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            s(10),
            s(6),
            s(10),
            s(10),
          ),
          child: Column(
            children: [
              Text(
                'Create Your Character',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: s(2),
              ),
              Text(
                'Your life begins at birth.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: s(5),
              ),
              Expanded(
                child: _ResponsiveCard(
                  padding:
                      EdgeInsets.fromLTRB(
                    s(10),
                    s(8),
                    s(10),
                    s(8),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child:
                            _buildMainAvatarPreview(
                          context,
                          zoom,
                        ),
                      ),
                      SizedBox(
                        height: s(2),
                      ),
                      TextButton.icon(
                        onPressed:
                            _showAppearanceDialog,
                        icon: Icon(
                          Icons.tune,
                          size: s(17),
                        ),
                        label: const Text(
                          'Customize Appearance',
                        ),
                      ),
                      SizedBox(
                        height: s(4),
                      ),
                      Expanded(
                        flex: 4,
                        child:
                            _buildCompactIdentityFields(
                          context,
                          zoom,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: s(8),
              ),
              SizedBox(
                width: double.infinity,
                height: s(46),
                child: FilledButton.icon(
                  onPressed:
                      _createCharacter,
                  icon: Icon(
                    Icons.child_friendly,
                    size: s(18),
                  ),
                  label: const Text(
                    'BEGIN LIFE',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainAvatarPreview(
    BuildContext context,
    double zoom,
  ) {
    final int age =
        _previewAge();

    final LifeStage stage =
        LifeStageAge.fromAge(age);

    return _buildAvatarStack(
      context: context,
      zoom: zoom,
      appearance: _appearance,
      stage: stage,
      gender: _gender,
      size: 190,
      containerSize: 200,
    );
  }

  int _previewAge() {
    final int age =
        _maximumBirthYear -
            _birthYear;

    return age.clamp(0, 126);
  }

  Widget _buildAppearancePreviewFor(
    BuildContext context,
    double zoom,
    CharacterAppearance appearance,
  ) {
    return Container(
      width: double.infinity,
      height: 205 * zoom,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(
              alpha: 0.35,
            ),
        borderRadius:
            BorderRadius.circular(
          10 * zoom,
        ),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(
                alpha: 0.5,
              ),
        ),
      ),
      child: Center(
        child: _buildAvatarStack(
          context: context,
          zoom: zoom,
          appearance: appearance,
          stage: LifeStage.youngAdult,
          gender: _gender,
          size: 180,
          containerSize: 190,
        ),
      ),
    );
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

  ColorFilter _irisColorFilter({
    required Color eyeColor,
  }) {
    const double luminanceRed = 0.2126 * 1.80;
    const double luminanceGreen = 0.7152 * 1.80;
    const double luminanceBlue = 0.0722 * 1.80;
    
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

  Widget _buildAvatarStack({
    required BuildContext context,
    required double zoom,
    required CharacterAppearance appearance,
    required LifeStage stage,
    required Gender gender,
    required double size,
    required double containerSize,
  }) {
    double s(double value) =>
        value * zoom;

    final Color skinColor =
        _skinToneColors[
                appearance.skinTone] ??
            _skinToneColors.values.first;

    final Color hairColor =
        _hairColors[
                appearance.hairColor] ??
            _hairColors.values.first;

    final Color eyeColor =
        _eyeColors[
                appearance.eyeColor] ??
            _eyeColors.values.first;

    final String headAsset =
        _headAssetFor(stage);

    final String eyesBaseAsset =
        _eyesBaseAssetFor(stage);

    final String eyesIrisAsset =
        _eyesIrisAssetFor(stage);

    final String eyebrowAsset =
        _eyebrowAssetFor(stage);

    final String mouthAsset =
        _mouthAssetFor(stage);

    final String? hairAsset =
        _hairAssetFor(
      appearance: appearance,
      gender: gender,
    );

    // Keep the eye layer slightly larger than
    // the head-base eye area so the original skin
    // does not remain visible around the eyes.
    const double eyeScale = 1.10;

    Widget tintedImage({
      required String assetPath,
      required Color color,
      bool useSkinGamma = false,
      BlendMode blendMode =
          BlendMode.modulate,
    }) {
      final Widget image = Image.asset(
        assetPath,
        width: s(size),
        height: s(size),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );

      if (useSkinGamma) {
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
          blendMode,
        ),
        child: image,
      );
    }

    Widget fixedImage({
      required String assetPath,
      double scale = 1.0,
    }) {
      final Widget image = Image.asset(
        assetPath,
        width: s(size),
        height: s(size),
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

    return SizedBox(
      width: s(containerSize),
      height: s(containerSize),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          tintedImage(
            assetPath: headAsset,
            color: skinColor,
            useSkinGamma: true,
          ),

          // Base eye layer:
          // sclera, eye outline and fixed eye details.
          // It must NOT receive eyeColor.
          //
          // Slightly enlarged to prevent the head-base
          // skin from remaining visible around the eyes.
          fixedImage(
            assetPath: eyesBaseAsset,
            scale: eyeScale,
          ),

          // Iris is a separate layer.
          // Only the iris receives eyeColor.
          //
          // It uses the exact same scale as the eye base
          // so both layers remain perfectly aligned.
          ColorFiltered(
            colorFilter: _irisColorFilter(
              eyeColor: eyeColor,
            ),
            child: fixedImage(
              assetPath: eyesIrisAsset,
              scale: eyeScale,
            ),
          ),

          tintedImage(
            assetPath: eyebrowAsset,
            color: hairColor,
          ),

          // Mouth is already colorization-ready
          // and therefore remains unfiltered.
          fixedImage(
            assetPath: mouthAsset,
          ),

          // Bald has no image layer at all.
          if (hairAsset != null)
            tintedImage(
              assetPath: hairAsset,
              color: hairColor,
            ),
        ],
      ),
    );
  }

  String _headAssetFor(
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

  String _eyesBaseAssetFor(
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

  String _eyesIrisAssetFor(
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

  String _eyebrowAssetFor(
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

  String _mouthAssetFor(
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

  String? _hairAssetFor({
    required CharacterAppearance appearance,
    required Gender gender,
  }) {
    if (appearance.hair == 'bald') {
      return null;
    }

    final List<String> available =
        gender == Gender.female
            ? _femaleHairStyles
            : _maleHairStyles;

    final List<String> nonBaldStyles =
        available
            .where(
              (String value) =>
                  value != 'bald',
            )
            .toList();

    if (nonBaldStyles.contains(
      appearance.hair,
    )) {
      return 'assets/character/hair/'
          '${appearance.hair}.png';
    }

    return 'assets/character/hair/'
        '${nonBaldStyles.first}.png';
  }

  Widget _buildCompactIdentityFields(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return Column(
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller:
                    _firstNameController,
                textCapitalization:
                    TextCapitalization.words,
                inputFormatters: [
                  _nameCapitalizationFormatter,
                ],
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'First Name',
                  hintText: 'First name',
                  border:
                      OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: s(8),
            ),
            Expanded(
              child: TextField(
                controller:
                    _lastNameController,
                textCapitalization:
                    TextCapitalization.words,
                inputFormatters: [
                  _nameCapitalizationFormatter,
                ],
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Last name',
                  border:
                      OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: s(8),
        ),
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildGenderField(
                context,
                zoom,
              ),
            ),
            SizedBox(
              width: s(8),
            ),
            Expanded(
              child: _buildBirthYearField(
                context,
                zoom,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderField(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        s(8),
      ),
      onTap: () {
        _showGenderPicker();
      },
      child: InputDecorator(
        decoration:
            const InputDecoration(
          labelText: 'Gender',
          border:
              OutlineInputBorder(),
          isDense: true,
          suffixIcon:
              Icon(
            Icons.arrow_drop_down,
          ),
        ),
        child: Text(
          _gender == Gender.male
              ? 'Male'
              : 'Female',
        ),
      ),
    );
  }

  Widget _buildBirthYearField(
    BuildContext context,
    double zoom,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(
        8 * zoom,
      ),
      onTap:
          _showBirthYearPicker,
      child: InputDecorator(
        decoration:
            const InputDecoration(
          labelText: 'Birth Year',
          border:
              OutlineInputBorder(),
          isDense: true,
          suffixIcon:
              Icon(
            Icons.arrow_drop_down,
          ),
        ),
        child: Text(
          '$_birthYear',
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showDialog<void>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Gender',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _gender == Gender.male
                      ? Icons
                          .radio_button_checked
                      : Icons
                          .radio_button_unchecked,
                ),
                title: const Text(
                  'Male',
                ),
                onTap: () {
                  setState(() {
                    _gender =
                        Gender.male;

                    if (!_maleHairStyles
                        .contains(
                      _appearance.hair,
                    )) {
                      _appearance =
                          _appearance.copyWith(
                        hair:
                            _maleHairStyles
                                .first,
                      );
                    }
                  });

                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
              ),
              ListTile(
                leading: Icon(
                  _gender == Gender.female
                      ? Icons
                          .radio_button_checked
                      : Icons
                          .radio_button_unchecked,
                ),
                title: const Text(
                  'Female',
                ),
                onTap: () {
                  setState(() {
                    _gender =
                        Gender.female;

                    if (!_femaleHairStyles
                        .contains(
                      _appearance.hair,
                    )) {
                      _appearance =
                          _appearance.copyWith(
                        hair:
                            _femaleHairStyles
                                .first,
                      );
                    }
                  });

                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkinToneSelectorFor(
    BuildContext context,
    double zoom,
    CharacterAppearance appearance,
    ValueChanged<CharacterAppearance>
        onChanged,
  ) {
    double s(double value) =>
        value * zoom;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Skin Tone',
          style: Theme.of(context)
              .textTheme
              .titleSmall,
        ),
        SizedBox(
          height: s(5),
        ),
        SizedBox(
          height: s(44),
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                _skinToneColors.length,
            separatorBuilder:
                (
              BuildContext context,
              int index,
            ) {
              return SizedBox(
                width: s(8),
              );
            },
            itemBuilder:
                (
              BuildContext context,
              int index,
            ) {
              final String key =
                  _skinToneColors.keys
                      .elementAt(index);

              final Color color =
                  _skinToneColors[key]!;

              final bool selected =
                  appearance.skinTone ==
                      key;

              return _buildColorDot(
                context: context,
                zoom: zoom,
                color: color,
                selected: selected,
                onTap: () {
                  onChanged(
                    appearance.copyWith(
                      skinTone: key,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelectorFor({
    required BuildContext context,
    required double zoom,
    required String title,
    required Map<String, Color> colors,
    required String selected,
    required ValueChanged<String>
        onSelected,
  }) {
    double s(double value) =>
        value * zoom;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall,
        ),
        SizedBox(
          height: s(5),
        ),
        SizedBox(
          height: s(44),
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                colors.length,
            separatorBuilder:
                (
              BuildContext context,
              int index,
            ) {
              return SizedBox(
                width: s(8),
              );
            },
            itemBuilder:
                (
              BuildContext context,
              int index,
            ) {
              final String key =
                  colors.keys.elementAt(
                index,
              );

              final Color color =
                  colors[key]!;

              final bool isSelected =
                  key == selected;

              return _buildColorDot(
                context: context,
                zoom: zoom,
                color: color,
                selected: isSelected,
                onTap: () {
                  onSelected(
                    key,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorDot({
    required BuildContext context,
    required double zoom,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    double s(double value) =>
        value * zoom;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        s(22),
      ),
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsets.all(s(2)),
        child: Container(
          width: s(36),
          height: s(36),
          decoration: BoxDecoration(
            shape:
                BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected
                  ? Theme.of(
                      context,
                    )
                      .colorScheme
                      .primary
                  : Theme.of(
                      context,
                    ).dividerColor,
              width: selected
                  ? s(3)
                  : s(1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetSelectorFor({
    required BuildContext context,
    required double zoom,
    required String title,
    required List<String> values,
    required String selected,
    required String assetDirectory,
    required ValueChanged<String>
        onSelected,
    required Color? color,
  }) {
    double s(double value) =>
        value * zoom;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall,
        ),
        SizedBox(
          height: s(5),
        ),
        SizedBox(
          height: s(88),
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                values.length,
            separatorBuilder:
                (
              BuildContext context,
              int index,
            ) {
              return SizedBox(
                width: s(6),
              );
            },
            itemBuilder:
                (
              BuildContext context,
              int index,
            ) {
              final String value =
                  values[index];

              final bool isSelected =
                  value == selected;

              final String assetPath =
                  '$assetDirectory/'
                  '$value.png';

              final bool isBald =
                  value == 'bald';

              return InkWell(
                borderRadius:
                    BorderRadius.circular(
                  s(8),
                ),
                onTap: () {
                  onSelected(
                    value,
                  );
                },
                child: Container(
                  width: s(78),
                  padding:
                      EdgeInsets.all(
                    s(4),
                  ),
                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? Theme.of(
                            context,
                          )
                            .colorScheme
                            .primary
                            .withValues(
                              alpha: 0.10,
                            )
                        : Theme.of(
                            context,
                          )
                            .colorScheme
                            .surface,
                    borderRadius:
                        BorderRadius.circular(
                      s(8),
                    ),
                    border:
                        Border.all(
                      color: isSelected
                          ? Theme.of(
                              context,
                            )
                              .colorScheme
                              .primary
                          : Theme.of(
                              context,
                            )
                              .dividerColor
                              .withValues(
                                alpha:
                                    0.6,
                              ),
                      width: isSelected
                          ? s(2)
                          : s(1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Expanded(
                        child: isBald
                            ? Image.asset(
                                assetPath,
                                fit: BoxFit
                                    .contain,
                                filterQuality:
                                    FilterQuality
                                        .high,
                              )
                            : ColorFiltered(
                                colorFilter:
                                    ColorFilter
                                        .mode(
                                  color ??
                                      Colors
                                          .white,
                                  BlendMode
                                      .modulate,
                                ),
                                child:
                                    Image.asset(
                                  assetPath,
                                  fit: BoxFit
                                      .contain,
                                  filterQuality:
                                      FilterQuality
                                          .high,
                                ),
                              ),
                      ),
                      SizedBox(
                        height: s(2),
                      ),
                      Text(
                        _prettyLabel(
                          value,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        textAlign:
                            TextAlign.center,
                        style:
                            Theme.of(
                          context,
                        )
                                .textTheme
                                .labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _prettyLabel(
    String value,
  ) {
    final String withoutPrefix =
        value.replaceFirst(
      RegExp(
        r'^(hair_|eyes_|brows_|male_hair_|female_hair_)',
      ),
      '',
    );

    return withoutPrefix
        .split('_')
        .where(
          (
            String word,
          ) =>
              word.isNotEmpty,
        )
        .map(
          (
            String word,
          ) {
            return word.substring(
                  0,
                  1,
                ).toUpperCase() +
                word.substring(1)
                    .toLowerCase();
          },
        )
        .join(' ');
  }
}

class _ResponsiveCard
    extends StatelessWidget {
  const _ResponsiveCard({
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
