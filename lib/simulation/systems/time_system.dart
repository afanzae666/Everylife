import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';

class TimeSystem implements SimulationSystem {
  @override
  String get id => 'time';

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final nextClock = state.clock.advanceYear();

    return state.copyWith(
      clock: nextClock,
    );
  }
}
