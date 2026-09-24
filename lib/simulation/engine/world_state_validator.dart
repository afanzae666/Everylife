import '../../core/result/result.dart';
import '../../domain/world/world_state.dart';

class WorldStateValidator {
  const WorldStateValidator();

  Result<void> validate(WorldState state) {
    final player = state.player;

    if (player.id.trim().isEmpty) {
      return const Failure(
        'World state is invalid: player id cannot be empty.',
      );
    }

    if (player.name.trim().isEmpty) {
      return const Failure(
        'World state is invalid: player name cannot be empty.',
      );
    }

    if (player.birthYear <= 0) {
      return const Failure(
        'World state is invalid: player birth year must be positive.',
      );
    }

    final stats = player.stats;

    if (!_isValidStat(stats.health)) {
      return const Failure(
        'World state is invalid: player health must be between 0 and 100.',
      );
    }

    if (!_isValidStat(stats.happiness)) {
      return const Failure(
        'World state is invalid: player happiness must be between 0 and 100.',
      );
    }

    if (!_isValidStat(stats.intelligence)) {
      return const Failure(
        'World state is invalid: player intelligence must be between 0 and 100.',
      );
    }

    if (!_isValidStat(stats.discipline)) {
      return const Failure(
        'World state is invalid: player discipline must be between 0 and 100.',
      );
    }

    if (!_isValidStat(stats.empathy)) {
      return const Failure(
        'World state is invalid: player empathy must be between 0 and 100.',
      );
    }

    if (!_isValidStat(stats.ambition)) {
      return const Failure(
        'World state is invalid: player ambition must be between 0 and 100.',
      );
    }

    if (state.clock.currentYear < player.birthYear) {
      return const Failure(
        'World state is invalid: current year is before player birth year.',
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

  bool _isValidStat(int value) {
    return value >= 0 && value <= 100;
  }
}
