
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/data/models/world_state_snapshot.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';

void main() {
  group('WorldStateSnapshot family serialization', () {
    test('preserves all household, parent, and asset fields', () {
      final originalHousehold = FamilyHousehold(
        id: 'household-round-trip-2026',
        parents: const [
          ParentNpc(
            id: 'parent-father-1980',
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
            id: 'parent-mother-1982',
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
        cashSavings: Money.fromMinorUnits(275000),
        assets: const [
          FamilyAsset(
            id: 'asset-home',
            name: 'Family Home',
            type: FamilyAssetType.property,
            value: Money.fromMinorUnits(12000000),
          ),
          FamilyAsset(
            id: 'asset-car',
            name: 'Family Car',
            type: FamilyAssetType.vehicle,
            value: Money.fromMinorUnits(1800000),
            ownerNpcId: 'parent-father-1980',
          ),
          FamilyAsset(
            id: 'asset-business',
            name: 'Family Grocery Store',
            type: FamilyAssetType.business,
            value: Money.fromMinorUnits(3500000),
            ownerNpcId: 'parent-mother-1982',
          ),
        ],
        housingStatus: HousingStatus.ownedWithMortgage,
        monthlyLivingCosts: Money.fromMinorUnits(390000),
        totalDebt: Money.fromMinorUnits(5200000),
      );

      final originalState = WorldState(
        clock: const SimulationClock(currentYear: 2026),
        player: Character(
          id: 'player-round-trip',
          name: 'Taylor Morgan',
          birthYear: 2026,
          stats: const CharacterStats(),
          money: Money.zero(),
        ),
        events: const [],
        familyHousehold: originalHousehold,
      );

      final originalSnapshot =
          WorldStateSnapshot.fromWorldState(originalState);

      final encodedJson = jsonEncode(originalSnapshot.toJson());
      final decodedJson =
          jsonDecode(encodedJson) as Map<String, dynamic>;

      final restoredState =
          WorldStateSnapshot.fromJson(decodedJson).toWorldState();

      final restored = restoredState.familyHousehold;

      expect(restored, isNotNull);
      expect(restored!.id, originalHousehold.id);
      expect(restored.housingStatus, originalHousehold.housingStatus);
      expect(restored.cashSavings, originalHousehold.cashSavings);
      expect(
        restored.monthlyLivingCosts,
        originalHousehold.monthlyLivingCosts,
      );
      expect(restored.totalDebt, originalHousehold.totalDebt);
      expect(restored.monthlyIncome, originalHousehold.monthlyIncome);
      expect(restored.totalAssetValue, originalHousehold.totalAssetValue);
      expect(restored.netWorth, originalHousehold.netWorth);
      expect(restored.monthlySurplus, originalHousehold.monthlySurplus);

      expect(restored.parents, hasLength(originalHousehold.parents.length));

      for (var index = 0;
          index < originalHousehold.parents.length;
          index++) {
        final expected = originalHousehold.parents[index];
        final actual = restored.parents[index];

        expect(actual.id, expected.id);
        expect(actual.firstName, expected.firstName);
        expect(actual.lastName, expected.lastName);
        expect(actual.fullName, expected.fullName);
        expect(actual.gender, expected.gender);
        expect(actual.birthYear, expected.birthYear);
        expect(actual.role, expected.role);
        expect(actual.employmentStatus, expected.employmentStatus);
        expect(actual.occupation, expected.occupation);
        expect(actual.monthlyIncome, expected.monthlyIncome);
        expect(actual.incomeStability, expected.incomeStability);
        expect(actual.hasIncome, expected.hasIncome);
      }

      expect(restored.assets, hasLength(originalHousehold.assets.length));

      for (var index = 0;
          index < originalHousehold.assets.length;
          index++) {
        final expected = originalHousehold.assets[index];
        final actual = restored.assets[index];

        expect(actual.id, expected.id);
        expect(actual.name, expected.name);
        expect(actual.type, expected.type);
        expect(actual.value, expected.value);
        expect(actual.ownerNpcId, expected.ownerNpcId);
      }
    });

    test('preserves a legacy world state without a household', () {
      final originalState = WorldState(
        clock: const SimulationClock(currentYear: 2050),
        player: Character(
          id: 'legacy-player',
          name: 'Legacy Player',
          birthYear: 2030,
          stats: const CharacterStats(),
          money: Money.zero(),
        ),
        events: const [],
      );

      final snapshot = WorldStateSnapshot.fromWorldState(originalState);
      final json = jsonDecode(jsonEncode(snapshot.toJson()))
          as Map<String, dynamic>;

      final restored = WorldStateSnapshot.fromJson(json).toWorldState();

      expect(restored.familyHousehold, isNull);
      expect(restored.player.id, originalState.player.id);
      expect(restored.clock.currentYear, originalState.clock.currentYear);
    });
  });
}
