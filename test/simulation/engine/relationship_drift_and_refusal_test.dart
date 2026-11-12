import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/domain/love/love_state.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  SimulationEngine engineWith({
    required int birthYear,
    required LifeProgress progress,
    int year = 2026,
  }) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        gender: Gender.male,
        birthYear: birthYear,
      ),
      seed: 3,
      saveRepository: InMemorySaveRepository(),
    );

    return SimulationEngine(
      initialState: base.state.copyWith(
        clock: SimulationClock(currentYear: year),
        lifeProgress: progress,
      ),
      random: SeededRandom(1),
      saveRepository: InMemorySaveRepository(),
    );
  }

  SchoolNpc person({int score = 60, String id = 'pal-1'}) => SchoolNpc(
        id: id,
        firstName: 'Dewi',
        lastName: 'Lestari',
        gender: Gender.female,
        birthYear: 2000,
        role: SchoolRole.classmate,
        relationshipPercent: score,
      );

  SchoolNpc scoreOf(SimulationEngine engine, String id) => engine
      .state.lifeProgress.friends
      .firstWhere((friend) => friend.id == id);

  test('hide deceased is saved as a flag and can be switched back', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: const LifeProgress(),
    );

    expect(engine.hideDeceased, isFalse);

    engine.setHideDeceased(hide: true);

    expect(engine.hideDeceased, isTrue);

    engine.setHideDeceased(hide: false);

    expect(engine.hideDeceased, isFalse);
  });

  test('people nobody talks to drift apart at the next birthday', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: LifeProgress(friends: [person()]),
    );

    expect(engine.ageUp().isSuccess, isTrue);

    expect(scoreOf(engine, 'pal-1').relationshipPercent, lessThan(60));
    expect(scoreOf(engine, 'pal-1').relationshipPercent, greaterThan(40));
  });

  test('keeping in touch stops the drift', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: LifeProgress(friends: [person()]),
    );

    expect(
      engine.interactWithNpc(npcId: 'pal-1', action: 'Talk').isSuccess,
      isTrue,
    );

    final before = scoreOf(engine, 'pal-1').relationshipPercent;

    expect(engine.ageUp().isSuccess, isTrue);
    expect(scoreOf(engine, 'pal-1').relationshipPercent, before);
  });

  test('exes do not fade', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: LifeProgress(
        friends: [person(score: 30)],
        love: const LoveState(exIds: {'pal-1'}),
      ),
    );

    expect(engine.ageUp().isSuccess, isTrue);
    expect(scoreOf(engine, 'pal-1').relationshipPercent, 30);
  });

  test('someone very distant refuses most of the time, never changing the '
      'score', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: LifeProgress(friends: [person(score: 0)]),
    );
    var refused = 0;

    for (var i = 0; i < 10; i++) {
      final before = scoreOf(engine, 'pal-1').relationshipPercent;
      final result = engine.interactWithNpc(npcId: 'pal-1', action: 'Talk');

      expect(result.isSuccess, isTrue);

      final outcome = (result as Success<NpcInteractionOutcome>).value;

      if (!outcome.progressed) {
        refused++;
        expect(outcome.relationshipPercent, before);
        expect(scoreOf(engine, 'pal-1').relationshipPercent, before);
      }
    }

    expect(refused, greaterThanOrEqualTo(1));
  });

  test('an ex with enough trust can get back together', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: LifeProgress(
        friends: [person(score: 55)],
        love: const LoveState(exIds: {'pal-1'}),
      ),
    );

    expect(
      engine.interactWithNpc(npcId: 'pal-1', action: 'Get Back Together')
          .isSuccess,
      isTrue,
    );

    final love = engine.state.lifeProgress.love;

    expect(love.partnerId, 'pal-1');
    expect(love.exIds, isEmpty);
  });

  test('an ex who is still hurt will not get back together', () {
    final engine = engineWith(
      birthYear: 2000,
      progress: LifeProgress(
        friends: [person(score: 20)],
        love: const LoveState(exIds: {'pal-1'}),
      ),
    );

    expect(
      engine.interactWithNpc(npcId: 'pal-1', action: 'Get Back Together')
          .isFailure,
      isTrue,
    );
    expect(engine.state.lifeProgress.love.exIds, contains('pal-1'));
  });
}
