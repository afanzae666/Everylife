import '../../core/result/result.dart';
import '../../domain/world/world_state.dart';
import 'simulation_command.dart';

class AgeUpCommand implements SimulationCommand<void> {
  const AgeUpCommand();

  @override
  String get id => 'age_up';

  @override
  Result<void> validate(WorldState state) {
    if (state.lifeProgress.ending != null) {
      return const Failure('This life has already ended.');
    }

    if (state.lifeProgress.pending != null) {
      return const Failure('Make your decision before aging up.');
    }

    return const Success(null);
  }
}
