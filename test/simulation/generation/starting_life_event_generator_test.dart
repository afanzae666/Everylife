
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/simulation/generation/starting_life_event_generator.dart';

void main() {
  const father = ParentNpc(
    id: 'father',
    firstName: 'Budi',
    lastName: 'Santoso',
    gender: Gender.male,
    birthYear: 1980,
    role: FamilyRole.father,
    employmentStatus: EmploymentStatus.employed,
    occupation: 'Teacher',
    annualIncome: Money.fromMinorUnits(5000000),
    incomeStability: IncomeStability.stable,
  );

  const mother = ParentNpc(
    id: 'mother',
    firstName: 'Sari',
    lastName: 'Santoso',
    gender: Gender.female,
    birthYear: 1982,
    role: FamilyRole.mother,
    employmentStatus: EmploymentStatus.unemployed,
    annualIncome: Money.zero(),
    incomeStability: IncomeStability.none,
  );

  FamilyHousehold household(List<ParentNpc> parents) => FamilyHousehold(
        id: 'test-household',
        parents: parents,
        cashSavings: Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.rented,
        annualLivingCosts: Money.zero(),
        totalDebt: Money.zero(),
      );

  List<SimulationEvent> generateEvents(FamilyHousehold family) =>
      StartingLifeEventGenerator.generate(
        random: SeededRandom(123),
        year: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
        household: family,
      );

  SimulationEvent familyEvent(List<SimulationEvent> events) =>
      events.singleWhere((event) => event.title == 'Starting Family');

  SimulationEvent economyEvent(List<SimulationEvent> events) =>
      events.singleWhere((event) => event.title == 'Starting Economy');

  test('generates separate family and economy events', () {
    final events = generateEvents(household(const [father, mother]));

    expect(events, hasLength(2));
    expect(
      events.map((event) => event.title),
      containsAll(['Starting Family', 'Starting Economy']),
    );

    expect(
      familyEvent(events).description,
      contains('both of your biological parents'),
    );
    expect(
      economyEvent(events).description,
      contains('Your father works as a Teacher.'),
    );
    expect(
      economyEvent(events).description,
      contains('Your mother is currently unemployed.'),
    );

    expect(
      familyEvent(events).description,
      isNot(contains('works as a Teacher')),
    );
    expect(
      familyEvent(events).description,
      isNot(contains('unemployed')),
    );
    expect(
      economyEvent(events).description,
      isNot(contains('biological parents')),
    );
  });

  test('describes a single mother separately from her employment', () {
    final events = generateEvents(household(const [mother]));

    expect(
      familyEvent(events).description,
      contains('Your mother raises you on her own'),
    );
    expect(
      economyEvent(events).description,
      contains('Your mother is currently unemployed.'),
    );
    expect(
      economyEvent(events).description,
      isNot(contains('raises you on her own')),
    );
  });

  test('does not invent employment history for a deceased mother', () {
    final deceasedMother = mother.copyWith(
      isAlive: false,
      deathYear: 2026,
    );
    final events = generateEvents(household([father, deceasedMother]));

    expect(
      familyEvent(events).description,
      contains('mother died while giving birth'),
    );
    expect(
      economyEvent(events).description,
      contains('Your father works as a Teacher.'),
    );
    expect(
      economyEvent(events).description,
      isNot(contains('Your mother is currently unemployed')),
    );
  });

  test('keeps orphanage story separate from guardian employment', () {
    const guardian = ParentNpc(
      id: 'guardian',
      firstName: 'Ayu',
      lastName: 'Santoso',
      gender: Gender.female,
      birthYear: 1980,
      role: FamilyRole.guardian,
      employmentStatus: EmploymentStatus.employed,
      occupation: 'Caregiver',
      annualIncome: Money.fromMinorUnits(1000000),
      incomeStability: IncomeStability.stable,
    );

    final events = generateEvents(household(const [guardian]));

    expect(
      familyEvent(events).description,
      contains('orphanage'),
    );
    expect(
      familyEvent(events).description,
      isNot(contains('Caregiver')),
    );
    expect(
      economyEvent(events).description,
      contains('Your guardian works as a Caregiver.'),
    );
    expect(
      economyEvent(events).description,
      isNot(contains('orphanage')),
    );
  });
}
