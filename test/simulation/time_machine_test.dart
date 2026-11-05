import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

SimulationEngine _engine() {
  return SimulationEngine(
    initialState: WorldState(
      clock: const SimulationClock(currentYear: 2026),
      player: Character.create(id: 'tm', name: 'Time Traveler', birthYear: 2026),
      events: const [],
    ),
    random: SeededRandom(99),
    saveRepository: InMemorySaveRepository(),
  );
}

void main() {
  persistenceTests();

  group('Time Machine', () {
    test('lists only past ages, newest first', () {
      final engine = _engine();
      expect(engine.rewindableAges, isEmpty);

      for (var i = 0; i < 4; i++) {
        expect(engine.ageUp().isSuccess, isTrue);
      }

      expect(engine.rewindableAges, [3, 2, 1]);
    });

    test('going back restores that age and forgets the future', () {
      final engine = _engine();

      for (var i = 0; i < 5; i++) {
        engine.ageUp();
      }

      final yearAtAge2 = 2026 + 2;
      expect(engine.rewindToAge(2).isSuccess, isTrue);

      expect(engine.state.clock.currentYear, yearAtAge2);
      expect(
        engine.state.player.ageAt(engine.state.clock.currentYear),
        2,
      );
      expect(engine.rewindableAges, [1]);

      // Life continues normally from there.
      expect(engine.ageUp().isSuccess, isTrue);
      expect(
        engine.state.player.ageAt(engine.state.clock.currentYear),
        3,
      );
    });

    test('the future and unknown ages are refused', () {
      final engine = _engine();
      engine.ageUp();
      engine.ageUp();

      expect(engine.rewindToAge(2).isFailure, isTrue);
      expect(engine.rewindToAge(5).isFailure, isTrue);
      expect(engine.rewindToAge(0).isFailure, isTrue);
    });
  });
}

void persistenceTests() {
  group('Time Machine persistence', () {
    test('the timeline survives leaving and re-entering the game', () async {
      final repository = InMemorySaveRepository();

      SimulationEngine build() => SimulationEngine(
            initialState: WorldState(
              clock: const SimulationClock(currentYear: 2026),
              player: Character.create(
                id: 'tm',
                name: 'Time Traveler',
                birthYear: 2026,
              ),
              events: const [],
            ),
            random: SeededRandom(99),
            saveRepository: repository,
          );

      final first = build();

      for (var i = 0; i < 4; i++) {
        first.ageUp();
      }

      expect((await first.save()).isSuccess, isTrue);

      final second = build();
      final slot = first.activeSlot!;

      expect((await second.loadFromSlot(slot)).isSuccess, isTrue);
      expect(second.rewindableAges, [3, 2, 1]);
      expect(second.rewindToAge(2).isSuccess, isTrue);
    });
  });
}
