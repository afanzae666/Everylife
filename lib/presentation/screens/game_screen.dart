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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saveResult.isSuccess
              ? 'Year advanced and game saved.'
              : 'Year advanced, but autosave failed.',
        ),
      ),
    );
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
    final lifeStageLabel = _formatLifeStage(lifeStage);

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
          padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Character',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Life Stage: $lifeStageLabel',
                    ),
                    Text(
                      'Health: ${player.stats.health}',
                    ),
                    Text(
                      'Happiness: ${player.stats.happiness}',
                    ),
                    Text(
                      'Intelligence: '
                      '${player.stats.intelligence}',
                    ),
                    Text(
                      'Money: ${player.money}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  : const Icon(Icons.arrow_forward),
              label: Text(
                _isProcessingTurn
                    ? 'SAVING...'
                    : 'AGE UP',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Life Events',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 8),
            if (state.events.isEmpty)
              const Text(
                'No events yet.',
              )
            else
              ...state.events.reversed.map(
                (event) => Card(
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.year} — '
                      '${event.description}',
                    ),
                  ),
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
