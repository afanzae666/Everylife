import '../../core/result/result.dart';
import '../../domain/world/world_state.dart';
import '../commands/simulation_command.dart';
import '../systems/simulation_system.dart';

class SimulationScheduler {
  SimulationScheduler({
    List<SimulationSystem> systems = const [],
  }) : _systems = List<SimulationSystem>.from(systems) {
    _sortSystems();
  }

  final List<SimulationSystem> _systems;

  List<SimulationSystem> get systems =>
      List<SimulationSystem>.unmodifiable(_systems);

  void registerSystem(SimulationSystem system) {
    if (_systems.any((existing) => existing.id == system.id)) {
      throw StateError(
        'Simulation system already registered: ${system.id}',
      );
    }

    _systems.add(system);
    _sortSystems();
  }

  Result<WorldState> execute({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    final validation = command.validate(state);

    if (validation case Failure<void>(:final message)) {
      return Failure(message);
    }

    try {
      var nextState = state;

      for (final system in _systems) {
        nextState = system.process(
          state: nextState,
          command: command,
        );
      }

      return Success(nextState);
    } catch (error) {
      return Failure(
        'Simulation command "${command.id}" failed: $error',
      );
    }
  }

  void _sortSystems() {
    _systems.sort(
      (a, b) => a.priority.compareTo(b.priority),
    );
  }
}
