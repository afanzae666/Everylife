import 'package:everylife/core/money/money.dart';

import '../../domain/family/family_household.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Applies one year of household income and living costs during age-up.
///
/// A positive cash flow pays outstanding debt first, then adds any remainder
/// to savings. A deficit consumes savings first and adds any remainder to
/// debt. Non-cash assets are not liquidated automatically.
class HouseholdEconomySystem implements SimulationSystem {
  const HouseholdEconomySystem();

  @override
  String get id => 'household_economy';

  @override
  int get priority => SystemPriority.householdEconomy.value;

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

    final annualCashFlow = household.annualSurplus.minorUnits;
    if (annualCashFlow == 0) {
      return state;
    }

    final savings = household.cashSavings.minorUnits;
    final debt = household.totalDebt.minorUnits;

    late final Money updatedSavings;
    late final Money updatedDebt;

    if (annualCashFlow > 0) {
      final debtPayment = annualCashFlow < debt ? annualCashFlow : debt;
      final remainingSurplus = annualCashFlow - debtPayment;

      updatedDebt = Money.fromMinorUnits(debt - debtPayment);
      updatedSavings = Money.fromMinorUnits(savings + remainingSurplus);
    } else {
      final deficit = -annualCashFlow;
      final savingsUsed = deficit < savings ? deficit : savings;
      final remainingDeficit = deficit - savingsUsed;

      updatedSavings = Money.fromMinorUnits(savings - savingsUsed);
      updatedDebt = Money.fromMinorUnits(debt + remainingDeficit);
    }

    final updatedHousehold = FamilyHousehold(
      id: household.id,
      parents: household.parents,
      cashSavings: updatedSavings,
      assets: household.assets,
      housingStatus: household.housingStatus,
      annualLivingCosts: household.annualLivingCosts,
      totalDebt: updatedDebt,
    );

    return state.copyWith(
      familyHousehold: updatedHousehold,
    );
  }
}
