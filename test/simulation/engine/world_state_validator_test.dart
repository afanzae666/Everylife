
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/character_stats.dart';
import '../../../lib/domain/character/gender.dart';
import '../../../lib/domain/family/family_asset.dart';
import '../../../lib/domain/family/family_household.dart';
import '../../../lib/domain/family/parent_npc.dart';
import '../../../lib/domain/time/simulation_clock.dart';
import '../../../lib/domain/world/world_state.dart';
import '../../../lib/simulation/engine/world_state_validator.dart';

Character createPlayer({
  String id = 'player-1',
  String name = 'Test Player',
  int birthYear = 2026,
  CharacterStats stats = const CharacterStats(),
}) {
  return Character(
    id: id,
    name: name,
    birthYear: birthYear,
    stats: stats,
    money: const Money.zero(),
  );
}

WorldState createState({
  Character? player,
  int currentYear = 2026,
}) {
  return WorldState(
    clock: SimulationClock(
      currentYear: currentYear,
    ),
    player: player ?? createPlayer(),
    events: const [],
  );
}

ParentNpc createParent({
  String id = 'parent-1',
  String firstName = 'Alex',
  String lastName = 'Test',
  int birthYear = 1980,
  Money monthlyIncome = const Money.fromMinorUnits(200000),
}) {
  return ParentNpc(
    id: id,
    firstName: firstName,
    lastName: lastName,
    gender: Gender.male,
    birthYear: birthYear,
    role: FamilyRole.father,
    employmentStatus: EmploymentStatus.employed,
    monthlyIncome: monthlyIncome,
    incomeStability: IncomeStability.stable,
    occupation: 'Worker',
  );
}

FamilyHousehold createHousehold({
  String id = 'household-1',
  List<ParentNpc>? parents,
  Money cashSavings = const Money.fromMinorUnits(500000),
  List<FamilyAsset> assets = const [],
  Money monthlyLivingCosts = const Money.fromMinorUnits(100000),
  Money totalDebt = const Money.zero(),
}) {
  return FamilyHousehold(
    id: id,
    parents: parents ?? [createParent()],
    cashSavings: cashSavings,
    assets: assets,
    housingStatus: HousingStatus.rented,
    monthlyLivingCosts: monthlyLivingCosts,
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

    test('rejects a world year before player birth year', () {
      final result = validator.validate(
        createState(
          player: createPlayer(birthYear: 2026),
          currentYear: 2025,
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

    test('rejects a household with more than two parents', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(id: 'parent-1'),
            createParent(id: 'parent-2'),
            createParent(id: 'parent-3'),
          ],
        ),
      );

      expect(validator.validate(state).isFailure, isTrue);
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

    test('rejects negative parent income', () {
      final state = createState().copyWith(
        familyHousehold: createHousehold(
          parents: [
            createParent(
              monthlyIncome: const Money.fromMinorUnits(-1),
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
              monthlyIncome: const Money.zero(),
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
              monthlyIncome: const Money.fromMinorUnits(200000),
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
              monthlyIncome: const Money.fromMinorUnits(200000),
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
              monthlyIncome: const Money.fromMinorUnits(200000),
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
              monthlyIncome: const Money.zero(),
              incomeStability: IncomeStability.none,
              occupation: 'Worker',
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
              monthlyIncome: const Money.fromMinorUnits(100000),
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
              monthlyIncome: const Money.fromMinorUnits(100000),
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
          monthlyLivingCosts: const Money.fromMinorUnits(-1),
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
