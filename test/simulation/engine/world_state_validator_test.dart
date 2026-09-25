import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/money/money.dart';
import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/character_stats.dart';
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

void main() {
  const validator = WorldStateValidator();

  group('WorldStateValidator', () {
    test('accepts a valid world state', () {
      final result = validator.validate(
        createState(),
      );

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
          player: createPlayer(
            stats: stats,
          ),
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('rejects an empty player id', () {
      final result = validator.validate(
        createState(
          player: createPlayer(id: ''),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects an empty player name', () {
      final result = validator.validate(
        createState(
          player: createPlayer(name: ''),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a non-positive birth year', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            birthYear: 0,
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a stat below zero', () {
      const stats = CharacterStats(
        health: -1,
      );

      final result = validator.validate(
        createState(
          player: createPlayer(
            stats: stats,
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a stat above one hundred', () {
      const stats = CharacterStats(
        health: 101,
      );

      final result = validator.validate(
        createState(
          player: createPlayer(
            stats: stats,
          ),
        ),
      );

      expect(result.isFailure, isTrue);
    });

    test('rejects a world year before player birth year', () {
      final result = validator.validate(
        createState(
          player: createPlayer(
            birthYear: 2026,
          ),
          currentYear: 2025,
        ),
      );

      expect(result.isFailure, isTrue);
    });
  });
}
