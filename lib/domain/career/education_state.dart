import 'major_catalog.dart';
import 'school_npc.dart';

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
    this.majorId,
    this.grades = 60,
    this.yearsInStage = 0,
    this.schoolName,
    this.isPrivateSchool = false,
    this.schoolStage = SchoolStage.none,
    this.npcs = const <SchoolNpc>[],
    this.lastStudyYear,
    this.club,
    this.lastClubYear,
    this.clubPerformance = 0,
    this.clubRank = 0,
    this.lastTrainYear,
    this.clubPromotion,
    this.sportsOffer,
  });

  /// False for lives that have not been processed yet. The first yearly
  /// update fills in schooling that matches the player's age, which also
  /// migrates saves created before this system existed.
  final bool initialized;

  final SchoolStage stage;
  final EducationLevel highest;

  /// The major being studied, or the one the degree is in.
  final String? majorId;

  /// Academic performance from 0 to 100.
  final int grades;

  final int yearsInStage;

  /// Name of the school or university, for example "Oakridge High School".
  final String? schoolName;

  /// A private school (otherwise a public one).
  final bool isPrivateSchool;

  /// The stage [schoolName] and [npcs] were made for. When the player moves
  /// to the next stage, a new school is made.
  final SchoolStage schoolStage;

  /// Classmates and faculty of the current school.
  final List<SchoolNpc> npcs;

  /// Last year the player used "Study Harder".
  final int? lastStudyYear;

  /// The extracurricular club joined this school year, and when.
  final String? club;
  final int? lastClubYear;

  /// How well the player does in the club, 0 to 100.
  final int clubPerformance;

  /// 0 member, 1 vice leader, 2 leader.
  final int clubRank;

  /// Last year the player trained with the club.
  final int? lastTrainYear;

  /// A rank (1 or 2) the player just earned and has not been told about yet.
  final int? clubPromotion;

  /// The sport club a university wants to recruit the player for, after
  /// high school. Gone once the player enrolls or the year passes.
  final String? sportsOffer;

  Iterable<SchoolNpc> get classmates =>
      npcs.where((npc) => npc.role == SchoolRole.classmate);

  Iterable<SchoolNpc> get faculty => npcs.where((npc) => npc.role.isFaculty);

  bool get isStudent => stage != SchoolStage.none;

  /// The major, when [majorId] is set.
  MajorDefinition? get major => MajorCatalog.byId(majorId);

  /// How many years the current university program lasts.
  int get programYears => major?.years ?? MajorCatalog.defaultYears;

  /// The field of the degree, when there is one.
  StudyField? get degreeField =>
      highest == EducationLevel.bachelor ? major?.field : null;

  EducationState copyWith({
    bool? initialized,
    SchoolStage? stage,
    EducationLevel? highest,
    String? majorId,
    bool clearMajor = false,
    int? grades,
    int? yearsInStage,
    String? schoolName,
    bool? isPrivateSchool,
    SchoolStage? schoolStage,
    List<SchoolNpc>? npcs,
    int? lastStudyYear,
    String? club,
    int? lastClubYear,
    int? clubPerformance,
    int? clubRank,
    int? lastTrainYear,
    int? clubPromotion,
    bool clearClubPromotion = false,
    bool clearClub = false,
    String? sportsOffer,
    bool clearSportsOffer = false,
  }) {
    return EducationState(
      initialized: initialized ?? this.initialized,
      stage: stage ?? this.stage,
      highest: highest ?? this.highest,
      majorId: clearMajor ? null : (majorId ?? this.majorId),
      grades: (grades ?? this.grades).clamp(0, 100).toInt(),
      yearsInStage: yearsInStage ?? this.yearsInStage,
      schoolName: schoolName ?? this.schoolName,
      isPrivateSchool: isPrivateSchool ?? this.isPrivateSchool,
      schoolStage: schoolStage ?? this.schoolStage,
      npcs: List.unmodifiable(npcs ?? this.npcs),
      lastStudyYear: lastStudyYear ?? this.lastStudyYear,
      club: clearClub ? null : (club ?? this.club),
      lastClubYear: lastClubYear ?? this.lastClubYear,
      clubPerformance: clearClub
          ? 0
          : (clubPerformance ?? this.clubPerformance).clamp(0, 100).toInt(),
      clubRank: clearClub ? 0 : (clubRank ?? this.clubRank),
      lastTrainYear: lastTrainYear ?? this.lastTrainYear,
      clubPromotion: clearClub || clearClubPromotion
          ? null
          : (clubPromotion ?? this.clubPromotion),
      sportsOffer: clearSportsOffer ? null : (sportsOffer ?? this.sportsOffer),
    );
  }

  Map<String, dynamic> toJson() => {
        'initialized': initialized,
        'stage': stage.name,
        'highest': highest.name,
        if (majorId != null) 'majorId': majorId,
        'grades': grades,
        'yearsInStage': yearsInStage,
        if (schoolName != null) 'schoolName': schoolName,
        if (isPrivateSchool) 'privateSchool': true,
        'schoolStage': schoolStage.name,
        if (npcs.isNotEmpty) 'npcs': [for (final npc in npcs) npc.toJson()],
        if (lastStudyYear != null) 'lastStudyYear': lastStudyYear,
        if (club != null) 'club': club,
        if (lastClubYear != null) 'lastClubYear': lastClubYear,
        if (club != null) 'clubPerformance': clubPerformance,
        if (club != null && clubRank != 0) 'clubRank': clubRank,
        if (lastTrainYear != null) 'lastTrainYear': lastTrainYear,
        if (clubPromotion != null) 'clubPromotion': clubPromotion,
        if (sportsOffer != null) 'sportsOffer': sportsOffer,
      };

  factory EducationState.fromJson(Object? json) {
    if (json is! Map) return const EducationState();

    final grades = json['grades'];
    final years = json['yearsInStage'];

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
      majorId: json['majorId'] is String ? json['majorId'] as String : null,
      grades: grades is int ? grades.clamp(0, 100).toInt() : 60,
      yearsInStage: years is int ? years : 0,
      schoolName: json['schoolName'] is String ? json['schoolName'] as String : null,
      isPrivateSchool: json['privateSchool'] == true,
      schoolStage: _enumByName(
        SchoolStage.values,
        json['schoolStage'],
        SchoolStage.none,
        legacy: _legacyNames,
      ),
      npcs: [
        if (json['npcs'] is List)
          for (final raw in json['npcs'] as List)
            if (SchoolNpc.fromJson(raw) case final npc?) npc,
      ],
      lastStudyYear: json['lastStudyYear'] is int ? json['lastStudyYear'] as int : null,
      club: json['club'] is String ? json['club'] as String : null,
      lastClubYear: json['lastClubYear'] is int ? json['lastClubYear'] as int : null,
      clubPerformance: json['clubPerformance'] is int
          ? (json['clubPerformance'] as int).clamp(0, 100).toInt()
          : 0,
      clubRank: json['clubRank'] is int ? json['clubRank'] as int : 0,
      lastTrainYear:
          json['lastTrainYear'] is int ? json['lastTrainYear'] as int : null,
      clubPromotion:
          json['clubPromotion'] is int ? json['clubPromotion'] as int : null,
      sportsOffer:
          json['sportsOffer'] is String ? json['sportsOffer'] as String : null,
    );
  }
}
