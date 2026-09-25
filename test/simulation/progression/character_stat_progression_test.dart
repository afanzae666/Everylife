import 'package:flutter_test/flutter_test.dart';

import '../../../lib/domain/character/character_stats.dart';
import '../../../lib/domain/character/life_stage.dart';
import '../../../lib/simulation/progression/character_stat_progression.dart';

void main() {
  const progression = CharacterStatProgression();

  group('CharacterStatProgression', () {
    test('improves child core stats', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.child,
      );

      expect(result.health, 51);
      expect(result.happiness, 51);
      expect(result.intelligence, 52);
      expect(result.fitness, 51);
      expect(result.willpower, 51);
      expect(result.charisma, 51);
      expect(result.creativity, 51);
      expect(result.luck, 50);
    });

    test('improves teen core stats', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.teen,
      );

      expect(result.health, 51);
      expect(result.happiness, 50);
      expect(result.intelligence, 52);
      expect(result.fitness, 51);
      expect(result.willpower, 51);
      expect(result.charisma, 51);
      expect(result.creativity, 52);
      expect(result.luck, 50);
    });

    test('adult progression changes health and fitness', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.adult,
      );

      expect(result.health, 49);
      expect(result.happiness, 50);
      expect(result.intelligence, 50);
      expect(result.fitness, 49);
      expect(result.willpower, 50);
      expect(result.charisma, 50);
      expect(result.creativity, 50);
      expect(result.luck, 50);
    });

    test('senior progression decreases health, fitness and creativity', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.senior,
      );

      expect(result.health, 48);
      expect(result.happiness, 51);
      expect(result.intelligence, 50);
      expect(result.fitness, 48);
      expect(result.willpower, 50);
      expect(result.charisma, 51);
      expect(result.creativity, 49);
      expect(result.luck, 50);
    });

    test('stats never exceed 100', () {
      const stats = CharacterStats(
        health: 100,
        happiness: 100,
        intelligence: 100,
        fitness: 100,
        willpower: 100,
        charisma: 100,
        creativity: 100,
        luck: 100,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.child,
      );

      expect(result.health, 100);
      expect(result.happiness, 100);
      expect(result.intelligence, 100);
      expect(result.fitness, 100);
      expect(result.willpower, 100);
      expect(result.charisma, 100);
      expect(result.creativity, 100);
      expect(result.luck, 100);
    });

    test('stats never fall below 0', () {
      const stats = CharacterStats(
        health: 0,
        happiness: 0,
        intelligence: 0,
        fitness: 0,
        willpower: 0,
        charisma: 0,
        creativity: 0,
        luck: 0,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.senior,
      );

      expect(result.health, 0);
      expect(result.happiness, 1);
      expect(result.intelligence, 0);
      expect(result.fitness, 0);
      expect(result.willpower, 0);
      expect(result.charisma, 1);
      expect(result.creativity, 0);
      expect(result.luck, 0);
    });

    test('does not mutate original stats', () {
      const stats = CharacterStats(
        health: 50,
        happiness: 50,
        intelligence: 50,
        fitness: 50,
        willpower: 50,
        charisma: 50,
        creativity: 50,
        luck: 50,
      );

      final result = progression.apply(
        stats: stats,
        stage: LifeStage.child,
      );

      expect(stats.health, 50);
      expect(stats.intelligence, 50);
      expect(stats.fitness, 50);
      expect(stats.willpower, 50);
      expect(stats.charisma, 50);
      expect(stats.creativity, 50);
      expect(stats.luck, 50);

      expect(result.health, 51);
      expect(result.intelligence, 52);
    });
  });
}
