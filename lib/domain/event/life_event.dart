import '../character/character_stats.dart';

/// Player stats that an event outcome can change.
enum StatKey {
  health,
  intelligence,
  fitness,
  happiness,
  willpower,
  charisma,
  creativity,
  luck,
}

extension StatKeyValue on CharacterStats {
  int valueOf(StatKey key) {
    return switch (key) {
      StatKey.health => health,
      StatKey.intelligence => intelligence,
      StatKey.fitness => fitness,
      StatKey.happiness => happiness,
      StatKey.willpower => willpower,
      StatKey.charisma => charisma,
      StatKey.creativity => creativity,
      StatKey.luck => luck,
    };
  }
}

/// A change applied to one stat. Results are clamped to 0-100.
class StatEffect {
  const StatEffect(this.stat, this.delta);

  final StatKey stat;
  final int delta;
}

/// A stat range an event needs before it can appear.
class StatRequirement {
  const StatRequirement(
    this.stat, {
    this.min,
    this.max,
  });

  final StatKey stat;
  final int? min;
  final int? max;

  bool isMetBy(CharacterStats stats) {
    final value = stats.valueOf(stat);

    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;

    return true;
  }
}

/// One possible result of a choice (or of an automatic event).
///
/// When a choice has several outcomes, one is picked by [weight]. That is
/// where risk and luck come from: a bold choice can pay off or backfire.
class LifeOutcome {
  const LifeOutcome({
    required this.text,
    this.weight = 1,
    this.stats = const <StatEffect>[],
    this.moneyBase = 0,
    this.addFlags = const <String>[],
    this.removeFlags = const <String>[],
  });

  /// First-person result text shown to the player.
  final String text;

  /// Relative chance among the sibling outcomes. Must be positive.
  final int weight;

  final List<StatEffect> stats;

  /// Money change in baseline minor units (US cents). It is scaled by the
  /// player's country cost of living when applied. Negative spends money.
  final int moneyBase;

  final List<String> addFlags;
  final List<String> removeFlags;
}

class LifeChoice {
  const LifeChoice({
    required this.id,
    required this.label,
    required this.outcomes,
    this.requiresMoneyBase = 0,
  });

  final String id;
  final String label;
  final List<LifeOutcome> outcomes;

  /// Money the player must hold (baseline minor units) to pick this choice.
  final int requiresMoneyBase;
}

class LifeEventDefinition {
  const LifeEventDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.minAge,
    required this.maxAge,
    this.weight = 10,
    this.cooldownYears = 4,
    this.oncePerLife = false,
    this.requiredFlags = const <String>[],
    this.forbiddenFlags = const <String>[],
    this.statRequirements = const <StatRequirement>[],
    this.needsLivingParent = false,
    this.needsLivingSibling = false,
    this.choices = const <LifeChoice>[],
    this.autoOutcomes = const <LifeOutcome>[],
  });

  final String id;
  final String title;

  /// First-person scene text.
  final String description;

  final int minAge;
  final int maxAge;

  /// Relative chance of being picked among eligible events.
  final int weight;

  /// Minimum years before the same event can appear again.
  final int cooldownYears;

  final bool oncePerLife;

  final List<String> requiredFlags;
  final List<String> forbiddenFlags;
  final List<StatRequirement> statRequirements;

  final bool needsLivingParent;
  final bool needsLivingSibling;

  /// Player decisions. When empty, [autoOutcomes] are applied automatically.
  final List<LifeChoice> choices;
  final List<LifeOutcome> autoOutcomes;
}

/// What the player sees after resolving a choice.
class LifeChoiceResult {
  const LifeChoiceResult({
    required this.eventTitle,
    required this.choiceLabel,
    required this.resultText,
  });

  final String eventTitle;
  final String choiceLabel;
  final String resultText;
}
