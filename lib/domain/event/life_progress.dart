import '../career/career_state.dart';
import '../career/education_state.dart';

/// Flags that systems (not events) set and clear. Events may require them.
abstract final class SystemFlags {
  static const String employed = 'employed';
  static const String student = 'student';
  static const String graduatedHighSchool = 'graduated_high_school';
  static const String graduatedUniversity = 'graduated_university';
  static const String schoolDropout = 'school_dropout';
  static const String lostParent = 'lost_parent';
  static const String lostSibling = 'lost_sibling';
  static const String bankrupt = 'bankrupt';

  static const Set<String> all = {
    employed,
    student,
    graduatedHighSchool,
    graduatedUniversity,
    schoolDropout,
    lostParent,
    lostSibling,
    bankrupt,
  };
}

/// An event that was shown to the player and is waiting for a decision.
class PendingLifeEvent {
  const PendingLifeEvent({
    required this.eventId,
    required this.year,
    this.subject,
  });

  final String eventId;
  final int year;

  /// Who or what the event is about, for scripted events ("my father, Alex").
  final String? subject;

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'year': year,
        if (subject != null) 'subject': subject,
      };

  static PendingLifeEvent? fromJson(Object? json) {
    if (json is! Map) return null;

    final eventId = json['eventId'];
    final year = json['year'];

    if (eventId is! String || year is! int) return null;

    final subject = json['subject'];

    return PendingLifeEvent(
      eventId: eventId,
      year: year,
      subject: subject is String ? subject : null,
    );
  }
}

/// How and when a life ended.
class LifeEnding {
  const LifeEnding({
    required this.year,
    required this.age,
    required this.cause,
    this.netWorthMinorUnits = 0,
  });

  final int year;
  final int age;
  final String cause;

  /// Net worth in base minor units at the moment of death.
  final int netWorthMinorUnits;

  Map<String, dynamic> toJson() => {
        'year': year,
        'age': age,
        'cause': cause,
        'netWorthMinorUnits': netWorthMinorUnits,
      };

  static LifeEnding? fromJson(Object? json) {
    if (json is! Map) return null;

    final year = json['year'];
    final age = json['age'];
    final cause = json['cause'];
    final netWorth = json['netWorthMinorUnits'];

    if (year is! int || age is! int || cause is! String) return null;

    return LifeEnding(
      year: year,
      age: age,
      cause: cause,
      netWorthMinorUnits: netWorth is int ? netWorth : 0,
    );
  }
}

/// Everything the event system remembers about the player's life story.
class LifeProgress {
  const LifeProgress({
    this.flags = const <String>{},
    this.lastSeenYear = const <String, int>{},
    this.choices = const <String, String>{},
    this.pending,
    this.ending,
    this.education = const EducationState(),
    this.career = const CareerState(),
    this.interactionCounts = const <String, int>{},
  });

  /// Story flags set by earlier outcomes (for example "bullied").
  final Set<String> flags;

  /// Event id to the last year it appeared. Drives cooldowns.
  final Map<String, int> lastSeenYear;

  /// Event id to the choice id the player picked last time.
  final Map<String, String> choices;

  final PendingLifeEvent? pending;
  final LifeEnding? ending;

  /// Schooling progress.
  final EducationState education;

  /// Work, income, and retirement.
  final CareerState career;

  /// How often the player interacted with each family member this year.
  /// Keys look like "2031:parent-father-2000".
  final Map<String, int> interactionCounts;

  bool hasFlag(String flag) => flags.contains(flag);

  bool get isAlive => ending == null;

  LifeProgress copyWith({
    Set<String>? flags,
    Map<String, int>? lastSeenYear,
    Map<String, String>? choices,
    PendingLifeEvent? pending,
    bool clearPending = false,
    LifeEnding? ending,
    EducationState? education,
    CareerState? career,
    Map<String, int>? interactionCounts,
  }) {
    return LifeProgress(
      flags: flags ?? this.flags,
      lastSeenYear: lastSeenYear ?? this.lastSeenYear,
      choices: choices ?? this.choices,
      pending: clearPending ? null : (pending ?? this.pending),
      ending: ending ?? this.ending,
      education: education ?? this.education,
      career: career ?? this.career,
      interactionCounts: interactionCounts ?? this.interactionCounts,
    );
  }

  Map<String, dynamic> toJson() => {
        'flags': flags.toList()..sort(),
        'lastSeenYear': lastSeenYear,
        'choices': choices,
        if (pending != null) 'pending': pending!.toJson(),
        if (ending != null) 'ending': ending!.toJson(),
        'education': education.toJson(),
        'career': career.toJson(),
        'interactionCounts': interactionCounts,
      };

  /// Reads saved progress. Missing or malformed data (for example from a
  /// save created before this system existed) becomes an empty progress.
  factory LifeProgress.fromJson(Object? json) {
    if (json is! Map) return const LifeProgress();

    final rawFlags = json['flags'];
    final rawSeen = json['lastSeenYear'];
    final rawChoices = json['choices'];

    return LifeProgress(
      flags: rawFlags is List
          ? rawFlags.whereType<String>().toSet()
          : const <String>{},
      lastSeenYear: rawSeen is Map
          ? {
              for (final entry in rawSeen.entries)
                if (entry.key is String && entry.value is int)
                  entry.key as String: entry.value as int,
            }
          : const <String, int>{},
      choices: rawChoices is Map
          ? {
              for (final entry in rawChoices.entries)
                if (entry.key is String && entry.value is String)
                  entry.key as String: entry.value as String,
            }
          : const <String, String>{},
      pending: PendingLifeEvent.fromJson(json['pending']),
      ending: LifeEnding.fromJson(json['ending']),
      education: EducationState.fromJson(json['education']),
      career: CareerState.fromJson(json['career']),
      interactionCounts: json['interactionCounts'] is Map
          ? {
              for (final entry in (json['interactionCounts'] as Map).entries)
                if (entry.key is String && entry.value is int)
                  entry.key as String: entry.value as int,
            }
          : const <String, int>{},
    );
  }
}
