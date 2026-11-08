import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/character/character_stats.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../narrative/school_narratives.dart';
import 'career_actions.dart';

/// An after-school club the player can join in middle or high school.
class ExtracurricularClub {
  const ExtracurricularClub({
    required this.id,
    required this.name,
    required this.emoji,
    required this.blurb,
    required this.viceTitle,
    required this.leadTitle,
  });

  final String id;
  final String name;
  final String emoji;
  final String blurb;

  /// What the player is called at rank 1 and rank 2 of this club.
  final String viceTitle;
  final String leadTitle;

  String titleFor(int rank) => switch (rank) {
        2 => leadTitle,
        1 => viceTitle,
        _ => 'Member',
      };
}

/// What the player can do at school: study harder or join a club.
abstract final class SchoolActions {
  static const List<ExtracurricularClub> clubs = [
    ExtracurricularClub(
      id: 'sports',
      name: 'Sports Team',
      emoji: '⚽',
      blurb: 'Fitness and happiness',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
    ),
    ExtracurricularClub(
      id: 'drama',
      name: 'Drama Club',
      emoji: '🎭',
      blurb: 'Charisma and creativity',
      viceTitle: 'Assistant Director',
      leadTitle: 'Drama Director',
    ),
    ExtracurricularClub(
      id: 'debate',
      name: 'Debate Club',
      emoji: '🗣️',
      blurb: 'Smarts and charisma',
      viceTitle: 'Vice President',
      leadTitle: 'President',
    ),
    ExtracurricularClub(
      id: 'art',
      name: 'Art Club',
      emoji: '🎨',
      blurb: 'Creativity',
      viceTitle: 'Vice Curator',
      leadTitle: 'Head Curator',
    ),
    ExtracurricularClub(
      id: 'music',
      name: 'Music Band',
      emoji: '🎸',
      blurb: 'Creativity and happiness',
      viceTitle: 'Co-Bandleader',
      leadTitle: 'Bandleader',
    ),
    ExtracurricularClub(
      id: 'science',
      name: 'Science Club',
      emoji: '🔬',
      blurb: 'Smarts and grades',
      viceTitle: 'Vice Chair',
      leadTitle: 'Chair',
    ),
  ];

  static ExtracurricularClub? clubById(String id) {
    for (final club in clubs) {
      if (club.id == id) return club;
    }

    return null;
  }

  static ExtracurricularClub? clubByName(String? name) {
    for (final club in clubs) {
      if (club.name == name) return club;
    }

    return null;
  }

  /// Club performance needed for each promotion.
  static const int viceAt = 60;
  static const int leadAt = 80;

  /// Gives the next rank if the performance is high enough. Sets
  /// [EducationState.clubPromotion] so the player is told about it once.
  static EducationState checkPromotion(EducationState education) {
    if (education.club == null) return education;

    if (education.clubRank == 0 && education.clubPerformance >= viceAt) {
      return education.copyWith(clubRank: 1, clubPromotion: 1);
    }

    if (education.clubRank == 1 && education.clubPerformance >= leadAt) {
      return education.copyWith(clubRank: 2, clubPromotion: 2);
    }

    return education;
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
    final text = SchoolNarratives.study(random, education.stage);

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
    required SeededRandom random,
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

    if (education.club != null) {
      return Failure(
        'I am already in the ${education.club}. '
        'I would have to leave it first.',
      );
    }

    final year = state.clock.currentYear;

    if (education.lastClubYear == year) {
      return const Failure(
        'I already joined a club this year. '
        'I can pick another after my next birthday.',
      );
    }

    final stats = state.player.stats;
    final changed = _clubStats(club.id, stats);
    final text = SchoolNarratives.join(
      random,
      clubId: club.id,
      clubName: club.name,
      school: education.schoolName ?? 'school',
    );

    final next = _log(
      state.copyWith(
        player: state.player.copyWith(stats: changed),
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(
            club: club.name,
            lastClubYear: year,
            clubPerformance: 30,
            clubRank: 0,
            grades: club.id == 'science' ? education.grades + 3 : null,
          ),
        ),
      ),
      'I joined a club',
      text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }

  /// Stat changes for joining or practising with a club.
  static CharacterStats _clubStats(String id, CharacterStats stats) {
    return switch (id) {
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
  }

  /// Practice with the club: raises performance, once per year.
  static Result<CareerActionResult> trainClub({
    required WorldState state,
    required SeededRandom random,
  }) {
    final guard = _guard(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;
    final club = clubByName(education.club);

    if (club == null) {
      return const Failure('I am not in a club.');
    }

    final year = state.clock.currentYear;

    if (education.lastTrainYear == year) {
      return const Failure(
        'I already trained hard this year. '
        'I need to rest until my next birthday.',
      );
    }

    final gain = 8 + random.nextInt(8);
    final text = SchoolNarratives.train(random, club.id);
    final stats = _clubStats(club.id, state.player.stats);

    final trained = education.copyWith(
      clubPerformance: education.clubPerformance + gain,
      lastTrainYear: year,
    );

    final next = _log(
      state.copyWith(
        player: state.player.copyWith(stats: stats),
        lifeProgress: state.lifeProgress.copyWith(
          education: checkPromotion(trained),
        ),
      ),
      'I trained with the ${club.name}',
      text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }

  static Result<CareerActionResult> leaveClub({
    required WorldState state,
    required SeededRandom random,
  }) {
    final guard = _guard(state);

    if (guard case Failure<void>(:final message)) {
      return Failure(message);
    }

    final education = state.lifeProgress.education;

    if (education.club == null) {
      return const Failure('I am not in a club.');
    }

    final text = SchoolNarratives.leave(random, education.club!);

    final next = _log(
      state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          education: education.copyWith(clearClub: true),
        ),
      ),
      'I left my club',
      text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }
}
