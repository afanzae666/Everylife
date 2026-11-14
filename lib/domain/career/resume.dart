/// What a line of the resume is about.
enum ResumeKind { school, job }

/// One line of the resume: a school or program attended, or a job held.
class ResumeEntry {
  const ResumeEntry({
    required this.kind,
    required this.title,
    required this.startYear,
    this.detail,
    this.place,
    this.endYear,
    this.outcome,
  });

  final ResumeKind kind;

  /// "High School", "University", or the job name.
  final String title;

  /// The major for a university line, the rank title for a job line.
  final String? detail;

  /// The school's name, once it is known.
  final String? place;

  final int startYear;

  /// Null while it is still going on.
  final int? endYear;

  /// "Graduated", "Left", "Retired"... Null while it is still going on.
  final String? outcome;

  bool get isOngoing => endYear == null;

  bool get isDegree =>
      kind == ResumeKind.school &&
      title == 'University' &&
      outcome == 'Graduated';

  ResumeEntry copyWith({
    String? detail,
    String? place,
    int? endYear,
    String? outcome,
  }) {
    return ResumeEntry(
      kind: kind,
      title: title,
      startYear: startYear,
      detail: detail ?? this.detail,
      place: place ?? this.place,
      endYear: endYear ?? this.endYear,
      outcome: outcome ?? this.outcome,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'title': title,
        'startYear': startYear,
        if (detail != null) 'detail': detail,
        if (place != null) 'place': place,
        if (endYear != null) 'endYear': endYear,
        if (outcome != null) 'outcome': outcome,
      };

  static ResumeEntry? fromJson(Object? json) {
    if (json is! Map) return null;

    final kindName = json['kind'];
    final title = json['title'];
    final start = json['startYear'];

    if (kindName is! String || title is! String || start is! int) return null;

    final kind = ResumeKind.values.where((k) => k.name == kindName);

    if (kind.isEmpty) return null;

    return ResumeEntry(
      kind: kind.first,
      title: title,
      startYear: start,
      detail: json['detail'] is String ? json['detail'] as String : null,
      place: json['place'] is String ? json['place'] as String : null,
      endYear: json['endYear'] is int ? json['endYear'] as int : null,
      outcome: json['outcome'] is String ? json['outcome'] as String : null,
    );
  }
}
