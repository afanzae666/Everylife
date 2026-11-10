import '../character/character_stats.dart';
import '../character/gender.dart';
import 'life_progress.dart';

/// Who a life event is about. The game picks a real person of that kind
/// (a living parent, an actual classmate, ...) when the event starts, so the
/// text can name them and the pop-up can show their avatar.
enum EventSubjectKind {
  none,
  parent,
  sibling,
  classmate,
  teacher,
  stranger,
  coworker,
  friend,

  /// The player's partner (boyfriend, girlfriend, fiancé(e) or spouse).
  partner,
}

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
    this.parentRelation = 0,
    this.siblingRelation = 0,
    this.subjectRelation = 0,
    this.makesFriend = false,
    this.losesFriend = false,
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

  /// Change to the relationship score with every living parent.
  final int parentRelation;

  /// Change to the relationship score with every living, born sibling.
  final int siblingRelation;

  /// Change to the relationship score with the person the event is about
  /// (see [LifeEventDefinition.about]) and nobody else.
  final int subjectRelation;

  /// The person the event is about becomes a friend.
  final bool makesFriend;

  /// The person the event is about stops being a friend.
  final bool losesFriend;
}

class LifeChoice {
  const LifeChoice({
    required this.id,
    required this.label,
    required this.outcomes,
    this.requiresMoneyBase = 0,
    this.narration,
  });

  final String id;
  final String label;
  final List<LifeOutcome> outcomes;

  /// Optional first-person sentence that tells what I did. When missing, it
  /// is made from [label] (see [story]).
  final String? narration;

  /// What I did, as a sentence in the story. Button labels are commands
  /// ("Join the team"); the story says "I join the team." so the event text
  /// reads as one flowing paragraph without an "I chose to:" prefix.
  String get story {
    final custom = narration;

    if (custom != null && custom.trim().isNotEmpty) return custom;

    final text = label.trim();

    if (text.isEmpty) return '';

    final lowered = text[0].toLowerCase() + text.substring(1);
    final sentence = 'I $lowered';

    return sentence.endsWith('.') ||
            sentence.endsWith('!') ||
            sentence.endsWith('?')
        ? sentence
        : '$sentence.';
  }

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
    this.scripted = false,
    this.about = EventSubjectKind.none,
  });

  final String id;
  final String title;

  /// The kind of person this event is about. Text may use `{name}`,
  /// `{first}`, `{role}`, `{Role}`, `{he}`, `{He}`, `{him}`, `{his}`, `{His}`.
  final EventSubjectKind about;

  /// Scripted events are started by game systems (for example a funeral),
  /// never drawn at random.
  final bool scripted;

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

/// Fills the `{who}` placeholder that scripted events use for the person the
/// event is about (for example "my father, Alex Rivera").
abstract final class LifeText {
  static String fill(String text, String? subject) {
    return text.replaceAll('{who}', subject ?? 'someone close to me');
  }

  /// Fills every placeholder from the person a pending event is about.
  static String fillPending(String text, PendingLifeEvent? pending) {
    var out = fill(text, pending?.subject);

    final name = pending?.subjectName;

    if (pending == null || name == null) return out;

    final first = pending.subjectFirst ?? name;
    final role = pending.subjectRole ?? 'someone';
    final female = pending.subjectGender == Gender.female.name;

    final replacements = <String, String>{
      '{name}': name,
      '{Name}': name,
      '{first}': first,
      '{role}': role,
      '{Role}': role[0].toUpperCase() + role.substring(1),
      '{he}': female ? 'she' : 'he',
      '{He}': female ? 'She' : 'He',
      '{him}': female ? 'her' : 'him',
      '{his}': female ? 'her' : 'his',
      '{His}': female ? 'Her' : 'His',
    };

    replacements.forEach((key, value) => out = out.replaceAll(key, value));

    return out;
  }
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
