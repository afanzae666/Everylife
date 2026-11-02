import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';

void main() {
  ParentNpc parent(String id) => ParentNpc(
        id: id,
        firstName: 'Alex',
        lastName: 'Rivera',
        gender: Gender.male,
        birthYear: 1990,
        role: FamilyRole.father,
        employmentStatus: EmploymentStatus.unemployed,
        annualIncome: const Money.zero(),
        incomeStability: IncomeStability.none,
      );

  FamilyHousehold household() => FamilyHousehold(
        id: 'family-household-2026',
        parents: [parent('parent-father-2026')],
        cashSavings: const Money.fromMinorUnits(500),
        assets: const [],
        housingStatus: HousingStatus.rented,
        annualLivingCosts: const Money.fromMinorUnits(100),
        totalDebt: const Money.fromMinorUnits(50),
        isAffairConception: true,
        raisedByFather: true,
      );

  test('copyWith without arguments keeps every field', () {
    final original = household();
    final copy = original.copyWith();

    expect(copy.id, original.id);
    expect(copy.parents, original.parents);
    expect(copy.siblings, original.siblings);
    expect(copy.cashSavings, original.cashSavings);
    expect(copy.assets, original.assets);
    expect(copy.housingStatus, original.housingStatus);
    expect(copy.annualLivingCosts, original.annualLivingCosts);
    expect(copy.totalDebt, original.totalDebt);
    expect(copy.isAffairConception, isTrue);
    expect(copy.raisedByFather, isTrue);
  });

  test('copyWith replaces only the requested fields', () {
    final copy = household().copyWith(
      housingStatus: HousingStatus.providedByOthers,
      parents: [parent('parent-father-other')],
    );

    expect(copy.housingStatus, HousingStatus.providedByOthers);
    expect(copy.parents.single.id, 'parent-father-other');
    expect(copy.isAffairConception, isTrue);
    expect(copy.raisedByFather, isTrue);
    expect(copy.cashSavings, const Money.fromMinorUnits(500));
  });
}
