/// Where the player currently studies.
///
/// School runs from age 6 to 17: elementary (6-11), middle (12-14) and high
/// school (15-17). University is optional after graduating at 18.
enum SchoolStage { none, elementary, middle, high, university }

/// The highest level the player has completed.
enum EducationLevel { none, elementary, middle, highSchool, bachelor }

/// Stage names used by saves made before the three-school system.
const Map<String, String> _legacyNames = {
  'primary': 'elementary',
  'secondary': 'high',
};

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback,
    {Map<String, String> legacy = const {}}) {
  if (name is! String) return fallback;

  final key = legacy[name] ?? name;

  for (final value in values) {
    if (value.name == key) return value;
  }

  return fallback;
}

/// Schooling progress, updated once a year by the education system.
class EducationState {
  const EducationState({
    this.initialized = false,
    this.stage = SchoolStage.none,
    this.highest = EducationLevel.none,
    this.grades = 60,
    this.yearsInStage = 0,
    this.lastUniversityApplicationYear,
  });

  /// False for lives that have not been processed yet. The first yearly
  /// update fills in schooling that matches the player's age, which also
  /// migrates saves created before this system existed.
  final bool initialized;

  final SchoolStage stage;
  final EducationLevel highest;

  /// Academic performance from 0 to 100.
  final int grades;

  final int yearsInStage;
  final int? lastUniversityApplicationYear;

  bool get isStudent => stage != SchoolStage.none;

  EducationState copyWith({
    bool? initialized,
    SchoolStage? stage,
    EducationLevel? highest,
    int? grades,
    int? yearsInStage,
    int? lastUniversityApplicationYear,
  }) {
    return EducationState(
      initialized: initialized ?? this.initialized,
      stage: stage ?? this.stage,
      highest: highest ?? this.highest,
      grades: (grades ?? this.grades).clamp(0, 100).toInt(),
      yearsInStage: yearsInStage ?? this.yearsInStage,
      lastUniversityApplicationYear:
          lastUniversityApplicationYear ?? this.lastUniversityApplicationYear,
    );
  }

  Map<String, dynamic> toJson() => {
        'initialized': initialized,
        'stage': stage.name,
        'highest': highest.name,
        'grades': grades,
        'yearsInStage': yearsInStage,
        if (lastUniversityApplicationYear != null)
          'lastUniversityApplicationYear': lastUniversityApplicationYear,
      };

  factory EducationState.fromJson(Object? json) {
    if (json is! Map) return const EducationState();

    final grades = json['grades'];
    final years = json['yearsInStage'];
    final applied = json['lastUniversityApplicationYear'];

    return EducationState(
      initialized: json['initialized'] == true,
      stage: _enumByName(
        SchoolStage.values,
        json['stage'],
        SchoolStage.none,
        legacy: _legacyNames,
      ),
      highest: _enumByName(
        EducationLevel.values,
        json['highest'],
        EducationLevel.none,
        legacy: const {
          'primary': 'elementary',
          'secondary': 'highSchool',
        },
      ),
      grades: grades is int ? grades.clamp(0, 100).toInt() : 60,
      yearsInStage: years is int ? years : 0,
      lastUniversityApplicationYear: applied is int ? applied : null,
    );
  }
}
