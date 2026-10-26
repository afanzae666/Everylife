
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/character.dart';
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

  FamilyHousehold household(
    List<ParentNpc> parents, {
    bool isAffairConception = false,
    bool raisedByFather = false,
  }) =>
      FamilyHousehold(
        id: 'test-household',
        parents: parents,
        cashSavings: Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.rented,
        annualLivingCosts: Money.zero(),
        totalDebt: Money.zero(),
        isAffairConception: isAffairConception,
        raisedByFather: raisedByFather,
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

  test('describes a single mother separately from her employment', () {
    final events = generateEvents(household(const [mother]));
    final economy = economyNarratives(events);
    expect(
      events.where((event) => event.title == 'Starting Economy'),
      hasLength(2),
    );

    expect(
      familyEvent(events).description,
      contains('My mother raised me on her own'),
    );
    expect(
      economy,
      contains('My father is unknown.'),
    );
    expect(
      economy,
      contains(
        'My mother, Sari Santoso, is currently unemployed (age 25).',
      ),
    );
    expect(economy, contains('\nMy mother,'));
    expect(
      economy,
      isNot(contains('raises you on her own')),
    );
  });

  test('does not invent employment history for a deceased mother', () {
    final deceasedMother = mother.copyWith(
      isAlive: false,
      deathYear: 2026,
    );
    final events = generateEvents(household([father, deceasedMother]));
    final economy = economyNarratives(events);

    expect(
      familyEvent(events).description,
      contains('My mother died while giving birth'),
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
        'My mother, Sari Santoso, is deceased in 2026 (age 23).',
      ),
    );
    expect(
      economy,
      isNot(contains('Your mother is currently unemployed')),
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
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
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

  test('birth narrative is first-person and includes the affair sentence', () {
    final player = Character.create(
      id: 'affair-birth-test',
      firstName: 'Ayu',
      lastName: 'Santoso',
      birthYear: 2026,
      birthMonth: 3,
      birthDay: 20,
    );
    final description = StartingLifeEventGenerator.birthNarrative(
      player: player,
      household: household(
        const [father, mother],
        isAffairConception: true,
      ),
      random: SeededRandom(123),
    );

    expect(
      description,
      'I was born in 2026. I was conceived during an affair between my '
      'mother and a married man.',
    );
    expect(description, isNot(contains('Ayu Santoso was born')));
  });

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

    expect(description, startsWith('I was born in 2026. '));
    expect(description, isNot(contains('affair')));
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
    final economy = economyNarratives(events);

    expect(
      familyEvent(events).description,
      contains('orphanage'),
    );
    expect(
      familyEvent(events).description,
      isNot(contains('Caregiver')),
    );
    expect(
      economy,
      contains(
        'My guardian, Ayu Santoso, works as a caregiver (age 25).',
      ),
    );
    expect(economy, contains('My father is unknown.'));
    expect(economy, isNot(contains('orphanage')));
  });
}
