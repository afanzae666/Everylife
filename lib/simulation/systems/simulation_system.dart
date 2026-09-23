import '../../domain/world/world_state.dart';
import '../commands/simulation_command.dart';

abstract interface class SimulationSystem {
  String get id;

  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  });
}
