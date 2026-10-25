import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/simulation/generation/starting_life_event_generator.dart';

void main() {
  const father = ParentNpc(
    id: 'father', firstName: 'Budi', lastName: 'Santoso', gender: Gender.male,
    birthYear: 1980, role: FamilyRole.father,
    employmentStatus: EmploymentStatus.employed, occupation: 'Teacher',
    annualIncome: Money.fromMinorUnits(5000000), incomeStability: IncomeStability.stable,
  );
  const mother = ParentNpc(
    id: 'mother', firstName: 'Sari', lastName: 'Santoso', gender: Gender.female,
    birthYear: 1982, role: FamilyRole.mother,
    employmentStatus: EmploymentStatus.unemployed,
    annualIncome: Money.zero(), incomeStability: IncomeStability.none,
  );

  FamilyHousehold household(List<ParentNpc> parents) => FamilyHousehold(
    id: 'test-household', parents: parents, cashSavings: Money.zero(), assets: const [],
    housingStatus: HousingStatus.rented, annualLivingCosts: Money.zero(), totalDebt: Money.zero(),
  );

  SimulationEvent generate(FamilyHousehold family, {int seed = 123}) =>
      StartingLifeEventGenerator.generate(
        random: SeededRandom(seed), year: 2026,
        background: const StartingBackground(tier: StartingBackgroundTier.middleClass),
        household: family,
      );

  test('describes intact biological family and concise employment facts', () {
    final event = generate(household(const [father, mother]));
    expect(event.type, SimulationEventType.startingLifeEvent);
    expect(event.description, contains('both of your biological parents'));
    expect(event.description, contains('Your father works as a Teacher.'));
    expect(event.description, contains('Your mother is currently unemployed.'));
    expect(event.description, isNot(contains('savings')));
    expect(event.description, isNot(contains('living costs')));
  });

  test('describes single mother without inventing a father NPC', () {
    final event = generate(household(const [mother]));
    expect(event.description, contains('Your mother raises you on her own'));
  });

  test('describes deceased mother and omits her unverified employment history', () {
    final deceasedMother = mother.copyWith(isAlive: false, deathYear: 2026);
    final event = generate(household([father, deceasedMother]));
    expect(event.description, contains('mother died while giving birth'));
    expect(event.description, isNot(contains('Your mother is currently unemployed')));
  });

  test('describes orphanage guardian without treating guardian as a parent', () {
    const guardian = ParentNpc(
      id: 'guardian', firstName: 'Ayu', lastName: 'Santoso', gender: Gender.female,
      birthYear: 1980, role: FamilyRole.guardian,
      employmentStatus: EmploymentStatus.employed, occupation: 'Caregiver',
      annualIncome: Money.fromMinorUnits(1000000), incomeStability: IncomeStability.stable,
    );
    final event = generate(household(const [guardian]));
    expect(event.description, contains('orphanage'));
    expect(event.description, isNot(contains('Your guardian works')));
  });
}
