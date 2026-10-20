
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/starting_background.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/simulation/generation/starting_life_event_generator.dart';

void main() {
  group('StartingLifeEventGenerator', () {
    test('generates a starting life event for the given background', () {
      final event = StartingLifeEventGenerator.generate(
        random: SeededRandom(42),
        year: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.middleClass,
        ),
      );

      expect(event.id, 'starting-life-event-2026');
      expect(event.type, SimulationEventType.startingLifeEvent);
      expect(event.year, 2026);
      expect(event.title, isNotEmpty);
      expect(event.description, isNotEmpty);
    });

    test('generates the same event for the same seed and background', () {
      final first = StartingLifeEventGenerator.generate(
        random: SeededRandom(42),
        year: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.wealthy,
        ),
      );

      final second = StartingLifeEventGenerator.generate(
        random: SeededRandom(42),
        year: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.wealthy,
        ),
      );

      expect(second.title, first.title);
      expect(second.description, first.description);
      expect(second.id, first.id);
      expect(second.type, first.type);
    });

    test('uses event templates associated with the background tier', () {
      final event = StartingLifeEventGenerator.generate(
        random: SeededRandom(7),
        year: 2026,
        background: const StartingBackground(
          tier: StartingBackgroundTier.veryWealthy,
        ),
      );

      expect(
        event.title,
        anyOf(
          'Born into Great Wealth',
          'Exceptional Opportunities',
          'A Highly Privileged Start',
        ),
      );
    });
  });
}
