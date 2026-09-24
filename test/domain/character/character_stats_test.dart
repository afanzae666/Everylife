import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character_stats.dart';

void main() {
  group('CharacterStats', () {
    test('uses the expected default values', () {
      const stats = CharacterStats();

      expect(stats.health, 100);
      expect(stats.happiness, 75);
      expect(stats.intelligence, 50);
      expect(stats.discipline, 50);
      expect(stats.empathy, 50);
      expect(stats.ambition, 50);
    });

    test('copyWith replaces only the supplied values', () {
      const original = CharacterStats();

      final updated = original.copyWith(
        health: 90,
        intelligence: 80,
      );

      expect(updated.health, 90);
      expect(updated.happiness, original.happiness);
      expect(updated.intelligence, 80);
      expect(updated.discipline, original.discipline);
      expect(updated.empathy, original.empathy);
      expect(updated.ambition, original.ambition);
    });

    test('copyWith with no arguments preserves every value', () {
      const original = CharacterStats(
        health: 91,
        happiness: 82,
        intelligence: 73,
        discipline: 64,
        empathy: 55,
        ambition: 46,
      );

      final copy = original.copyWith();

      expect(copy.health, original.health);
      expect(copy.happiness, original.happiness);
      expect(copy.intelligence, original.intelligence);
      expect(copy.discipline, original.discipline);
      expect(copy.empathy, original.empathy);
      expect(copy.ambition, original.ambition);
    });
  });
}
