import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  group('Generated household story consistency', () {
    test(
      'starting life events reflect generated household facts across seeds',
      () {
        for (var seed = 0; seed < 300; seed++) {
          final engine = SimulationEngine.create(
            player: Character.create(
              id: 'story-validation-player-$seed',
              firstName: 'Alex',
              lastName: 'Morgan',
              birthYear: 2026,
            ),
            seed: seed,
            saveRepository: InMemorySaveRepository(),
          );

          final state = engine.state;
          final household = state.familyHousehold!;

          final event = state.events.firstWhere(
            (event) =>
                event.type == SimulationEventType.startingLifeEvent,
          );

          final description = event.description;

          expect(
            event.title,
            isNotEmpty,
            reason: 'Seed $seed generated an empty event title.',
          );

          expect(
            description,
            contains(state.startingBackground!.label),
            reason: 'Seed $seed omitted the starting background.',
          );

          for (final parent in household.parents) {
            expect(
              description,
              contains(parent.fullName),
              reason: 'Seed $seed omitted parent ${parent.id}.',
            );

            expect(
              description,
              contains(_employmentDescription(parent)),
              reason: 'Seed $seed misrepresented parent ${parent.id}.',
            );
          }

          expect(
            description,
            contains(_housingDescription(household.housingStatus)),
            reason: 'Seed $seed misrepresented household housing.',
          );

          expect(
            description,
            contains(_incomeDescription(household)),
            reason: 'Seed $seed misrepresented household income.',
          );

          expect(
            description,
            contains(
              household.parents.fold<int>(0, (sum, parent) =>
                          sum + parent.cashBalance.minorUnits) == 0
                  ? 'The parents have no recorded personal cash savings.'
                  : 'The parents have accumulated personal cash savings over time.',
            ),
            reason: 'Seed $seed misrepresented household savings.',
          );

          expect(
            description,
            isNot(contains('Investment portfolio')),
            reason: 'Seed $seed exposed family asset details.',
          );

          expect(
            description,
            isNot(contains('No additional family assets are recorded.')),
            reason: 'Seed $seed included an unnecessary asset notice.',
          );

          expect(
            description,
            isNot(contains('outstanding debt')),
            reason: 'Seed $seed included an unnecessary debt notice.',
          );

          expect(
            household.totalDebt.minorUnits,
            0,
            reason: 'Seed $seed generated household debt.',
          );
        }
      },
    );
  });
}

String _employmentDescription(ParentNpc parent) {
  final occupation = parent.occupation;
  final hasOccupation = occupation != null && occupation.trim().isNotEmpty;

  return switch (parent.employmentStatus) {
    EmploymentStatus.employed => hasOccupation
        ? 'works as a $occupation'
        : 'works as an employee',
    EmploymentStatus.selfEmployed => hasOccupation
        ? 'is self-employed as a $occupation'
        : 'works independently',
    EmploymentStatus.unemployed => 'is currently unemployed',
    EmploymentStatus.retired => 'is retired',
    EmploymentStatus.homemaker => 'takes care of the household',
    EmploymentStatus.unableToWork => 'is unable to work',
  };
}

String _housingDescription(HousingStatus status) {
  return switch (status) {
    HousingStatus.rented => 'The family lives in rented housing.',
    HousingStatus.familyOwned =>
      'The family lives in a home owned by the family.',
    HousingStatus.ownedWithMortgage =>
      'The family lives in a home financed with a mortgage.',
    HousingStatus.temporary =>
      'The family lives in temporary accommodation.',
    HousingStatus.providedByOthers =>
      'The family accommodation is provided by others.',
    HousingStatus.homeless =>
      'The family currently has no stable housing.',
  };
}

String _incomeDescription(FamilyHousehold household) {
  final income = household.parents.fold<int>(
    0, (sum, parent) => sum + parent.annualIncome.minorUnits,
  );
  final expenses = household.parents.fold<int>(
    0, (sum, parent) => sum + parent.annualExpenses.minorUnits,
  );

  if (income == 0) {
    return 'The parents currently have no recorded annual income.';
  }
  if (income < expenses) {
    return 'The parents’ combined income is lower than their recorded '
        'personal living contributions, creating financial pressure.';
  }
  if (income == expenses) {
    return 'The parents’ recorded income is fully committed to expenses, '
        'leaving little room for unexpected costs.';
  }
  return 'The parents earn income, but their individual expenses '
      'and obligations affect how much they can save.';
}
