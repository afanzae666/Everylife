
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/character_stats.dart';
import '../../../lib/domain/character/gender.dart';
import '../../../lib/domain/character/player_asset.dart';
import '../../../lib/domain/family/family_asset.dart';
import '../../../lib/domain/family/family_household.dart';
import '../../../lib/domain/family/parent_npc.dart';
import '../../../lib/domain/event/simulation_event.dart';
import '../../../lib/domain/time/simulation_clock.dart';
import '../../../lib/domain/world/world_state.dart';
import '../../../lib/simulation/engine/world_state_validator.dart';

Character createPlayer({
  String id = 'player-1',
  String name = 'Test Player',
  int birthYear = 2026,
  CharacterStats stats = const CharacterStats(),
  Money money = const Money.zero(),
  List<PlayerAsset> assets = const [],
  Money debt = const Money.zero(),
}) {
  return Character(
    id: id,
    name: name,
    birthYear: birthYear,
    stats: stats,
    money: money,
    assets: assets,
    debt: debt,
  );
}

WorldState createState({
  Character? player,
  int currentYear = 2026,
  List<SimulationEvent> events = const [],
}) {
  return WorldState(
    clock: SimulationClock(
      currentYear: currentYear,
    ),
    player: player ?? createPlayer(),
    events: events,
  );
}

ParentNpc createParent({
  String id = 'parent-1',
  String firstName = 'Alex',
  String lastName = 'Test',
  int birthYear = 1980,
  Money annualIncome = const Money.fromMinorUnits(200000),
  FamilyRole role = FamilyRole.father,
}) {
  return ParentNpc(
    id: id,
    firstName: firstName,
    lastName: lastName,
    gender: Gender.male,
    birthYear: birthYear,
    role: role,
    employmentStatus: EmploymentStatus.employed,
    annualIncome: annualIncome,
    incomeStability: IncomeStability.stable,
    occupation: 'Worker',
  );
}

FamilyHousehold createHousehold({
  String id = 'household-1',
  List<ParentNpc>? parents,
  Money cashSavings = const Money.fromMinorUnits(500000),
  List<FamilyAsset> assets = const [],
  HousingStatus housingStatus = HousingStatus.rented,
  Money annualLivingCosts = const Money.fromMinorUnits(100000),
  Money totalDebt = const Money.zero(),
}) {
  return FamilyHousehold(
    id: id,
    parents: parents ?? [createParent()],
    cashSavings: cashSavings,
    assets: assets,
    housingStatus: housingStatus,
    annualLivingCosts: annualLivingCosts,
    totalDebt: totalDebt,
  );
}

void main() {
  const validator = WorldStateValidator();

  group('WorldStateValidator', () {
    test('accepts a valid world state', () {
      final result = validator.validate(createState());

      expect(result.isSuccess, isTrue);
    });

    test('accepts all core stats at zero and one hundred', () {
      const stats = CharacterStats(
        health: 0,
        intelligence: 100,
        fitness: 0,
        happiness: 100,
        willpower: 0,
        charisma: 100,
        creativity: 0,
        luck: 100,
      );

      final result = validator.validate(
        createState(
          player: createPlayer(stats: stats),
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('rejects an empty player id', () {
      final result = validator.validate(
        createState(player: createPlayer(id: '')),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects an empty player name', () {
      final result = validator.validate(
        createState(player: createPlayer(name: '')),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a non-positive birth year', () {
      final result = validator.validate(
        createState(
          player: createPlayer(birthYear: 0),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a stat below zero', () {
      const stats = CharacterStats(health: -1);

      final result = validator.validate(
        createState(
          player: createPlayer(stats: stats),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a stat above one hundred', () {
      const stats = CharacterStats(health: 101);

      final result = validator.validate(
        createState(
          player: createPlayer(stats: stats),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects negative player money', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            money: const Money.fromMinorUnits(-1),
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects negative player debt', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            debt: const Money.fromMinorUnits(-1),
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a player asset with an empty id', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            assets: [
              const PlayerAsset(
                id: ' ',
                name: 'Car',
                type: PlayerAssetType.vehicle,
                value: Money.fromMinorUnits(100),
              ),
            ],
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects duplicate player asset ids', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            assets: [
              const PlayerAsset(
                id: 'asset-1',
                name: 'Car',
                type: PlayerAssetType.vehicle,
                value: Money.fromMinorUnits(100),
              ),
              const PlayerAsset(
                id: ' asset-1 ',
                name: 'Motorcycle',
                type: PlayerAssetType.vehicle,
                value: Money.fromMinorUnits(200),
              ),
            ],
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a player asset with an empty name', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            assets: [
              const PlayerAsset(
                id: 'asset-1',
                name: ' ',
                type: PlayerAssetType.vehicle,
                value: Money.fromMinorUnits(100),
              ),
            ],
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a player asset with a negative value', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            assets: [
              const PlayerAsset(
                id: 'asset-1',
                name: 'Car',
                type: PlayerAssetType.vehicle,
                value: Money.fromMinorUnits(-1),
              ),
            ],
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('accepts a valid player asset and financial balances', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            money: const Money.fromMinorUnits(500),
            debt: const Money.fromMinorUnits(200),
            assets: [
              const PlayerAsset(
                id: 'asset-1',
                name: 'Car',
                type: PlayerAssetType.vehicle,
                value: Money.fromMinorUnits(1000),
              ),
            ],
          ),
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('rejects a world year before player birth year', () {
      final result = validator.validate(
        createState(
          player: createPlayer(birthYear: 2026),
          currentYear: 2025,
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('accepts a valid event in the current year', () {
      final result = validator.validate(
        createState(
          events: [
            const SimulationEvent(
              id: 'event-1',
              type: SimulationEventType.lifeCreated,
              year: 2026,
              title: 'A new life begins',
              description: 'The simulation starts.',
            ),
          ],
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('rejects an event from a future year', () {
      final result = validator.validate(
        createState(
          events: [
            const SimulationEvent(
              id: 'event-future',
              type: SimulationEventType.randomEvent,
              year: 2027,
              title: 'A future event',
              description: 'This event has not happened yet.',
            ),
          ],
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects an event with an empty id', () {
      final result = validator.validate(
        createState(
          events: [
            const SimulationEvent(
              id: ' ',
              type: SimulationEventType.lifeCreated,
              year: 2026,
              title: 'A new life begins',
              description: 'The simulation starts.',
            ),
          ],
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects duplicate event ids after trimming whitespace', () {
      final result = validator.validate(
        createState(
          events: [
            const SimulationEvent(
              id: 'event-1',
              type: SimulationEventType.lifeCreated,
              year: 2026,
              title: 'First event',
              description: 'First description.',
            ),
            const SimulationEvent(
              id: ' event-1 ',
              type: SimulationEventType.randomEvent,
              year: 2026,
              title: 'Second event',
              description: 'Second description.',
            ),
          ],
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects an event with a non-positive year', () {
      final result = validator.validate(
        createState(
          events: [
            const SimulationEvent(
              id: 'event-1',
              type: SimulationEventType.lifeCreated,
              year: 0,
              title: 'A new life begins',
              description: 'The simulation starts.',
            ),
          ],
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects an event with an empty title', () {
      final result = validator.validate(
        createState(
          events: [
            const SimulationEvent(
              id: 'event-1',
              type: SimulationEventType.lifeCreated,
              year: 2026,
              title: ' ',
              description: 'The simulation starts.',
            ),
          ],
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('accepts a valid family household', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: 'asset-1',
              name: 'Family Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(1000000),
              ownerNpcId: 'parent-1',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('accepts a family-owned home with one property asset', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          housingStatus: HousingStatus.familyOwned,
          assets: [
            const FamilyAsset(
              id: 'property-1',
              name: 'Family Home',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(5000000),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('accepts a mortgaged home with one property asset', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          housingStatus: HousingStatus.ownedWithMortgage,
          assets: [
            const FamilyAsset(
              id: 'property-1',
              name: 'Mortgaged Home',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(5000000),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('rejects an owned home without a property asset', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          housingStatus: HousingStatus.familyOwned,
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects multiple property assets for one household home', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          housingStatus: HousingStatus.familyOwned,
          assets: [
            const FamilyAsset(
              id: 'property-1',
              name: 'Family Home',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(5000000),
            ),
            const FamilyAsset(
              id: 'property-2',
              name: 'Second Home',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(7000000),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a property asset when the household rents', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          housingStatus: HousingStatus.rented,
          assets: [
            const FamilyAsset(
              id: 'property-1',
              name: 'Unexpected Property',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(5000000),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('accepts a household with two parents', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(id: 'parent-father'),
            createParent(
              id: 'parent-mother',
              firstName: 'Jamie',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('rejects a household without parents', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test(
      'rejects a household with more than two parents when there is no step-parent',
      () {
        final state = createState().copyWith(
          familyHousehold: createHousehold(
            parents: [
              createParent(id: 'parent-1'),
              createParent(id: 'parent-2'),
              createParent(id: 'parent-3'),
              createParent(id: 'parent-4'),
            ],
          ),
        );

        expect(validator.validate(state).isFailure, isTrue);
      },
    );

    test('accepts three parents when one is a step-parent', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(id: 'parent-father'),
            createParent(id: 'parent-mother', firstName: 'Jamie'),
            createParent(
              id: 'parent-step-mother',
              firstName: 'Morgan',
              role: FamilyRole.stepMother,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('accepts a world state without a household for legacy saves', () {
      expect(
        validator.validate(createState()).isSuccess,
        isTrue,
      );
    });

    test('rejects an empty household id', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(id: ' '),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects duplicate parent ids', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(id: 'parent-1'),
            createParent(
              id: 'parent-1',
              firstName: 'Jamie',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an empty parent id', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [createParent(id: ' ')],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects duplicate parent ids after trimming whitespace', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(id: 'parent-1'),
            createParent(
              id: ' parent-1 ',
              firstName: 'Jamie',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an empty parent name', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [createParent(firstName: ' ')],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a non-positive parent birth year', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [createParent(birthYear: 0)],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a parent born in the same year as the player', () {
      final state = createState(
        player: createPlayer(birthYear: 2026),
      ).copyWith(
        familyHousehold: createHousehold(
          parents: [createParent(birthYear: 2026)],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a parent born after the player', () {
      final state = createState(
        player: createPlayer(birthYear: 2026),
      ).copyWith(
        familyHousehold: createHousehold(
          parents: [createParent(birthYear: 2027)],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('accepts a parent born before the player', () {
      final state = createState(
        player: createPlayer(birthYear: 2026),
      ).copyWith(
        familyHousehold: createHousehold(
          parents: [createParent(birthYear: 1980)],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('rejects negative parent income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(
              annualIncome: const Money.fromMinorUnits(-1),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an employed parent without positive income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(
              annualIncome: const Money.zero(),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an employed parent without an occupation', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.employed,
              annualIncome: const Money.fromMinorUnits(200000),
              incomeStability: IncomeStability.stable,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an employed parent with no income stability', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.employed,
              annualIncome: const Money.fromMinorUnits(200000),
              incomeStability: IncomeStability.none,
              occupation: 'Worker',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an unemployed parent with employment income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.unemployed,
              annualIncome: const Money.fromMinorUnits(200000),
              incomeStability: IncomeStability.stable,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a homemaker with an occupation or work income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.homemaker,
              annualIncome: const Money.zero(),
              incomeStability: IncomeStability.none,
              occupation: 'Worker',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    
    test('rejects an unable-to-work parent with income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.unableToWork,
              annualIncome: const Money.fromMinorUnits(200000),
              incomeStability: IncomeStability.stable,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an unable-to-work parent with an occupation', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.unableToWork,
              annualIncome: const Money.zero(),
              incomeStability: IncomeStability.none,
              occupation: 'Worker',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a retired parent with a current occupation', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1950,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.retired,
              annualIncome: const Money.fromMinorUnits(100000),
              incomeStability: IncomeStability.stable,
              occupation: 'Worker',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('accepts a self-employed parent with income and occupation', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.selfEmployed,
              annualIncome: const Money.fromMinorUnits(200000),
              incomeStability: IncomeStability.variable,
              occupation: 'Small business owner',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('rejects an unemployed parent with stability but no income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.unemployed,
              annualIncome: const Money.zero(),
              incomeStability: IncomeStability.stable,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects a homemaker with stability but no income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1980,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.homemaker,
              annualIncome: const Money.zero(),
              incomeStability: IncomeStability.stable,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('accepts a retired parent with recorded pension income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1950,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.retired,
              annualIncome: const Money.fromMinorUnits(100000),
              incomeStability: IncomeStability.stable,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isSuccess, isTrue);
    });

    test('rejects positive parent income marked as stability none', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            ParentNpc(
              id: 'parent-1',
              firstName: 'Alex',
              lastName: 'Test',
              gender: Gender.male,
              birthYear: 1950,
              role: FamilyRole.father,
              employmentStatus: EmploymentStatus.retired,
              annualIncome: const Money.fromMinorUnits(100000),
              incomeStability: IncomeStability.none,
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects negative household savings', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          cashSavings: const Money.fromMinorUnits(-1),
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects negative household living costs', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          annualLivingCosts: const Money.fromMinorUnits(-1),
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects negative household debt', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          totalDebt: const Money.fromMinorUnits(-1),
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects duplicate family asset ids', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: 'asset-1',
              name: 'Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(100),
            ),
            const FamilyAsset(
              id: 'asset-1',
              name: 'House',
              type: FamilyAssetType.property,
              value: Money.fromMinorUnits(200),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects duplicate family asset ids after trimming whitespace', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: 'asset-1',
              name: 'Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(100),
            ),
            const FamilyAsset(
              id: ' asset-1 ',
              name: 'Motorcycle',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(200),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an empty family asset id', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: ' ',
              name: 'Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(100),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an empty family asset name', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: 'asset-1',
              name: ' ',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(100),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects negative asset values', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: 'asset-1',
              name: 'Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(-1),
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });

    test('rejects an asset owner who is not a household parent', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          assets: [
            const FamilyAsset(
              id: 'asset-1',
              name: 'Car',
              type: FamilyAssetType.vehicle,
              value: Money.fromMinorUnits(100),
              ownerNpcId: 'missing-parent',
            ),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
    });
  });
}
