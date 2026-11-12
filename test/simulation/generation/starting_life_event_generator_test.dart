
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/character.dart';
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
        household: family,
      );

  SimulationEvent familyEvent(List<SimulationEvent> events) =>
      events.singleWhere((event) => event.title == 'Starting Family');

  String economyNarratives(List<SimulationEvent> events) => events
      .where((event) => event.title == 'Starting Economy')
      .map((event) => event.description)
      .join('\n');


  test('generates separate family and economy events', () {
    final events = generateEvents(household(const [father, mother]));
    final economy = economyNarratives(events);
    final economyEvents = events
        .where((event) => event.title == 'Starting Economy')
        .toList();

    expect(events, hasLength(3));
    expect(economyEvents, hasLength(2));
    expect(economyEvents.every((event) => !event.description.contains('•')), isTrue);
    expect(
      events.map((event) => event.title),
      containsAll(['Starting Family', 'Starting Economy']),
    );

    expect(
      familyEvent(events).description,
      contains('both of my parents'),
    );

    expect(
      economy,
      contains(
        'My father, Budi Santoso, works as a teacher (age 25).',
      ),
    );
    expect(
      economy,
      contains(
        'My mother, Sari Santoso, is currently unemployed (age 23).',
      ),
    );
    expect(economy, contains('\nMy mother,'));
    expect(economy, isNot(contains('biological parents')));

    expect(
      familyEvent(events).description,
      isNot(contains('works as a Teacher')),
    );
    expect(
      familyEvent(events).description,
      isNot(contains('unemployed')),
    );
  });

  test(
    'uses first-person family details and identifies the birthday zodiac',
    () {
      final player = Character.create(
        id: 'birthday-test',
        firstName: 'Olivia',
        lastName: 'Taylor',
        birthYear: 2026,
        birthMonth: 3,
        birthDay: 20,
      );
      final events = StartingLifeEventGenerator.generate(
        random: SeededRandom(123),
        year: 2026,
        household: household(const [father, mother]),
        player: player,
      );
      final birthday = events.singleWhere(
        (event) => event.title == 'My Birthday',
      );

      expect(
        birthday.description,
        'My birthday is March 20. I am a Pisces.',
      );
      expect(events, hasLength(4));
      expect(
        events.map((event) => event.description).join(' '),
        isNot(contains('You ')),
      );
    },
  );

  test('ordinary two-parent birth does not mention an affair', () {
    final player = Character.create(
      id: 'ordinary-birth-test',
      firstName: 'Ayu',
      lastName: 'Santoso',
      birthYear: 2026,
      birthMonth: 3,
      birthDay: 20,
    );
    final description = StartingLifeEventGenerator.birthNarrative(
      player: player,
      household: household(const [father, mother]),
      random: SeededRandom(123),
    );

    expect(description, contains('born'));
    expect(description, isNot(contains('2026')));
    expect(description, isNot(contains('affair')));
  });
}
