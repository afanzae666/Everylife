import 'package:flutter_test/flutter_test.dart';

import '../../../lib/data/repositories/save_repository.dart';
import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/event/simulation_event.dart';
import '../../../lib/simulation/engine/simulation_engine.dart';

void main() {
  group('SimulationEngine ageUp', () {
    test('advances the year and character age', () {
      final player = Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2026,
      );

      final engine = SimulationEngine.create(
        player: player,
        seed: 42,
        saveRepository: InMemorySaveRepository(),
      );

      expect(engine.state.clock.currentYear, 2026);
      expect(engine.state.player.ageAt(2026), 0);
      expect(engine.state.events.length, 1);

      final result = engine.ageUp();

      expect(result.isSuccess, isTrue);
      expect(engine.state.clock.currentYear, 2027);
      expect(engine.state.player.ageAt(2027), 1);
    });

    test('creates a character aged event after ageUp', () {
      final player = Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2026,
      );

      final engine = SimulationEngine.create(
        player: player,
        seed: 42,
        saveRepository: InMemorySaveRepository(),
      );

      final result = engine.ageUp();

      expect(result.isSuccess, isTrue);
      expect(engine.state.events.length, 2);

      final event = engine.state.events.last;

      expect(event.id, 'character-aged-2027');
      expect(event.type, SimulationEventType.characterAged);
      expect(event.year, 2027);
      expect(event.title, 'Another year passes');
      expect(
        event.description,
        'Test Player is now 1 years old.',
      );
    });

    test('increments the tick id after a successful ageUp', () {
      final player = Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2026,
      );

      final engine = SimulationEngine.create(
        player: player,
        seed: 42,
        saveRepository: InMemorySaveRepository(),
      );

      expect(engine.nextTickId, 1);

      final result = engine.ageUp();

      expect(result.isSuccess, isTrue);
      expect(engine.nextTickId, 2);
    });
  });
}
