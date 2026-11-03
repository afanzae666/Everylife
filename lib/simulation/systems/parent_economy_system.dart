import 'package:everylife/core/money/money.dart';

import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/parent_npc.dart';

import '../../domain/family/family_household.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'funeral_planner.dart';
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
    final diedNow = <ParentNpc>[];
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
        final isGuardian = parent.role == FamilyRole.guardian;
        final isStepParent = parent.role == FamilyRole.stepFather ||
            parent.role == FamilyRole.stepMother;
        final heirs = parent.siblingCount + 1;
        if (!isGuardian && !isStepParent) {
          final playerShare = estateValue ~/ heirs;
          player = player.copyWith(
            money: Money.fromMinorUnits(player.money.minorUnits + playerShare),
          );
        }
        updatedAssets.removeWhere((asset) => asset.ownerNpcId == parent.id);
        diedNow.add(parent);
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
          description: isGuardian || isStepParent
              ? '${parent.fullName} passed away after many years of caring for you.'
              : "After the estate was divided among $heirs eligible heirs, you received your share of ${parent.fullName}'s estate.",
        ));
        parentsChanged = true;
        continue;
      }

      final income = parent.annualIncome.minorUnits;
      // Older data has no recorded expenses; assume a working parent spends
      // 70% of what they earn so savings grow realistically.
      final expenses = parent.annualExpenses.minorUnits > 0
          ? parent.annualExpenses.minorUnits
          : income * 70 ~/ 100;
      final flow = income - expenses;
      final balance = (parent.cashBalance.minorUnits + flow)
          .clamp(0, 0x7fffffffffffffff)
          .toInt();

      var updated = parent.copyWith(cashBalance: Money.fromMinorUnits(balance));

      // Working parents retire at 65 on a pension of 45% of their income.
      final isWorking = parent.employmentStatus == EmploymentStatus.employed ||
          parent.employmentStatus == EmploymentStatus.selfEmployed;

      if (isWorking && age >= 65) {
        final pension = income * 45 ~/ 100;

        updated = updated.copyWith(
          employmentStatus: EmploymentStatus.retired,
          clearOccupation: true,
          annualIncome: Money.fromMinorUnits(pension),
          incomeStability:
              pension > 0 ? IncomeStability.stable : IncomeStability.none,
        );
        nextState = nextState.addEvent(SimulationEvent(
          id: 'parent-retired-${parent.id}-$currentYear',
          type: SimulationEventType.family,
          year: currentYear,
          title: '${parent.fullName} retired',
          description: 'My ${_roleName(parent.role)}, ${parent.fullName}, '
              'retired after many years of work.',
        ));
      }

      updatedParents.add(updated);
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
    // copyWith keeps every other field, including the story flags
    // isAffairConception and raisedByFather. The legacy aggregate money
    // fields are intentionally left untouched.
    final updatedHousehold = household.copyWith(
      parents: updatedParents,
      assets: updatedAssets,
      housingStatus: housingStatus,
    );
    return FuneralPlanner.schedule(
      nextState.copyWith(
        player: player,
        familyHousehold: updatedHousehold,
      ),
      diedNow,
    );
  }

  static String _roleName(FamilyRole role) => switch (role) {
        FamilyRole.father => 'father',
        FamilyRole.mother => 'mother',
        FamilyRole.guardian => 'guardian',
        FamilyRole.stepFather => 'stepfather',
        FamilyRole.stepMother => 'stepmother',
      };
}
