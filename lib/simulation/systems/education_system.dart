import '../../core/random/seeded_random.dart';
import '../../domain/career/education_state.dart';
import '../career/school_actions.dart';
import '../narrative/school_narratives.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Moves the player through school and university once a year.
///
/// School starts at 6: elementary school (6-11), middle school (12-14) and
/// high school (15-17). Graduation is at 18. University (4 years) starts when
/// the player was accepted (the "university" flag from an event, or an
/// application on the occupation screen) and is only possible without a
/// full-time job.
class EducationSystem implements SimulationSystem {
  EducationSystem({
    required SeededRandom random,
  }) : _random = random;

  final SeededRandom _random;

  static const int universityYears = 4;

  /// Ages at which the player moves up.
  static const int elementaryStartAge = 6;
  static const int middleStartAge = 12;
  static const int highStartAge = 15;
  static const int graduationAge = 18;

  /// Number of grades in each school stage.
  static const int elementaryYears = 6;
  static const int middleYears = 3;
  static const int highYears = 3;

  @override
  String get id => 'education';

  @override
  int get priority => SystemPriority.education.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final progress = state.lifeProgress;

    if (progress.ending != null) {
      return state;
    }

    final year = state.clock.currentYear;
    final age = state.player.ageAt(year);
    final flags = <String>{...progress.flags};
    final logs = <SimulationEvent>[];

    var education = progress.education;

    void log(String key, String title, String text) {
      logs.add(
        SimulationEvent(
          id: 'education-$key-$year',
          type: SimulationEventType.education,
          year: year,
          title: title,
          description: text,
        ),
      );
    }

    if (!education.initialized) {
      education = _backfill(education, age, flags);
    } else {
      education = _advance(
        education: education,
        age: age,
        flags: flags,
        stats: state.player.stats.intelligence,
        will: state.player.stats.willpower,
        hasJob: progress.career.hasJob,
        log: log,
      );
    }

    // A dropout request (from an event) ends the current studies.
    if (flags.remove('dropout') && education.isStudent) {
      education = education.copyWith(
        stage: SchoolStage.none,
        yearsInStage: 0,
      );
      flags.add(SystemFlags.schoolDropout);
      log('dropout', 'I left school', 'I walked away from my studies for now.');
    }

    // Club members get better every year, and may be promoted for it.
    if (education.isStudent && education.club != null) {
      final before = education.clubRank;

      education = SchoolActions.checkPromotion(
        education.copyWith(
          clubPerformance: education.clubPerformance + 8,
        ),
      );

      final club = SchoolActions.clubByName(education.club);

      if (club != null && education.clubRank > before) {
        log(
          'club-promotion',
          'Promoted in my club',
          SchoolNarratives.promotion(
            clubName: club.name,
            title: club.titleFor(education.clubRank),
            rank: education.clubRank,
            school: education.schoolName ?? 'school',
          ),
        );
      }
    }

    if (education.isStudent) {
      flags.add(SystemFlags.student);
    } else {
      flags.remove(SystemFlags.student);
    }

    var next = state.copyWith(
      lifeProgress: progress.copyWith(
        education: education,
        flags: flags,
      ),
    );

    for (final entry in logs) {
      next = next.addEvent(entry);
    }

    return next;
  }

  /// Fits schooling to the player's age for a life that has no record yet.
  EducationState _backfill(
    EducationState education,
    int age,
    Set<String> flags,
  ) {
    if (age >= graduationAge) {
      flags.add(SystemFlags.graduatedHighSchool);

      return education.copyWith(
        initialized: true,
        highest: education.highest.index > EducationLevel.highSchool.index
            ? education.highest
            : EducationLevel.highSchool,
        stage: SchoolStage.none,
      );
    }

    if (age >= highStartAge) {
      return education.copyWith(
        initialized: true,
        highest: EducationLevel.middle,
        stage: SchoolStage.high,
        yearsInStage: age - highStartAge,
      );
    }

    if (age >= middleStartAge) {
      return education.copyWith(
        initialized: true,
        highest: EducationLevel.elementary,
        stage: SchoolStage.middle,
        yearsInStage: age - middleStartAge,
      );
    }

    if (age >= elementaryStartAge) {
      return education.copyWith(
        initialized: true,
        stage: SchoolStage.elementary,
        yearsInStage: age - elementaryStartAge,
      );
    }

    return education.copyWith(initialized: true);
  }

  EducationState _advance({
    required EducationState education,
    required int age,
    required Set<String> flags,
    required int stats,
    required int will,
    required bool hasJob,
    required void Function(String key, String title, String text) log,
  }) {
    var current = education;

    // Study performance drifts with intelligence, discipline, and luck.
    if (current.isStudent) {
      var change = (stats - 50) ~/ 10 + (will - 50) ~/ 20 + _random.nextInt(7) - 3;

      if (flags.remove('failed_test')) {
        change -= 4;
      }

      current = current.copyWith(
        grades: current.grades + change,
        yearsInStage: current.yearsInStage + 1,
      );
    }

    switch (current.stage) {
      case SchoolStage.none:
        if (current.highest == EducationLevel.none &&
            age >= elementaryStartAge &&
            age < middleStartAge &&
            !flags.contains(SystemFlags.schoolDropout)) {
          current = current.copyWith(
            stage: SchoolStage.elementary,
            yearsInStage: 0,
          );
          log(
            'elementary',
            'First day of elementary school',
            'I started elementary school.',
          );
        } else if (current.highest == EducationLevel.highSchool &&
            flags.contains('university')) {
          flags.remove('university');

          if (hasJob) {
            // Nobody studies full time and works full time.
            log(
              'university-blocked',
              'No time for university',
              'I could not start university because I work full time.',
            );
          } else {
            current = current.copyWith(
              stage: SchoolStage.university,
              yearsInStage: 0,
            );
            log('university', 'University begins', 'I started university.');
          }
        }
      case SchoolStage.elementary:
        if (age >= middleStartAge) {
          current = current.copyWith(
            highest: EducationLevel.elementary,
            stage: SchoolStage.middle,
            yearsInStage: 0,
          );
          log('middle', 'Middle school', 'I started middle school.');
        }
      case SchoolStage.middle:
        if (age >= highStartAge) {
          current = current.copyWith(
            highest: EducationLevel.middle,
            stage: SchoolStage.high,
            yearsInStage: 0,
          );
          log('high', 'High school', 'I started high school.');
        }
      case SchoolStage.high:
        if (age >= graduationAge) {
          current = current.copyWith(
            highest: EducationLevel.highSchool,
            stage: SchoolStage.none,
            yearsInStage: 0,
          );
          flags.add(SystemFlags.graduatedHighSchool);
          log(
            'graduation',
            'High school graduation',
            'I graduated from high school.',
          );
        }
      case SchoolStage.university:
        if (current.yearsInStage >= universityYears) {
          if (current.grades >= 35) {
            current = current.copyWith(
              highest: EducationLevel.bachelor,
              stage: SchoolStage.none,
              yearsInStage: 0,
            );
            flags.add(SystemFlags.graduatedUniversity);
            log(
              'degree',
              'University graduation',
              'I earned my bachelor degree.',
            );
          } else {
            current = current.copyWith(
              stage: SchoolStage.none,
              yearsInStage: 0,
            );
            flags.add(SystemFlags.schoolDropout);
            log(
              'failed',
              'Left university',
              'My grades were too low to graduate.',
            );
          }
        }
    }

    return current;
  }
}
