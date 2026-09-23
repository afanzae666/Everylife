import '../../core/result/result.dart';
import '../../domain/world/world_state.dart';
import 'simulation_command.dart';

class AgeUpCommand implements SimulationCommand<void> {
  const AgeUpCommand();

  @override
  String get id => 'age_up';

  @override
  Result<void> validate(WorldState state) {
    return const Success(null);
  }
}
