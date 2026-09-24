import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/data/repositories/json_save_repository.dart';
import 'package:everylife/data/storage/json_save_storage.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';

void main() {
  group('JsonSaveRepository', () {
    late InMemoryJsonSaveStorage storage;
    late JsonSaveRepository repository;

    setUp(() {
      storage = InMemoryJsonSaveStorage();
      repository = JsonSaveRepository(
        storage: storage,
      );
    });

    test(
      'returns null when no save exists',
      () async {
        final loaded = await repository.load();

        expect(loaded, isNull);
      },
    );

    test(
      'saves and loads WorldState without losing data',
      () async {
        final original = WorldState(
          clock: const SimulationClock(
            currentYear: 2050,
          ),
          player: Character(
            id: 'character-1',
            name: 'Marshall Royce',
            gender: Gender.male,
            birthYear: 2030,
            stats: const CharacterStats(
              health: 91,
              happiness: 82,
              intelligence: 73,
              discipline: 64,
              empathy: 55,
              ambition: 88,
            ),
            money: const Money.fromMinorUnits(123456),
          ),
          events: const [
            SimulationEvent(
              id: 'event-1',
              type: SimulationEventType.yearAdvanced,
              year: 2050,
              title: 'A New Year',
              description: 'Another year has passed.',
            ),
          ],
        );

        await repository.save(original);

        final loaded = await repository.load();

        expect(loaded, isNotNull);

        expect(
          loaded!.clock.currentYear,
          original.clock.currentYear,
        );

        expect(
          loaded.player.id,
          original.player.id,
        );

        expect(
          loaded.player.name,
          original.player.name,
        );

        expect(
          loaded.player.gender,
          original.player.gender,
        );

        expect(
          loaded.player.birthYear,
          original.player.birthYear,
        );

        expect(
          loaded.player.stats.health,
          original.player.stats.health,
        );

        expect(
          loaded.player.stats.happiness,
          original.player.stats.happiness,
        );

        expect(
          loaded.player.stats.intelligence,
          original.player.stats.intelligence,
        );

        expect(
          loaded.player.stats.discipline,
          original.player.stats.discipline,
        );

        expect(
          loaded.player.stats.empathy,
          original.player.stats.empathy,
        );

        expect(
          loaded.player.stats.ambition,
          original.player.stats.ambition,
        );

        expect(
          loaded.player.money.minorUnits,
          original.player.money.minorUnits,
        );

        expect(
          loaded.events.length,
          original.events.length,
        );

        expect(
          loaded.events.first.id,
          original.events.first.id,
        );

        expect(
          loaded.events.first.type,
          original.events.first.type,
        );

        expect(
          loaded.events.first.year,
          original.events.first.year,
        );

        expect(
          loaded.events.first.title,
          original.events.first.title,
        );

        expect(
          loaded.events.first.description,
          original.events.first.description,
        );
      },
    );

    test(
      'overwrites the previous save',
      () async {
        final firstState = WorldState(
          clock: const SimulationClock(
            currentYear: 2040,
          ),
          player: Character(
            id: 'character-1',
            name: 'First Character',
            birthYear: 2020,
            stats: const CharacterStats(),
            money: const Money.zero(),
          ),
          events: const [],
        );

        final secondState = WorldState(
          clock: const SimulationClock(
            currentYear: 2060,
          ),
          player: Character(
            id: 'character-2',
            name: 'Second Character',
            gender: Gender.female,
            birthYear: 2030,
            stats: const CharacterStats(
              health: 80,
              happiness: 60,
              intelligence: 70,
              discipline: 40,
              empathy: 90,
              ambition: 100,
            ),
            money: const Money.fromMinorUnits(5000),
          ),
          events: const [],
        );

        await repository.save(firstState);
        await repository.save(secondState);

        final loaded = await repository.load();

        expect(loaded, isNotNull);
        expect(loaded!.clock.currentYear, 2060);
        expect(loaded.player.id, 'character-2');
        expect(loaded.player.name, 'Second Character');
        expect(loaded.player.gender, Gender.female);
        expect(loaded.player.money.minorUnits, 5000);
      },
    );

    test(
      'delete removes the saved game',
      () async {
        final state = WorldState(
          clock: const SimulationClock(
            currentYear: 2050,
          ),
          player: Character(
            id: 'character-1',
            name: 'Test Character',
            birthYear: 2030,
            stats: const CharacterStats(),
            money: const Money.zero(),
          ),
          events: const [],
        );

        await repository.save(state);

        expect(
          await repository.load(),
          isNotNull,
        );

        await repository.delete();

        expect(
          await repository.load(),
          isNull,
        );
      },
    );

    test(
      'rejects invalid saved JSON structure',
      () async {
        await storage.write(
          '"this is not a saved game object"',
        );

        expect(
          () => repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'rejects malformed JSON',
      () async {
        await storage.write(
          '{"currentYear":',
        );

        expect(
          () => repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
