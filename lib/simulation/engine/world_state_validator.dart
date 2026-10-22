
import '../../core/result/result.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
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
      final householdError = _validateHousehold(
        household,
        playerBirthYear: player.birthYear,
      );

      if (householdError != null) {
        return Failure(householdError);
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

  String? _validateHousehold(
    FamilyHousehold household, {
    required int playerBirthYear,
  }) {
    if (household.id.trim().isEmpty) {
      return 'World state is invalid: household id cannot be empty.';
    }

    if (household.parents.isEmpty) {
      return 'World state is invalid: household must have at least one parent.';
    }

    if (household.parents.length > 2) {
      return 'World state is invalid: household cannot have more than two parents.';
    }

    if (household.cashSavings.minorUnits < 0) {
      return 'World state is invalid: household cash savings cannot be negative.';
    }

    if (household.annualLivingCosts.minorUnits < 0) {
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

      if (parent.birthYear >= playerBirthYear) {
        return 'World state is invalid: parent "${parent.id}" must be born before the player.';
      }

      if (parent.annualIncome.minorUnits < 0) {
        return 'World state is invalid: parent income cannot be negative.';
      }

      final employmentError = _validateParentEmployment(parent);

      if (employmentError != null) {
        return employmentError;
      }
    }

    final assetIds = <String>{};
    var propertyAssetCount = 0;

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

      if (asset.type == FamilyAssetType.property) {
        propertyAssetCount++;
      }

      final ownerNpcId = asset.ownerNpcId;

      if (ownerNpcId != null && !parentIds.contains(ownerNpcId)) {
        return 'World state is invalid: family asset owner "$ownerNpcId" does not exist.';
      }
    }

    final householdOwnsHome =
        household.housingStatus == HousingStatus.familyOwned ||
        household.housingStatus == HousingStatus.ownedWithMortgage;

    if (householdOwnsHome && propertyAssetCount == 0) {
      return 'World state is invalid: household ownership status requires a property asset.';
    }

    if (householdOwnsHome && propertyAssetCount > 1) {
      return 'World state is invalid: household ownership status cannot have multiple property assets.';
    }

    if (!householdOwnsHome && propertyAssetCount > 0) {
      return 'World state is invalid: household has a property asset but does not own its home.';
    }

    return null;
  }

  String? _validateParentEmployment(ParentNpc parent) {
    final hasIncome = parent.annualIncome.minorUnits > 0;
    final occupation = parent.occupation?.trim() ?? '';
    final hasOccupation = occupation.isNotEmpty;

    if (hasIncome && parent.incomeStability == IncomeStability.none) {
      return 'World state is invalid: parent "${parent.id}" has income '
          'without income stability.';
    }

    if (!hasIncome && parent.incomeStability != IncomeStability.none) {
      return 'World state is invalid: parent "${parent.id}" has income '
          'stability without income.';
    }

    switch (parent.employmentStatus) {
      case EmploymentStatus.employed:
      case EmploymentStatus.selfEmployed:
        if (!hasIncome) {
          return 'World state is invalid: working parent "${parent.id}" '
              'must have positive annual income.';
        }

        if (!hasOccupation) {
          return 'World state is invalid: working parent "${parent.id}" '
              'must have an occupation.';
        }

        break;

      case EmploymentStatus.unemployed:
      case EmploymentStatus.homemaker:
      case EmploymentStatus.unableToWork:
        if (hasIncome) {
          return 'World state is invalid: parent "${parent.id}" '
              'cannot have work income for employment status '
              '"${parent.employmentStatus.name}".';
        }

        if (hasOccupation) {
          return 'World state is invalid: parent "${parent.id}" '
              'cannot have an occupation for employment status '
              '"${parent.employmentStatus.name}".';
        }

        break;

      case EmploymentStatus.retired:
        // Retired parents may receive pension income.
        // The general income-stability checks above still apply.
        if (hasOccupation) {
          return 'World state is invalid: retired parent "${parent.id}" '
              'cannot have a current occupation.';
        }

        break;
    }

    return null;
  }

  bool _isValidStat(int value) {
    return value >= 0 && value <= 100;
  }
}
