import '../../core/result/result.dart';
import '../../domain/world/world_state.dart';

class WorldStateValidator {
  const WorldStateValidator();

  Result<void> validate(WorldState state) {
    if (state.clock.currentYear < state.player.birthYear) {
      return const Failure(
        'World state is invalid: current year is before player birth year.',
      );
    }

    if (state.player.ageAt(state.clock.currentYear) < 0) {
      return const Failure(
        'World state is invalid: player age is negative.',
      );
    }

    final eventIds = <String>{};

    for (final event in state.events) {
      if (!eventIds.add(event.id)) {
        return Failure(
          'World state is invalid: duplicate event id "${event.id}".',
        );
      }

      if (event.year > state.clock.currentYear) {
        return Failure(
          'World state is invalid: event "${event.id}" is from the future.',
        );
      }
    }

    return const Success(null);
  }
}
