import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/appearance.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/data/models/world_state_snapshot.dart';

void main() {
  group('Family household snapshot integration', () {
    test('preserves household data through JSON round trip', () {
      final household = FamilyHousehold(
        id: 'family-household-2026',
        parents: [
          ParentNpc(
            id: 'parent-father-2000',
            firstName: 'Budi',
            lastName: 'Santoso',
            gender: Gender.male,
            birthYear: 2000,
            role: FamilyRole.father,
            employmentStatus: EmploymentStatus.employed,
            occupation: 'Teacher',
            annualIncome: Money.fromMinorUnits(250000),
            incomeStability: IncomeStability.stable,
            relationshipPercent: 72,
            appearance: const CharacterAppearance(
              skinTone: 'medium',
              hair: 'male_hair_03',
              hairColor: 'dark_brown',
              eyeColor: 'brown',
              eyebrows: 'straight',
            ),
          ),
          ParentNpc(
            id: 'parent-mother-2002',
            firstName: 'Sari',
            lastName: 'Santoso',
            gender: Gender.female,
            birthYear: 2002,
            role: FamilyRole.mother,
            employmentStatus: EmploymentStatus.selfEmployed,
            occupation: 'Food seller',
            annualIncome: Money.fromMinorUnits(150000),
            incomeStability: IncomeStability.variable,
            relationshipPercent: 28,
          ),
        ],
        cashSavings: Money.fromMinorUnits(500000),
        assets: [
          FamilyAsset(
            id: 'family-household-2026-property',
            name: 'Family home',
            type: FamilyAssetType.property,
            value: Money.fromMinorUnits(10000000),
          ),
          FamilyAsset(
            id: 'family-household-2026-asset-0',
            name: 'Vehicle',
            type: FamilyAssetType.vehicle,
            value: Money.fromMinorUnits(2000000),
            ownerNpcId: 'parent-father-2000',
          ),
        ],
        housingStatus: HousingStatus.ownedWithMortgage,
        annualLivingCosts: Money.fromMinorUnits(200000),
        totalDebt: Money.fromMinorUnits(1000000),
      );

      final original = WorldState(
        clock: const SimulationClock(
          currentYear: 2026,
        ),
        player: Character(
          id: 'player-1',
          name: 'Andi Santoso',
          firstName: 'Andi',
          lastName: 'Santoso',
          gender: Gender.male,
          birthYear: 2026,
          stats: const CharacterStats(),
          money: const Money.zero(),
        ),
        events: const [
          SimulationEvent(
            id: 'life-created',
            type: SimulationEventType.lifeCreated,
            year: 2026,
            title: 'A new life begins',
            description: 'Andi Santoso was born in 2026.',
          ),
        ],
        startingBackground: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        familyHousehold: household,
      );

      final json = WorldStateSnapshot
          .fromWorldState(original)
          .toJson();

      final restored = WorldStateSnapshot
          .fromJson(json)
          .toWorldState();

      final restoredHousehold = restored.familyHousehold!;

      expect(restoredHousehold.id, household.id);
      expect(
        restoredHousehold.housingStatus,
        HousingStatus.ownedWithMortgage,
      );
      expect(
        restoredHousehold.cashSavings.minorUnits,
        500000,
      );
      expect(
        restoredHousehold.annualLivingCosts.minorUnits,
        200000,
      );
      expect(
        restoredHousehold.totalDebt.minorUnits,
        1000000,
      );

      expect(restoredHousehold.parents, hasLength(2));

      final father = restoredHousehold.parents.first;
      expect(father.firstName, 'Budi');
      expect(father.lastName, 'Santoso');
      expect(
        father.employmentStatus,
        EmploymentStatus.employed,
      );
      expect(father.occupation, 'Teacher');
      expect(father.relationshipPercent, 72);
      expect(restoredHousehold.parents[1].relationshipPercent, 28);
      expect(father.annualIncome.minorUnits, 250000);
      expect(
        father.incomeStability,
        IncomeStability.stable,
      );
      expect(father.appearance.skinTone, 'medium');
      expect(father.appearance.hair, 'male_hair_03');
      expect(father.appearance.hairColor, 'dark_brown');
      expect(father.appearance.eyeColor, 'brown');
      expect(father.appearance.eyebrows, 'straight');

      expect(restoredHousehold.assets, hasLength(2));
      expect(
        restoredHousehold.assets.last.ownerNpcId,
        'parent-father-2000',
      );
      expect(
        restoredHousehold.assets.last.value.minorUnits,
        2000000,
      );
    });

    test('keeps household null when loading a legacy save', () {
      final legacyJson = WorldStateSnapshot
          .fromWorldState(
            WorldState(
              clock: const SimulationClock(
                currentYear: 2026,
              ),
              player: Character(
                id: 'legacy-player',
                name: 'Legacy Character',
                birthYear: 2026,
                stats: const CharacterStats(),
                money: const Money.zero(),
              ),
              events: const [],
            ),
          )
          .toJson()
        ..remove('familyHousehold');

      final restored = WorldStateSnapshot
          .fromJson(legacyJson)
          .toWorldState();

      expect(restored.familyHousehold, isNull);
    });
  });
}
