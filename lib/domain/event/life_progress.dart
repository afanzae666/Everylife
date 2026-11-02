/// An event that was shown to the player and is waiting for a decision.
class PendingLifeEvent {
  const PendingLifeEvent({
    required this.eventId,
    required this.year,
  });

  final String eventId;
  final int year;

  Map<String, dynamic> toJson() => {'eventId': eventId, 'year': year};

  static PendingLifeEvent? fromJson(Object? json) {
    if (json is! Map) return null;

    final eventId = json['eventId'];
    final year = json['year'];

    if (eventId is! String || year is! int) return null;

    return PendingLifeEvent(eventId: eventId, year: year);
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
  });

  /// Story flags set by earlier outcomes (for example "bullied").
  final Set<String> flags;

  /// Event id to the last year it appeared. Drives cooldowns.
  final Map<String, int> lastSeenYear;

  /// Event id to the choice id the player picked last time.
  final Map<String, String> choices;

  final PendingLifeEvent? pending;
  final LifeEnding? ending;

  bool hasFlag(String flag) => flags.contains(flag);

  bool get isAlive => ending == null;

  LifeProgress copyWith({
    Set<String>? flags,
    Map<String, int>? lastSeenYear,
    Map<String, String>? choices,
    PendingLifeEvent? pending,
    bool clearPending = false,
    LifeEnding? ending,
  }) {
    return LifeProgress(
      flags: flags ?? this.flags,
      lastSeenYear: lastSeenYear ?? this.lastSeenYear,
      choices: choices ?? this.choices,
      pending: clearPending ? null : (pending ?? this.pending),
      ending: ending ?? this.ending,
    );
  }

  Map<String, dynamic> toJson() => {
        'flags': flags.toList()..sort(),
        'lastSeenYear': lastSeenYear,
        'choices': choices,
        if (pending != null) 'pending': pending!.toJson(),
        if (ending != null) 'ending': ending!.toJson(),
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
    );
  }
}
