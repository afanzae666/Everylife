import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/character/life_stage.dart';
import '../../simulation/engine/simulation_engine.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.engine,
    super.key,
  });

  final SimulationEngine engine;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  SimulationEngine get engine => widget.engine;

  bool _isProcessingTurn = false;

  Future<void> _ageUp() async {
    if (_isProcessingTurn) {
      return;
    }

    setState(() {
      _isProcessingTurn = true;
    });

    final result = engine.ageUp();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _isProcessingTurn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result is Failure
                ? result.message
                : 'Simulation failed.',
          ),
        ),
      );

      return;
    }

    setState(() {});

    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessingTurn = false;
    });

    if (!saveResult.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Year advanced, but autosave failed.',
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_isProcessingTurn) {
      return;
    }

    final result = await engine.save();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Game saved.'
              : 'Save failed.',
        ),
      ),
    );
  }

  Future<void> _load() async {
    if (_isProcessingTurn) {
      return;
    }

    final result = await engine.load();

    if (!mounted) {
      return;
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Game loaded.'
              : 'Load failed.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final player = state.player;

    final age = player.ageAt(
      state.clock.currentYear,
    );

    final lifeStage = LifeStageAge.fromAge(age);
    final lifeStageLabel = _formatLifeStage(
      lifeStage,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Simulation'),
        actions: [
          IconButton(
            onPressed: _isProcessingTurn ? null : _save,
            tooltip: 'Save',
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: _isProcessingTurn ? null : _load,
            tooltip: 'Load',
            icon: const Icon(Icons.folder_open),
          ),
        ],
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
            Text(
              player.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Age $age',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              lifeStageLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Year ${state.clock.currentYear}',
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life Panel',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Character',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Life Stage: $lifeStageLabel',
                    ),
                    Text(
                      'Money: ${player.money}',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Core Stats',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _StatRow(
                      label: 'Health',
                      value: player.stats.health,
                    ),
                    _StatRow(
                      label: 'Intelligence',
                      value: player.stats.intelligence,
                    ),
                    _StatRow(
                      label: 'Fitness',
                      value: player.stats.fitness,
                    ),
                    _StatRow(
                      label: 'Happiness',
                      value: player.stats.happiness,
                    ),
                    _StatRow(
                      label: 'Willpower',
                      value: player.stats.willpower,
                    ),
                    _StatRow(
                      label: 'Charisma',
                      value: player.stats.charisma,
                    ),
                    _StatRow(
                      label: 'Creativity',
                      value: player.stats.creativity,
                    ),
                    _StatRow(
                      label: 'Luck',
                      value: player.stats.luck,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Life Events',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (state.events.isEmpty)
                      const Text(
                        'No events yet.',
                      )
                    else
                      Column(
                        children: state.events.reversed
                            .map(
                              (event) => Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(
                                        top: 5,
                                      ),
                                      child: Icon(
                                        Icons.circle,
                                        size: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: Theme.of(
                                              context,
                                            )
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${event.year} — '
                                            '${event.description}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed:
                  _isProcessingTurn ? null : _ageUp,
              icon: _isProcessingTurn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward,
                    ),
              label: Text(
                _isProcessingTurn
                    ? 'SAVING...'
                    : 'AGE UP',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLifeStage(LifeStage stage) {
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Text(
            '$value / 100',
            style: Theme.of(context)
                .textTheme
                .titleSmall,
          ),
        ],
      ),
    );
  }
}
