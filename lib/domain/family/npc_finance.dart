/// The real money of an NPC who has a job or savings. Amounts are in the
/// minor units of the NPC's country (already scaled by its cost of living).
///
/// An NPC with no finance (null) simply owns nothing: children, students.
class NpcFinance {
  const NpcFinance({
    this.jobId,
    this.rank = 0,
    this.startAge = 18,
    this.annualIncomeMinor = 0,
    this.cashMinor = 0,
  });

  /// Job in the catalog, or null for an adult without a job.
  final String? jobId;
  final int rank;

  /// Age when this NPC started working.
  final int startAge;

  /// Income per year (0 when jobless or retired).
  final int annualIncomeMinor;

  /// Savings. This is also the NPC's net worth.
  final int cashMinor;

  NpcFinance copyWith({
    int? rank,
    int? annualIncomeMinor,
    int? cashMinor,
  }) =>
      NpcFinance(
        jobId: jobId,
        rank: rank ?? this.rank,
        startAge: startAge,
        annualIncomeMinor: annualIncomeMinor ?? this.annualIncomeMinor,
        cashMinor: cashMinor ?? this.cashMinor,
      );

  Map<String, dynamic> toJson() => {
        if (jobId != null) 'jobId': jobId,
        'rank': rank,
        'startAge': startAge,
        'annualIncomeMinor': annualIncomeMinor,
        'cashMinor': cashMinor,
      };

  static NpcFinance? fromJson(Object? json) {
    if (json is! Map) return null;

    int number(Object? value, int fallback) =>
        value is int ? value : fallback;

    final job = json['jobId'];

    return NpcFinance(
      jobId: job is String ? job : null,
      rank: number(json['rank'], 0).clamp(0, 3).toInt(),
      startAge: number(json['startAge'], 18),
      annualIncomeMinor: number(json['annualIncomeMinor'], 0),
      cashMinor: number(json['cashMinor'], 0),
    );
  }
}
