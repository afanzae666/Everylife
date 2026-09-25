import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/character/character_stats.dart';

void main() {
  group('CharacterStats', () {
    test(
      'contains the eight core stats',
      () {
        const stats = CharacterStats();

        expect(stats.health, 100);
        expect(stats.intelligence, 50);
        expect(stats.fitness, 50);
        expect(stats.happiness, 75);
        expect(stats.willpower, 50);
        expect(stats.charisma, 50);
        expect(stats.creativity, 50);
        expect(stats.luck, 50);
      },
    );

    test(
      'copyWith changes only the requested stats',
      () {
        const stats = CharacterStats();

        final updated = stats.copyWith(
          health: 80,
          fitness: 90,
          creativity: 65,
        );

        expect(updated.health, 80);
        expect(updated.intelligence, 50);
        expect(updated.fitness, 90);
        expect(updated.happiness, 75);
        expect(updated.willpower, 50);
        expect(updated.charisma, 50);
        expect(updated.creativity, 65);
        expect(updated.luck, 50);
      },
    );

    test(
      'clamps stats below zero',
      () {
        const stats = CharacterStats();

        final updated = stats.copyWith(
          health: -10,
          fitness: -1,
          luck: -100,
        );

        expect(
          updated.health,
          CharacterStats.minimum,
        );

        expect(
          updated.fitness,
          CharacterStats.minimum,
        );

        expect(
          updated.luck,
          CharacterStats.minimum,
        );
      },
    );

    test(
      'clamps stats above one hundred',
      () {
        const stats = CharacterStats();

        final updated = stats.copyWith(
          health: 101,
          intelligence: 150,
          charisma: 1000,
        );

        expect(
          updated.health,
          CharacterStats.maximum,
        );

        expect(
          updated.intelligence,
          CharacterStats.maximum,
        );

        expect(
          updated.charisma,
          CharacterStats.maximum,
        );
      },
    );

    test(
      'keeps valid values unchanged',
      () {
        const stats = CharacterStats();

        final updated = stats.copyWith(
          health: 0,
          intelligence: 1,
          fitness: 50,
          happiness: 99,
          willpower: 100,
          charisma: 25,
          creativity: 75,
          luck: 42,
        );

        expect(updated.health, 0);
        expect(updated.intelligence, 1);
        expect(updated.fitness, 50);
        expect(updated.happiness, 99);
        expect(updated.willpower, 100);
        expect(updated.charisma, 25);
        expect(updated.creativity, 75);
        expect(updated.luck, 42);
      },
    );
  });
}
