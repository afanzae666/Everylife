import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/job_catalog.dart';
import 'package:everylife/domain/career/resume.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/career/resume_tracker.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

WorldState _state({
  int year = 2020,
  EducationState education = const EducationState(initialized: true),
  CareerState career = const CareerState(),
  List<ResumeEntry> resume = const [],
}) {
  final base = SimulationEngine.create(
    player: Character.create(id: 'p', name: 'Test Player', birthYear: 2000),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  ).state;

  return base.copyWith(
    clock: SimulationClock(currentYear: year),
    lifeProgress: LifeProgress(
      education: education,
      career: career,
      resume: resume,
    ),
  );
}

const _open = ResumeEntry(
  kind: ResumeKind.school,
  title: 'High School',
  startYear: 2014,
);

void main() {
  group('school lines', () {
    test('starting a school opens a line dated by the years already spent', () {
      final before = _state();
      final after = _state(
        year: 2014,
        education: const EducationState(
          initialized: true,
          stage: SchoolStage.high,
          yearsInStage: 2,
        ),
      );

      final next = ResumeTracker.record(before: before, after: after);
      final entry = next.lifeProgress.resume.single;

      expect(entry.title, 'High School');
      expect(entry.startYear, 2012);
      expect(entry.isOngoing, isTrue);
    });

    test('finishing high school closes the line as graduated', () {
      final before = _state(
        year: 2017,
        education: const EducationState(
          initialized: true,
          stage: SchoolStage.high,
          highest: EducationLevel.middle,
          schoolName: 'Lincoln High',
          schoolStage: SchoolStage.high,
        ),
        resume: const [_open],
      );
      final after = _state(
        year: 2018,
        education: const EducationState(
          initialized: true,
          highest: EducationLevel.highSchool,
        ),
        resume: const [_open],
      );

      final entry = ResumeTracker.record(before: before, after: after)
          .lifeProgress
          .resume
          .single;

      expect(entry.endYear, 2018);
      expect(entry.outcome, 'Graduated');
      expect(entry.place, 'Lincoln High');
    });

    test('leaving school early closes the line as left', () {
      final before = _state(
        education: const EducationState(
          initialized: true,
          stage: SchoolStage.high,
          highest: EducationLevel.middle,
        ),
        resume: const [_open],
      );
      final after = _state(
        education: const EducationState(
          initialized: true,
          highest: EducationLevel.middle,
        ),
        resume: const [_open],
      );

      final entry = ResumeTracker.record(before: before, after: after)
          .lifeProgress
          .resume
          .single;

      expect(entry.outcome, 'Left');
    });

    test('a university line carries the major and tells degrees apart', () {
      const studying = EducationState(
        initialized: true,
        stage: SchoolStage.university,
        highest: EducationLevel.highSchool,
        majorId: 'business',
      );
      final started = ResumeTracker.record(
        before: _state(
          education: const EducationState(
            initialized: true,
            highest: EducationLevel.highSchool,
          ),
        ),
        after: _state(education: studying),
      );
      final line = started.lifeProgress.resume.single;

      expect(line.title, 'University');
      expect(line.detail, 'Business');

      final graduated = ResumeTracker.record(
        before: started,
        after: started.copyWith(
          lifeProgress: started.lifeProgress.copyWith(
            education: studying.copyWith(
              stage: SchoolStage.none,
              highest: EducationLevel.bachelor,
            ),
          ),
        ),
      );

      expect(graduated.lifeProgress.resume.single.isDegree, isTrue);

      final dropped = ResumeTracker.record(
        before: started,
        after: started.copyWith(
          lifeProgress: started.lifeProgress.copyWith(
            education: studying.copyWith(
              stage: SchoolStage.none,
              clearMajor: true,
            ),
          ),
        ),
      );

      expect(dropped.lifeProgress.resume.single.outcome, 'Left');
      expect(dropped.lifeProgress.resume.single.isDegree, isFalse);
    });

    test('a second major makes a second line', () {
      const degree = ResumeEntry(
        kind: ResumeKind.school,
        title: 'University',
        detail: 'Business',
        startYear: 2018,
        endYear: 2021,
        outcome: 'Graduated',
      );
      final before = _state(
        education: const EducationState(
          initialized: true,
          highest: EducationLevel.bachelor,
          majorId: 'business',
        ),
        resume: const [degree],
      );
      final after = _state(
        education: const EducationState(
          initialized: true,
          stage: SchoolStage.university,
          highest: EducationLevel.bachelor,
          majorId: 'law',
        ),
        resume: const [degree],
      );

      final resume = ResumeTracker.record(before: before, after: after)
          .lifeProgress
          .resume;

      expect(resume, hasLength(2));
      expect(resume.first.isDegree, isTrue);
      expect(resume.last.detail, 'Law');
      expect(resume.last.isOngoing, isTrue);
    });
  });

  group('job lines', () {
    final job = JobCatalog.byId('cashier')!;

    test('getting a job opens a line and quitting closes it', () {
      final hired = ResumeTracker.record(
        before: _state(),
        after: _state(
          career: const CareerState(jobId: 'cashier'),
        ),
      );
      final line = hired.lifeProgress.resume.single;

      expect(line.kind, ResumeKind.job);
      expect(line.title, job.title);
      expect(line.detail, job.rankTitles.first);

      final quit = ResumeTracker.record(
        before: hired,
        after: hired.copyWith(
          lifeProgress: hired.lifeProgress.copyWith(
            career: const CareerState(),
          ),
        ),
      );

      expect(quit.lifeProgress.resume.single.outcome, 'Left');
      expect(quit.lifeProgress.resume.single.endYear, 2020);
    });

    test('retiring is written as retired', () {
      final hired = ResumeTracker.record(
        before: _state(),
        after: _state(career: const CareerState(jobId: 'cashier')),
      );
      final retired = ResumeTracker.record(
        before: hired,
        after: hired.copyWith(
          lifeProgress: hired.lifeProgress.copyWith(
            career: const CareerState(retired: true),
          ),
        ),
      );

      expect(retired.lifeProgress.resume.single.outcome, 'Retired');
    });

    test('a promotion updates the rank title of the open line', () {
      final hired = ResumeTracker.record(
        before: _state(),
        after: _state(career: const CareerState(jobId: 'cashier')),
      );
      final promoted = ResumeTracker.record(
        before: hired,
        after: hired.copyWith(
          lifeProgress: hired.lifeProgress.copyWith(
            career: const CareerState(jobId: 'cashier', rank: 1),
          ),
        ),
      );

      expect(promoted.lifeProgress.resume.single.detail, job.rankTitles[1]);
      expect(promoted.lifeProgress.resume.single.isOngoing, isTrue);
    });
  });

  test('nothing changes when nothing started or ended', () {
    final state = _state(resume: const [_open]);

    expect(
      identical(ResumeTracker.record(before: state, after: state), state),
      isTrue,
    );
  });

  test('the resume survives saving', () {
    final progress = LifeProgress(
      resume: const [
        ResumeEntry(
          kind: ResumeKind.job,
          title: 'Nurse',
          detail: 'Staff Nurse',
          startYear: 2022,
          endYear: 2025,
          outcome: 'Left',
        ),
      ],
    );

    final restored = LifeProgress.fromJson(progress.toJson()).resume.single;

    expect(restored.title, 'Nurse');
    expect(restored.detail, 'Staff Nurse');
    expect(restored.endYear, 2025);
    expect(restored.outcome, 'Left');
  });

  test('the engine writes a hired job on the resume', () {
    for (var seed = 0; seed < 100; seed++) {
      final base = _state(
        year: 2018,
        education: const EducationState(
          initialized: true,
          highest: EducationLevel.highSchool,
        ),
      );
      final engine = SimulationEngine(
        initialState: base,
        random: SeededRandom(seed),
        saveRepository: InMemorySaveRepository(),
      );

      engine.applyForJob('cashier');

      if (!engine.state.lifeProgress.career.hasJob) continue;

      expect(
        engine.state.lifeProgress.resume.single.title,
        JobCatalog.byId('cashier')!.title,
      );

      engine.quitJob();

      expect(engine.state.lifeProgress.resume.single.outcome, 'Left');
      return;
    }

    fail('Nobody was hired.');
  });
}
