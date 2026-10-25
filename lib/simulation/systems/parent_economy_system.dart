import 'package:everylife/core/money/money.dart';

import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/parent_npc.dart';

import '../../domain/family/family_household.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Advances each living parent’s personal finances and distributes an estate
/// once when that parent reaches the terminal age. Legacy aggregate household
/// financial fields are intentionally not used for ongoing simulation.
class ParentEconomySystem implements SimulationSystem {
  const ParentEconomySystem();

  @override
  String get id => 'parent_economy';

  @override
  int get priority => SystemPriority.parentEconomy.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final household = state.familyHousehold;
    if (household == null) {
      return state;
    }

    final currentYear = state.clock.currentYear;
    var player = state.player;
    var parentsChanged = false;
    final updatedParents = <ParentNpc>[];
    final updatedAssets = List<FamilyAsset>.of(household.assets);
    var nextState = state;

    for (final parent in household.parents) {
      if (!parent.isAlive) {
        updatedParents.add(parent);
        continue;
      }

      final age = currentYear - parent.birthYear;
      // Keep death deterministic and save-safe: a parent reaches the terminal
      // age once, and the estate is distributed only on that transition.
      if (age >= 100) {
        final ownedAssets = updatedAssets
            .where((asset) => asset.ownerNpcId == parent.id)
            .toList(growable: false);
        final estateValue = parent.cashBalance.minorUnits +
            ownedAssets.fold<int>(0, (sum, asset) => sum + asset.value.minorUnits);
        final heirs = parent.siblingCount + 1;
        final playerShare = estateValue ~/ heirs;
        player = player.copyWith(
          money: Money.fromMinorUnits(player.money.minorUnits + playerShare),
        );
        updatedAssets.removeWhere((asset) => asset.ownerNpcId == parent.id);
        updatedParents.add(parent.copyWith(
          isAlive: false,
          deathYear: currentYear,
          cashBalance: Money.zero(),
          assets: const <FamilyAsset>[],
        ));
        nextState = nextState.addEvent(SimulationEvent(
          id: 'parent-inheritance-${parent.id}-$currentYear',
          type: SimulationEventType.randomEvent,
          year: currentYear,
          title: '${parent.fullName} passed away',
          description: "After the estate was divided among $heirs eligible heirs, you received your share of ${parent.fullName}'s estate.",
        ));
        parentsChanged = true;
        continue;
      }

      final income = parent.annualIncome.minorUnits;
      final expenses = parent.annualExpenses.minorUnits;
      final flow = income - expenses;
      final balance = (parent.cashBalance.minorUnits + flow)
          .clamp(0, 0x7fffffffffffffff)
          .toInt();
      updatedParents.add(parent.copyWith(cashBalance: Money.fromMinorUnits(balance)));
      parentsChanged = true;
    }

    if (!parentsChanged) return state;

    final hasProperty = updatedAssets.any(
      (asset) => asset.type == FamilyAssetType.property,
    );
    final housingStatus = !hasProperty &&
            (household.housingStatus == HousingStatus.familyOwned ||
                household.housingStatus == HousingStatus.ownedWithMortgage)
        ? HousingStatus.providedByOthers
        : household.housingStatus;
    final updatedHousehold = FamilyHousehold(
      id: household.id,
      parents: updatedParents,
      siblings: household.siblings,
      // Legacy aggregate fields are retained only for old-save compatibility;
      // the economy system no longer changes or consults them.
      cashSavings: household.cashSavings,
      assets: updatedAssets,
      housingStatus: housingStatus,
      annualLivingCosts: household.annualLivingCosts,
      totalDebt: household.totalDebt,
    );
    return nextState.copyWith(
      player: player,
      familyHousehold: updatedHousehold,
    );
  }
}

