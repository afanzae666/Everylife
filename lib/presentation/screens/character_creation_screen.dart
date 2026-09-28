import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/character/appearance.dart';
import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';

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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthYearController = TextEditingController();

  Gender _gender = Gender.male;

  static const int _minimumBirthYear = 1900;
  static const int _maximumBirthYear = 2026;

  int _birthYear = _maximumBirthYear;

  CharacterAppearance _appearance =
      const CharacterAppearance(
    base: 'default',
    skinTone: 'skin_04',
    hair: 'hair_short',
    hairColor: 'black',
    eyes: 'eyes_normal',
    eyeColor: 'brown',
    eyebrows: 'brows_normal',
  );

  static const List<String> _hairStyles = [
    'hair_bald',
    'hair_short',
    'hair_crop',
    'hair_side',
    'hair_curly',
    'hair_wave',
    'hair_long',
    'hair_bun',
  ];

  static const List<String> _eyeStyles = [
    'eyes_normal',
    'eyes_large',
    'eyes_narrow',
    'eyes_round',
    'eyes_soft',
  ];

  static const List<String> _eyebrowStyles = [
    'brows_normal',
    'brows_straight',
    'brows_thick',
    'brows_thin',
  ];

  static const Map<String, Color> _skinToneColors = {
    'skin_01': Color(0xFFF7D2B4),
    'skin_02': Color(0xFFF1B58D),
    'skin_03': Color(0xFFD99A73),
    'skin_04': Color(0xFFC47E5C),
    'skin_05': Color(0xFFA96345),
    'skin_06': Color(0xFF7D4B34),
    'skin_07': Color(0xFF543126),
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
  void initState() {
    super.initState();

    _birthYearController.text = _birthYear.toString();

    _birthYearController.addListener(
      _handleBirthYearTextChanged,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  void _handleBirthYearTextChanged() {
    final text = _birthYearController.text.trim();

    if (text.isEmpty) {
      return;
    }

    final parsed = int.tryParse(text);

    if (parsed == null) {
      return;
    }

    final clamped = parsed.clamp(
      _minimumBirthYear,
      _maximumBirthYear,
    );

    if (clamped != _birthYear) {
      setState(() {
        _birthYear = clamped;
      });
    }
  }

  void _setBirthYear(int value) {
    final clamped = value.clamp(
      _minimumBirthYear,
      _maximumBirthYear,
    );

    setState(() {
      _birthYear = clamped;

      final text = clamped.toString();

      if (_birthYearController.text != text) {
        _birthYearController.value =
            TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
            offset: text.length,
          ),
        );
      }
    });
  }

  void _commitManualBirthYear() {
    final text = _birthYearController.text.trim();

    final parsed = int.tryParse(text);

    if (parsed == null) {
      _birthYearController.text =
          _birthYear.toString();

      FocusScope.of(context).unfocus();
      return;
    }

    _setBirthYear(parsed);

    FocusScope.of(context).unfocus();
  }

  String _capitalizeName(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return '';
    }

    return normalized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) {
            if (word.length == 1) {
              return word.toUpperCase();
            }

            return '${word.substring(0, 1).toUpperCase()}'
                '${word.substring(1).toLowerCase()}';
          },
        )
        .join(' ');
  }

  void _normalizeNameFields() {
    final firstName =
        _capitalizeName(
      _firstNameController.text,
    );

    final lastName =
        _capitalizeName(
      _lastNameController.text,
    );

    if (_firstNameController.text != firstName) {
      _firstNameController.value =
          TextEditingValue(
        text: firstName,
        selection: TextSelection.collapsed(
          offset: firstName.length,
        ),
      );
    }

    if (_lastNameController.text != lastName) {
      _lastNameController.value =
          TextEditingValue(
        text: lastName,
        selection: TextSelection.collapsed(
          offset: lastName.length,
        ),
      );
    }
  }

  void _createCharacter() {
    _normalizeNameFields();

    final firstName =
        _capitalizeName(
      _firstNameController.text,
    );

    final lastName =
        _capitalizeName(
      _lastNameController.text,
    );

    final birthYearText =
        _birthYearController.text.trim();

    final parsedBirthYear =
        int.tryParse(birthYearText);

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

    if (parsedBirthYear == null ||
        parsedBirthYear < _minimumBirthYear ||
        parsedBirthYear > _maximumBirthYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Birth year must be between '
            '$_minimumBirthYear and '
            '$_maximumBirthYear.',
          ),
        ),
      );
      return;
    }

    final character = Character.create(
      id: 'player-'
          '${DateTime.now().microsecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      gender: _gender,
      birthYear: parsedBirthYear,
      appearance: _appearance,
    );

    widget.onCharacterCreated(
      character,
    );
  }

  void _updateAppearance(
    CharacterAppearance next,
  ) {
    setState(() {
      _appearance = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller =
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
        context,
        zoom,
        _,
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
    final mediaQuery =
        MediaQuery.of(context);

    final scaledMediaQuery =
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
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            s(8),
            s(4),
            s(8),
            s(12),
          ),
          children: [
            _ResponsiveCard(
              padding: EdgeInsets.all(s(8)),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Your Character',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  SizedBox(
                    height: s(2),
                  ),
                  Text(
                    'Your life begins at birth.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge,
                  ),
                ],
              ),
            ),
            SizedBox(height: s(4)),
            _buildBasicIdentityCard(
              context,
              zoom,
            ),
            SizedBox(height: s(4)),
            _buildGenderCard(
              context,
              zoom,
            ),
            SizedBox(height: s(4)),
            _buildBirthYearCard(
              context,
              zoom,
            ),
            SizedBox(height: s(4)),
            _buildAppearanceCard(
              context,
              zoom,
            ),
            SizedBox(height: s(6)),
            SizedBox(
              width: double.infinity,
              height: s(44),
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
    );
  }

  Widget _buildBasicIdentityCard(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.all(s(8)),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Identity',
            style: Theme.of(context)
                .textTheme
                .titleSmall,
          ),
          SizedBox(height: s(4)),
          TextField(
            controller:
                _firstNameController,
            textCapitalization:
                TextCapitalization.words,
            textInputAction:
                TextInputAction.next,
            onEditingComplete: () {
              _normalizeNameFields();

              FocusScope.of(context)
                  .nextFocus();
            },
            decoration:
                const InputDecoration(
              labelText: 'First Name',
              hintText:
                  'Enter first name',
              border:
                  OutlineInputBorder(),
            ),
          ),
          SizedBox(height: s(5)),
          TextField(
            controller:
                _lastNameController,
            textCapitalization:
                TextCapitalization.words,
            textInputAction:
                TextInputAction.done,
            onEditingComplete: () {
              _normalizeNameFields();

              FocusScope.of(context)
                  .unfocus();
            },
            onSubmitted: (_) {
              _normalizeNameFields();
            },
            decoration:
                const InputDecoration(
              labelText: 'Last Name',
              hintText:
                  'Enter last name',
              border:
                  OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(7),
        s(8),
        s(7),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: Theme.of(context)
                .textTheme
                .titleSmall,
          ),
          SizedBox(height: s(3)),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Gender>(
              segments: const [
                ButtonSegment<Gender>(
                  value: Gender.male,
                  label: Text('Male'),
                  icon: Icon(Icons.male),
                ),
                ButtonSegment<Gender>(
                  value: Gender.female,
                  label: Text('Female'),
                  icon: Icon(Icons.female),
                ),
              ],
              selected: {_gender},
              onSelectionChanged:
                  (selection) {
                setState(() {
                  _gender =
                      selection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthYearCard(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(7),
        s(8),
        s(7),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Birth Year',
            style: Theme.of(context)
                .textTheme
                .titleSmall,
          ),
          SizedBox(height: s(3)),
          TextField(
            controller:
                _birthYearController,
            keyboardType:
                TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter
                  .digitsOnly,
              LengthLimitingTextInputFormatter(
                4,
              ),
            ],
            textInputAction:
                TextInputAction.done,
            onSubmitted: (_) {
              _commitManualBirthYear();
            },
            onEditingComplete:
                _commitManualBirthYear,
            decoration:
                const InputDecoration(
              labelText: 'Year',
              border:
                  OutlineInputBorder(),
              suffixText: 'AD',
            ),
          ),
          SizedBox(height: s(2)),
          Slider(
            min: _minimumBirthYear
                .toDouble(),
            max: _maximumBirthYear
                .toDouble(),
            divisions:
                _maximumBirthYear -
                    _minimumBirthYear,
            value:
                _birthYear.toDouble(),
            label:
                '$_birthYear',
            onChanged: (value) {
              _setBirthYear(
                value.round(),
              );
            },
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: s(4),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_minimumBirthYear',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
                Text(
                  '$_birthYear',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),
                Text(
                  '$_maximumBirthYear',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(height: s(2)),
          Text(
            'Choose a year by sliding or '
            'entering it manually.',
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    return _ResponsiveCard(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(8),
        s(8),
        s(8),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
          SizedBox(height: s(5)),
          _buildAppearancePreview(
            context,
            zoom,
          ),
          SizedBox(height: s(8)),
          _buildSkinToneSelector(
            context,
            zoom,
          ),
          SizedBox(height: s(8)),
          _buildAssetSelector(
            context: context,
            zoom: zoom,
            title: 'Hair',
            values: _hairStyles,
            selected:
                _appearance.hair,
            assetDirectory:
                'assets/character/hair',
            onSelected: (value) {
              _updateAppearance(
                _appearance.copyWith(
                  hair: value,
                ),
              );
            },
          ),
          SizedBox(height: s(8)),
          _buildColorSelector(
            context: context,
            zoom: zoom,
            title: 'Hair Color',
            colors: _hairColors,
            selected:
                _appearance.hairColor,
            onSelected: (value) {
              _updateAppearance(
                _appearance.copyWith(
                  hairColor: value,
                ),
              );
            },
          ),
          SizedBox(height: s(8)),
          _buildAssetSelector(
            context: context,
            zoom: zoom,
            title: 'Eyes',
            values: _eyeStyles,
            selected:
                _appearance.eyes,
            assetDirectory:
                'assets/character/eyes',
            onSelected: (value) {
              _updateAppearance(
                _appearance.copyWith(
                  eyes: value,
                ),
              );
            },
          ),
          SizedBox(height: s(8)),
          _buildColorSelector(
            context: context,
            zoom: zoom,
            title: 'Eye Color',
            colors: _eyeColors,
            selected:
                _appearance.eyeColor,
            onSelected: (value) {
              _updateAppearance(
                _appearance.copyWith(
                  eyeColor: value,
                ),
              );
            },
          ),
          SizedBox(height: s(8)),
          _buildAssetSelector(
            context: context,
            zoom: zoom,
            title: 'Eyebrows',
            values: _eyebrowStyles,
            selected:
                _appearance.eyebrows,
            assetDirectory:
                'assets/character/eyebrows',
            onSelected: (value) {
              _updateAppearance(
                _appearance.copyWith(
                  eyebrows: value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearancePreview(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) =>
        value * zoom;

    final skinColor =
        _skinToneColors[
                _appearance.skinTone] ??
            _skinToneColors.values.first;

    final hairColor =
        _hairColors[
                _appearance.hairColor] ??
            _hairColors.values.first;

    final eyeColor =
        _eyeColors[
                _appearance.eyeColor] ??
            _eyeColors.values.first;

    return Container(
      width: double.infinity,
      height: s(210),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius:
            BorderRadius.circular(s(10)),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: s(160),
          height: s(180),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Skin foundation.
              Container(
                width: s(126),
                height: s(142),
                decoration:
                    BoxDecoration(
                  color: skinColor,
                  borderRadius:
                      BorderRadius.circular(
                    s(58),
                  ),
                ),
              ),

              // Actual head asset.
              SvgPicture.asset(
                'assets/character/base/'
                'head_base.svg',
                width: s(142),
                height: s(158),
                fit: BoxFit.contain,
              ),

              // Eyes.
              ColorFiltered(
                colorFilter:
                    ColorFilter.mode(
                  eyeColor,
                  BlendMode.srcIn,
                ),
                child:
                    SvgPicture.asset(
                  'assets/character/eyes/'
                  '${_appearance.eyes}.svg',
                  width: s(142),
                  height: s(158),
                  fit: BoxFit.contain,
                ),
              ),

              // Eyebrows.
              SvgPicture.asset(
                'assets/character/eyebrows/'
                '${_appearance.eyebrows}.svg',
                width: s(142),
                height: s(158),
                fit: BoxFit.contain,
              ),

              // Nose.
              SvgPicture.asset(
                'assets/character/base/'
                'nose.fixed.svg',
                width: s(142),
                height: s(158),
                fit: BoxFit.contain,
              ),

              // Mouth.
              SvgPicture.asset(
                'assets/character/base/'
                'mouth.fixed.svg',
                width: s(142),
                height: s(158),
                fit: BoxFit.contain,
              ),

              // Neutral expression layer.
              SvgPicture.asset(
                'assets/character/expression/'
                'expression_neutral.svg',
                width: s(142),
                height: s(158),
                fit: BoxFit.contain,
              ),

              // Hair is rendered last so it sits
              // above the other facial layers.
              ColorFiltered(
                colorFilter:
                    ColorFilter.mode(
                  hairColor,
                  BlendMode.srcIn,
                ),
                child:
                    SvgPicture.asset(
                  'assets/character/hair/'
                  '${_appearance.hair}.svg',
                  width: s(142),
                  height: s(158),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkinToneSelector(
    BuildContext context,
    double zoom,
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
        SizedBox(height: s(4)),
        Wrap(
          spacing: s(7),
          runSpacing: s(7),
          children:
              _skinToneColors.entries
                  .map(
                    (entry) {
                      final selected =
                          _appearance.skinTone ==
                              entry.key;

                      return InkWell(
                        borderRadius:
                            BorderRadius.circular(
                          s(20),
                        ),
                        onTap: () {
                          _updateAppearance(
                            _appearance.copyWith(
                              skinTone:
                                  entry.key,
                            ),
                          );
                        },
                        child: Container(
                          width: s(34),
                          height: s(34),
                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,
                            color: entry.value,
                            border: Border.all(
                              color: selected
                                  ? Theme.of(
                                      context,
                                    )
                                      .colorScheme
                                      .primary
                                  : Theme.of(
                                      context,
                                    )
                                      .dividerColor,
                              width: selected
                                  ? s(3)
                                  : s(1),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector({
    required BuildContext context,
    required double zoom,
    required String title,
    required Map<String, Color> colors,
    required String selected,
    required ValueChanged<String> onSelected,
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
        SizedBox(height: s(4)),
        Wrap(
          spacing: s(7),
          runSpacing: s(7),
          children: colors.entries
              .map(
                (entry) {
                  final isSelected =
                      entry.key == selected;

                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      s(20),
                    ),
                    onTap: () {
                      onSelected(entry.key);
                    },
                    child: Container(
                      width: s(34),
                      height: s(34),
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: entry.value,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                )
                                  .colorScheme
                                  .primary
                              : Theme.of(
                                  context,
                                )
                                  .dividerColor,
                          width: isSelected
                              ? s(3)
                              : s(1),
                        ),
                      ),
                    ),
                  );
                },
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAssetSelector({
    required BuildContext context,
    required double zoom,
    required String title,
    required List<String> values,
    required String selected,
    required String assetDirectory,
    required ValueChanged<String> onSelected,
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
        SizedBox(height: s(4)),
        SizedBox(
          height: s(86),
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount: values.length,
            separatorBuilder: (
              _,
              __,
            ) =>
                SizedBox(width: s(6)),
            itemBuilder: (
              context,
              index,
            ) {
              final value =
                  values[index];

              final isSelected =
                  value == selected;

              final assetPath =
                  '$assetDirectory/'
                  '$value.svg';

              return InkWell(
                borderRadius:
                    BorderRadius.circular(
                  s(8),
                ),
                onTap: () {
                  onSelected(value);
                },
                child: Container(
                  width: s(76),
                  padding:
                      EdgeInsets.all(s(4)),
                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(
                              alpha: 0.10,
                            )
                        : Theme.of(context)
                            .colorScheme
                            .surface,
                    borderRadius:
                        BorderRadius.circular(
                      s(8),
                    ),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                          : Theme.of(context)
                              .dividerColor
                              .withValues(
                                alpha: 0.6,
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
                        child:
                            SvgPicture.asset(
                          assetPath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: s(2),
                      ),
                      Text(
                        _prettyLabel(value),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        textAlign:
                            TextAlign.center,
                        style: Theme.of(context)
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

  String _prettyLabel(String value) {
    final withoutPrefix = value
        .replaceFirst(
          RegExp(
            r'^(hair_|eyes_|brows_)',
          ),
          '',
        );

    return withoutPrefix
        .split('_')
        .map(
          (word) {
            if (word.isEmpty) {
              return word;
            }

            return word.substring(0, 1)
                    .toUpperCase() +
                word.substring(1);
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
  Widget build(BuildContext context) {
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
