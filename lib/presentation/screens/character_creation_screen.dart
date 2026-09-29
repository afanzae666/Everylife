import 'package:flutter/material.dart';

import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({
    required this.onCharacterCreated,
    this.uiScaleController,
    super.key,
  });

  final void Function(Character character)
      onCharacterCreated;

  final ValueNotifier<double>? uiScaleController;

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends State<CharacterCreationScreen> {
  final _firstNameController =
      TextEditingController();

  final _lastNameController =
      TextEditingController();

  Gender _gender = Gender.male;

  static const int _minimumBirthYear = 1900;
  static const int _maximumBirthYear = 2026;

  int _birthYear = _maximumBirthYear;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _createCharacter() {
    final firstName =
        _firstNameController.text.trim();

    final lastName =
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
            'Please enter your family name.',
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
      birthYear: _birthYear,
    );

    widget.onCharacterCreated(
      character,
    );
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
            SizedBox(
              height: s(4),
            ),
            _ResponsiveCard(
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
                  TextField(
                    controller:
                        _firstNameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        const InputDecoration(
                      labelText: 'First Name',
                      hintText:
                          'Enter first name',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: s(5),
                  ),
                  TextField(
                    controller:
                        _lastNameController,
                    textInputAction:
                        TextInputAction.done,
                    onSubmitted: (_) =>
                        _createCharacter(),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Last Name / Family Name',
                      hintText:
                          'Enter family name',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: s(4),
            ),
            _ResponsiveCard(
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
                  SizedBox(
                    height: s(3),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child:
                        SegmentedButton<Gender>(
                      segments: const [
                        ButtonSegment<Gender>(
                          value: Gender.male,
                          label: Text(
                            'Male',
                          ),
                          icon: Icon(
                            Icons.male,
                          ),
                        ),
                        ButtonSegment<Gender>(
                          value: Gender.female,
                          label: Text(
                            'Female',
                          ),
                          icon: Icon(
                            Icons.female,
                          ),
                        ),
                      ],
                      selected: {
                        _gender,
                      },
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
            ),
            SizedBox(
              height: s(4),
            ),
            _ResponsiveCard(
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
                  SizedBox(
                    height: s(2),
                  ),
                  Text(
                    '$_birthYear',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  SizedBox(
                    height: s(1),
                  ),
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
                      setState(() {
                        _birthYear =
                            value.round();
                      });
                    },
                  ),
                  Text(
                    'Your character will begin '
                    'life as a newborn in '
                    '$_birthYear.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: s(6),
            ),
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
}

class _ResponsiveCard extends StatelessWidget {
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
