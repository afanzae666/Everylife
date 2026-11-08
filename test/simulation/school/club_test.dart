import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/career/school_actions.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/narrative/school_narratives.dart';

SimulationEngine _engine(EducationState? education) {
  final base = SimulationEngine.create(
    player: Character.create(
      id: 'club-player',
      name: 'Club Kid',
      birthYear: 2000,
    ),
    seed: 9,
    saveRepository: InMemorySaveRepository(),
  );

  var state = base.state.copyWith(
    clock: const SimulationClock(currentYear: 2016),
  );

  state = state.copyWith(
    lifeProgress: state.lifeProgress.copyWith(
      education: education ??
          const EducationState(
            initialized: true,
            stage: SchoolStage.high,
          ),
    ),
  );

  return SimulationEngine(
    initialState: state,
    random: SeededRandom(3),
    saveRepository: InMemorySaveRepository(),
  );
}

/// A high school student that already has a school.
EducationState _withSchool() {
  final engine = _engine(null)..ensureSchool();

  return engine.state.lifeProgress.education;
}

void main() {
  test('joining a club starts at a fair performance, and only one at a time',
      () {
    final engine = _engine(_withSchool());

    expect(engine.joinClub('sports').isSuccess, isTrue);

    final education = engine.state.lifeProgress.education;

    expect(education.club, 'Soccer Team');
    expect(education.clubPerformance, 30);
    expect(education.clubRank, 0);

    expect(engine.joinClub('art').isFailure, isTrue);
  });

  test('training raises performance once a year', () {
    final engine = _engine(_withSchool());

    engine.joinClub('drama');

    expect(engine.trainClub().isSuccess, isTrue);
    expect(
      engine.state.lifeProgress.education.clubPerformance,
      greaterThanOrEqualTo(38),
    );
    expect(engine.trainClub().isFailure, isTrue);
  });

  test('enough performance makes the player vice, then the leader', () {
    var engine = _engine(
      _withSchool().copyWith(
        club: 'Sports Team',
        clubPerformance: SchoolActions.viceAt - 5,
      ),
    );

    expect(engine.trainClub().isSuccess, isTrue);

    var education = engine.state.lifeProgress.education;

    expect(education.clubRank, 1);
    expect(engine.clubPromotion, 1);

    engine.acknowledgeClubPromotion();
    expect(engine.clubPromotion, isNull);

    engine = _engine(
      _withSchool().copyWith(
        club: 'Sports Team',
        clubRank: 1,
        clubPerformance: SchoolActions.leadAt - 5,
      ),
    );

    expect(engine.trainClub().isSuccess, isTrue);

    education = engine.state.lifeProgress.education;

    expect(education.clubRank, 2);
    expect(engine.clubPromotion, 2);
  });

  test('every club has its own titles', () {
    expect(
      SchoolActions.clubById('sports')!.titleFor(2),
      'Captain',
    );

    for (final club in SchoolActions.clubs) {
      expect(club.viceTitle, isNot(club.leadTitle));
      expect(club.titleFor(0), 'Member');
    }
  });

  test('leaving a club clears performance and rank', () {
    final engine = _engine(
      _withSchool().copyWith(
        club: 'Sports Team',
        clubRank: 1,
        clubPerformance: 70,
      ),
    );

    expect(engine.leaveClub().isSuccess, isTrue);

    final education = engine.state.lifeProgress.education;

    expect(education.club, isNull);
    expect(education.clubPerformance, 0);
    expect(education.clubRank, 0);
    expect(engine.leaveClub().isFailure, isTrue);
  });

  test('club progress survives save and load; old saves default to none', () {
    final education = _withSchool().copyWith(
      club: 'Music Band',
      clubRank: 1,
      clubPerformance: 66,
      lastTrainYear: 2016,
    );

    final loaded = EducationState.fromJson(education.toJson());

    expect(loaded.club, 'Music Band');
    expect(loaded.clubRank, 1);
    expect(loaded.clubPerformance, 66);
    expect(loaded.lastTrainYear, 2016);

    final old = EducationState.fromJson({'stage': 'high', 'club': 'Art Club'});

    expect(old.clubPerformance, 0);
    expect(old.clubRank, 0);
  });

  test('school stories are varied', () {
    final seen = <String>{};

    for (var seed = 0; seed < 60; seed++) {
      seen.add(SchoolNarratives.study(SeededRandom(seed), SchoolStage.high));
    }

    expect(seen.length, greaterThan(4));

    final training = <String>{};

    for (var seed = 0; seed < 60; seed++) {
      training.add(SchoolNarratives.train(SeededRandom(seed), 'sports'));
    }

    expect(training.length, greaterThan(2));
  });

  test('even the slowest player becomes the leader by grade 3', () {
    // Join in grade 1 with the weakest practice (+8) and the yearly +6.
    const start = 30;
    const practice = 8;
    const yearly = 6;

    const grade2 = start + practice + yearly + practice;
    const grade3 = grade2 + yearly + practice;

    expect(grade2, greaterThanOrEqualTo(SchoolActions.viceAt));
    expect(grade3, greaterThanOrEqualTo(SchoolActions.leadAt));
  });

  test('there are many clubs, with sports like basketball and baseball', () {
    final ids = SchoolActions.clubs.map((club) => club.id).toSet();
    final names = SchoolActions.clubs.map((club) => club.name).toSet();

    expect(SchoolActions.clubs.length, greaterThanOrEqualTo(20));
    expect(ids.length, SchoolActions.clubs.length);
    expect(names.length, SchoolActions.clubs.length);
    expect(ids, containsAll(['sports', 'basketball', 'baseball']));

    for (final club in SchoolActions.clubs) {
      expect(
        SchoolNarratives.train(SeededRandom(1), club.id),
        isNotEmpty,
        reason: club.id,
      );
      expect(
        SchoolNarratives.join(
          SeededRandom(1),
          clubId: club.id,
          category: club.category,
          clubName: club.name,
          school: 'Test School',
        ),
        contains(club.name),
        reason: club.id,
      );
    }
  });

  test('saves that call the soccer team "Sports Team" still work', () {
    expect(SchoolActions.clubByName('Sports Team')?.id, 'sports');
    expect(SchoolActions.clubByName('Soccer Team')?.id, 'sports');
  });
}
