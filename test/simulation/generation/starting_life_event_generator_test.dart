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
    id: 'parent-1', firstName: 'Budi', lastName: 'Santoso',
    gender: Gender.male, birthYear: 1980, role: FamilyRole.father,
    employmentStatus: EmploymentStatus.employed, occupation: 'Teacher',
    annualIncome: Money.fromMinorUnits(5000000),
    incomeStability: IncomeStability.stable,
    annualExpenses: Money.fromMinorUnits(4000000),
    cashBalance: Money.fromMinorUnits(1000000),
  );

  FamilyHousehold household({
    List<ParentNpc> parents = const [parent],
    HousingStatus housing = HousingStatus.rented,
    List<FamilyAsset> assets = const [],
  }) => FamilyHousehold(
    id: 'family-context-test', parents: parents,
    cashSavings: const Money.zero(), assets: assets,
    housingStatus: housing,
    annualLivingCosts: Money.fromMinorUnits(3000000),
    totalDebt: Money.zero(),
  );

  SimulationEvent generate({
    int seed = 123,
    int year = 2026,
    StartingBackgroundTier tier = StartingBackgroundTier.middleClass,
    FamilyHousehold? family,
  }) => StartingLifeEventGenerator.generate(
    random: SeededRandom(seed), year: year,
    background: StartingBackground(tier: tier), household: family,
  );

  test('generates an event for every background tier', () {
    for (final tier in StartingBackgroundTier.values) {
      final event = generate(tier: tier);
      expect(event.type, SimulationEventType.startingLifeEvent);
      expect(event.year, 2026);
      expect(event.title, isNotEmpty);
      expect(event.description, isNotEmpty);
    }
  });

  test('is deterministic for a fixed seed and background', () {
    final first = generate(seed: 12345, family: household());
    final second = generate(seed: 12345, family: household());
    expect(first.title, second.title);
    expect(first.description, second.description);
    expect(first.id, second.id);
  });

  test('describes parents and their personal finances', () {
    final event = generate(family: household());
    expect(event.description, contains('Budi Santoso'));
    expect(event.description, contains('works as a Teacher'));
    expect(event.description, contains('parents have accumulated personal cash savings'));
    expect(event.description, contains('parents earn income'));
    expect(event.description, contains('Middle Class'));
  });

  test('uses family housing facts for event title and description', () {
    final event = generate(
      tier: StartingBackgroundTier.veryWealthy,
      family: household(housing: HousingStatus.temporary),
    );
    expect(event.title, 'An Uncertain Place to Call Home');
    expect(event.description, contains('temporary accommodation'));
    expect(event.description, contains('Very Wealthy'));
  });

  test('does not expose individual asset names or household debt', () {
    const asset = FamilyAsset(
      id: 'asset-business', name: 'Secret Grocery Store',
      type: FamilyAssetType.business, value: Money.fromMinorUnits(10000000),
    );
    final event = generate(family: household(assets: const [asset]));
    expect(event.description, isNot(contains('Secret Grocery Store')));
    expect(event.description, isNot(contains('outstanding debt')));
  });

  test('uses the requested year in event identity', () {
    final event = generate(year: 2010, tier: StartingBackgroundTier.struggling);
    expect(event.id, 'starting-life-event-2010');
    expect(event.year, 2010);
  });
}
