import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  group('Generated household story consistency', () {
    test('starting narratives reflect family scenario and concise work facts', () {
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
          (event) => event.type == SimulationEventType.startingLifeEvent,
        );
        final description = event.description;

        expect(event.title, isNotEmpty);
        expect(description, isNotEmpty);
        expect(household.totalDebt.minorUnits, 0);
        expect(household.cashSavings.minorUnits, 0);
        expect(household.annualLivingCosts.minorUnits, 0);
        expect(household.parents.every((parent) => parent.cashBalance.minorUnits == 0), isTrue);
        expect(household.parents.every((parent) => parent.annualExpenses.minorUnits == 0), isTrue);
        expect(household.assets.every((asset) => asset.type == FamilyAssetType.property), isTrue);
        expect(household.assets.length, lessThanOrEqualTo(1));

        final guardian = household.parents.any((parent) => parent.role == FamilyRole.guardian);
        final mother = _findRole(household.parents, FamilyRole.mother);
        final father = _findRole(household.parents, FamilyRole.father);
        if (guardian) {
          expect(description, contains('orphanage'));
          expect(household.parents, hasLength(1));
        } else if (mother != null && !mother.isAlive && father != null) {
          expect(description, contains('mother died while giving birth'));
        } else if (mother != null && father == null) {
          expect(description, contains('raises you on her own'));
        } else {
          expect(description, contains('both of your biological parents'));
        }

        for (final parent in household.parents.where((parent) => parent.isAlive && parent.role != FamilyRole.guardian)) {
          final occupation = parent.occupation;
          if (parent.employmentStatus.name == 'employed' && occupation != null) {
            expect(description, contains('works as a $occupation'));
          } else if (parent.employmentStatus.name == 'selfEmployed' && occupation != null) {
            expect(description, contains('self-employed as a $occupation'));
          } else if (parent.employmentStatus.name == 'unemployed') {
            expect(description, contains('is currently unemployed'));
          }
        }

        expect(description, isNot(contains('savings')));
        expect(description, isNot(contains('living costs')));
        expect(description, isNot(contains('Investment portfolio')));
        expect(description, isNot(contains('outstanding debt')));
      }
    });
  });
}

ParentNpc? _findRole(List<ParentNpc> parents, FamilyRole role) {
  for (final parent in parents) {
    if (parent.role == role) return parent;
  }
  return null;
}
