import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character_stats.dart';
import '../../../lib/domain/character/life_stage.dart';
import '../../../lib/simulation/progression/character_stat_progression.dart';

void main() {
  const progression = CharacterStatProgression();

  group('CharacterStatProgression', () {
    test('improves child development stats', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.child,
      );

      expect(result.health, 51);
      expect(result.happiness, 51);
      expect(result.intelligence, 52);
      expect(result.discipline, 51);
      expect(result.empathy, 51);
      expect(result.ambition, 51);
    });

    test('improves teen development according to teen progression', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.teen,
      );

      expect(result.health, 51);
      expect(result.happiness, 50);
      expect(result.intelligence, 52);
      expect(result.discipline, 51);
      expect(result.empathy, 51);
      expect(result.ambition, 52);
    });

    test('adult progression decreases health without changing other stats', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.adult,
      );

      expect(result.health, 49);
      expect(result.happiness, 50);
      expect(result.intelligence, 50);
      expect(result.discipline, 50);
      expect(result.empathy, 50);
      expect(result.ambition, 50);
    });

    test('senior progression decreases health and ambition', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.senior,
      );

      expect(result.health, 48);
      expect(result.happiness, 51);
      expect(result.intelligence, 50);
      expect(result.discipline, 50);
      expect(result.empathy, 51);
      expect(result.ambition, 49);
    });

    test('stats never exceed 100', () {
      const stats = CharacterStats(
        health: 100,
        happiness: 100,
        intelligence: 100,
        discipline: 100,
        empathy: 100,
        ambition: 100,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.child,
      );

      expect(result.health, 100);
      expect(result.happiness, 100);
      expect(result.intelligence, 100);
      expect(result.discipline, 100);
      expect(result.empathy, 100);
      expect(result.ambition, 100);
    });

    test('stats never fall below 0', () {
      const stats = CharacterStats(
        health: 0,
        happiness: 0,
        intelligence: 0,
        discipline: 0,
        empathy: 0,
        ambition: 0,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.senior,
      );

      expect(result.health, 0);
      expect(result.happiness, 1);
      expect(result.intelligence, 0);
      expect(result.discipline, 0);
      expect(result.empathy, 1);
      expect(result.ambition, 0);
    });

    test('does not mutate the original stats', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        discipline: 50,
        empathy: 50,
        ambition: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.child,
      );

      expect(stats.health, 50);
      expect(stats.happiness, 50);
      expect(stats.intelligence, 50);
      expect(stats.discipline, 50);
      expect(stats.empathy, 50);
      expect(stats.ambition, 50);

      expect(result.health, 51);
      expect(result.intelligence, 52);
    });
  });
}
