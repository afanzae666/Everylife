import 'gender.dart';

/// How fertile someone is. Everybody has a baseline (0 to 100) that they are
/// born with; the fertility shown in the game also follows age.
abstract final class Fertility {
  /// A steady baseline from a person's id (so the same person is always the
  /// same), from 60 to 100.
  static int baselineFor(String id) => 60 + _hash(id) % 41;

  /// Fertility now, from the baseline and age.
  static int effective(int baseline, int age, Gender gender) {
    final base = baseline.clamp(0, 100).toInt();

    if (age < 12) return 0;

    // Rising through the teens.
    if (age < 20) return (base * (age - 11) / 9).round();

    if (gender == Gender.female) {
      if (age <= 29) return base;

      final factor = 1 - (age - 29) * 0.045;

      return (base * factor.clamp(0.0, 1.0)).round();
    }

    if (age <= 39) return base;

    final factor = 1 - (age - 39) * 0.02;

    return (base * factor.clamp(0.3, 1.0)).round();
  }

  static int _hash(String text) {
    var hash = 2166136261;

    for (final unit in text.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x3fffffff;
    }

    return hash;
  }
}

/// Looks, smarts and fertility of a person who is not the player. They follow
/// from the person's id, so they never change between visits.
class NpcTraits {
  const NpcTraits({
    required this.looks,
    required this.smarts,
    required this.fertility,
    this.fertilityBase = 70,
  });

  final int looks;
  final int smarts;

  /// Fertility now (follows age).
  final int fertility;

  /// What they were born with.
  final int fertilityBase;

  factory NpcTraits.forPerson({
    required String id,
    required Gender gender,
    required int birthYear,
    required int currentYear,
  }) {
    final hash = Fertility._hash('traits|$id');
    final base = Fertility.baselineFor(id);

    return NpcTraits(
      looks: 35 + hash % 56,
      smarts: 35 + (hash ~/ 56) % 56,
      fertility: Fertility.effective(base, currentYear - birthYear, gender),
      fertilityBase: base,
    );
  }
}
