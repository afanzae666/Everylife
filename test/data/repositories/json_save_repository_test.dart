import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/data/models/world_state_snapshot.dart';
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
      'saves and loads complete simulation data without losing data',
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

        await repository.save(
          original,
          randomState: 123456,
          nextTickId: 42,
        );

        final loaded = await repository.load();

        expect(loaded, isNotNull);

        expect(
          loaded!.state.clock.currentYear,
          original.clock.currentYear,
        );

        expect(
          loaded.state.player.id,
          original.player.id,
        );

        expect(
          loaded.state.player.name,
          original.player.name,
        );

        expect(
          loaded.state.player.gender,
          original.player.gender,
        );

        expect(
          loaded.state.player.birthYear,
          original.player.birthYear,
        );

        expect(
          loaded.state.player.stats.health,
          original.player.stats.health,
        );

        expect(
          loaded.state.player.stats.happiness,
          original.player.stats.happiness,
        );

        expect(
          loaded.state.player.stats.intelligence,
          original.player.stats.intelligence,
        );

        expect(
          loaded.state.player.stats.discipline,
          original.player.stats.discipline,
        );

        expect(
          loaded.state.player.stats.empathy,
          original.player.stats.empathy,
        );

        expect(
          loaded.state.player.stats.ambition,
          original.player.stats.ambition,
        );

        expect(
          loaded.state.player.money.minorUnits,
          original.player.money.minorUnits,
        );

        expect(
          loaded.state.events.length,
          original.events.length,
        );

        expect(
          loaded.state.events.first.id,
          original.events.first.id,
        );

        expect(
          loaded.state.events.first.type,
          original.events.first.type,
        );

        expect(
          loaded.state.events.first.year,
          original.events.first.year,
        );

        expect(
          loaded.state.events.first.title,
          original.events.first.title,
        );

        expect(
          loaded.state.events.first.description,
          original.events.first.description,
        );

        expect(
          loaded.randomState,
          123456,
        );

        expect(
          loaded.nextTickId,
          42,
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

        await repository.save(
          firstState,
          randomState: 100,
          nextTickId: 5,
        );

        await repository.save(
          secondState,
          randomState: 200,
          nextTickId: 10,
        );

        final loaded = await repository.load();

        expect(loaded, isNotNull);

        expect(
          loaded!.state.clock.currentYear,
          2060,
        );

        expect(
          loaded.state.player.id,
          'character-2',
        );

        expect(
          loaded.state.player.name,
          'Second Character',
        );

        expect(
          loaded.state.player.gender,
          Gender.female,
        );

        expect(
          loaded.state.player.money.minorUnits,
          5000,
        );

        expect(
          loaded.randomState,
          200,
        );

        expect(
          loaded.nextTickId,
          10,
        );
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

        await repository.save(
          state,
          randomState: 123,
          nextTickId: 2,
        );

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
          '{"schemaVersion":',
        );

        expect(
          () => repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'rejects unsupported save schema version',
      () async {
        final json = _createValidSaveJson();

        json['schemaVersion'] = 999;

        await storage.write(
          jsonEncode(json),
        );

        expect(
          () => repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'rejects invalid random state',
      () async {
        final json = _createValidSaveJson();

        final engine = Map<String, dynamic>.from(
          json['engine'] as Map,
        );

        engine['randomState'] = -1;
        json['engine'] = engine;

        await storage.write(
          jsonEncode(json),
        );

        expect(
          () => repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'rejects invalid next tick id',
      () async {
        final json = _createValidSaveJson();

        final engine = Map<String, dynamic>.from(
          json['engine'] as Map,
        );

        engine['nextTickId'] = 0;
        json['engine'] = engine;

        await storage.write(
          jsonEncode(json),
        );

        expect(
          () => repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

Map<String, dynamic> _createValidSaveJson() {
  final state = WorldState(
    clock: const SimulationClock(
      currentYear: 2050,
    ),
    player: Character(
      id: 'character-1',
      name: 'Test Character',
      gender: Gender.male,
      birthYear: 2030,
      stats: const CharacterStats(),
      money: const Money.zero(),
    ),
    events: const [],
  );

  final world = WorldStateSnapshot
      .fromWorldState(state)
      .toJson();

  return {
    'schemaVersion': 1,
    'engine': {
      'randomState': 12345,
      'nextTickId': 1,
    },
    'world': world,
  };
}
