import '../../core/result/result.dart';
import '../../domain/world/world_state.dart';

abstract interface class SimulationCommand<T> {
  const SimulationCommand();

  String get id;

  Result<void> validate(WorldState state);
}
