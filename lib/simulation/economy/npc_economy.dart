import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/family/npc_finance.dart';
import '../generation/country_economic_profile.dart';

/// The yearly money rules for NPCs. Everything here is deterministic, so a
/// saved life always replays the same way.
abstract final class NpcEconomy {
  /// Share of a year's income an NPC puts into savings.
  static const int savingsPercent = 15;

  /// NPCs stop earning from this age.
  static const int retirementAge = 65;

  static const int _promotionEveryYears = 7;

  static int _seed(String id) {
    var seed = 11;

    for (final unit in id.codeUnits) {
      seed = (seed * 31 + unit) & 0x3fffffff;
    }

    return seed;
  }

  static int _rankAt({
    required int yearsWorked,
    required int minRank,
  }) {
    final byYears = (yearsWorked ~/ _promotionEveryYears).clamp(0, 3).toInt();

    return byYears < minRank ? minRank : byYears;
  }

  static int _incomeFor({
    required JobDefinition job,
    required int rank,
    required String countryCode,
  }) {
    return CountryEconomicProfile.forCountryCode(countryCode)
        .scaleAmount(job.salaryAt(rank));
  }

  static int _minRankFor(String jobId) => switch (jobId) {
        'principal' || 'dean' => 3,
        'professor' => 1,
        _ => 0,
      };

  /// Adult jobs a sibling can have (no degree needed).
  static List<JobDefinition> _siblingJobs(int age) => [
        for (final job in JobCatalog.all)
          if (job.sector != JobSector.education &&
              job.minAge <= age &&
              JobCatalog.meetsEducation(
                EducationLevel.highSchool,
                job.requiredEducation,
              ))
            job,
      ];

  /// The job of school faculty, from their role.
  static String? facultyJobId(SchoolRole role) => switch (role) {
        SchoolRole.teacher => 'teacher',
        SchoolRole.professor => 'professor',
        SchoolRole.principal => 'principal',
        SchoolRole.dean => 'dean',
        SchoolRole.classmate => null,
      };

  /// Money for an NPC who has worked as [job] since [startAge], up to [age].
  static NpcFinance startingFinance({
    required JobDefinition job,
    required int startAge,
    required int age,
    required String countryCode,
  }) {
    final minRank = _minRankFor(job.id);
    var cash = 0;

    for (var y = startAge; y < age && y < retirementAge; y++) {
      final rank = _rankAt(yearsWorked: y - startAge, minRank: minRank);
      cash += _incomeFor(job: job, rank: rank, countryCode: countryCode) *
          savingsPercent ~/
          100;
    }

    return _current(
      job: job,
      startAge: startAge,
      age: age,
      countryCode: countryCode,
      cash: cash,
    );
  }

  static NpcFinance _current({
    required JobDefinition job,
    required int startAge,
    required int age,
    required String countryCode,
    required int cash,
  }) {
    final rank = _rankAt(
      yearsWorked: age - startAge < 0 ? 0 : age - startAge,
      minRank: _minRankFor(job.id),
    );
    final retired = age >= retirementAge;

    return NpcFinance(
      jobId: job.id,
      rank: rank,
      startAge: startAge,
      annualIncomeMinor:
          retired ? 0 : _incomeFor(job: job, rank: rank, countryCode: countryCode),
      cashMinor: cash,
    );
  }

  /// A new adult sibling: a job (or none, about one in seven) and savings
  /// that match the years already worked.
  static NpcFinance forSibling({
    required String id,
    required int age,
    required String countryCode,
  }) {
    final seed = _seed(id);

    if (seed % 7 == 0) {
      return const NpcFinance();
    }

    final jobs = _siblingJobs(age);

    if (jobs.isEmpty) {
      return const NpcFinance();
    }

    final job = jobs[(seed ~/ 7) % jobs.length];
    final startAge = job.minAge < 18 ? 18 : job.minAge;

    return startingFinance(
      job: job,
      startAge: startAge,
      age: age,
      countryCode: countryCode,
    );
  }

  /// Faculty start with the savings of a career that began at the minimum
  /// age of their job.
  static NpcFinance? forFaculty({
    required SchoolNpc npc,
    required int age,
  }) {
    final jobId = facultyJobId(npc.role);
    final job = jobId == null ? null : JobCatalog.byId(jobId);

    if (job == null) {
      return null;
    }

    return startingFinance(
      job: job,
      startAge: job.minAge,
      age: age,
      countryCode: npc.countryCode,
    );
  }

  /// One more year of work: the NPC earns and saves.
  static NpcFinance advance({
    required NpcFinance finance,
    required int age,
    required String countryCode,
  }) {
    final jobId = finance.jobId;
    final job = jobId == null ? null : JobCatalog.byId(jobId);

    if (job == null) {
      return finance;
    }

    // The year that just ended, when the NPC was a year younger.
    final lastYearAge = age - 1;
    final earned = lastYearAge >= retirementAge
        ? 0
        : finance.annualIncomeMinor * savingsPercent ~/ 100;

    return _current(
      job: job,
      startAge: finance.startAge,
      age: age,
      countryCode: countryCode,
      cash: finance.cashMinor + earned,
    );
  }
}
