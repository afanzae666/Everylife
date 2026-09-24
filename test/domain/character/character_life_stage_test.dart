import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character.dart';
import '../../../lib/domain/character/life_stage.dart';

void main() {
  group('Character.lifeStageAt', () {
    test('returns infant for age 0', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 2026,
      );

      expect(character.lifeStageAt(2026), LifeStage.infant);
    });

    test('returns child for age 6', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 2020,
      );

      expect(character.lifeStageAt(2026), LifeStage.child);
    });

    test('returns teen for age 13', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 2013,
      );

      expect(character.lifeStageAt(2026), LifeStage.teen);
    });

    test('returns young adult for age 18', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 2008,
      );

      expect(character.lifeStageAt(2026), LifeStage.youngAdult);
    });

    test('returns adult for age 30', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 1996,
      );

      expect(character.lifeStageAt(2026), LifeStage.adult);
    });

    test('returns senior for age 60', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 1966,
      );

      expect(character.lifeStageAt(2026), LifeStage.senior);
    });

    test('rejects a year before the character birth year', () {
      final character = Character.create(
        id: 'character-1',
        name: 'Test Character',
        birthYear: 2026,
      );

      expect(
        () => character.lifeStageAt(2025),
        throwsStateError,
      );
    });
  });
}
