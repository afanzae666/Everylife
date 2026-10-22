
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
              household.cashSavings.minorUnits == 0
                  ? 'The household has no recorded cash savings.'
                  : 'The household has recorded cash savings.',
            ),
            reason: 'Seed $seed misrepresented household savings.',
          );

          if (household.assets.isEmpty) {
            expect(
              description,
              contains('No additional family assets are recorded.'),
              reason: 'Seed $seed omitted the absence of family assets.',
            );
          } else {
            for (final asset in household.assets) {
              expect(
                description,
                contains(asset.name),
                reason:
                    'Seed $seed omitted family asset ${asset.id}.',
              );
            }
          }

          expect(
            description,
            contains(
              household.totalDebt.minorUnits > 0
                  ? 'The household has recorded outstanding debt.'
                  : 'No outstanding household debt is recorded.',
            ),
            reason: 'Seed $seed misrepresented household debt.',
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
  final income = household.annualIncome.minorUnits;
  final costs = household.annualLivingCosts.minorUnits;

  if (income == 0) {
    return 'The household currently has no recorded annual income.';
  }

  if (income < costs) {
    return 'The household income is lower than its estimated '
        'annual living costs, creating financial pressure.';
  }

  if (income == costs) {
    return 'The household income matches its estimated '
        'annual living costs, leaving little room '
        'for unexpected expenses.';
  }

  return 'The household income covers its estimated '
      'annual living costs, although other '
      'obligations may affect its financial flexibility.';
}
