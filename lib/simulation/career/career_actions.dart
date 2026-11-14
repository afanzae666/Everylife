import 'dart:math' as math;

import 'package:everylife/core/money/money.dart';

import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/major_catalog.dart';
import '../../domain/career/tuition_funding.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../events/money_text.dart';
import '../generation/country_economic_profile.dart';
import '../narrative/tuition_narratives.dart';

/// The new world and a message for the player after a career action.
class CareerActionResult {
  const CareerActionResult({
    required this.state,
    required this.message,
  });

  final WorldState state;
  final String message;
}

/// Player-triggered school and work actions (the career screen buttons).
abstract final class CareerActions {
  /// Jobs the player is old enough and qualified for.
  ///
  /// Nobody can work full time while enrolled in school or university.
  static List<JobDefinition> availableJobs(WorldState state) {
    if (state.lifeProgress.education.isStudent) {
      return const <JobDefinition>[];
    }

    final age = state.player.ageAt(state.clock.currentYear);
    final education = state.lifeProgress.education;

    return [
      for (final job in JobCatalog.all)
        if (age >= job.minAge && JobCatalog.qualifies(education, job)) job,
    ];
  }

  /// Chance (percent) of being hired for [job].
  static int hiringChance(WorldState state, JobDefinition job) {
    final stats = state.player.stats;
    final education = state.lifeProgress.education;

    var chance = 55 +
        (stats.intelligence - 50) ~/ 2 +
        (stats.charisma - 50) * 3 ~/ 10;

    if (education.highest != EducationLevel.none) {
      chance += (education.grades - 60) ~/ 5;
    }

    return chance.clamp(10, 90).toInt();
  }

  /// Total tuition for [major] in the player's country, paid once.
  static int tuitionFor(WorldState state, MajorDefinition major) {
    final code = state.player.location?.countryCode ?? '';

    return CountryEconomicProfile.forCountryCode(code)
        .scaleAmount(major.tuition);
  }

  /// Chance (percent) that the university takes the player. Grades and
  /// intelligence below what the major likes lower it; they never lock it.
  static int admissionChance(WorldState state, MajorDefinition major) {
    final grades = state.lifeProgress.education.grades;
    final intelligence = state.player.stats.intelligence;

    var chance = 30 + grades ~/ 2 + (intelligence - 50) * 3 ~/ 10;

    if (grades < major.minGrades) chance -= (major.minGrades - grades) ~/ 2;

    if (intelligence < major.minIntelligence) {
      chance -= (major.minIntelligence - intelligence) ~/ 2;
    }

    return chance.clamp(5, 95).toInt();
  }

  /// A stable number for the same player, year, major and method, so asking
  /// twice in a year never changes the answer.
  static int _stableSeed(WorldState state, String majorId, TuitionFunding how) {
    var hash = 17;

    for (final unit in '${state.player.id}|${state.clock.currentYear}|$majorId|${how.name}'
        .codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return hash;
  }

  static int _stableRoll(WorldState state, String majorId, TuitionFunding how) {
    return math.Random(_stableSeed(state, majorId, how)).nextInt(100);
  }

  /// The parent most likely to help: alive, closest to the player.
  static ParentNpc? _closestParent(WorldState state) {
    final parents = [
      for (final parent
          in state.familyHousehold?.parents ?? const <ParentNpc>[])
        if (parent.isAlive) parent,
    ];

    if (parents.isEmpty) return null;

    parents.sort(
      (a, b) => b.relationshipPercent.compareTo(a.relationshipPercent),
    );

    return parents.first;
  }

  /// Share (percent) of the tuition a scholarship covers, from grades and
  /// intelligence. Zero means no scholarship at all.
  static int scholarshipShare(WorldState state, String majorId) {
    final score = (state.lifeProgress.education.grades +
            state.player.stats.intelligence) ~/
        2;

    if (score < 60) return 0;

    final chance = ((score - 55) * 2).clamp(10, 90).toInt();

    if (_stableRoll(state, majorId, TuitionFunding.scholarship) >= chance) {
      return 0;
    }

    if (score >= 90) return 100;
    if (score >= 80) return 70;
    if (score >= 70) return 50;

    return 30;
  }

  /// Whether [how] can pay for [major], with a scene when it cannot.
  static TuitionAnswer fundingAnswer(
    WorldState state,
    String majorId,
    TuitionFunding how,
  ) {
    final major = MajorCatalog.byId(majorId);

    if (major == null) {
      return const TuitionAnswer.refused(
        title: 'No Major',
        text: 'I need to pick a major first.',
      );
    }

    final seed = _stableSeed(state, majorId, how);
    final total = tuitionFor(state, major);
    final totalText = MoneyText.of(state, total);

    TuitionAnswer refuse(TuitionRefusal reason, {String? parent}) {
      final (title, text) = TuitionNarratives.refusal(
        reason,
        seed: seed,
        parent: parent ?? 'My parent',
        total: totalText,
      );

      return TuitionAnswer.refused(title: title, text: text);
    }

    switch (how) {
      case TuitionFunding.sports:
        // The university teams only take students of the general university.
        return state.lifeProgress.education.sportsOffer != null &&
                major.institution == InstitutionType.general
            ? const TuitionAnswer.approved()
            : refuse(TuitionRefusal.noOffer);
      case TuitionFunding.loan:
        return const TuitionAnswer.approved();
      case TuitionFunding.self:
        return state.player.money.minorUnits >= total
            ? const TuitionAnswer.approved()
            : refuse(TuitionRefusal.noMoney);
      case TuitionFunding.scholarship:
        if (scholarshipShare(state, majorId) > 0) {
          return const TuitionAnswer.approved();
        }

        final score = (state.lifeProgress.education.grades +
                state.player.stats.intelligence) ~/
            2;

        return refuse(
          score < 60
              ? TuitionRefusal.scholarshipLow
              : TuitionRefusal.scholarshipDenied,
        );
      case TuitionFunding.parents:
        final parent = _closestParent(state);

        if (parent == null) return refuse(TuitionRefusal.noParents);

        if (parent.cashBalance.minorUnits < total) {
          return refuse(TuitionRefusal.parentsCannot, parent: parent.firstName);
        }

        final willing = 20 + parent.relationshipPercent * 7 ~/ 10;

        if (_stableRoll(state, majorId, how) >= willing) {
          return refuse(
            TuitionRefusal.parentsWontHelp,
            parent: parent.firstName,
          );
        }

        return const TuitionAnswer.approved();
    }
  }

  static Result<void> _ensureActive(WorldState state) {
    if (state.lifeProgress.ending != null) {
      return const Failure('This life has already ended.');
    }

    if (state.lifeProgress.pending != null) {
      return const Failure('Make your decision first.');
    }

    return const Success(null);
  }

  static WorldState _log(
    WorldState state, {
    required SimulationEventType type,
    required String title,
    required String text,
  }) {
    return state.addEvent(
      SimulationEvent(
        id: 'action-${state.events.length + 1}-${state.clock.currentYear}',
        type: type,
        year: state.clock.currentYear,
        title: title,
        description: text,
      ),
    );
  }

  /// Turning down a university's sports scholarship.
  static Result<CareerActionResult> declineSportsOffer({
    required WorldState state,
    required String text,
  }) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;

    if (education.sportsOffer == null) {
      return const Failure('There is no scholarship offer to turn down.');
    }

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(clearSportsOffer: true),
        ),
      ),
      type: SimulationEventType.education,
      title: 'Turned down a scholarship',
      text: text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }

  /// Taking a break after school: nothing changes except the life log.
  static Result<CareerActionResult> takeBreak({
    required WorldState state,
    required String text,
  }) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final next = _log(
      state,
      type: SimulationEventType.career,
      title: 'Taking a break',
      text: text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }

  static Result<CareerActionResult> applyForJob({
    required WorldState state,
    required SeededRandom random,
    required String jobId,
  }) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final year = state.clock.currentYear;
    final career = state.lifeProgress.career;
    final job = JobCatalog.byId(jobId);

    if (job == null) {
      return const Failure('That job does not exist.');
    }

    if (career.retired) {
      return const Failure('I am retired and no longer looking for work.');
    }

    if (career.hasJob) {
      return const Failure('I already have a job. I would need to quit first.');
    }

    if (state.lifeProgress.education.isStudent) {
      return const Failure(
        'I cannot work full time while I am still studying.',
      );
    }

    if (!availableJobs(state).any((candidate) => candidate.id == jobId)) {
      return const Failure('I do not qualify for that job yet.');
    }

    if (career.lastApplicationYear == year) {
      return const Failure('I already applied this year. I can try again after my next birthday.');
    }

    final hired = random.nextInt(100) < hiringChance(state, job);

    final progress = state.lifeProgress.copyWith(
      career: career.copyWith(
        lastApplicationYear: year,
        jobId: hired ? job.id : null,
        rank: hired ? 0 : null,
        salaryBase: hired ? job.salaryAt(0) : null,
        performance: hired ? 60 : null,
        yearsInRole: hired ? 0 : null,
      ),
      flags: hired
          ? {...state.lifeProgress.flags, SystemFlags.employed}
          : null,
    );

    final next = _log(
      state.copyWith(lifeProgress: progress),
      type: SimulationEventType.career,
      title: hired ? 'New job' : 'Application rejected',
      text: hired
          ? 'I was hired as ${job.titleAt(0)}.'
          : 'I applied for a job as ${job.titleAt(0)}, but they chose someone else.',
    );

    return Success(
      CareerActionResult(
        state: next,
        message: hired
            ? 'You got the job: ${job.titleAt(0)}!'
            : 'They chose someone else this time.',
      ),
    );
  }

  static Result<CareerActionResult> quitJob(WorldState state) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final career = state.lifeProgress.career;
    final job = career.hasJob ? JobCatalog.byId(career.jobId!) : null;

    if (!career.hasJob) {
      return const Failure('I do not have a job to quit.');
    }

    final flags = {...state.lifeProgress.flags}..remove(SystemFlags.employed);

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          career: career.copyWith(
            clearJob: true,
            salaryBase: 0,
            rank: 0,
            yearsInRole: 0,
          ),
          flags: flags,
        ),
      ),
      type: SimulationEventType.career,
      title: 'Quit my job',
      text: 'I quit my job${job == null ? '' : ' as ${job.titleAt(career.rank)}'}.',
    );

    return Success(
      CareerActionResult(state: next, message: 'You quit your job.'),
    );
  }

  static Result<CareerActionResult> askForRaise({
    required WorldState state,
    required SeededRandom random,
  }) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final year = state.clock.currentYear;
    final career = state.lifeProgress.career;

    if (!career.hasJob) {
      return const Failure('I need a job before I can ask for a raise.');
    }

    if (career.lastRaiseRequestYear == year) {
      return const Failure('I already asked for a raise this year.');
    }

    final chance = (30 + (career.performance - 60) ~/ 2).clamp(10, 80).toInt();
    final granted = random.nextInt(100) < chance;

    final updated = career.copyWith(
      lastRaiseRequestYear: year,
      salaryBase: granted ? career.salaryBase * 108 ~/ 100 : null,
      performance: granted ? null : career.performance - 8,
    );

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(career: updated),
      ),
      type: SimulationEventType.career,
      title: granted ? 'Raise granted' : 'Raise denied',
      text: granted
          ? 'My boss agreed to give me a raise.'
          : 'I asked for a raise and my boss was not impressed.',
    );

    return Success(
      CareerActionResult(
        state: next,
        message: granted
            ? 'Your salary went up by 8%.'
            : 'Your boss said no, and your standing took a hit.',
      ),
    );
  }

  static Result<CareerActionResult> applyForUniversity({
    required WorldState state,
    required SeededRandom random,
    required String majorId,
    required TuitionFunding funding,
  }) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;

    if (education.isStudent) {
      return const Failure('I am already studying.');
    }

    // A graduate may study again, for example for a second major.
    if (education.highest.index < EducationLevel.highSchool.index) {
      return const Failure('I need a high school diploma first.');
    }

    if (state.lifeProgress.career.hasJob) {
      return const Failure(
        'I cannot study and work full time. I would have to quit my job first.',
      );
    }

    final major = MajorCatalog.byId(majorId);

    if (major == null) {
      return const Failure('I need to pick a major first.');
    }

    final answer = fundingAnswer(state, majorId, funding);

    if (!answer.approved) {
      return Failure(answer.text ?? 'That way of paying is not possible.');
    }

    final accepted = funding == TuitionFunding.sports ||
        random.nextInt(100) < admissionChance(state, major);

    if (!accepted) {
      final next = _log(
        state,
        type: SimulationEventType.education,
        title: 'University said no',
        text: 'My application to study ${major.name} was turned down.',
      );

      return Success(
        CareerActionResult(
          state: next,
          message:
              'The university turned you down. You can apply again, nothing was charged.',
        ),
      );
    }

    final total = tuitionFor(state, major);
    var paid = state;
    final String how;

    switch (funding) {
      case TuitionFunding.sports:
        how = 'The ${education.sportsOffer} team recruited me, and the '
            'university paid all of it.';
      case TuitionFunding.scholarship:
        final covered = total * scholarshipShare(state, majorId) ~/ 100;
        final rest = total - covered;
        final cash = paid.player.money.minorUnits;
        final fromCash = cash < rest ? cash : rest;

        paid = paid.copyWith(
          player: paid.player.copyWith(
            money: Money.fromMinorUnits(cash - fromCash),
            debt: Money.fromMinorUnits(
              paid.player.debt.minorUnits + (rest - fromCash),
            ),
          ),
        );
        how = covered >= total
            ? 'A scholarship paid all of it.'
            : 'A scholarship covered ${MoneyText.of(state, covered)}. '
                'I paid ${MoneyText.of(state, fromCash)} myself'
                '${rest > fromCash ? ' and borrowed ${MoneyText.of(state, rest - fromCash)}' : ''}.';
      case TuitionFunding.parents:
        final parent = _closestParent(state)!;
        final household = paid.familyHousehold!;

        paid = paid.copyWith(
          familyHousehold: household.copyWith(
            parents: [
              for (final p in household.parents)
                if (p.id == parent.id)
                  p.copyWith(
                    cashBalance: Money.fromMinorUnits(
                      p.cashBalance.minorUnits - total,
                    ),
                  )
                else
                  p,
            ],
          ),
        );
        how = '${parent.firstName} paid all of it.';
      case TuitionFunding.self:
        paid = paid.copyWith(
          player: paid.player.copyWith(
            money: Money.fromMinorUnits(paid.player.money.minorUnits - total),
          ),
        );
        how = 'I paid all of it from my own savings.';
      case TuitionFunding.loan:
        paid = paid.copyWith(
          player: paid.player.copyWith(
            debt: Money.fromMinorUnits(paid.player.debt.minorUnits + total),
          ),
        );
        how = 'I took a tuition loan for all of it.';
    }

    final flags = {...paid.lifeProgress.flags}
      ..add(SystemFlags.student)
      ..add(SystemFlags.universityStudent)
      ..remove(SystemFlags.schoolStudent);

    final next = _log(
      paid.copyWith(
        lifeProgress: paid.lifeProgress.copyWith(
          education: education.copyWith(
            stage: SchoolStage.university,
            yearsInStage: 0,
            majorId: major.id,
            clearClub: true,
            clearSportsOffer: true,
          ),
          flags: flags,
        ),
      ),
      type: SimulationEventType.education,
      title: 'Accepted to university',
      text: 'I was accepted to study ${major.name}. Tuition was '
          '${MoneyText.of(state, total)} for the whole program. $how',
    );

    return Success(
      CareerActionResult(
        state: next,
        message: 'You are in! ${major.name} starts now.',
      ),
    );
  }

  static Result<CareerActionResult> dropOutOfSchool(WorldState state) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;

    if (education.stage != SchoolStage.high &&
        education.stage != SchoolStage.university) {
      return const Failure('There is no school I can leave right now.');
    }

    final flags = {...state.lifeProgress.flags}
      ..remove(SystemFlags.student)
      ..remove(SystemFlags.schoolStudent)
      ..remove(SystemFlags.universityStudent)
      ..add(SystemFlags.schoolDropout);

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(
            stage: SchoolStage.none,
            yearsInStage: 0,
            clearMajor: education.stage == SchoolStage.university,
            clearClub: true,
          ),
          flags: flags,
        ),
      ),
      type: SimulationEventType.education,
      title: 'Dropped out',
      text: 'I decided to leave school.',
    );

    return Success(
      CareerActionResult(state: next, message: 'You left school.'),
    );
  }
}
