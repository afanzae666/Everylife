import 'package:flutter/material.dart';

import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({
    required this.onCharacterCreated,
    super.key,
  });

  final void Function(Character character) onCharacterCreated;

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends State<CharacterCreationScreen> {
  final _nameController = TextEditingController();

  Gender _gender = Gender.male;

  static const int _minimumBirthYear = 1900;
  static const int _maximumBirthYear = 2026;

  int _birthYear = _maximumBirthYear;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createCharacter() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your character name.'),
        ),
      );
      return;
    }

    final character = Character.create(
      id: 'player-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      gender: _gender,
      birthYear: _birthYear,
    );

    widget.onCharacterCreated(character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Character'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Create Your Character',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your life begins at birth.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter character name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gender',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<Gender>(
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
              onSelectionChanged: (selection) {
                setState(() {
                  _gender = selection.first;
                });
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Birth Year',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$_birthYear',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),
            Slider(
              min: _minimumBirthYear.toDouble(),
              max: _maximumBirthYear.toDouble(),
              divisions:
                  _maximumBirthYear - _minimumBirthYear,
              value: _birthYear.toDouble(),
              label: '$_birthYear',
              onChanged: (value) {
                setState(() {
                  _birthYear = value.round();
                });
              },
            ),
            Text(
              'Your character will begin life as a newborn '
              'in $_birthYear.',
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: _createCharacter,
              icon: const Icon(Icons.child_friendly),
              label: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Text('BEGIN LIFE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
