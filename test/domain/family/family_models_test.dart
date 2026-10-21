import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';

void main() {
  group('ParentNpc', () {
    test('builds full name from first and last name', () {
      const parent = ParentNpc(
        id: 'parent-1',
        firstName: 'Budi',
        lastName: 'Santoso',
        gender: Gender.male,
        birthYear: 1975,
        role: FamilyRole.father,
        employmentStatus: EmploymentStatus.employed,
        occupation: 'Teacher',
        monthlyIncome: Money.fromMinorUnits(5000000),
        incomeStability: IncomeStability.stable,
      );

      expect(parent.fullName, 'Budi Santoso');
    });

    test('trims name parts and handles an empty last name', () {
      const parent = ParentNpc(
        id: 'parent-2',
        firstName: '  Siti  ',
        lastName: '  ',
        gender: Gender.female,
        birthYear: 1978,
        role: FamilyRole.mother,
        employmentStatus: EmploymentStatus.homemaker,
        monthlyIncome: Money.zero(),
        incomeStability: IncomeStability.none,
      );

      expect(parent.fullName, 'Siti');
      expect(parent.hasIncome, isFalse);
    });

    test('detects positive income', () {
      const parent = ParentNpc(
        id: 'parent-3',
        firstName: 'Dewi',
        lastName: 'Putri',
        gender: Gender.female,
        birthYear: 1980,
        role: FamilyRole.mother,
        employmentStatus: EmploymentStatus.selfEmployed,
        occupation: 'Shop owner',
        monthlyIncome: Money.fromMinorUnits(2500000),
        incomeStability: IncomeStability.variable,
      );

      expect(parent.hasIncome, isTrue);
    });
  });

  group('FamilyAsset', () {
    test('stores asset details and optional owner', () {
      const asset = FamilyAsset(
        id: 'asset-1',
        name: 'Family car',
        type: FamilyAssetType.vehicle,
        value: Money.fromMinorUnits(15000000),
        ownerNpcId: 'parent-1',
      );

      expect(asset.id, 'asset-1');
      expect(asset.name, 'Family car');
      expect(asset.type, FamilyAssetType.vehicle);
      expect(
        asset.value,
        const Money.fromMinorUnits(15000000),
      );
      expect(asset.ownerNpcId, 'parent-1');
    });

    test('allows an asset to belong to the household', () {
      const asset = FamilyAsset(
        id: 'asset-2',
        name: 'Household furniture',
        type: FamilyAssetType.valuable,
        value: Money.fromMinorUnits(500000),
      );

      expect(asset.ownerNpcId, isNull);
    });
  });

  group('FamilyHousehold', () {
    const father = ParentNpc(
      id: 'parent-father',
      firstName: 'Budi',
      lastName: 'Santoso',
      gender: Gender.male,
      birthYear: 1975,
      role: FamilyRole.father,
      employmentStatus: EmploymentStatus.employed,
      occupation: 'Teacher',
      monthlyIncome: Money.fromMinorUnits(5000000),
      incomeStability: IncomeStability.stable,
    );

    const mother = ParentNpc(
      id: 'parent-mother',
      firstName: 'Siti',
      lastName: 'Santoso',
      gender: Gender.female,
      birthYear: 1978,
      role: FamilyRole.mother,
      employmentStatus: EmploymentStatus.selfEmployed,
      occupation: 'Food seller',
      monthlyIncome: Money.fromMinorUnits(2000000),
      incomeStability: IncomeStability.variable,
    );

    const car = FamilyAsset(
      id: 'asset-car',
      name: 'Family car',
      type: FamilyAssetType.vehicle,
      value: Money.fromMinorUnits(15000000),
      ownerNpcId: 'parent-father',
    );

    test('calculates combined household income', () {
      final household = FamilyHousehold(
        id: 'household-1',
        parents: const [father, mother],
        cashSavings: const Money.fromMinorUnits(3000000),
        assets: const [car],
        housingStatus: HousingStatus.ownedWithMortgage,
        monthlyLivingCosts: const Money.fromMinorUnits(4000000),
        totalDebt: const Money.fromMinorUnits(5000000),
      );

      expect(
        household.monthlyIncome,
        const Money.fromMinorUnits(7000000),
      );
    });

    test('calculates total assets including cash savings', () {
      final household = FamilyHousehold(
        id: 'household-2',
        parents: const [father, mother],
        cashSavings: const Money.fromMinorUnits(3000000),
        assets: const [car],
        housingStatus: HousingStatus.rented,
        monthlyLivingCosts: const Money.fromMinorUnits(4000000),
        totalDebt: const Money.fromMinorUnits(5000000),
      );

      expect(
        household.totalAssetValue,
        const Money.fromMinorUnits(18000000),
      );
    });

    test('calculates net worth after debt', () {
      final household = FamilyHousehold(
        id: 'household-3',
        parents: const [father, mother],
        cashSavings: const Money.fromMinorUnits(3000000),
        assets: const [car],
        housingStatus: HousingStatus.ownedWithMortgage,
        monthlyLivingCosts: const Money.fromMinorUnits(4000000),
        totalDebt: const Money.fromMinorUnits(5000000),
      );

      expect(
        household.netWorth,
        const Money.fromMinorUnits(13000000),
      );
    });

    test('calculates monthly surplus or deficit', () {
      final household = FamilyHousehold(
        id: 'household-4',
        parents: const [father, mother],
        cashSavings: const Money.fromMinorUnits(3000000),
        assets: const [car],
        housingStatus: HousingStatus.rented,
        monthlyLivingCosts: const Money.fromMinorUnits(4000000),
        totalDebt: const Money.fromMinorUnits(5000000),
      );

      expect(
        household.monthlySurplus,
        const Money.fromMinorUnits(3000000),
      );

      final strugglingHousehold = FamilyHousehold(
        id: 'household-5',
        parents: const [father],
        cashSavings: const Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.temporary,
        monthlyLivingCosts: const Money.fromMinorUnits(6000000),
        totalDebt: const Money.fromMinorUnits(1000000),
      );

      expect(
        strugglingHousehold.monthlySurplus,
        const Money.fromMinorUnits(-1000000),
      );
    });

    test('supports a household with no parents or assets', () {
      final household = FamilyHousehold(
        id: 'household-6',
        parents: const [],
        cashSavings: const Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.providedByOthers,
        monthlyLivingCosts: const Money.zero(),
        totalDebt: const Money.zero(),
      );

      expect(
        household.monthlyIncome,
        const Money.zero(),
      );
      expect(
        household.totalAssetValue,
        const Money.zero(),
      );
      expect(
        household.netWorth,
        const Money.zero(),
      );
      expect(
        household.monthlySurplus,
        const Money.zero(),
      );
    });

    test('makes parent and asset lists unmodifiable', () {
      final household = FamilyHousehold(
        id: 'household-7',
        parents: const [father],
        cashSavings: const Money.zero(),
        assets: const [car],
        housingStatus: HousingStatus.familyOwned,
        monthlyLivingCosts: const Money.fromMinorUnits(1000000),
        totalDebt: const Money.zero(),
      );

      expect(
        () => household.parents.add(mother),
        throwsUnsupportedError,
      );

      expect(
        () => household.assets.add(
          const FamilyAsset(
            id: 'asset-extra',
            name: 'Extra asset',
            type: FamilyAssetType.other,
            value: Money.zero(),
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
