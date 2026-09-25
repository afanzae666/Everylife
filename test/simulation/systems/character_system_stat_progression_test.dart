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
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
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
      expect(result.player.stats.fitness, 51);
      expect(result.player.stats.willpower, 51);
      expect(result.player.stats.charisma, 51);
      expect(result.player.stats.creativity, 51);
      expect(result.player.stats.luck, 50);
    });

    test('applies teen progression during age up', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
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
      expect(result.player.stats.fitness, 51);
      expect(result.player.stats.willpower, 51);
      expect(result.player.stats.charisma, 51);
      expect(result.player.stats.creativity, 52);
      expect(result.player.stats.luck, 50);
    });

    test('applies adult progression during age up', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
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
      expect(result.player.stats.fitness, 49);
      expect(result.player.stats.willpower, 50);
      expect(result.player.stats.charisma, 50);
      expect(result.player.stats.creativity, 50);
      expect(result.player.stats.luck, 50);
    });

    test('preserves the original world state player', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
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
      expect(state.player.stats.fitness, 50);
      expect(state.player.stats.willpower, 50);
      expect(state.player.stats.charisma, 50);
      expect(state.player.stats.creativity, 50);
      expect(state.player.stats.luck, 50);

      expect(result.player, isNot(same(state.player)));
    });

    test('keeps character aged event when stats are progressed', () {
      const initialStats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
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
              event.type ==
                  SimulationEventType.characterAged &&
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
