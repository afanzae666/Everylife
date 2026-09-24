import 'package:flutter/material.dart';

import 'app_dependencies.dart';
import '../domain/character/character.dart';
import '../presentation/screens/character_creation_screen.dart';
import '../presentation/screens/game_screen.dart';
import '../simulation/engine/simulation_engine.dart';
import '../simulation/systems/event_system.dart';

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
  SimulationEngine? _engine;

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
      saveRepository: widget.dependencies.createSaveRepository(),
    );

    engine.registerSystem(
      EventSystem(
        random: engine.random,
      ),
    );

    return engine;
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
      home: _engine == null
          ? CharacterCreationScreen(
              onCharacterCreated: _createCharacter,
            )
          : GameScreen(
              engine: _engine!,
            ),
    );
  }
}
