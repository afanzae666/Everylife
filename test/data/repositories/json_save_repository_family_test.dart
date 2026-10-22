
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/data/repositories/json_save_repository.dart';
import 'package:everylife/data/storage/json_save_storage.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';

void main() {
  group('JsonSaveRepository family persistence', () {
    late InMemoryJsonSaveStorage storage;
    late JsonSaveRepository repository;

    setUp(() {
      storage = InMemoryJsonSaveStorage();
      repository = JsonSaveRepository(storage: storage);
    });

    test(
      'preserves household, parents, employment, finances, and assets',
      () async {
        final household = FamilyHousehold(
          id: 'household-save-load-01',
          parents: const [
            ParentNpc(
              id: 'father-save-load',
              firstName: 'Alex',
              lastName: 'Morgan',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.employed,
              occupation: 'Teacher',
              monthlyIncome: Money.fromMinorUnits(450000),
              incomeStability: IncomeStability.stable,
            ),
            ParentNpc(
              id: 'mother-save-load',
              firstName: 'Jamie',
              lastName: 'Morgan',
              gender: Gender.female,
              birthYear: 1982,
              role: FamilyRole.mother,
              employmentStatus: EmploymentStatus.unemployed,
              occupation: null,
              monthlyIncome: Money.zero(),
              incomeStability: IncomeStability.none,
            ),
          ],
          cashSavings: const Money.fromMinorUnits(275000),
          assets: const [
            FamilyAsset(
              id: 'family-home',
              name: 'Family Home',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(12000000),
            ),
            FamilyAsset(
              id: 'family-car',
              name: 'Family Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(1800000),
              ownerNpcId: 'father-save-load',
            ),
            FamilyAsset(
              id: 'family-business',
              name: 'Family Grocery Store',
              type: FamilyAssetType.business,
              value: Money.fromMinorUnits(3500000),
              ownerNpcId: 'mother-save-load',
            ),
          ],
          housingStatus: HousingStatus.ownedWithMortgage,
          monthlyLivingCosts: const Money.fromMinorUnits(390000),
          totalDebt: const Money.fromMinorUnits(5200000),
        );

        final original = WorldState(
          clock: const SimulationClock(currentYear: 2026),
          player: Character(
            id: 'player-save-load',
            name: 'Taylor Morgan',
            gender: Gender.female,
            birthYear: 2026,
            stats: const CharacterStats(),
            money: const Money.zero(),
          ),
          events: const [],
          startingBackground: const StartingBackground(
            tier: StartingBackgroundTier.workingClass,
          ),
          familyHousehold: household,
        );

        await repository.save(
          original,
          randomState: 123456,
          nextTickId: 42,
        );

        final loaded = await repository.load();

        expect(loaded, isNotNull);
        expect(loaded!.randomState, 123456);
        expect(loaded.nextTickId, 42);

        final restoredState = loaded.state;
        final restored = restoredState.familyHousehold;

        expect(restored, isNotNull);
        expect(restored!.id, household.id);
        expect(restored.housingStatus, household.housingStatus);
        expect(restored.cashSavings, household.cashSavings);
        expect(
          restored.monthlyLivingCosts,
          household.monthlyLivingCosts,
        );
        expect(restored.totalDebt, household.totalDebt);

        expect(restored.monthlyIncome, household.monthlyIncome);
        expect(restored.totalAssetValue, household.totalAssetValue);
        expect(restored.netWorth, household.netWorth);
        expect(restored.monthlySurplus, household.monthlySurplus);

        expect(restored.parents, hasLength(2));

        final father = restored.parents[0];
        expect(father.id, 'father-save-load');
        expect(father.firstName, 'Alex');
        expect(father.lastName, 'Morgan');
        expect(father.fullName, 'Alex Morgan');
        expect(father.gender, Gender.male);
        expect(father.birthYear, 1980);
        expect(father.role, FamilyRole.father);
        expect(father.employmentStatus, EmploymentStatus.employed);
        expect(father.occupation, 'Teacher');
        expect(
          father.monthlyIncome,
          const Money.fromMinorUnits(450000),
        );
        expect(father.incomeStability, IncomeStability.stable);
        expect(father.hasIncome, isTrue);

        final mother = restored.parents[1];
        expect(mother.id, 'mother-save-load');
        expect(mother.firstName, 'Jamie');
        expect(mother.lastName, 'Morgan');
        expect(mother.fullName, 'Jamie Morgan');
        expect(mother.gender, Gender.female);
        expect(mother.birthYear, 1982);
        expect(mother.role, FamilyRole.mother);
        expect(mother.employmentStatus, EmploymentStatus.unemployed);
        expect(mother.occupation, isNull);
        expect(mother.monthlyIncome, const Money.zero());
        expect(mother.incomeStability, IncomeStability.none);
        expect(mother.hasIncome, isFalse);

        expect(restored.assets, hasLength(3));

        final home = restored.assets[0];
        expect(home.id, 'family-home');
        expect(home.name, 'Family Home');
        expect(home.type, FamilyAssetType.property);
        expect(home.value, const Money.fromMinorUnits(12000000));
        expect(home.ownerNpcId, isNull);

        final car = restored.assets[1];
        expect(car.id, 'family-car');
        expect(car.name, 'Family Car');
        expect(car.type, FamilyAssetType.vehicle);
        expect(car.value, const Money.fromMinorUnits(1800000));
        expect(car.ownerNpcId, 'father-save-load');

        final business = restored.assets[2];
        expect(business.id, 'family-business');
        expect(business.name, 'Family Grocery Store');
        expect(business.type, FamilyAssetType.business);
        expect(business.value, const Money.fromMinorUnits(3500000));
        expect(business.ownerNpcId, 'mother-save-load');

        expect(
          restoredState.startingBackground?.tier,
          StartingBackgroundTier.workingClass,
        );
        expect(restoredState.player.id, original.player.id);
        expect(
          restoredState.clock.currentYear,
          original.clock.currentYear,
        );
      },
    );

    test(
      'keeps family data isolated between save slots',
      () async {
        final firstState = WorldState(
          clock: const SimulationClock(currentYear: 2040),
          player: Character(
            id: 'player-with-family',
            name: 'Family Player',
            birthYear: 2020,
            stats: const CharacterStats(),
            money: const Money.zero(),
          ),
          events: const [],
          familyHousehold: FamilyHousehold(
            id: 'first-household',
            parents: const [],
            cashSavings: const Money.fromMinorUnits(100000),
            assets: const [],
            housingStatus: HousingStatus.rented,
            monthlyLivingCosts: const Money.fromMinorUnits(20000),
            totalDebt: const Money.zero(),
          ),
        );

        final secondState = WorldState(
          clock: const SimulationClock(currentYear: 2060),
          player: Character(
            id: 'player-without-family',
            name: 'Legacy Player',
            birthYear: 2030,
            stats: const CharacterStats(),
            money: const Money.zero(),
          ),
          events: const [],
        );

        await repository.save(
          firstState,
          randomState: 10,
          nextTickId: 5,
        );

        await repository.save(
          secondState,
          randomState: 20,
          nextTickId: 10,
          slot: SaveSlot.manual1,
        );

        final autosave = await repository.load();
        final manualSave = await repository.load(
          slot: SaveSlot.manual1,
        );

        expect(autosave, isNotNull);
        expect(
          autosave!.state.familyHousehold?.id,
          'first-household',
        );
        expect(autosave.state.player.id, 'player-with-family');

        expect(manualSave, isNotNull);
        expect(manualSave!.state.familyHousehold, isNull);
        expect(manualSave.state.player.id, 'player-without-family');
      },
    );
  });
}
