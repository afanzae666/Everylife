/// The player's working life.
///
/// Money amounts are baseline minor units (US cents) per year. They are
/// scaled by the player's country cost of living when paid out.
class CareerState {
  const CareerState({
    this.jobId,
    this.rank = 0,
    this.salaryBase = 0,
    this.performance = 60,
    this.yearsInRole = 0,
    this.totalYearsWorked = 0,
    this.lastApplicationYear,
    this.lastRaiseRequestYear,
    this.retired = false,
    this.pensionBase = 0,
    this.partTimeId,
    this.gigYear,
    this.gigsDone = 0,
  });

  /// Id of the current job in the job catalog, or null when not employed.
  final String? jobId;

  /// 0 (entry level) to 3 (top of the ladder).
  final int rank;

  final int salaryBase;

  /// Work performance from 0 to 100.
  final int performance;

  final int yearsInRole;
  final int totalYearsWorked;
  final int? lastApplicationYear;
  final int? lastRaiseRequestYear;

  final bool retired;
  final int pensionBase;

  /// Id of the part-time job in the part-time catalog, or null.
  final String? partTimeId;

  /// The year [gigsDone] counts gigs for.
  final int? gigYear;

  /// Gigs done in [gigYear].
  final int gigsDone;

  bool get hasJob => jobId != null;

  bool get hasPartTime => partTimeId != null;

  /// Gigs done in [year] (zero when the counter belongs to another year).
  int gigsIn(int year) => gigYear == year ? gigsDone : 0;

  CareerState copyWith({
    String? jobId,
    bool clearJob = false,
    int? rank,
    int? salaryBase,
    int? performance,
    int? yearsInRole,
    int? totalYearsWorked,
    int? lastApplicationYear,
    int? lastRaiseRequestYear,
    bool? retired,
    int? pensionBase,
    String? partTimeId,
    bool clearPartTime = false,
    int? gigYear,
    int? gigsDone,
  }) {
    return CareerState(
      jobId: clearJob ? null : (jobId ?? this.jobId),
      rank: rank ?? this.rank,
      salaryBase: salaryBase ?? this.salaryBase,
      performance: (performance ?? this.performance).clamp(0, 100).toInt(),
      yearsInRole: yearsInRole ?? this.yearsInRole,
      totalYearsWorked: totalYearsWorked ?? this.totalYearsWorked,
      lastApplicationYear: lastApplicationYear ?? this.lastApplicationYear,
      lastRaiseRequestYear: lastRaiseRequestYear ?? this.lastRaiseRequestYear,
      retired: retired ?? this.retired,
      pensionBase: pensionBase ?? this.pensionBase,
      partTimeId: clearPartTime ? null : (partTimeId ?? this.partTimeId),
      gigYear: gigYear ?? this.gigYear,
      gigsDone: gigsDone ?? this.gigsDone,
    );
  }

  Map<String, dynamic> toJson() => {
        if (jobId != null) 'jobId': jobId,
        'rank': rank,
        'salaryBase': salaryBase,
        'performance': performance,
        'yearsInRole': yearsInRole,
        'totalYearsWorked': totalYearsWorked,
        if (lastApplicationYear != null)
          'lastApplicationYear': lastApplicationYear,
        if (lastRaiseRequestYear != null)
          'lastRaiseRequestYear': lastRaiseRequestYear,
        'retired': retired,
        'pensionBase': pensionBase,
        if (partTimeId != null) 'partTimeId': partTimeId,
        if (gigYear != null) 'gigYear': gigYear,
        if (gigsDone > 0) 'gigsDone': gigsDone,
      };

  factory CareerState.fromJson(Object? json) {
    if (json is! Map) return const CareerState();

    int intOr(Object? value, int fallback) => value is int ? value : fallback;

    return CareerState(
      jobId: json['jobId'] is String ? json['jobId'] as String : null,
      rank: intOr(json['rank'], 0).clamp(0, 3).toInt(),
      salaryBase: intOr(json['salaryBase'], 0).clamp(0, 1 << 40).toInt(),
      performance: intOr(json['performance'], 60).clamp(0, 100).toInt(),
      yearsInRole: intOr(json['yearsInRole'], 0),
      totalYearsWorked: intOr(json['totalYearsWorked'], 0),
      lastApplicationYear:
          json['lastApplicationYear'] is int ? json['lastApplicationYear'] as int : null,
      lastRaiseRequestYear: json['lastRaiseRequestYear'] is int
          ? json['lastRaiseRequestYear'] as int
          : null,
      retired: json['retired'] == true,
      pensionBase: intOr(json['pensionBase'], 0).clamp(0, 1 << 40).toInt(),
      partTimeId:
          json['partTimeId'] is String ? json['partTimeId'] as String : null,
      gigYear: json['gigYear'] is int ? json['gigYear'] as int : null,
      gigsDone: intOr(json['gigsDone'], 0).clamp(0, 1000).toInt(),
    );
  }
}
