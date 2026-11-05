import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/presentation/widgets/core_stat_bars.dart';
import 'package:everylife/presentation/widgets/stat_icons.dart';

void main() {
  test('stat mood follows the value in five steps', () {
    expect(statMoodOf(100), StatMood.great);
    expect(statMoodOf(80), StatMood.great);
    expect(statMoodOf(79), StatMood.good);
    expect(statMoodOf(60), StatMood.good);
    expect(statMoodOf(59), StatMood.okay);
    expect(statMoodOf(40), StatMood.okay);
    expect(statMoodOf(39), StatMood.poor);
    expect(statMoodOf(20), StatMood.poor);
    expect(statMoodOf(19), StatMood.awful);
    expect(statMoodOf(0), StatMood.awful);
  });

  test('looks follows fitness, charisma, and health', () {
    expect(
      const CharacterStats(fitness: 100, charisma: 100, health: 100).looks,
      100,
    );
    expect(
      const CharacterStats(fitness: 0, charisma: 0, health: 0).looks,
      0,
    );
    expect(
      const CharacterStats(fitness: 50, charisma: 50, health: 100).looks,
      60,
    );
    expect(
      const CharacterStats(fitness: 80).looks,
      greaterThan(const CharacterStats(fitness: 20).looks),
    );
  });

  test('looks uses the weather emoji scale', () {
    expect(statEmojiFor(CoreStatKind.looks, 1), '⛈️');
    expect(statEmojiFor(CoreStatKind.looks, 20), '⛈️');
    expect(statEmojiFor(CoreStatKind.looks, 21), '☁️');
    expect(statEmojiFor(CoreStatKind.looks, 40), '☁️');
    expect(statEmojiFor(CoreStatKind.looks, 41), '⛅');
    expect(statEmojiFor(CoreStatKind.looks, 60), '⛅');
    expect(statEmojiFor(CoreStatKind.looks, 61), '☀️');
    expect(statEmojiFor(CoreStatKind.looks, 80), '☀️');
    expect(statEmojiFor(CoreStatKind.looks, 81), '🔥');
    expect(statEmojiFor(CoreStatKind.looks, 100), '🔥');
  });

  test('other stats change their face with the value', () {
    for (final kind in [
      CoreStatKind.happiness,
      CoreStatKind.health,
      CoreStatKind.smarts,
    ]) {
      final faces = {
        for (final value in [5, 30, 50, 70, 90]) statEmojiFor(kind, value),
      };
      expect(faces, hasLength(5));
    }
  });

  testWidgets('every icon draws at every mood without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final kind in CoreStatKind.values)
                for (final value in [0, 10, 30, 50, 70, 90, 100])
                  StatIcon(kind: kind, value: value, size: 32),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(StatIcon), findsNWidgets(28));
  });

  testWidgets('the bars show label, percent, and a changing icon', (tester) async {
    Future<void> pumpStats(CharacterStats stats) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CoreStatBars(stats: stats, zoom: 1),
          ),
        ),
      );
    }

    await pumpStats(const CharacterStats(happiness: 47, health: 46, intelligence: 55));
    await tester.pumpAndSettle();

    expect(find.text('Happiness'), findsOneWidget);
    expect(find.text('Smarts'), findsOneWidget);
    expect(find.text('47%'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);

    // A very unhappy character is shown with the "awful" face.
    await pumpStats(const CharacterStats(happiness: 5));
    await tester.pumpAndSettle();

    final icon = tester.widget<StatIcon>(
      find.descendant(
        of: find.byKey(const Key('core-stat-happiness')),
        matching: find.byType(StatIcon),
      ),
    );

    expect(icon.value, 5);
    expect(statMoodOf(icon.value), StatMood.awful);
    expect(tester.takeException(), isNull);
  });
}
