
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

    if (player.money.minorUnits < 0) {
      return const Failure(
        'World state is invalid: player money cannot be negative.',
      );
    }

    if (player.debt.minorUnits < 0) {
      return const Failure(
        'World state is invalid: player debt cannot be negative.',
      );
    }

    final playerAssetIds = <String>{};

    for (final asset in player.assets) {
      final assetId = asset.id.trim();

      if (assetId.isEmpty) {
        return const Failure(
          'World state is invalid: player asset id cannot be empty.',
        );
      }

      if (!playerAssetIds.add(assetId)) {
        return Failure(
          'World state is invalid: duplicate player asset id "${asset.id}".',
        );
      }

      if (asset.name.trim().isEmpty) {
        return Failure(
          'World state is invalid: player asset "${asset.id}" '
          'name cannot be empty.',
        );
      }

      if (asset.value.minorUnits < 0) {
        return Failure(
          'World state is invalid: player asset "${asset.id}" '
          'value cannot be negative.',
        );
      }
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
      final eventId = event.id.trim();

      if (eventId.isEmpty) {
        return const Failure(
          'World state is invalid: event id cannot be empty.',
        );
      }

      if (!eventIds.add(eventId)) {
        return Failure(
          'World state is invalid: duplicate event id "${event.id}".',
        );
      }

      if (event.year <= 0) {
        return Failure(
          'World state is invalid: event "${event.id}" year must be positive.',
        );
      }

      if (event.title.trim().isEmpty) {
        return Failure(
          'World state is invalid: event "${event.id}" title cannot be empty.',
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

    final hasStepParent = household.parents.any(
      (parent) =>
          parent.role == FamilyRole.stepFather ||
          parent.role == FamilyRole.stepMother,
    );
    final maximumParents = hasStepParent ? 3 : 2;
    if (household.parents.length > maximumParents) {
      return hasStepParent
          ? 'World state is invalid: household cannot have more than three parents.'
          : 'World state is invalid: a household with no step-parent cannot have more than two parents.';
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

      if (!parentIds.add(parent.id.trim())) {
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

      if (parent.cashBalance.minorUnits < 0 ||
          parent.annualExpenses.minorUnits < 0) {
        return 'World state is invalid: parent personal finances cannot be negative.';
      }

      if (parent.siblingCount < 0) {
        return 'World state is invalid: parent sibling count cannot be negative.';
      }

      if (parent.isAlive && parent.deathYear != null) {
        return 'World state is invalid: living parent cannot have a death year.';
      }

      if (!parent.isAlive && parent.deathYear == null) {
        return 'World state is invalid: deceased parent must have a death year.';
      }

      final employmentError = _validateParentEmployment(parent);

      if (employmentError != null) {
        return employmentError;
      }
    }

    final siblingIds = <String>{};
    for (final sibling in household.siblings) {
      if (sibling.id.trim().isEmpty) {
        return 'World state is invalid: sibling id cannot be empty.';
      }
      if (!siblingIds.add(sibling.id.trim())) {
        return 'World state is invalid: duplicate sibling id "${sibling.id}".';
      }
      if (sibling.firstName.trim().isEmpty ||
          sibling.lastName.trim().isEmpty) {
        return 'World state is invalid: sibling name cannot be empty.';
      }
      if (sibling.birthYear <= 0 ||
          (sibling.birthYear - playerBirthYear).abs() > 100) {
        return 'World state is invalid: sibling "${sibling.id}" has an invalid birth year.';
      }
    }

    final assetIds = <String>{};
    var propertyAssetCount = 0;

    for (final asset in household.assets) {
      if (asset.id.trim().isEmpty) {
        return 'World state is invalid: family asset id cannot be empty.';
      }

      if (!assetIds.add(asset.id.trim())) {
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

      if (ownerNpcId != null && !parentIds.contains(ownerNpcId.trim())) {
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
