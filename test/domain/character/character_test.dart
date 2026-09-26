import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/money/money.dart';
import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/character_stats.dart';

void main() {
  group('Character', () {
    test(
      'create uses the expected defaults',
      () {
        final character =
            Character.create(
          id: 'character-1',
          name: 'Alex',
          birthYear: 2026,
        );

        expect(
          character.id,
          'character-1',
        );

        expect(
          character.name,
          'Alex',
        );

        expect(
          character.resolvedFirstName,
          'Alex',
        );

        expect(
          character.resolvedLastName,
          '',
        );

        expect(
          character.fullName,
          'Alex',
        );

        expect(
          character.birthYear,
          2026,
        );

        expect(
          character.stats,
          const CharacterStats(),
        );

        expect(
          character.money,
          const Money.zero(),
        );
      },
    );

    test(
      'create stores first name and family name',
      () {
        final character =
            Character.create(
          id: 'character-2',
          firstName: 'Marshall',
          lastName: 'Royce',
          birthYear: 2026,
        );

        expect(
          character.firstName,
          'Marshall',
        );

        expect(
          character.lastName,
          'Royce',
        );

        expect(
          character.resolvedFirstName,
          'Marshall',
        );

        expect(
          character.resolvedLastName,
          'Royce',
        );

        expect(
          character.fullName,
          'Marshall Royce',
        );

        expect(
          character.name,
          'Marshall Royce',
        );
      },
    );

    test(
      'ageAt returns the elapsed years',
      () {
        final character =
            Character.create(
          id: 'character-1',
          name: 'Alex',
          birthYear: 2026,
        );

        expect(
          character.ageAt(2026),
          0,
        );

        expect(
          character.ageAt(2027),
          1,
        );

        expect(
          character.ageAt(2051),
          25,
        );
      },
    );

    test(
      'ageAt rejects a year before birth year',
      () {
        final character =
            Character.create(
          id: 'character-1',
          name: 'Alex',
          birthYear: 2026,
        );

        expect(
          () => character.ageAt(2025),
          throwsStateError,
        );
      },
    );

    test(
      'copyWith preserves unchanged values',
      () {
        final original =
            Character.create(
          id: 'character-1',
          firstName: 'Alex',
          lastName: 'Royce',
          birthYear: 2026,
        );

        final updated =
            original.copyWith(
          firstName: 'Jordan',
        );

        expect(
          updated.id,
          original.id,
        );

        expect(
          updated.firstName,
          'Jordan',
        );

        expect(
          updated.lastName,
          'Royce',
        );

        expect(
          updated.fullName,
          'Jordan Royce',
        );

        expect(
          updated.birthYear,
          original.birthYear,
        );

        expect(
          updated.stats,
          original.stats,
        );

        expect(
          updated.money,
          original.money,
        );
      },
    );

    test(
      'copyWith can replace stats and money',
      () {
        final original =
            Character.create(
          id: 'character-1',
          firstName: 'Alex',
          lastName: 'Royce',
          birthYear: 2026,
        );

        const stats = CharacterStats(
          health: 90,
          intelligence: 70,
          fitness: 80,
          happiness: 75,
          willpower: 60,
          charisma: 50,
          creativity: 40,
          luck: 30,
        );

        const money =
            Money.fromMinorUnits(
          1250,
        );

        final updated =
            original.copyWith(
          stats: stats,
          money: money,
        );

        expect(
          updated.stats,
          stats,
        );

        expect(
          updated.money,
          money,
        );
      },
    );
  });
}
