import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/money/money.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/character_stats.dart';
import '../../../lib/domain/character/gender.dart';
import '../../../lib/domain/family/family_household.dart';
import '../../../lib/domain/family/sibling_npc.dart';
import '../../../lib/domain/event/simulation_event.dart';
import '../../../lib/domain/time/simulation_clock.dart';
import '../../../lib/domain/world/world_state.dart';
import '../../../lib/simulation/commands/age_up_command.dart';
import '../../../lib/simulation/systems/character_system.dart';

void main() {
  test('reports a twin birth once when siblings share a birth year', () {
    final player = Character(
      id: 'player-twin-test',
      name: 'Taylor Morgan',
      birthYear: 2026,
      stats: const CharacterStats(),
      money: Money.zero(),
    );
    final state = WorldState(
      clock: const SimulationClock(currentYear: 2029),
      player: player,
      events: const [],
      familyHousehold: FamilyHousehold(
        id: 'twin-household-test',
        parents: const [],
        siblings: const [
          SiblingNpc(
            id: 'twin-one',
            firstName: 'Olivia',
            lastName: 'Morgan',
            gender: Gender.female,
            birthYear: 2029,
            relationship: SiblingRelationship.fullSibling,
            isTwin: true,
          ),
          SiblingNpc(
            id: 'twin-two',
            firstName: 'Emma',
            lastName: 'Morgan',
            gender: Gender.female,
            birthYear: 2029,
            relationship: SiblingRelationship.fullSibling,
            isTwin: true,
          ),
        ],
        cashSavings: Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.temporary,
        annualLivingCosts: Money.zero(),
        totalDebt: Money.zero(),
      ),
    );

    final result = CharacterSystem().process(
      state: state,
      command: const AgeUpCommand(),
    );
    final birthEvents = result.events.where(
      (event) => event.title == 'Twins are born',
    );

    expect(birthEvents, hasLength(1));
    expect(birthEvents.single.description, contains('Olivia Morgan'));
    expect(birthEvents.single.description, contains('Emma Morgan'));
  });

  group('CharacterSystem life stage transitions', () {
    test('creates lifeStageChanged when entering toddler stage', () {
      final state = _createState(
        birthYear: 2024,
        currentYear: 2027,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2027,
        ),
        isTrue,
      );
    });

    test('creates lifeStageChanged when entering child stage', () {
      final state = _createState(
        birthYear: 2020,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2026,
        ),
        isTrue,
      );
    });

    test('creates lifeStageChanged when entering teen stage', () {
      final state = _createState(
        birthYear: 2013,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2026,
        ),
        isTrue,
      );
    });

    test('creates lifeStageChanged when entering young adult stage', () {
      final state = _createState(
        birthYear: 2008,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2026,
        ),
        isTrue,
      );
    });

    test('creates lifeStageChanged when entering adult stage', () {
      final state = _createState(
        birthYear: 1996,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2026,
        ),
        isTrue,
      );
    });

    test('creates lifeStageChanged when entering senior stage', () {
      final state = _createState(
        birthYear: 1966,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2026,
        ),
        isTrue,
      );
    });

    test('does not create lifeStageChanged when stage remains unchanged', () {
      final state = _createState(
        birthYear: 2015,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.where(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged,
        ),
        isEmpty,
      );
    });

    test('still creates characterAged during a life stage transition', () {
      final state = _createState(
        birthYear: 2008,
        currentYear: 2026,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.characterAged &&
              event.year == 2026,
        ),
        isTrue,
      );

      expect(
        result.events.any(
          (event) =>
              event.type == SimulationEventType.lifeStageChanged &&
              event.year == 2026,
        ),
        isTrue,
      );
    });
  });
}

WorldState _createState({
  required int birthYear,
  required int currentYear,
}) {
  final character = Character(
    id: 'character-test',
    name: 'Test Character',
    birthYear: birthYear,
    stats: const CharacterStats(),
    money: const Money.zero(),
  );

  return WorldState(
    clock: SimulationClock(
      currentYear: currentYear,
    ),
    player: character,
    events: const [],
  );
}
