import '../../core/random/seeded_random.dart';
import '../../domain/career/education_state.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Moves the player through school and university once a year.
///
/// Primary school starts at 6, secondary at 13, and graduation is at 18.
/// University (4 years) starts when the player was accepted (the
/// "university" flag from an event, or an application on the career screen).
class EducationSystem implements SimulationSystem {
  EducationSystem({
    required SeededRandom random,
  }) : _random = random;

  final SeededRandom _random;

  static const int universityYears = 4;

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
    if (age >= 18) {
      flags.add(SystemFlags.graduatedHighSchool);

      return education.copyWith(
        initialized: true,
        highest: education.highest.index > EducationLevel.secondary.index
            ? education.highest
            : EducationLevel.secondary,
        stage: SchoolStage.none,
      );
    }

    if (age >= 13) {
      return education.copyWith(
        initialized: true,
        highest: EducationLevel.primary,
        stage: SchoolStage.secondary,
      );
    }

    if (age >= 6) {
      return education.copyWith(
        initialized: true,
        stage: SchoolStage.primary,
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
            age >= 6 &&
            age < 13 &&
            !flags.contains(SystemFlags.schoolDropout)) {
          current = current.copyWith(stage: SchoolStage.primary, yearsInStage: 0);
          log('primary', 'First day of primary school', 'I started primary school.');
        } else if (current.highest == EducationLevel.secondary &&
            flags.remove('university')) {
          current = current.copyWith(stage: SchoolStage.university, yearsInStage: 0);
          log('university', 'University begins', 'I started university.');
        }
      case SchoolStage.primary:
        if (age >= 13) {
          current = current.copyWith(
            highest: EducationLevel.primary,
            stage: SchoolStage.secondary,
            yearsInStage: 0,
          );
          log('secondary', 'Secondary school', 'I moved up to secondary school.');
        }
      case SchoolStage.secondary:
        if (age >= 18) {
          current = current.copyWith(
            highest: EducationLevel.secondary,
            stage: SchoolStage.none,
            yearsInStage: 0,
          );
          flags.add(SystemFlags.graduatedHighSchool);
          log('graduation', 'High school graduation', 'I graduated from high school.');
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
            log('degree', 'University graduation', 'I earned my bachelor degree.');
          } else {
            current = current.copyWith(stage: SchoolStage.none, yearsInStage: 0);
            flags.add(SystemFlags.schoolDropout);
            log('failed', 'Left university', 'My grades were too low to graduate.');
          }
        }
    }

    return current;
  }
}
