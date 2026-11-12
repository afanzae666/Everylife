
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  group('Generated household story consistency', () {
    test(
      'keeps family and economy narratives separate across generated lives',
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

          final startingEvents = state.events
              .where(
                (event) =>
                    event.type == SimulationEventType.startingLifeEvent,
              )
              .toList();

          final familyEvent = startingEvents.singleWhere(
            (event) => event.title == 'Starting Family',
          );
          final economyEvents = startingEvents
              .where((event) => event.title == 'Starting Economy')
              .toList();
          final birthdayEvents = startingEvents
              .where((event) => event.title == 'My Birthday')
              .toList();

          final familyDescription = familyEvent.description;
          final economyDescription = economyEvents
              .map((event) => event.description)
              .join('\n');

          expect(economyEvents, isNotEmpty);

          // One family event, one birthday event, and a variable number
          // of economy events depending on the generated family.
          expect(birthdayEvents, hasLength(1));
          expect(
            startingEvents,
            hasLength(economyEvents.length + 2),
          );

          expect(familyDescription, isNotEmpty);
          expect(economyDescription, isNotEmpty);

          expect(
            familyDescription,
            isNot(contains('works as a')),
          );
          expect(
            familyDescription,
            isNot(contains('self-employed')),
          );
          expect(
            familyDescription,
            isNot(contains('currently unemployed')),
          );
          expect(
            economyDescription,
            isNot(contains('biological parents')),
          );
          expect(
            economyDescription,
            isNot(contains('My mother raised me on her own')),
          );
          expect(
            economyDescription,
            isNot(contains('orphanage')),
          );

          expect(household.totalDebt.minorUnits, 0);
          expect(household.cashSavings.minorUnits, 0);
          expect(household.annualLivingCosts.minorUnits, 0);
          // A parent with an income has savings; one without has none.
          expect(
            household.parents.every(
              (parent) =>
                  parent.annualIncome.minorUnits > 0 ||
                  parent.cashBalance.minorUnits == 0,
            ),
            isTrue,
          );
          expect(
            household.parents.every(
              (parent) => parent.annualExpenses.minorUnits == 0,
            ),
            isTrue,
          );
          expect(
            household.assets.every(
              (asset) => asset.type == FamilyAssetType.property,
            ),
            isTrue,
          );
          expect(household.assets.length, lessThanOrEqualTo(1));

          expect(familyDescription, contains('both of my parents'));

          for (final parent in household.parents) {
            if (parent.isAlive) {
              expect(
                economyDescription,
                contains(parent.fullName),
              );
            }
          }

          for (final parent in household.parents.where(
            (parent) => parent.isAlive,
          )) {
            final occupation = parent.occupation;

            if (parent.employmentStatus.name == 'employed' &&
                occupation != null) {
              expect(
                economyDescription,
                contains(occupation.toLowerCase()),
              );
            } else if (parent.employmentStatus.name == 'selfEmployed' &&
                occupation != null) {
              expect(
                economyDescription,
                contains(occupation.toLowerCase()),
              );
            } else if (parent.employmentStatus.name == 'unemployed') {
              expect(
                economyDescription,
                contains('is currently unemployed'),
              );
            }
          }

          for (final description in [
            familyDescription,
            economyDescription,
          ]) {
            expect(description, isNot(contains('savings')));
            expect(description, isNot(contains('living costs')));
            expect(description, isNot(contains('Investment portfolio')));
            expect(description, isNot(contains('outstanding debt')));
            expect(description, isNot(contains('Alex')));
          }
        }
      },
    );
  });
}
