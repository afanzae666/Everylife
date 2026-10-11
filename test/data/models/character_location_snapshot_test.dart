import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/character_location.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/data/models/world_state_snapshot.dart';

void main() {
  group('Character location integration', () {
    test('stores location on Character', () {
      const location = CharacterLocation(
        countryCode: 'ID',
        cityId: 'id-jakarta',
      );

      final character = Character(
        id: 'character-location-1',
        name: 'Test Character',
        birthYear: 2025,
        stats: const CharacterStats(),
        money: const Money.zero(),
        location: location,
      );

      expect(character.location, isNotNull);
      expect(character.location!.countryCode, 'ID');
      expect(character.location!.cityId, 'id-jakarta');
      expect(character.location!.isValid, isTrue);
    });

    test('preserves location when copying Character', () {
      const location = CharacterLocation(
        countryCode: 'ID',
        cityId: 'id-jakarta',
      );

      final character = Character(
        id: 'character-location-2',
        name: 'Test Character',
        birthYear: 2025,
        stats: const CharacterStats(),
        money: const Money.zero(),
        location: location,
      );

      final copiedCharacter = character.copyWith(
        name: 'Updated Character',
      );

      expect(copiedCharacter.name, 'Updated Character');
      expect(copiedCharacter.location, location);
    });

    test('round-trips location through WorldStateSnapshot', () {
      const location = CharacterLocation(
        countryCode: 'ID',
        cityId: 'id-jakarta',
      );

      final original = _createWorldState(
        location: location,
      );

      final snapshot = WorldStateSnapshot.fromWorldState(
        original,
      );

      final restored = snapshot.toWorldState();

      expect(restored.player.location, isNotNull);
      expect(restored.player.location!.countryCode, 'ID');
      expect(restored.player.location!.cityId, 'id-jakarta');
      expect(restored.player.location!.isValid, isTrue);
    });

    test('serializes location to JSON', () {
      const location = CharacterLocation(
        countryCode: 'US',
        cityId: 'us-new-york',
      );

      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(location: location),
      );

      final json = snapshot.toJson();
      final playerJson = json['player'] as Map<String, dynamic>;
      final locationJson =
          playerJson['location'] as Map<String, dynamic>;

      expect(locationJson['countryCode'], 'US');
      expect(locationJson['cityId'], 'us-new-york');
    });

    test('deserializes location from JSON', () {
      const location = CharacterLocation(
        countryCode: 'JP',
        cityId: 'jp-tokyo',
      );

      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(location: location),
      );

      final restoredSnapshot = WorldStateSnapshot.fromJson(
        snapshot.toJson(),
      );

      expect(restoredSnapshot.playerLocation, isNotNull);
      expect(restoredSnapshot.playerLocation!.countryCode, 'JP');
      expect(restoredSnapshot.playerLocation!.cityId, 'jp-tokyo');
    });

    test('loads an older save without location', () {
      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(),
      );

      final json = snapshot.toJson();
      final playerJson = json['player'] as Map<String, dynamic>;

      playerJson.remove('location');

      final restoredSnapshot = WorldStateSnapshot.fromJson(json);
      final restored = restoredSnapshot.toWorldState();

      expect(restoredSnapshot.playerLocation, isNull);
      expect(restored.player.location, isNull);
      expect(restored.player.name, 'Test Character');
    });

    test('loads a save where location is explicitly null', () {
      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(),
      );

      final json = snapshot.toJson();
      final playerJson = json['player'] as Map<String, dynamic>;

      playerJson['location'] = null;

      final restoredSnapshot = WorldStateSnapshot.fromJson(json);

      expect(restoredSnapshot.playerLocation, isNull);
    });

    test('rejects a city that does not belong to the saved country', () {
      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(),
      );

      final json = snapshot.toJson();
      final playerJson = json['player'] as Map<String, dynamic>;

      playerJson['location'] = {
        'countryCode': 'ID',
        'cityId': 'us-new-york',
      };

      expect(
        () => WorldStateSnapshot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an unknown city in saved location', () {
      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(),
      );

      final json = snapshot.toJson();
      final playerJson = json['player'] as Map<String, dynamic>;

      playerJson['location'] = {
        'countryCode': 'ID',
        'cityId': 'id-unknown-city',
      };

      expect(
        () => WorldStateSnapshot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a location missing its city ID', () {
      final snapshot = WorldStateSnapshot.fromWorldState(
        _createWorldState(),
      );

      final json = snapshot.toJson();
      final playerJson = json['player'] as Map<String, dynamic>;

      playerJson['location'] = {
        'countryCode': 'ID',
      };

      expect(
        () => WorldStateSnapshot.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

WorldState _createWorldState({
  CharacterLocation? location,
}) {
  return WorldState(
    clock: const SimulationClock(
      currentYear: 2050,
    ),
    player: Character(
      id: 'character-location-test',
      name: 'Test Character',
      gender: Gender.male,
      birthYear: 2025,
      stats: const CharacterStats(),
      money: const Money.zero(),
      location: location,
    ),
    events: const [],
  );
}
