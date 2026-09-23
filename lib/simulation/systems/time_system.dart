import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';

class TimeSystem implements SimulationSystem {
  const TimeSystem();

  @override
  String get id => 'time';

  @override
  int get priority => 0;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    return state.copyWith(
      clock: state.clock.advanceYear(),
    );
  }
}
