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
  group('CharacterSystem stat progression', () {
    test('applies life stage progression during age up', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final state = _createState(
        birthYear: 2020,
        currentYear: 2026,
        stats: initialStats,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(result.player.stats.health, 51);
      expect(result.player.stats.happiness, 51);
      expect(result.player.stats.intelligence, 52);
      expect(result.player.stats.discipline, 51);
      expect(result.player.stats.empathy, 51);
      expect(result.player.stats.ambition, 51);
    });

    test('applies teen progression during age up', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final state = _createState(
        birthYear: 2013,
        currentYear: 2026,
        stats: initialStats,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(result.player.stats.health, 51);
      expect(result.player.stats.happiness, 50);
      expect(result.player.stats.intelligence, 52);
      expect(result.player.stats.discipline, 51);
      expect(result.player.stats.empathy, 51);
      expect(result.player.stats.ambition, 52);
    });

    test('applies adult health decline during age up', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final state = _createState(
        birthYear: 1996,
        currentYear: 2026,
        stats: initialStats,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(result.player.stats.health, 49);
      expect(result.player.stats.happiness, 50);
      expect(result.player.stats.intelligence, 50);
      expect(result.player.stats.discipline, 50);
      expect(result.player.stats.empathy, 50);
      expect(result.player.stats.ambition, 50);
    });

    test('preserves the original world state player', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final state = _createState(
        birthYear: 2020,
        currentYear: 2026,
        stats: initialStats,
      );

      final result = CharacterSystem().process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(state.player.stats.health, 50);
      expect(state.player.stats.happiness, 50);
      expect(state.player.stats.intelligence, 50);
      expect(state.player.stats.discipline, 50);
      expect(state.player.stats.empathy, 50);
      expect(state.player.stats.ambition, 50);

      expect(result.player, isNot(same(state.player)));
    });

    test('keeps character aged event when stats are progressed', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final state = _createState(
        birthYear: 2020,
        currentYear: 2026,
        stats: initialStats,
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
    });
  });
}

WorldState _createState({
  required int birthYear,
  required int currentYear,
  required CharacterStats stats,
}) {
  final character = Character(
    id: 'character-test',
    name: 'Test Character',
    birthYear: birthYear,
    stats: stats,
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
