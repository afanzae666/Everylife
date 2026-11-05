import 'package:flutter/material.dart';

/// The four stats shown on the main screen.
enum CoreStatKind { happiness, health, smarts, looks }

extension CoreStatKindStyle on CoreStatKind {
  String get label => switch (this) {
        CoreStatKind.happiness => 'Happiness',
        CoreStatKind.health => 'Health',
        CoreStatKind.smarts => 'Smarts',
        CoreStatKind.looks => 'Looks',
      };

  /// The color of the label and the bar.
  Color get color => switch (this) {
        CoreStatKind.happiness => const Color(0xFFFFC42E),
        CoreStatKind.health => const Color(0xFF2ED8A3),
        CoreStatKind.smarts => const Color(0xFF22D3EE),
        CoreStatKind.looks => const Color(0xFFF472B6),
      };
}

/// How good a stat is, in five steps. The emoji changes with it.
enum StatMood { great, good, okay, poor, awful }

StatMood statMoodOf(int value) {
  if (value >= 80) return StatMood.great;
  if (value >= 60) return StatMood.good;
  if (value >= 40) return StatMood.okay;
  if (value >= 20) return StatMood.poor;

  return StatMood.awful;
}

/// The emoji for a stat value. Happiness, health, and smarts use
/// expressive faces; looks uses the weather scale
/// (1-20 storm, 21-40 cloud, 41-60 partly sunny, 61-80 sun, 81-100 fire).
String statEmojiFor(CoreStatKind kind, int value) {
  if (kind == CoreStatKind.looks) {
    if (value > 80) return '🔥';
    if (value > 60) return '☀️';
    if (value > 40) return '⛅';
    if (value > 20) return '☁️';

    return '⛈️';
  }

  final faces = switch (kind) {
    CoreStatKind.happiness => const ['😭', '😟', '😐', '😊', '🤩'],
    CoreStatKind.health => const ['🤒', '🤕', '😮‍💨', '😃', '💪'],
    _ => const ['🥴', '🥱', '🤔', '🤓', '🧠'],
  };

  return faces[switch (statMoodOf(value)) {
    StatMood.awful => 0,
    StatMood.poor => 1,
    StatMood.okay => 2,
    StatMood.good => 3,
    StatMood.great => 4,
  }];
}

/// A stat icon made of an emoji. The emoji changes with the value.
class StatIcon extends StatelessWidget {
  const StatIcon({
    required this.kind,
    required this.value,
    this.size = 28,
    super.key,
  });

  final CoreStatKind kind;
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          statEmojiFor(kind, value),
          style: TextStyle(fontSize: size * 0.85, height: 1.1),
        ),
      ),
    );
  }
}
