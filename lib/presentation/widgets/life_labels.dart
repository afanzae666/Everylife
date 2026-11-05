import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/world/world_state.dart';

/// A country flag emoji from a two-letter country code ('' when invalid).
String countryFlag(String? countryCode) {
  final code = (countryCode ?? '').toUpperCase();

  if (code.length != 2) {
    return '';
  }

  final first = code.codeUnitAt(0);
  final second = code.codeUnitAt(1);

  if (first < 65 || first > 90 || second < 65 || second > 90) {
    return '';
  }

  const base = 0x1F1E6 - 65;

  return String.fromCharCodes([base + first, base + second]);
}

/// What the character does with their days: a job title, a school stage,
/// or a short status such as "Retired". Shown on the character card.
String occupationLabel(WorldState state) {
  final age = state.player.ageAt(state.clock.currentYear);
  final progress = state.lifeProgress;
  final career = progress.career;
  final education = progress.education;

  if (career.retired) {
    return 'Retired';
  }

  final job = career.jobId == null ? null : JobCatalog.byId(career.jobId!);

  if (job != null) {
    return job.titleAt(career.rank);
  }

  if (education.isStudent) {
    return switch (education.stage) {
      SchoolStage.elementary => 'Elementary Student',
      SchoolStage.middle => 'Middle School Student',
      SchoolStage.high => 'High School Student',
      SchoolStage.university => 'University Student',
      SchoolStage.none => 'Student',
    };
  }

  if (age <= 2) {
    return 'Infant';
  }

  if (age <= 5) {
    return 'Toddler';
  }

  return 'Unemployed';
}
