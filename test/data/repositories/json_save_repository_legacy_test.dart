
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/models/world_state_snapshot.dart';
import 'package:everylife/data/repositories/json_save_repository.dart';
import 'package:everylife/data/storage/json_save_storage.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';

void main() {
  group('JsonSaveRepository legacy migration', () {
    test(
      'loads a legacy world snapshot without losing world data',
      () async {
        final storage = InMemoryJsonSaveStorage();
        final repository = JsonSaveRepository(
          storage: storage,
        );

        final original = WorldState(
          clock: const SimulationClock(
            currentYear: 2050,
          ),
          player: Character.create(
            id: 'legacy-player',
            name: 'Legacy Player',
            birthYear: 2030,
          ),
          events: const [],
        );

        final legacyJson = jsonEncode(
          WorldStateSnapshot.fromWorldState(
            original,
          ).toJson(),
        );

        await storage.write(legacyJson);

        final loaded = await repository.load();

        expect(loaded, isNotNull);
        expect(
          loaded!.state.clock.currentYear,
          2050,
        );
        expect(
          loaded.state.player.id,
          'legacy-player',
        );
        expect(
          loaded.state.player.name,
          'Legacy Player',
        );
        expect(loaded.randomState, 0);
        expect(loaded.nextTickId, 21);
      },
    );

    test(
      'does not treat an invalid unversioned object as a legacy save',
      () async {
        final storage = InMemoryJsonSaveStorage();
        final repository = JsonSaveRepository(
          storage: storage,
        );

        await storage.write(
          '{"unexpected": true}',
        );

        await expectLater(
          repository.load(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
