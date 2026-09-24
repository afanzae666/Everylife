import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/money/money.dart';
import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/character_stats.dart';
import '../../../lib/domain/event/simulation_event.dart';
import '../../../lib/domain/time/simulation_clock.dart';
import '../../../lib/domain/world/world_state.dart';
import '../../../lib/simulation/commands/age_up_command.dart';
import '../../../lib/simulation/systems/character_system.dart';

void main() {
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
