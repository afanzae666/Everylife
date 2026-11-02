import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';

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
  static List<JobDefinition> availableJobs(WorldState state) {
    final age = state.player.ageAt(state.clock.currentYear);
    final education = state.lifeProgress.education.highest;

    return [
      for (final job in JobCatalog.all)
        if (age >= job.minAge &&
            JobCatalog.meetsEducation(education, job.requiredEducation))
          job,
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

  /// Chance (percent) that university accepts the player.
  static int universityChance(WorldState state) {
    final education = state.lifeProgress.education;

    final chance =
        30 + education.grades ~/ 2 + (state.player.stats.intelligence - 50) * 3 ~/ 10;

    return chance.clamp(10, 95).toInt();
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

    if (!availableJobs(state).any((candidate) => candidate.id == jobId)) {
      return const Failure('I do not qualify for that job yet.');
    }

    if (career.lastApplicationYear == year) {
      return const Failure('I already applied this year. I can try again next year.');
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
  }) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final year = state.clock.currentYear;
    final education = state.lifeProgress.education;

    if (education.isStudent) {
      return const Failure('I am already studying.');
    }

    if (education.highest == EducationLevel.bachelor) {
      return const Failure('I already have a university degree.');
    }

    if (education.highest != EducationLevel.secondary) {
      return const Failure('I need a high school diploma first.');
    }

    if (education.lastUniversityApplicationYear == year) {
      return const Failure('I already applied this year. I can try again next year.');
    }

    final accepted = random.nextInt(100) < universityChance(state);

    final flags = {...state.lifeProgress.flags};
    if (accepted) flags.add(SystemFlags.student);

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(
            lastUniversityApplicationYear: year,
            stage: accepted ? SchoolStage.university : null,
            yearsInStage: accepted ? 0 : null,
          ),
          flags: flags,
        ),
      ),
      type: SimulationEventType.education,
      title: accepted ? 'Accepted to university' : 'University said no',
      text: accepted
          ? 'I was accepted to university and will start this year.'
          : 'My university application was turned down.',
    );

    return Success(
      CareerActionResult(
        state: next,
        message: accepted
            ? 'You are in! University starts now.'
            : 'The university turned you down. You can apply again next year.',
      ),
    );
  }

  static Result<CareerActionResult> dropOutOfSchool(WorldState state) {
    final guard = _ensureActive(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;

    if (education.stage != SchoolStage.secondary &&
        education.stage != SchoolStage.university) {
      return const Failure('There is no school I can leave right now.');
    }

    final flags = {...state.lifeProgress.flags}
      ..remove(SystemFlags.student)
      ..add(SystemFlags.schoolDropout);

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(stage: SchoolStage.none, yearsInStage: 0),
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
