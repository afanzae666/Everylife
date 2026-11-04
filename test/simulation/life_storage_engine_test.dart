import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

SimulationEngine _engine(InMemorySaveRepository repository, String id) {
  return SimulationEngine(
    initialState: WorldState(
      clock: const SimulationClock(currentYear: 2026),
      player: Character.create(id: id, name: 'Life $id', birthYear: 2026),
      events: const [],
    ),
    random: SeededRandom(7),
    saveRepository: repository,
  );
}

void main() {
  group('Life Storage autosave', () {
    test('each new life takes the first free slot', () async {
      final repository = InMemorySaveRepository();
      final first = _engine(repository, 'a');
      final second = _engine(repository, 'b');

      expect((await first.save()).isSuccess, isTrue);
      expect((await second.save()).isSuccess, isTrue);

      expect(first.activeSlot, SaveSlot.slot1);
      expect(second.activeSlot, SaveSlot.slot2);

      // Saving again keeps writing into the same slot.
      expect((await first.save()).isSuccess, isTrue);
      expect(first.activeSlot, SaveSlot.slot1);
      expect(await repository.load(slot: SaveSlot.slot3), isNull);
    });

    test('a full storage refuses a new life until one is deleted', () async {
      final repository = InMemorySaveRepository();

      for (var i = 0; i < lifeStorageCapacity; i++) {
        expect((await _engine(repository, 'l$i').save()).isSuccess, isTrue);
      }

      final extra = _engine(repository, 'extra');
      expect(await extra.firstFreeSlot(), isNull);
      expect((await extra.save()).isSuccess, isFalse);

      expect((await extra.deleteSave(SaveSlot.slot4)).isSuccess, isTrue);
      expect(await extra.firstFreeSlot(), SaveSlot.slot4);
      expect((await extra.save()).isSuccess, isTrue);
      expect(extra.activeSlot, SaveSlot.slot4);
    });

    test('loading a life makes its slot the active one', () async {
      final repository = InMemorySaveRepository();
      final first = _engine(repository, 'a');
      final second = _engine(repository, 'b');
      await first.save();
      await second.save();

      expect((await second.loadFromSlot(SaveSlot.slot1)).isSuccess, isTrue);
      expect(second.activeSlot, SaveSlot.slot1);
      expect(second.state.player.id, 'a');
    });
  });
}
