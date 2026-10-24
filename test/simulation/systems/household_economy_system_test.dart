import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';
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
import 'package:everylife/simulation/systems/parent_economy_system.dart';

void main() {
  const system = ParentEconomySystem();

  ParentNpc makeParent({
    int birthYear = 1980,
    int income = 10000,
    int expenses = 6000,
    int balance = 2000,
    int siblingCount = 0,
    bool alive = true,
    int? deathYear,
  }) => ParentNpc(
    id: 'parent-1', firstName: 'Test', lastName: 'Parent',
    gender: Gender.male, birthYear: birthYear, role: FamilyRole.father,
    employmentStatus: EmploymentStatus.employed, occupation: 'Worker',
    annualIncome: Money.fromMinorUnits(income),
    incomeStability: IncomeStability.stable,
    annualExpenses: Money.fromMinorUnits(expenses),
    cashBalance: Money.fromMinorUnits(balance),
    siblingCount: siblingCount, isAlive: alive, deathYear: deathYear,
  );

  WorldState makeState(ParentNpc parent, {int year = 2026}) => WorldState(
    clock: SimulationClock(currentYear: year),
    player: Character.create(id: 'player-1', name: 'Test Player', birthYear: 2000),
    events: const <SimulationEvent>[],
    familyHousehold: FamilyHousehold(
      id: 'legacy-family-container', parents: [parent],
      cashSavings: const Money.zero(), assets: const <FamilyAsset>[],
      housingStatus: HousingStatus.rented,
      annualLivingCosts: const Money.zero(), totalDebt: const Money.zero(),
    ),
  );

  WorldState process(WorldState initial) => system.process(
    state: initial.copyWith(clock: initial.clock.advanceYear()),
    command: const AgeUpCommand(),
  );

  test('accumulates income minus expenses in the parent personal balance', () {
    final result = process(makeState(makeParent()));
    expect(result.familyHousehold!.parents.single.cashBalance.minorUnits, 6000);
    expect(result.familyHousehold!.cashSavings.minorUnits, 0);
    expect(result.player.money.minorUnits, 0);
  });

  test('does not advance finances for a deceased parent', () {
    final parent = makeParent(alive: false, deathYear: 2025, balance: 2000);
    final initial = makeState(parent);
    expect(process(initial), same(initial));
  });

  test('distributes an estate once when a parent reaches terminal age', () {
    final parent = makeParent(
      birthYear: 1926, balance: 2000, income: 10000, expenses: 6000,
      siblingCount: 1,
    );
    final result = process(makeState(parent));
    expect(result.familyHousehold!.parents.single.isAlive, isFalse);
    expect(result.familyHousehold!.parents.single.deathYear, 2027);
    expect(result.player.money.minorUnits, 1000);
    expect(result.events, hasLength(1));

    final nextYear = process(result);
    expect(nextYear.player.money.minorUnits, 1000);
    expect(nextYear.events, hasLength(1));
  });
}
