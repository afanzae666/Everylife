import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/major_catalog.dart';
import '../../domain/career/resume.dart';
import '../../domain/world/world_state.dart';

/// Keeps the resume up to date. It looks at a state before and after a change
/// and writes down every school or job that started, ended or moved up.
abstract final class ResumeTracker {
  static String _schoolTitle(SchoolStage stage) => switch (stage) {
        SchoolStage.elementary => 'Elementary School',
        SchoolStage.middle => 'Middle School',
        SchoolStage.high => 'High School',
        SchoolStage.university => 'University',
        SchoolStage.none => '',
      };

  /// The program a student is in, or null when not studying.
  static String? _programKey(EducationState education) {
    if (education.stage == SchoolStage.none) return null;

    return education.stage == SchoolStage.university
        ? 'university:${education.majorId}'
        : education.stage.name;
  }

  static int _lastOpen(List<ResumeEntry> resume, ResumeKind kind) {
    for (var i = resume.length - 1; i >= 0; i--) {
      if (resume[i].kind == kind && resume[i].isOngoing) return i;
    }

    return -1;
  }

  static WorldState record({
    required WorldState before,
    required WorldState after,
  }) {
    final b = before.lifeProgress;
    final a = after.lifeProgress;
    final year = after.clock.currentYear;
    final resume = [...a.resume];
    var changed = false;

    // School.
    if (_programKey(b.education) != _programKey(a.education)) {
      final open = _lastOpen(resume, ResumeKind.school);

      if (open >= 0) {
        final graduated = b.education.stage == SchoolStage.university
            ? a.education.majorId != null
            : a.education.highest.index > b.education.highest.index;

        resume[open] = resume[open].copyWith(
          endYear: year,
          outcome: graduated ? 'Graduated' : 'Left',
          place: b.education.schoolStage == b.education.stage
              ? b.education.schoolName
              : null,
        );
        changed = true;
      }

      if (a.education.stage != SchoolStage.none) {
        resume.add(
          ResumeEntry(
            kind: ResumeKind.school,
            title: _schoolTitle(a.education.stage),
            detail: a.education.stage == SchoolStage.university
                ? MajorCatalog.byId(a.education.majorId ?? '')?.name
                : null,
            startYear: year - a.education.yearsInStage,
          ),
        );
        changed = true;
      }
    }

    // Work.
    final jobBefore = b.career.jobId;
    final jobNow = a.career.jobId;

    String rankTitle(String id, int rank) {
      final titles = JobCatalog.byId(id)?.rankTitles ?? const <String>[];

      return titles.isEmpty ? '' : titles[rank.clamp(0, titles.length - 1)];
    }

    if (jobBefore != jobNow) {
      final open = _lastOpen(resume, ResumeKind.job);

      if (open >= 0) {
        resume[open] = resume[open].copyWith(
          endYear: year,
          outcome: a.career.retired ? 'Retired' : 'Left',
          detail: jobBefore == null ? null : rankTitle(jobBefore, b.career.rank),
        );
        changed = true;
      }

      if (jobNow != null) {
        resume.add(
          ResumeEntry(
            kind: ResumeKind.job,
            title: JobCatalog.byId(jobNow)?.title ?? jobNow,
            detail: rankTitle(jobNow, a.career.rank),
            startYear: year,
          ),
        );
        changed = true;
      }
    } else if (jobNow != null && b.career.rank != a.career.rank) {
      final open = _lastOpen(resume, ResumeKind.job);

      if (open >= 0) {
        resume[open] = resume[open].copyWith(
          detail: rankTitle(jobNow, a.career.rank),
        );
        changed = true;
      }
    }

    if (!changed) return after;

    return after.copyWith(lifeProgress: a.copyWith(resume: resume));
  }
}
