import 'package:flutter/material.dart';

import '../core/random/seeded_random.dart';
import '../data/repositories/save_repository.dart';
import '../domain/character/character.dart';
import '../presentation/screens/character_creation_screen.dart';
import '../presentation/screens/game_screen.dart';
import '../simulation/engine/simulation_engine.dart';
import '../simulation/systems/event_system.dart';
import 'app_dependencies.dart';

class LifeSimulationApp extends StatefulWidget {
  const LifeSimulationApp({
    super.key,
    this.dependencies = const AppDependencies(),
  });

  final AppDependencies dependencies;

  @override
  State<LifeSimulationApp> createState() =>
      _LifeSimulationAppState();
}

class _LifeSimulationAppState extends State<LifeSimulationApp> {
  late final SaveRepository _saveRepository;

  SimulationEngine? _engine;

  bool _isInitializing = true;

  String? _startupError;

  @override
  void initState() {
    super.initState();

    _saveRepository =
        widget.dependencies.createSaveRepository();

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final saveData = await _saveRepository.load();

      if (!mounted) {
        return;
      }

      if (saveData == null) {
        setState(() {
          _isInitializing = false;
        });

        return;
      }

      final engine = SimulationEngine(
        initialState: saveData.state,
        random: SeededRandom.fromState(
          saveData.randomState,
        ),
        saveRepository: _saveRepository,
        nextTickId: saveData.nextTickId,
      );

      engine.registerSystem(
        EventSystem(
          random: engine.random,
        ),
      );

      setState(() {
        _engine = engine;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _startupError = error.toString();
        _isInitializing = false;
      });
    }
  }

  void _createCharacter(Character character) {
    final engine = _createEngine(character);

    setState(() {
      _engine = engine;
    });
  }

  SimulationEngine _createEngine(
    Character character,
  ) {
    final engine = SimulationEngine.create(
      player: character,
      seed: 20260924,
      saveRepository: _saveRepository,
    );

    engine.registerSystem(
      EventSystem(
        random: engine.random,
      ),
    );

    return engine;
  }

  void _retryStartup() {
    setState(() {
      _isInitializing = true;
      _startupError = null;
    });

    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Simulation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading your life...',
              ),
            ],
          ),
        ),
      );
    }

    if (_startupError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Startup Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load saved game.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _startupError!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _retryStartup,
                  icon: const Icon(Icons.refresh),
                  label: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_engine == null) {
      return CharacterCreationScreen(
        onCharacterCreated: _createCharacter,
      );
    }

    return GameScreen(
      engine: _engine!,
    );
  }
}
