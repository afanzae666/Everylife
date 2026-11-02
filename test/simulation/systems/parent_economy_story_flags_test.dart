import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/systems/parent_economy_system.dart';

void main() {
  test('parent economy keeps the affair and raised-by-father flags', () {
    const parent = ParentNpc(
      id: 'parent-father-2026',
      firstName: 'Alex',
      lastName: 'Rivera',
      gender: Gender.male,
      birthYear: 1990,
      role: FamilyRole.father,
      employmentStatus: EmploymentStatus.employed,
      occupation: 'Teacher',
      annualIncome: Money.fromMinorUnits(100000),
      incomeStability: IncomeStability.stable,
    );

    final household = FamilyHousehold(
      id: 'family-household-2026',
      parents: const [parent],
      cashSavings: const Money.zero(),
      assets: const [],
      housingStatus: HousingStatus.rented,
      annualLivingCosts: const Money.zero(),
      totalDebt: const Money.zero(),
      isAffairConception: true,
      raisedByFather: true,
    );

    final state = WorldState(
      clock: const SimulationClock(currentYear: 2027),
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2026,
      ),
      events: const [],
      familyHousehold: household,
    );

    final next = const ParentEconomySystem().process(
      state: state,
      command: const AgeUpCommand(),
    );

    final updated = next.familyHousehold!;

    expect(updated.isAffairConception, isTrue);
    expect(updated.raisedByFather, isTrue);
    // Income 100000 minus the default expenses (70% of income).
    expect(
      updated.parents.single.cashBalance,
      const Money.fromMinorUnits(30000),
    );
  });
}
