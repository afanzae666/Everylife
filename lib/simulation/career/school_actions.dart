import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import 'career_actions.dart';

/// An after-school club the player can join in middle or high school.
class ExtracurricularClub {
  const ExtracurricularClub({
    required this.id,
    required this.name,
    required this.emoji,
    required this.blurb,
  });

  final String id;
  final String name;
  final String emoji;
  final String blurb;
}

/// What the player can do at school: study harder or join a club.
abstract final class SchoolActions {
  static const List<ExtracurricularClub> clubs = [
    ExtracurricularClub(
      id: 'sports',
      name: 'Sports Team',
      emoji: '⚽',
      blurb: 'Fitness and happiness',
    ),
    ExtracurricularClub(
      id: 'drama',
      name: 'Drama Club',
      emoji: '🎭',
      blurb: 'Charisma and creativity',
    ),
    ExtracurricularClub(
      id: 'debate',
      name: 'Debate Club',
      emoji: '🗣️',
      blurb: 'Smarts and charisma',
    ),
    ExtracurricularClub(
      id: 'art',
      name: 'Art Club',
      emoji: '🎨',
      blurb: 'Creativity',
    ),
    ExtracurricularClub(
      id: 'music',
      name: 'Music Band',
      emoji: '🎸',
      blurb: 'Creativity and happiness',
    ),
    ExtracurricularClub(
      id: 'science',
      name: 'Science Club',
      emoji: '🔬',
      blurb: 'Smarts and grades',
    ),
  ];

  static ExtracurricularClub? clubById(String id) {
    for (final club in clubs) {
      if (club.id == id) return club;
    }

    return null;
  }

  /// Clubs exist for middle school and high school only.
  static bool hasClubs(SchoolStage stage) =>
      stage == SchoolStage.middle || stage == SchoolStage.high;

  static Result<void> _guard(WorldState state) {
    if (state.lifeProgress.ending != null) {
      return const Failure('This life has already ended.');
    }

    if (state.lifeProgress.pending != null) {
      return const Failure('Make your decision first.');
    }

    if (!state.lifeProgress.education.isStudent) {
      return const Failure('I am not in school right now.');
    }

    return const Success(null);
  }

  static WorldState _log(WorldState state, String title, String text) {
    return state.addEvent(
      SimulationEvent(
        id: 'school-${state.events.length + 1}-${state.clock.currentYear}',
        type: SimulationEventType.education,
        year: state.clock.currentYear,
        title: title,
        description: text,
      ),
    );
  }

  static Result<CareerActionResult> studyHarder({
    required WorldState state,
    required SeededRandom random,
  }) {
    final guard = _guard(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final year = state.clock.currentYear;
    final education = state.lifeProgress.education;

    if (education.lastStudyYear == year) {
      return const Failure(
        'I already studied extra hard this year. '
        'I can do it again after my next birthday.',
      );
    }

    final gain = 4 + random.nextInt(5);
    final stats = state.player.stats;
    final text = switch (random.nextInt(3)) {
      0 => 'I stayed up late with my notes and finally things started to '
          'click.',
      1 => 'I made a study schedule and actually stuck to it this time.',
      _ => 'I spent my free time in the library, and my grades went up.',
    };

    final next = _log(
      state.copyWith(
        player: state.player.copyWith(
          stats: stats.copyWith(
            intelligence: stats.intelligence + 1,
            happiness: stats.happiness - 1,
          ),
        ),
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(
            grades: education.grades + gain,
            lastStudyYear: year,
          ),
        ),
      ),
      'I studied harder',
      text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }

  static Result<CareerActionResult> joinClub({
    required WorldState state,
    required String clubId,
  }) {
    final guard = _guard(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;

    if (!hasClubs(education.stage)) {
      return const Failure('My school has no clubs.');
    }

    final club = clubById(clubId);

    if (club == null) {
      return const Failure('That club does not exist.');
    }

    final year = state.clock.currentYear;

    if (education.lastClubYear == year) {
      return const Failure(
        'I already joined a club this year. '
        'I can pick another after my next birthday.',
      );
    }

    final stats = state.player.stats;
    final changed = switch (club.id) {
      'sports' => stats.copyWith(
          fitness: stats.fitness + 3,
          happiness: stats.happiness + 2,
        ),
      'drama' => stats.copyWith(
          charisma: stats.charisma + 3,
          creativity: stats.creativity + 1,
        ),
      'debate' => stats.copyWith(
          intelligence: stats.intelligence + 1,
          charisma: stats.charisma + 2,
        ),
      'art' => stats.copyWith(
          creativity: stats.creativity + 3,
          happiness: stats.happiness + 1,
        ),
      'music' => stats.copyWith(
          creativity: stats.creativity + 2,
          happiness: stats.happiness + 2,
        ),
      _ => stats.copyWith(
          intelligence: stats.intelligence + 2,
        ),
    };

    final text = 'I joined the ${club.name} at '
        '${education.schoolName ?? 'school'}. ${club.emoji}';

    final next = _log(
      state.copyWith(
        player: state.player.copyWith(stats: changed),
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(
            club: club.name,
            lastClubYear: year,
            grades: club.id == 'science' ? education.grades + 3 : null,
          ),
        ),
      ),
      'I joined a club',
      text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }
}
