import 'package:flutter/material.dart';

import '../data/repositories/save_repository.dart';
import '../domain/character/character.dart';
import '../presentation/screens/game_screen.dart';
import '../simulation/engine/simulation_engine.dart';
import '../simulation/systems/character_system.dart';
import '../simulation/systems/event_system.dart';

class LifeSimulationApp extends StatelessWidget {
  const LifeSimulationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = _createEngine();

    return MaterialApp(
      title: 'Life Simulation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: GameScreen(
        engine: engine,
      ),
    );
  }

  SimulationEngine _createEngine() {
    final character = Character.create(
      id: 'player-1',
      name: 'Newborn',
      birthYear: 2026,
    );

    final engine = SimulationEngine.create(
      player: character,
      seed: 20260924,
      saveRepository: InMemorySaveRepository(),
    );

    engine.registerSystem(
      CharacterSystem(),
    );

    engine.registerSystem(
      EventSystem(
        random: engine.random,
      ),
    );

    return engine;
  }
}
