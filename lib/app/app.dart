import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _isCreatingCharacter = false;

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

  Future<void> _createCharacter(
    Character character,
  ) async {
    if (_isCreatingCharacter) {
      return;
    }

    setState(() {
      _isCreatingCharacter = true;
    });

    final engine = _createEngine(character);

    final saveResult = await engine.save();

    if (!mounted) {
      return;
    }

    if (!saveResult.isSuccess) {
      setState(() {
        _isCreatingCharacter = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save your new life. '
            'Please try again.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _engine = engine;
      _isCreatingCharacter = false;
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
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
      ),
      useMaterial3: true,
    );

    final baseTextTheme = GoogleFonts.nunitoTextTheme(
      baseTheme.textTheme,
    );

    final everyLifeTextTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 27,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 17,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 16,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 14,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );

    final everyLifeTheme = baseTheme.copyWith(
      textTheme: everyLifeTextTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle:
            everyLifeTextTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return MaterialApp(
      title: 'EveryLife',
      debugShowCheckedModeBanner: false,
      theme: everyLifeTheme,
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
      return Stack(
        children: [
          CharacterCreationScreen(
            onCharacterCreated: _createCharacter,
          ),
          if (_isCreatingCharacter)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Saving your new life...',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return GameScreen(
      engine: _engine!,
    );
  }
}
