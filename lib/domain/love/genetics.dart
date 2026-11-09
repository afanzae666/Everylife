import '../../core/random/seeded_random.dart';

/// What a parent hands down.
class ParentGenes {
  const ParentGenes({
    required this.skinTone,
    required this.hairColor,
    required this.eyeColor,
    required this.eyebrows,
    required this.looks,
    required this.smarts,
    required this.fertility,
  });

  final String skinTone;
  final String hairColor;
  final String eyeColor;
  final String eyebrows;
  final int looks;
  final int smarts;

  /// Baseline fertility (not the age-adjusted one).
  final int fertility;
}

/// What a baby gets from its two parents.
class ChildGenes {
  const ChildGenes({
    required this.skinTone,
    required this.hairColor,
    required this.eyeColor,
    required this.eyebrows,
    required this.looks,
    required this.smarts,
    required this.fertility,
  });

  final String skinTone;
  final String hairColor;
  final String eyeColor;
  final String eyebrows;
  final int looks;
  final int smarts;
  final int fertility;
}

/// Inheritance: every trait of a child comes from its parents, never from
/// thin air. Colours and brows come from one parent or the other, skin tone
/// lands between the two, and the numbers sit near the parents' average with
/// a small random nudge.
abstract final class Genetics {
  /// Skin tones from lightest to darkest (the same order the avatar uses).
  static const List<String> skinScale = [
    'pale', 'very_light', 'light', 'light_medium', 'medium',
    'medium_tan', 'tan', 'deep_tan', 'brown', 'deep_brown',
    'dark', 'very_dark',
  ];

  static ChildGenes inherit(
    SeededRandom random,
    ParentGenes first,
    ParentGenes second,
  ) {
    String either(String a, String b) => random.nextInt(2) == 0 ? a : b;

    int blend(int a, int b, int low) {
      final nudge = random.nextInt(13) - 6;

      return (((a + b) / 2).round() + nudge).clamp(low, 100).toInt();
    }

    return ChildGenes(
      skinTone: _skin(random, first.skinTone, second.skinTone),
      hairColor: either(first.hairColor, second.hairColor),
      eyeColor: either(first.eyeColor, second.eyeColor),
      eyebrows: either(first.eyebrows, second.eyebrows),
      looks: blend(first.looks, second.looks, 15),
      smarts: blend(first.smarts, second.smarts, 15),
      fertility: blend(first.fertility, second.fertility, 60),
    );
  }

  static String _skin(SeededRandom random, String a, String b) {
    final i = skinScale.indexOf(a);
    final j = skinScale.indexOf(b);

    if (i < 0 || j < 0) return random.nextInt(2) == 0 ? a : b;

    final low = i < j ? i : j;
    final high = i < j ? j : i;

    return skinScale[low + random.nextInt(high - low + 1)];
  }
}
