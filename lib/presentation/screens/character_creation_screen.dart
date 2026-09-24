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
  int _startingAge = 18;

  static const int _currentYear = 2026;

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
      birthYear: _currentYear - _startingAge,
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
              'Choose the starting details for your life.',
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
              'Starting Age',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$_startingAge years old',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),
            Slider(
              min: 0,
              max: 80,
              divisions: 80,
              value: _startingAge.toDouble(),
              label: '$_startingAge',
              onChanged: (value) {
                setState(() {
                  _startingAge = value.round();
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Birth year: ${_currentYear - _startingAge}',
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: _createCharacter,
              icon: const Icon(Icons.play_arrow),
              label: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Text('CREATE CHARACTER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
