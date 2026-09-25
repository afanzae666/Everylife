import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/data/models/world_state_snapshot.dart';

void main() {
  group('WorldStateSnapshot', () {
    test(
      'converts WorldState to snapshot and back without losing data',
      () {
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
              intelligence: 73,
              fitness: 82,
              happiness: 64,
              willpower: 55,
              charisma: 88,
              creativity: 71,
              luck: 43,
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

        final snapshot =
            WorldStateSnapshot.fromWorldState(original);

        final restored = snapshot.toWorldState();

        expect(
          restored.clock.currentYear,
          original.clock.currentYear,
        );

        expect(
          restored.player.id,
          original.player.id,
        );

        expect(
          restored.player.name,
          original.player.name,
        );

        expect(
          restored.player.gender,
          original.player.gender,
        );

        expect(
          restored.player.birthYear,
          original.player.birthYear,
        );

        expect(
          restored.player.stats.health,
          original.player.stats.health,
        );

        expect(
          restored.player.stats.intelligence,
          original.player.stats.intelligence,
        );

        expect(
          restored.player.stats.fitness,
          original.player.stats.fitness,
        );

        expect(
          restored.player.stats.happiness,
          original.player.stats.happiness,
        );

        expect(
          restored.player.stats.willpower,
          original.player.stats.willpower,
        );

        expect(
          restored.player.stats.charisma,
          original.player.stats.charisma,
        );

        expect(
          restored.player.stats.creativity,
          original.player.stats.creativity,
        );

        expect(
          restored.player.stats.luck,
          original.player.stats.luck,
        );

        expect(
          restored.player.money.minorUnits,
          original.player.money.minorUnits,
        );

        expect(
          restored.events.length,
          original.events.length,
        );

        expect(
          restored.events.first.id,
          original.events.first.id,
        );

        expect(
          restored.events.first.type,
          original.events.first.type,
        );

        expect(
          restored.events.first.year,
          original.events.first.year,
        );

        expect(
          restored.events.first.title,
          original.events.first.title,
        );

        expect(
          restored.events.first.description,
          original.events.first.description,
        );
      },
    );

    test(
      'serializes and deserializes all eight core stats',
      () {
        final original = WorldState(
          clock: const SimulationClock(
            currentYear: 2045,
          ),
          player: Character(
            id: 'character-2',
            name: 'Test Character',
            gender: Gender.female,
            birthYear: 2025,
            stats: const CharacterStats(
              health: 90,
              intelligence: 60,
              fitness: 80,
              happiness: 70,
              willpower: 65,
              charisma: 55,
              creativity: 45,
              luck: 35,
            ),
            money: const Money.fromMinorUnits(98765),
          ),
          events: const [
            SimulationEvent(
              id: 'event-2',
              type: SimulationEventType.randomEvent,
              year: 2045,
              title: 'Unexpected Event',
              description: 'Something unexpected happened.',
            ),
          ],
        );

        final snapshot =
            WorldStateSnapshot.fromWorldState(original);

        final json = snapshot.toJson();

        final restoredSnapshot =
            WorldStateSnapshot.fromJson(json);

        final restored =
            restoredSnapshot.toWorldState();

        expect(
          restored.clock.currentYear,
          2045,
        );

        expect(
          restored.player.id,
          'character-2',
        );

        expect(
          restored.player.name,
          'Test Character',
        );

        expect(
          restored.player.gender,
          Gender.female,
        );

        expect(
          restored.player.birthYear,
          2025,
        );

        expect(
          restored.player.stats.health,
          90,
        );

        expect(
          restored.player.stats.intelligence,
          60,
        );

        expect(
          restored.player.stats.fitness,
          80,
        );

        expect(
          restored.player.stats.happiness,
          70,
        );

        expect(
          restored.player.stats.willpower,
          65,
        );

        expect(
          restored.player.stats.charisma,
          55,
        );

        expect(
          restored.player.stats.creativity,
          45,
        );

        expect(
          restored.player.stats.luck,
          35,
        );

        expect(
          restored.player.money.minorUnits,
          98765,
        );

        expect(
          restored.events.single.type,
          SimulationEventType.randomEvent,
        );
      },
    );

    test(
      'rejects invalid current year',
      () {
        expect(
          () => WorldStateSnapshot.fromJson({
            'currentYear': '2050',
            'player': {
              'id': 'character-1',
              'name': 'Test',
              'gender': 'male',
              'birthYear': 2030,
              'stats': {
                'health': 100,
                'intelligence': 50,
                'fitness': 50,
                'happiness': 75,
                'willpower': 50,
                'charisma': 50,
                'creativity': 50,
                'luck': 50,
              },
              'moneyMinorUnits': 0,
            },
            'events': [],
          }),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'rejects unknown gender',
      () {
        expect(
          () => WorldStateSnapshot.fromJson({
            'currentYear': 2050,
            'player': {
              'id': 'character-1',
              'name': 'Test',
              'gender': 'unknown',
              'birthYear': 2030,
              'stats': {
                'health': 100,
                'intelligence': 50,
                'fitness': 50,
                'happiness': 75,
                'willpower': 50,
                'charisma': 50,
                'creativity': 50,
                'luck': 50,
              },
              'moneyMinorUnits': 0,
            },
            'events': [],
          }),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'rejects missing core stat',
      () {
        expect(
          () => WorldStateSnapshot.fromJson({
            'currentYear': 2050,
            'player': {
              'id': 'character-1',
              'name': 'Test',
              'gender': 'male',
              'birthYear': 2030,
              'stats': {
                'health': 100,
                'intelligence': 50,
                'fitness': 50,
                'happiness': 75,
                'willpower': 50,
                'charisma': 50,
                'creativity': 50,
              },
              'moneyMinorUnits': 0,
            },
            'events': [],
          }),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
