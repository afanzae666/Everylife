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
    this.category = 'sport',
    this.fitness = 0,
    this.charisma = 0,
    this.creativity = 0,
    this.intelligence = 0,
    this.happiness = 0,
    this.willpower = 0,
    this.grades = 0,
  });

  final String id;
  final String name;
  final String emoji;
  final String blurb;

  /// What the player is called at rank 1 and rank 2 of this club.
  final String viceTitle;
  final String leadTitle;

  /// Groups the clubs in the picker and picks the story lines:
  /// sport, stage, craft, mind, tech or social.
  final String category;

  /// What joining or practising gives the player.
  final int fitness;
  final int charisma;
  final int creativity;
  final int intelligence;
  final int happiness;
  final int willpower;

  /// Extra grades when joining (the science-type clubs).
  final int grades;

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
      name: 'Soccer Team',
      emoji: '⚽',
      blurb: 'Fitness and happiness',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 3,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'basketball',
      name: 'Basketball Team',
      emoji: '🏀',
      blurb: 'Fitness and charisma',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 3,
      charisma: 1,
      happiness: 1,
    ),
    ExtracurricularClub(
      id: 'baseball',
      name: 'Baseball Team',
      emoji: '⚾',
      blurb: 'Fitness and focus',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 2,
      willpower: 1,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'volleyball',
      name: 'Volleyball Team',
      emoji: '🏐',
      blurb: 'Fitness and teamwork',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 2,
      charisma: 1,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'swimming',
      name: 'Swim Team',
      emoji: '🏊',
      blurb: 'Fitness and discipline',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 3,
      willpower: 2,
    ),
    ExtracurricularClub(
      id: 'track',
      name: 'Track & Field',
      emoji: '🏃',
      blurb: 'Fitness and discipline',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 3,
      willpower: 2,
    ),
    ExtracurricularClub(
      id: 'tennis',
      name: 'Tennis Team',
      emoji: '🎾',
      blurb: 'Fitness and focus',
      viceTitle: 'Vice Captain',
      leadTitle: 'Captain',
      category: 'sport',
      fitness: 2,
      willpower: 1,
      happiness: 1,
    ),
    ExtracurricularClub(
      id: 'karate',
      name: 'Martial Arts Club',
      emoji: '🥋',
      blurb: 'Discipline and fitness',
      viceTitle: 'Senior Student',
      leadTitle: 'Head Student',
      category: 'sport',
      fitness: 2,
      willpower: 3,
    ),
    ExtracurricularClub(
      id: 'drama',
      name: 'Drama Club',
      emoji: '🎭',
      blurb: 'Charisma and creativity',
      viceTitle: 'Assistant Director',
      leadTitle: 'Drama Director',
      category: 'stage',
      charisma: 3,
      creativity: 1,
    ),
    ExtracurricularClub(
      id: 'music',
      name: 'Music Band',
      emoji: '🎸',
      blurb: 'Creativity and happiness',
      viceTitle: 'Co-Bandleader',
      leadTitle: 'Bandleader',
      category: 'stage',
      creativity: 2,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'choir',
      name: 'Choir',
      emoji: '🎤',
      blurb: 'Charisma and happiness',
      viceTitle: 'Section Leader',
      leadTitle: 'Head Singer',
      category: 'stage',
      charisma: 2,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'dance',
      name: 'Dance Crew',
      emoji: '💃',
      blurb: 'Fitness and creativity',
      viceTitle: 'Dance Captain',
      leadTitle: 'Head Choreographer',
      category: 'stage',
      fitness: 2,
      creativity: 2,
      charisma: 1,
    ),
    ExtracurricularClub(
      id: 'art',
      name: 'Art Club',
      emoji: '🎨',
      blurb: 'Creativity',
      viceTitle: 'Vice Curator',
      leadTitle: 'Head Curator',
      category: 'craft',
      creativity: 3,
      happiness: 1,
    ),
    ExtracurricularClub(
      id: 'photo',
      name: 'Photography Club',
      emoji: '📷',
      blurb: 'Creativity and focus',
      viceTitle: 'Assistant Editor',
      leadTitle: 'Chief Photographer',
      category: 'craft',
      creativity: 3,
      willpower: 1,
    ),
    ExtracurricularClub(
      id: 'cooking',
      name: 'Cooking Club',
      emoji: '🍳',
      blurb: 'Creativity and happiness',
      viceTitle: 'Sous Chef',
      leadTitle: 'Head Chef',
      category: 'craft',
      creativity: 2,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'debate',
      name: 'Debate Club',
      emoji: '🗣️',
      blurb: 'Smarts and charisma',
      viceTitle: 'Vice President',
      leadTitle: 'President',
      category: 'mind',
      intelligence: 1,
      charisma: 2,
    ),
    ExtracurricularClub(
      id: 'science',
      name: 'Science Club',
      emoji: '🔬',
      blurb: 'Smarts and grades',
      viceTitle: 'Vice Chair',
      leadTitle: 'Chair',
      category: 'mind',
      intelligence: 2,
      grades: 3,
    ),
    ExtracurricularClub(
      id: 'chess',
      name: 'Chess Club',
      emoji: '♟️',
      blurb: 'Smarts and focus',
      viceTitle: 'Second Board',
      leadTitle: 'First Board',
      category: 'mind',
      intelligence: 2,
      willpower: 1,
    ),
    ExtracurricularClub(
      id: 'news',
      name: 'School Newspaper',
      emoji: '📰',
      blurb: 'Smarts and charisma',
      viceTitle: 'Deputy Editor',
      leadTitle: 'Editor-in-Chief',
      category: 'mind',
      intelligence: 1,
      charisma: 1,
      creativity: 1,
    ),
    ExtracurricularClub(
      id: 'robotics',
      name: 'Robotics Club',
      emoji: '🤖',
      blurb: 'Smarts and creativity',
      viceTitle: 'Vice Lead',
      leadTitle: 'Team Lead',
      category: 'tech',
      intelligence: 2,
      creativity: 1,
    ),
    ExtracurricularClub(
      id: 'coding',
      name: 'Coding Club',
      emoji: '💻',
      blurb: 'Smarts and focus',
      viceTitle: 'Senior Coder',
      leadTitle: 'Lead Coder',
      category: 'tech',
      intelligence: 2,
      willpower: 1,
    ),
    ExtracurricularClub(
      id: 'green',
      name: 'Green Club',
      emoji: '🌱',
      blurb: 'Willpower and happiness',
      viceTitle: 'Vice Coordinator',
      leadTitle: 'Coordinator',
      category: 'social',
      willpower: 2,
      happiness: 2,
    ),
    ExtracurricularClub(
      id: 'volunteer',
      name: 'Volunteer Club',
      emoji: '🤝',
      blurb: 'Charisma and happiness',
      viceTitle: 'Vice Coordinator',
      leadTitle: 'Coordinator',
      category: 'social',
      charisma: 2,
      happiness: 2,
    ),
  ];

  static ExtracurricularClub? clubById(String id) {
    for (final club in clubs) {
      if (club.id == id) return club;
    }

    return null;
  }

  static ExtracurricularClub? clubByName(String? name) {
    // Saves from before the soccer team was named call it "Sports Team".
    final wanted = name == 'Sports Team' ? 'Soccer Team' : name;

    for (final club in clubs) {
      if (club.name == wanted) return club;
    }

    return null;
  }

  /// Club performance needed for each promotion.
  static const int viceAt = 48;
  static const int leadAt = 65;

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
    final changed = _clubStats(club, stats);
    final text = SchoolNarratives.join(
      random,
      clubId: club.id,
      category: club.category,
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
            grades: club.grades > 0 ? education.grades + club.grades : null,
          ),
        ),
      ),
      'I joined a club',
      text,
    );

    return Success(CareerActionResult(state: next, message: text));
  }

  /// Stat changes for joining or practising with a club.
  static CharacterStats _clubStats(ExtracurricularClub club, CharacterStats stats) {
    return stats.copyWith(
      fitness: stats.fitness + club.fitness,
      charisma: stats.charisma + club.charisma,
      creativity: stats.creativity + club.creativity,
      intelligence: stats.intelligence + club.intelligence,
      happiness: stats.happiness + club.happiness,
      willpower: stats.willpower + club.willpower,
    );
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
    final stats = _clubStats(club, state.player.stats);

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
