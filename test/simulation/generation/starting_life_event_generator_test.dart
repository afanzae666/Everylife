import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/family/family_asset.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/simulation/generation/starting_life_event_generator.dart';

void main() {
  const parent = ParentNpc(
    id: 'parent-1',
    firstName: 'Budi',
    lastName: 'Santoso',
    gender: Gender.male,
    birthYear: 1980,
    role: FamilyRole.father,
    employmentStatus: EmploymentStatus.employed,
    occupation: 'Teacher',
    monthlyIncome: Money.fromMinorUnits(5000000),
    incomeStability: IncomeStability.stable,
  );

  const unemployedParent = ParentNpc(
    id: 'parent-2',
    firstName: 'Siti',
    lastName: 'Santoso',
    gender: Gender.female,
    birthYear: 1982,
    role: FamilyRole.mother,
    employmentStatus: EmploymentStatus.unemployed,
    monthlyIncome: Money.zero(),
    incomeStability: IncomeStability.none,
  );

  const businessAsset = FamilyAsset(
    id: 'asset-business',
    name: 'Family Grocery Store',
    type: FamilyAssetType.business,
    value: Money.fromMinorUnits(10000000),
  );

  FamilyHousehold createHousehold({
    List<ParentNpc> parents = const [parent],
    Money? cashSavings,
    List<FamilyAsset> assets = const [],
    HousingStatus housingStatus = HousingStatus.rented,
    Money? monthlyLivingCosts,
    Money? totalDebt,
  }) {
    return FamilyHousehold(
      id: 'household-test',
      parents: parents,
      cashSavings: cashSavings ?? const Money.fromMinorUnits(1000000),
      assets: assets,
      housingStatus: housingStatus,
      monthlyLivingCosts:
          monthlyLivingCosts ?? const Money.fromMinorUnits(3000000),
      totalDebt: totalDebt ?? const Money.zero(),
    );
  }

  SimulationEvent generate({
    int seed = 123,
    int year = 2026,
    StartingBackgroundTier tier = StartingBackgroundTier.middleClass,
    FamilyHousehold? household,
  }) {
    return StartingLifeEventGenerator.generate(
      random: SeededRandom(seed),
      year: year,
      background: StartingBackground(tier: tier),
      household: household,
    );
  }

  group('StartingLifeEventGenerator', () {
    test('generates an event for every starting background tier', () {
      for (final tier in StartingBackgroundTier.values) {
        final event = generate(tier: tier);

        expect(event.id, 'starting-life-event-2026');
        expect(event.type, SimulationEventType.startingLifeEvent);
        expect(event.year, 2026);
        expect(event.title, isNotEmpty);
        expect(event.description, isNotEmpty);
      }
    });

    test('generates the same event for the same seed and background', () {
      final first = generate(
        seed: 12345,
        tier: StartingBackgroundTier.middleClass,
      );

      final second = generate(
        seed: 12345,
        tier: StartingBackgroundTier.middleClass,
      );

      expect(first.title, second.title);
      expect(first.description, second.description);
      expect(first.id, second.id);
    });

    test('uses the original background template without a household', () {
      final event = generate(
        seed: 123,
        tier: StartingBackgroundTier.workingClass,
      );

      expect(event.title, isNotEmpty);
      expect(event.description, contains('working-class'));
      expect(event.description, isNot(contains('Budi Santoso')));
    });

    test('includes the background label when a household is provided', () {
      final event = generate(
        tier: StartingBackgroundTier.middleClass,
        household: createHousehold(),
      );

      expect(event.description, contains('Middle Class'));
    });

    test('uses household facts over conflicting background narratives', () {
      final household = createHousehold(
        monthlyLivingCosts: const Money.fromMinorUnits(7000000),
        cashSavings: const Money.zero(),
        housingStatus: HousingStatus.temporary,
      );

      final event = generate(
        tier: StartingBackgroundTier.veryWealthy,
        household: household,
      );

      expect(event.title, 'An Uncertain Place to Call Home');
      expect(event.description, contains('Very Wealthy'));
      expect(
        event.description,
        contains('income is lower than its estimated'),
      );
      expect(
        event.description,
        contains('temporary accommodation'),
      );
      expect(
        event.description,
        contains('no recorded cash savings'),
      );
      expect(
        event.description,
        isNot(contains('extraordinary resources')),
      );
      expect(
        event.description,
        isNot(contains('exceptional wealth')),
      );
    });

    test('includes parent employment and occupation details', () {
      final household = createHousehold(
        parents: const [parent, unemployedParent],
      );

      final event = generate(household: household);

      expect(event.description, contains('Budi Santoso'));
      expect(event.description, contains('works as a Teacher'));
      expect(event.description, contains('Siti Santoso'));
      expect(event.description, contains('currently unemployed'));
    });

    test('describes financial pressure when income is below expenses', () {
      final household = createHousehold(
        monthlyLivingCosts: const Money.fromMinorUnits(7000000),
      );

      final event = generate(household: household);

      expect(event.title, 'A Family Facing Financial Pressure');
      expect(
        event.description,
        contains('income is lower than its estimated'),
      );
    });

    test('describes a family without stable housing', () {
      final household = createHousehold(
        housingStatus: HousingStatus.homeless,
      );

      final event = generate(household: household);

      expect(event.title, 'A Family Without Stable Housing');
      expect(
        event.description,
        contains('no stable housing'),
      );
    });

    test('describes temporary accommodation', () {
      final household = createHousehold(
        housingStatus: HousingStatus.temporary,
      );

      final event = generate(household: household);

      expect(event.title, 'An Uncertain Place to Call Home');
      expect(
        event.description,
        contains('temporary accommodation'),
      );
    });

    test('recognizes a family business asset', () {
      final household = createHousehold(
        assets: const [businessAsset],
        monthlyLivingCosts: const Money.fromMinorUnits(3000000),
      );

      final event = generate(household: household);

      expect(event.title, 'A Family with Business Interests');
      expect(
        event.description,
        contains('Family Grocery Store'),
      );
    });

    test('describes a household with no cash savings', () {
      final household = createHousehold(
        cashSavings: const Money.zero(),
      );

      final event = generate(household: household);

      expect(event.title, 'A Family Building Financial Security');
      expect(
        event.description,
        contains('no recorded cash savings'),
      );
    });

    test('describes a household whose income matches living costs', () {
      final household = createHousehold(
        monthlyLivingCosts: const Money.fromMinorUnits(5000000),
      );

      final event = generate(household: household);

      expect(
        event.description,
        contains('income matches its estimated'),
      );
    });

    test('describes savings, assets, housing, and outstanding debt', () {
      final household = createHousehold(
        cashSavings: const Money.fromMinorUnits(2000000),
        assets: const [businessAsset],
        housingStatus: HousingStatus.ownedWithMortgage,
        monthlyLivingCosts: const Money.fromMinorUnits(3000000),
        totalDebt: const Money.fromMinorUnits(4000000),
      );

      final event = generate(household: household);

      expect(event.description, contains('home financed with a mortgage'));
      expect(event.description, contains('recorded cash savings'));
      expect(event.description, contains('Family Grocery Store'));
      expect(event.description, contains('outstanding debt'));
    });

    test('handles a household with no parents or assets', () {
      final household = createHousehold(
        parents: const [],
        cashSavings: const Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.providedByOthers,
        monthlyLivingCosts: const Money.zero(),
      );

      final event = generate(household: household);

      expect(
        event.description,
        contains('No parent or guardian employment details are recorded'),
      );
      expect(
        event.description,
        contains('No additional family assets are recorded'),
      );
      expect(
        event.description,
        contains('accommodation is provided by others'),
      );
    });

    test('uses the requested year in the event ID and year field', () {
      final event = generate(
        year: 2010,
        tier: StartingBackgroundTier.struggling,
      );

      expect(event.id, 'starting-life-event-2010');
      expect(event.year, 2010);
    });
  });
}
