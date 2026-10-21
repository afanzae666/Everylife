
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

    final invalidStats = <String, int>{
      'health': stats.health,
      'intelligence': stats.intelligence,
      'fitness': stats.fitness,
      'happiness': stats.happiness,
      'willpower': stats.willpower,
      'charisma': stats.charisma,
      'creativity': stats.creativity,
      'luck': stats.luck,
    };

    for (final entry in invalidStats.entries) {
      if (!_isValidStat(entry.value)) {
        return Failure(
          'World state is invalid: player '
          '${entry.key} must be between 0 and 100.',
        );
      }
    }

    if (state.clock.currentYear < player.birthYear) {
      return const Failure(
        'World state is invalid: current year is before player birth year.',
      );
    }

    final household = state.familyHousehold;
    if (household != null) {
      final householdResult = _validateHousehold(household);
      if (householdResult != null) {
        return Failure(householdResult);
      }
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

  String? _validateHousehold(dynamic household) {
    if (household.id.trim().isEmpty) {
      return 'World state is invalid: household id cannot be empty.';
    }

    if (household.cashSavings.minorUnits < 0) {
      return 'World state is invalid: household cash savings cannot be negative.';
    }

    if (household.monthlyLivingCosts.minorUnits < 0) {
      return 'World state is invalid: household living costs cannot be negative.';
    }

    if (household.totalDebt.minorUnits < 0) {
      return 'World state is invalid: household debt cannot be negative.';
    }

    final parentIds = <String>{};

    for (final parent in household.parents) {
      if (parent.id.trim().isEmpty) {
        return 'World state is invalid: parent id cannot be empty.';
      }

      if (!parentIds.add(parent.id)) {
        return 'World state is invalid: duplicate parent id "${parent.id}".';
      }

      if (parent.firstName.trim().isEmpty ||
          parent.lastName.trim().isEmpty) {
        return 'World state is invalid: parent name cannot be empty.';
      }

      if (parent.birthYear <= 0) {
        return 'World state is invalid: parent birth year must be positive.';
      }

      if (parent.monthlyIncome.minorUnits < 0) {
        return 'World state is invalid: parent income cannot be negative.';
      }
    }

    final assetIds = <String>{};

    for (final asset in household.assets) {
      if (asset.id.trim().isEmpty) {
        return 'World state is invalid: family asset id cannot be empty.';
      }

      if (!assetIds.add(asset.id)) {
        return 'World state is invalid: duplicate family asset id "${asset.id}".';
      }

      if (asset.name.trim().isEmpty) {
        return 'World state is invalid: family asset name cannot be empty.';
      }

      if (asset.value.minorUnits < 0) {
        return 'World state is invalid: family asset value cannot be negative.';
      }

      final ownerNpcId = asset.ownerNpcId;
      if (ownerNpcId != null && !parentIds.contains(ownerNpcId)) {
        return 'World state is invalid: family asset owner "$ownerNpcId" does not exist.';
      }
    }

    return null;
  }

  bool _isValidStat(int value) {
    return value >= 0 && value <= 100;
  }
}
