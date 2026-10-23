import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/commands/simulation_command.dart';
import 'package:everylife/simulation/systems/household_economy_system.dart';

void main() {
  const system = HouseholdEconomySystem();

  ParentNpc parent({
    int income = 10000,
    EmploymentStatus status = EmploymentStatus.employed,
  }) {
    return ParentNpc(
      id: 'parent-1',
      firstName: 'Test',
      lastName: 'Parent',
      gender: Gender.male,
      birthYear: 1980,
      role: FamilyRole.father,
      employmentStatus: status,
      occupation: status == EmploymentStatus.employed ? 'Worker' : null,
      annualIncome: Money.fromMinorUnits(income),
      incomeStability: income > 0 ? IncomeStability.stable : IncomeStability.none,
    );
  }

  WorldState state({
    required int income,
    required int costs,
    int savings = 0,
    int debt = 0,
    bool includeHousehold = true,
  }) {
    return WorldState(
      clock: const SimulationClock(currentYear: 2026),
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2026,
      ),
      events: const <SimulationEvent>[],
      familyHousehold: includeHousehold
          ? FamilyHousehold(
              id: 'household-1',
              parents: [
                parent(
                  income: income,
                  status: income > 0
                      ? EmploymentStatus.employed
                      : EmploymentStatus.unemployed,
                ),
              ],
              cashSavings: Money.fromMinorUnits(savings),
              assets: const <FamilyAsset>[],
              housingStatus: HousingStatus.rented,
              annualLivingCosts: Money.fromMinorUnits(costs),
              totalDebt: Money.fromMinorUnits(debt),
            )
          : null,
    );
  }

  WorldState process(WorldState initial) => system.process(
        state: initial.copyWith(clock: initial.clock.advanceYear()),
        command: const AgeUpCommand(),
      );

  group('HouseholdEconomySystem', () {
    test('uses surplus to pay debt before increasing savings', () {
      final result = process(state(
        income: 10000,
        costs: 6000,
        savings: 500,
        debt: 2500,
      ));

      expect(result.familyHousehold!.totalDebt.minorUnits, 0);
      expect(result.familyHousehold!.cashSavings.minorUnits, 2000);
    });

    test('adds surplus to savings after all debt is paid', () {
      final result = process(state(
        income: 10000,
        costs: 6000,
        savings: 500,
        debt: 1000,
      ));

      expect(result.familyHousehold!.totalDebt.minorUnits, 0);
      expect(result.familyHousehold!.cashSavings.minorUnits, 3500);
    });

    test('uses savings first and borrows only for remaining deficit', () {
      final result = process(state(
        income: 3000,
        costs: 5000,
        savings: 1200,
        debt: 400,
      ));

      expect(result.familyHousehold!.cashSavings.minorUnits, 0);
      expect(result.familyHousehold!.totalDebt.minorUnits, 1200);
    });

    test('deficit does not create debt when savings cover it', () {
      final result = process(state(
        income: 3000,
        costs: 5000,
        savings: 3000,
      ));

      expect(result.familyHousehold!.cashSavings.minorUnits, 1000);
      expect(result.familyHousehold!.totalDebt.minorUnits, 0);
    });

    test('zero income consumes savings and records an uncovered deficit', () {
      final result = process(state(
        income: 0,
        costs: 2500,
        savings: 500,
        debt: 100,
      ));

      expect(result.familyHousehold!.cashSavings.minorUnits, 0);
      expect(result.familyHousehold!.totalDebt.minorUnits, 2100);
    });

    test('zero living costs lets all income go to debt and savings', () {
      final result = process(state(
        income: 2500,
        costs: 0,
        savings: 300,
        debt: 1000,
      ));

      expect(result.familyHousehold!.totalDebt.minorUnits, 0);
      expect(result.familyHousehold!.cashSavings.minorUnits, 1800);
    });

    test('leaves household unchanged when income matches costs', () {
      final initial = state(
        income: 5000,
        costs: 5000,
        savings: 100,
        debt: 200,
      );

      expect(process(initial).familyHousehold, same(initial.familyHousehold));
    });

    test('does not change state for commands other than age-up', () {
      final initial = state(income: 10000, costs: 1000);

      final result = system.process(
        state: initial,
        command: _NonAgeUpCommand(),
      );

      expect(result, same(initial));
    });

    test('does not fail when no household exists', () {
      final initial = state(
        income: 0,
        costs: 0,
        includeHousehold: false,
      );

      expect(process(initial).familyHousehold, isNull);
    });

    test('preserves parents, assets, housing and annual costs', () {
      final initial = state(
        income: 10000,
        costs: 6000,
        savings: 0,
      );
      final household = initial.familyHousehold!;
      final result = process(initial).familyHousehold!;

      expect(result.parents, equals(household.parents));
      expect(result.assets, equals(household.assets));
      expect(result.housingStatus, household.housingStatus);
      expect(result.annualLivingCosts, household.annualLivingCosts);
    });
  });
}

class _NonAgeUpCommand implements SimulationCommand<void> {
  @override
  String get id => 'not_age_up';

  @override
  Result<void> validate(WorldState state) => const Success(null);
}
