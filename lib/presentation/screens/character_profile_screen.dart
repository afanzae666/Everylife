import 'package:flutter/material.dart';

import '../../domain/character/character.dart';
import '../../domain/character/life_stage.dart';

class CharacterProfileScreen extends StatelessWidget {
  const CharacterProfileScreen({
    required this.character,
    required this.currentYear,
    super.key,
  });

  final Character character;
  final int currentYear;

  @override
  Widget build(BuildContext context) {
    final age = character.ageAt(currentYear);
    final lifeStage =
        character.lifeStageAt(currentYear);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            32,
          ),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                child: Icon(
                  character.gender == Gender.male
                      ? Icons.person
                      : Icons.person_outline,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                character.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Name',
                      value: character.name,
                    ),
                    _InfoRow(
                      label: 'Gender',
                      value: character.gender.label,
                    ),
                    _InfoRow(
                      label: 'Birth Year',
                      value:
                          '${character.birthYear}',
                    ),
                    _InfoRow(
                      label: 'Age',
                      value: '$age',
                    ),
                    _InfoRow(
                      label: 'Year',
                      value:
                          '$currentYear',
                    ),
                    _InfoRow(
                      label: 'Life Stage',
                      value:
                          _formatLifeStage(
                        lifeStage,
                      ),
                    ),
                    _InfoRow(
                      label: 'Money',
                      value:
                          character.money.toString(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Core Stats',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: 'Health',
                      value:
                          '${character.stats.health} / 100',
                    ),
                    _InfoRow(
                      label: 'Intelligence',
                      value:
                          '${character.stats.intelligence} / 100',
                    ),
                    _InfoRow(
                      label: 'Fitness',
                      value:
                          '${character.stats.fitness} / 100',
                    ),
                    _InfoRow(
                      label: 'Happiness',
                      value:
                          '${character.stats.happiness} / 100',
                    ),
                    _InfoRow(
                      label: 'Willpower',
                      value:
                          '${character.stats.willpower} / 100',
                    ),
                    _InfoRow(
                      label: 'Charisma',
                      value:
                          '${character.stats.charisma} / 100',
                    ),
                    _InfoRow(
                      label: 'Creativity',
                      value:
                          '${character.stats.creativity} / 100',
                    ),
                    _InfoRow(
                      label: 'Luck',
                      value:
                          '${character.stats.luck} / 100',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Character Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This profile will become the '
                      'home for additional character '
                      'information as the life simulation '
                      'expands.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLifeStage(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'Infant';

      case LifeStage.toddler:
        return 'Toddler';

      case LifeStage.child:
        return 'Child';

      case LifeStage.teen:
        return 'Teen';

      case LifeStage.youngAdult:
        return 'Young Adult';

      case LifeStage.adult:
        return 'Adult';

      case LifeStage.senior:
        return 'Senior';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
