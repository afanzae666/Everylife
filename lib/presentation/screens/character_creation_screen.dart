import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/appearance.dart';
import '../../domain/character/character.dart';
import '../../domain/character/character_hair.dart';
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

  final Random _random = Random();

  static final TextInputFormatter _nameCapitalizationFormatter =
      TextInputFormatter.withFunction(
    (
      TextEditingValue oldValue,
      TextEditingValue newValue,
    ) {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      final StringBuffer buffer = StringBuffer();

      bool capitalizeNext = true;

      for (final int rune in newValue.text.runes) {
        final String character = String.fromCharCode(rune);

        if (RegExp(r'\s').hasMatch(character)) {
          buffer.write(character);
          capitalizeNext = true;
          continue;
        }

        if (capitalizeNext) {
          buffer.write(character.toUpperCase());
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

  CharacterAppearance _appearance = const CharacterAppearance(
    base: 'default',
    skinTone: 'medium',
    hair: 'male_hair_01',
    hairColor: 'black',
    eyes: 'adult_eyes',
    eyeColor: 'brown',
    eyebrows: 'straight',
    beard: 'none',
  );

  CharacterPaletteService? _paletteService;

  bool _paletteLoading = true;

  String? _paletteError;


  static const List<String> _maleFirstNames = [
    'Alex',
    'Daniel',
    'Ethan',
    'James',
    'Liam',
    'Noah',
    'Oliver',
    'Ryan',
    'Samuel',
    'William',
  ];

  static const List<String> _femaleFirstNames = [
    'Anna',
    'Chloe',
    'Emma',
    'Grace',
    'Hannah',
    'Isabella',
    'Mia',
    'Olivia',
    'Sophia',
    'Victoria',
  ];

  static const List<String> _lastNames = [
    'Anderson',
    'Bennett',
    'Brooks',
    'Carter',
    'Collins',
    'Cooper',
    'Davis',
    'Evans',
    'Foster',
    'Garcia',
    'Harris',
    'Johnson',
    'Lewis',
    'Martin',
    'Morgan',
    'Parker',
    'Roberts',
    'Smith',
    'Taylor',
    'Wilson',
  ];

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
  void initState() {
    super.initState();


    _loadPalette();
  }

  String _randomItem(
    List<String> values,
  ) {
    return values[
      _random.nextInt(
        values.length,
      )
    ];
  }

  Future<void> _loadPalette() async {
    try {
      final CharacterPaletteService palette =
          await CharacterPaletteService.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _paletteService = palette;
        _paletteLoading = false;
        _paletteError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _paletteLoading = false;
        _paletteError = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _createCharacter() {
    if (_paletteService == null) {
      return;
    }

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

final bool playerSelectedBald =
    _appearance.hair == CharacterHair.bald;

final CharacterAppearance finalAppearance =
    _appearance.copyWith(
  infantHair: playerSelectedBald
      ? CharacterHair.bald
      : CharacterHair.randomAutomaticHair(
          random: _random,
          gender: _gender,
          stage: LifeStage.infant,
        ),
  toddlerHair: playerSelectedBald
      ? CharacterHair.bald
      : CharacterHair.randomAutomaticHair(
          random: _random,
          gender: _gender,
          stage: LifeStage.toddler,
        ),
  childHair: playerSelectedBald
      ? CharacterHair.bald
      : CharacterHair.randomAutomaticHair(
          random: _random,
          gender: _gender,
          stage: LifeStage.child,
        ),
);
    
    final Character character = Character.create(
      id:
          'player-${DateTime.now().microsecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      gender: _gender,
      birthYear: _birthYear,
      appearance: finalAppearance,
    );

    widget.onCharacterCreated(
      character,
    );
  }

  void _randomizeAppearance() {
    if (_paletteService == null) {
      return;
    }

    final Gender randomGender =
        _random.nextBool()
            ? Gender.male
            : Gender.female;

    final List<String> hairStyles =
        <String>[
          CharacterHair.bald,
          ...CharacterHair.masterStylesFor(
            randomGender,
          ),
        ];

    final List<String> firstNamePool =
        randomGender == Gender.female
            ? _femaleFirstNames
            : _maleFirstNames;

    final String randomHair =
        _randomItem(hairStyles);

    final String randomBeard =
        randomGender == Gender.male
            ? _randomItem(_beardStyles)
            : 'none';

    final String randomFirstName =
        _randomItem(firstNamePool);

    final String randomLastName =
        _randomItem(_lastNames);

    final String randomSkinTone =
        _randomItem(
      _paletteService!.skinColors.keys.toList(),
    );

    final String randomHairColor =
        _randomItem(
      _paletteService!.hairColors.keys.toList(),
    );

    final String randomEyeColor =
        _randomItem(
      _paletteService!.eyeColors.keys.toList(),
    );

    final String randomEyebrow =
        _randomItem(_eyebrowStyles);

    setState(() {
      _gender = randomGender;


      _appearance = _appearance.copyWith(
        skinTone: randomSkinTone,
        hair: randomHair,
        hairColor: randomHairColor,
        eyeColor: randomEyeColor,
        eyebrows: randomEyebrow,
        beard: randomBeard,
      );

      _firstNameController.text =
          randomFirstName;

      _lastNameController.text =
          randomLastName;
    });
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
    if (_paletteService == null) {
      return;
    }

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

            const LifeStage previewStage =
                LifeStage.youngAdult;

            final bool showBeardSelector =
                _gender == Gender.male &&
                    _canUseBeardAtStage(
                      previewStage,
                    );

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 520,
                  maxHeight: 720,
                ),
                child: LayoutBuilder(
                  builder: (
                    BuildContext context,
                    BoxConstraints constraints,
                  ) {
                    final double availableHeight =
                        constraints.maxHeight;

                    final double contentPadding =
                        availableHeight < 420
                            ? 8
                            : availableHeight < 560
                                ? 10
                                : 16;

                    final double headerGap =
                        availableHeight < 420
                            ? 0
                            : 2;

                    final double doneHeight =
                        availableHeight < 420
                            ? 36
                            : availableHeight < 560
                                ? 40
                                : 46;

                    final double selectorZoom =
                        (availableHeight / 520.0)
                            .clamp(
                              0.90,
                              1.0,
                            )
                            .toDouble();

                    return Padding(
                      padding:
                          EdgeInsets.all(
                        contentPadding,
                      ),
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
                                visualDensity:
                                    availableHeight <
                                            560
                                        ? VisualDensity
                                            .compact
                                        : null,
                                onPressed: () {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop();
                                },
                                icon:
                                    const Icon(
                                  Icons.close,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: headerGap,
                          ),
                          Expanded(
                            child:
                                LayoutBuilder(
                              builder: (
                                BuildContext context,
                                BoxConstraints middleConstraints,
                              ) {
                                final double middleHeight =
                                    middleConstraints
                                        .maxHeight;

                                final int assetCount =
                                    showBeardSelector
                                        ? 3
                                        : 2;

                                final int elementCount =
                                    1 +
                                        3 +
                                        assetCount;

                                final int gapCount =
                                    elementCount -
                                        1;

                                final double desiredPreviewHeight =
                                    (middleHeight *
                                            0.31)
                                        .clamp(
                                          82.0,
                                          190.0,
                                        )
                                        .toDouble();

                                final double desiredColorRowHeight =
                                    (middleHeight *
                                            0.09)
                                        .clamp(
                                          30.0,
                                          52.0,
                                        )
                                        .toDouble();

                                final double desiredAssetRowHeight =
                                    (middleHeight *
                                            0.115)
                                        .clamp(
                                          38.0,
                                          68.0,
                                        )
                                        .toDouble();

                                final double desiredGap =
                                    (middleHeight *
                                            0.012)
                                        .clamp(
                                          2.0,
                                          8.0,
                                        )
                                        .toDouble();

                                final double desiredTotal =
                                    desiredPreviewHeight +
                                        (desiredColorRowHeight *
                                            3) +
                                        (desiredAssetRowHeight *
                                            assetCount) +
                                        (desiredGap *
                                            gapCount);

                                final double fitScale =
                                    min(
                                      1.0,
                                      middleHeight /
                                          desiredTotal,
                                    );

                                final double previewHeight =
                                    desiredPreviewHeight *
                                        fitScale;

                                final double colorRowHeight =
                                    desiredColorRowHeight *
                                        fitScale;

                                final double assetRowHeight =
                                    desiredAssetRowHeight *
                                        fitScale;

                                final double sectionGap =
                                    desiredGap *
                                        fitScale;

                                final double previewAvatarSize =
                                    (previewHeight -
                                            6)
                                        .clamp(
                                          64.0,
                                          180.0,
                                        )
                                        .toDouble();

                                final double previewContainerSize =
                                    (previewAvatarSize +
                                            8)
                                        .clamp(
                                          72.0,
                                          188.0,
                                        )
                                        .toDouble();

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    _buildAppearancePreviewFor(
                                      context,
                                      selectorZoom,
                                      temporaryAppearance,
                                      height:
                                          previewHeight,
                                      avatarSize:
                                          previewAvatarSize,
                                      avatarContainerSize:
                                          previewContainerSize,
                                    ),
                                    SizedBox(
                                      height:
                                          sectionGap,
                                    ),
                                    _buildSkinToneSelectorFor(
                                      context,
                                      selectorZoom,
                                      temporaryAppearance,
                                      updateTemporaryAppearance,
                                      rowHeight:
                                          colorRowHeight,
                                    ),
                                    SizedBox(
                                      height:
                                          sectionGap,
                                    ),
                                    _buildColorSelectorFor(
                                      context:
                                          context,
                                      zoom:
                                          selectorZoom,
                                      title:
                                          'Eye Color',
                                      colors:
                                          _paletteService!
                                              .eyeColors,
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
                                      rowHeight:
                                          colorRowHeight,
                                    ),
                                    SizedBox(
                                      height:
                                          sectionGap,
                                    ),
                                    _buildAssetSelectorFor(
                                      context:
                                          context,
                                      zoom:
                                          selectorZoom,
                                      title:
                                          'Hair',
                                      showTitle:
                                          false,
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
                                            hair:
                                                value,
                                          ),
                                        );
                                      },
                                      color:
                                          _paletteService!
                                              .hairColor(
                                        temporaryAppearance
                                            .hairColor,
                                      ),
                                      rowHeight:
                                          assetRowHeight,
                                    ),
                                    SizedBox(
                                      height:
                                          sectionGap,
                                    ),
                                    _buildColorSelectorFor(
                                      context:
                                          context,
                                      zoom:
                                          selectorZoom,
                                      title:
                                          'Hair Color',
                                      colors:
                                          _paletteService!
                                              .hairColors,
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
                                      rowHeight:
                                          colorRowHeight,
                                    ),
                                    SizedBox(
                                      height:
                                          sectionGap,
                                    ),
                                    _buildAssetSelectorFor(
                                      context:
                                          context,
                                      zoom:
                                          selectorZoom,
                                      title:
                                          'Eyebrows',
                                      showTitle:
                                          false,
                                      values:
                                          _eyebrowStyles,
                                      selected:
                                          temporaryAppearance
                                              .eyebrows,
                                      assetDirectory:
                                          _eyebrowDirectoryFor(
                                        previewStage,
                                      ),
                                      assetFilePrefix:
                                          _eyebrowFilePrefixFor(
                                        previewStage,
                                      ),
                                      onSelected:
                                          (
                                        String value,
                                      ) {
                                        updateTemporaryAppearance(
                                          temporaryAppearance
                                              .copyWith(
                                            eyebrows:
                                                value,
                                          ),
                                        );
                                      },
                                      color:
                                          _paletteService!
                                              .hairColor(
                                        temporaryAppearance
                                            .hairColor,
                                      ),
                                      rowHeight:
                                          assetRowHeight,
                                    ),
                                    if (showBeardSelector) ...[
                                      SizedBox(
                                        height:
                                            sectionGap,
                                      ),
                                      _buildAssetSelectorFor(
                                        context:
                                            context,
                                        zoom:
                                            selectorZoom,
                                        title:
                                            'Beard',
                                        showTitle:
                                            false,
                                        values:
                                            _beardStyles,
                                        selected:
                                            temporaryAppearance
                                                .beard,
                                        assetDirectory:
                                            'assets/character/beard',
                                        onSelected:
                                            (
                                          String value,
                                        ) {
                                          updateTemporaryAppearance(
                                            temporaryAppearance
                                                .copyWith(
                                              beard:
                                                  value,
                                            ),
                                          );
                                        },
                                        color:
                                            _paletteService!
                                                .hairColor(
                                          temporaryAppearance
                                              .hairColor,
                                        ),
                                        rowHeight:
                                            assetRowHeight,
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: sectionGapFallback(
                              availableHeight,
                            ),
                          ),
                          SizedBox(
                            width:
                                double.infinity,
                            height: doneHeight,
                            child:
                                FilledButton(
                              onPressed: () {
                                setState(() {
                                  _appearance =
                                      temporaryAppearance;
                                });

                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              },
                              child:
                                  const Text(
                                'DONE',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  double sectionGapFallback(
    double availableHeight,
  ) {
    if (availableHeight < 420) {
      return 4;
    }

    if (availableHeight < 560) {
      return 6;
    }

    return 8;
  }

  List<String> _currentHairStyles() {
    return <String>[
      CharacterHair.bald,
      ...CharacterHair.masterStylesFor(_gender),
    ];
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final ValueNotifier<double>? controller =
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
    if (_paletteLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_paletteError != null ||
        _paletteService == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'Unable to load character palettes.',
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _paletteLoading =
                          true;
                      _paletteError =
                          null;
                    });

                    _loadPalette();
                  },
                  child: const Text(
                    'RETRY',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final MediaQueryData mediaQuery =
        MediaQuery.of(context);

    final MediaQueryData scaledMediaQuery =
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
      resizeToAvoidBottomInset: true,
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
                  child: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      final bool compact =
                          constraints.maxHeight < 430;

                      final double previewSize =
                          compact ? 125 : 190;

                      final double previewContainerSize =
                          compact ? 132 : 200;

                      final double sectionGap =
                          compact ? s(1) : s(2);

                      final double buttonVerticalPadding =
                          compact ? s(2) : s(8);

                      final ButtonStyle buttonStyle =
                          TextButton.styleFrom(
                        minimumSize:
                            const Size(0, 0),
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: s(8),
                          vertical:
                              buttonVerticalPadding,
                        ),
                        tapTargetSize:
                            MaterialTapTargetSize
                                .shrinkWrap,
                      );

                      return Column(
                        children: [
                          Flexible(
                            flex: 5,
                            fit: FlexFit.loose,
                            child: Center(
                              child:
                                  _buildMainAvatarPreview(
                                context,
                                zoom,
                                size: previewSize,
                                containerSize:
                                    previewContainerSize,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: sectionGap,
                          ),
                          TextButton.icon(
                            style: buttonStyle,
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
                            height: sectionGap,
                          ),
                          TextButton.icon(
                            style: buttonStyle,
                            onPressed:
                                _randomizeAppearance,
                            icon: Icon(
                              Icons.casino_outlined,
                              size: s(17),
                            ),
                            label: const Text(
                              'Random Appearance',
                            ),
                          ),
                          SizedBox(
                            height:
                                compact
                                    ? s(2)
                                    : s(4),
                          ),
                          Flexible(
                            flex: 4,
                            fit: FlexFit.loose,
                            child:
                                _buildCompactIdentityFields(
                              context,
                              zoom,
                            ),
                          ),
                        ],
                      );
                    },
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
    double zoom, {
    double size = 190,
    double containerSize = 200,
  }) {
    const LifeStage stage =
        LifeStage.youngAdult;

    return _buildAvatarStack(
      context: context,
      zoom: zoom,
      appearance: _appearance,
      stage: stage,
      gender: _gender,
      size: size,
      containerSize: containerSize,
    );
  }

  Widget _buildAppearancePreviewFor(
    BuildContext context,
    double zoom,
    CharacterAppearance appearance, {
    required double height,
    required double avatarSize,
    required double avatarContainerSize,
  }) {
    const LifeStage previewStage =
        LifeStage.youngAdult;

    return Container(
      width: double.infinity,
      height: height,
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
          stage: previewStage,
          gender: _gender,
          size: avatarSize,
          containerSize:
              avatarContainerSize,
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

    final CharacterPaletteService palette =
        _paletteService!;

    final Color skinColor =
        palette.skinColor(
              appearance.skinTone,
            ) ??
            palette.skinColors.values.first;

    final Color hairColor =
        palette.hairColor(
              appearance.hairColor,
            ) ??
            palette.hairColors.values.first;

    final Color eyeColor =
        palette.eyeColor(
              appearance.eyeColor,
            ) ??
            palette.eyeColors.values.first;

    final String headAsset =
        _headAssetFor(stage);

    final String eyesBaseAsset =
        _eyesBaseAssetFor(stage);

    final String eyesIrisAsset =
        _eyesIrisAssetFor(stage);

    final String eyebrowAsset =
        _eyebrowAssetFor(
      stage,
      appearance.eyebrows,
    );

    final String mouthAsset =
        _mouthAssetFor(stage);

    final String? hairAsset =
        _hairAssetFor(
      appearance: appearance,
      gender: gender,
      stage: stage,
    );

    final String? beardAsset =
        _beardAssetFor(
      appearance: appearance,
      stage: stage,
      gender: gender,
    );

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
          fixedImage(
            assetPath: eyesBaseAsset,
            scale: eyeScale,
          ),
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
          fixedImage(
            assetPath: mouthAsset,
          ),
          if (beardAsset != null)
            tintedImage(
              assetPath: beardAsset,
              color: hairColor,
            ),
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

  String _eyebrowDirectoryFor(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'assets/character/eyebrows/infant';

      case LifeStage.toddler:
        return 'assets/character/eyebrows/toddler';

      case LifeStage.child:
        return 'assets/character/eyebrows/child';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'assets/character/eyebrows/young_adult';
    }
  }

  String _eyebrowFilePrefixFor(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'infant_eyebrow';

      case LifeStage.toddler:
        return 'toddler_eyebrow';

      case LifeStage.child:
        return 'child_eyebrow';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return 'young_adult_eyebrow';
    }
  }

  String _eyebrowAssetFor(
    LifeStage stage,
    String eyebrowStyle,
  ) {
    final String directory =
        _eyebrowDirectoryFor(stage);

    final String selectedStyle =
        _eyebrowStyles.contains(
      eyebrowStyle,
    )
            ? eyebrowStyle
            : 'straight';

    String prefix;

    switch (stage) {
      case LifeStage.infant:
        prefix = 'infant_eyebrow';

      case LifeStage.toddler:
        prefix = 'toddler_eyebrow';

      case LifeStage.child:
        prefix = 'child_eyebrow';

      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        prefix = 'young_adult_eyebrow';
    }

    return '$directory/'
        '${prefix}_$selectedStyle.png';
  }

  bool _canUseBeardAtStage(
    LifeStage stage,
  ) {
    if (_gender != Gender.male) {
      return false;
    }

    switch (stage) {
      case LifeStage.youngAdult:
      case LifeStage.adult:
      case LifeStage.senior:
        return true;

      case LifeStage.infant:
      case LifeStage.toddler:
      case LifeStage.child:
      case LifeStage.teen:
        return false;
    }
  }

  String? _beardAssetFor({
    required CharacterAppearance appearance,
    required LifeStage stage,
    required Gender gender,
  }) {
    if (gender != Gender.male ||
        !_canUseBeardAtStage(stage) ||
        appearance.beard == 'none') {
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
    required LifeStage stage,
  }) {
    return CharacterHair.assetPath(
      hair: appearance.hair,
      gender: gender,
      stage: stage,
    );
  }

  Widget _buildCompactIdentityFields(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return Column(
      mainAxisSize: MainAxisSize.min,
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

                    final List<String> validStyles =
                        CharacterHair.masterStylesFor(
                      Gender.male,
                    );

                    if (_appearance.hair != CharacterHair.bald &&
                        !validStyles.contains(
                          _appearance.hair,
                        )) {
                      _appearance =
                          _appearance.copyWith(
                        hair: validStyles.first,
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

                    final List<String> validStyles =
                        CharacterHair.masterStylesFor(
                      Gender.female,
                    );

                    if (_appearance.hair != CharacterHair.bald &&
                        !validStyles.contains(
                          _appearance.hair,
                        )) {
                      _appearance =
                          _appearance.copyWith(
                        hair: validStyles.first,
                      );
                    }

                    _appearance =
                        _appearance.copyWith(
                      beard: 'none',
                    );
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
        onChanged, {
    required double rowHeight,
  }) {
    final Map<String, Color> skinColors =
        _paletteService!.skinColors;

    final double diameter =
        (rowHeight - 4)
            .clamp(
              24.0,
              38.0,
            )
            .toDouble();

    final double labelWidth =
        rowHeight < 34
            ? 72
            : 78;

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              'Skin Tone',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount:
                  skinColors.length,
              separatorBuilder:
                  (
                BuildContext context,
                int index,
              ) {
                return const SizedBox(
                  width: 4,
                );
              },
              itemBuilder:
                  (
                BuildContext context,
                int index,
              ) {
                final String key =
                    skinColors.keys.elementAt(
                  index,
                );

                final Color color =
                    skinColors[key]!;

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
                  diameter: diameter,
                );
              },
            ),
          ),
        ],
      ),
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
    required double rowHeight,
  }) {
    final double diameter =
        (rowHeight - 4)
            .clamp(
              24.0,
              38.0,
            )
            .toDouble();

    final double labelWidth =
        rowHeight < 34
            ? 72
            : 78;

    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          Expanded(
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount:
                  colors.length,
              separatorBuilder:
                  (
                BuildContext context,
                int index,
              ) {
                return const SizedBox(
                  width: 4,
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
                  diameter: diameter,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot({
    required BuildContext context,
    required double zoom,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
    double diameter = 36,
  }) {
    final double padding =
        diameter < 28
            ? 1
            : 2;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        diameter / 2 + padding,
      ),
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsets.all(padding),
        child: Container(
          width: diameter,
          height: diameter,
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
                  ? 3
                  : 1,
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
    String? assetFilePrefix,
    required ValueChanged<String>
        onSelected,
    required Color? color,
    required double rowHeight,
    bool showTitle = true,
  }) {
    final double cardWidth =
        (rowHeight * 1.25)
            .clamp(
              60.0,
              82.0,
            )
            .toDouble();

    final double cardRadius =
        rowHeight < 42
            ? 7
            : 8;

    final double cardPadding =
        rowHeight < 42
            ? 2
            : 3;

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount:
            values.length,
        separatorBuilder:
            (
          BuildContext context,
          int index,
        ) {
          return const SizedBox(
            width: 5,
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

          final bool isNone =
              value == 'none';

          final bool isBald =
              value == 'bald';

          final String assetName =
              assetFilePrefix == null
                  ? value
                  : '${assetFilePrefix}_$value';

          final String assetPath =
              '$assetDirectory/'
              '$assetName.png';

          return InkWell(
            borderRadius:
                BorderRadius.circular(
              cardRadius,
            ),
            onTap: () {
              onSelected(
                value,
              );
            },
            child: Container(
              width: cardWidth,
              padding:
                  EdgeInsets.all(
                cardPadding,
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
                  cardRadius,
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
                            alpha: 0.6,
                          ),
                  width: isSelected
                      ? 2
                      : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Expanded(
                    child: isNone
                        ? Icon(
                            Icons.block,
                            size:
                                rowHeight < 42
                                    ? 16
                                    : 22,
                          )
                        : isBald
                            ? Image.asset(
                                assetPath,
                                fit:
                                    BoxFit.contain,
                                filterQuality:
                                    FilterQuality.high,
                              )
                            : ColorFiltered(
                                colorFilter:
                                    ColorFilter.mode(
                                  color ??
                                      Colors.white,
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
                  if (rowHeight >= 38)
                    SizedBox(
                      height:
                          rowHeight < 44
                              ? 0
                              : 1,
                    ),
                  Text(
                    _prettyLabel(value),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign:
                        TextAlign.center,
                    style:
                        Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              fontSize:
                                  rowHeight < 44
                                      ? 8
                                      : 9,
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _prettyLabel(
    String value,
  ) {
    if (value == CharacterHair.bald) {
      return 'Bald';
    }

    final String withoutPrefix =
        value.replaceFirst(
      RegExp(
        r'^(hair_|eyes_|brows_|male_hair_|female_hair_|male_hair_toddler_|female_hair_toddler_|male_hair_child_|female_hair_child_)',
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
