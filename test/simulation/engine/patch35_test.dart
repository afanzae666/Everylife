import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/domain/love/love_state.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/events/event_subjects.dart';

void main() {
  SimulationEngine engineWith({
    required LifeProgress progress,
    int cash = 0,
  }) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        gender: Gender.male,
        birthYear: 2000,
      ),
      seed: 3,
      saveRepository: InMemorySaveRepository(),
    );

    return SimulationEngine(
      initialState: base.state.copyWith(
        clock: SimulationClock(currentYear: 2026),
        player: base.state.player.copyWith(
          money: Money.fromMinorUnits(cash),
        ),
        lifeProgress: progress,
      ),
      random: SeededRandom(1),
      saveRepository: InMemorySaveRepository(),
    );
  }

  SchoolNpc partner({int score = 100}) => SchoolNpc(
        id: 'pal-1',
        firstName: 'Dewi',
        lastName: 'Lestari',
        gender: Gender.female,
        birthYear: 2000,
        role: SchoolRole.classmate,
        relationshipPercent: score,
      );

  LifeProgress progressFor({
    String stage = LoveRules.stageDating,
    int since = 2024,
    int score = 100,
    String? prenup,
    Set<String> flags = const {},
    PendingLifeEvent? pending,
  }) =>
      LifeProgress(
        friends: [partner(score: score)],
        flags: flags,
        pending: pending,
        love: LoveState(
          partnerId: 'pal-1',
          partnerSince: 2023,
          stage: stage,
          stageSince: since,
          prenup: prenup,
        ),
      );

  test('partner words and marital rows follow the stage', () {
    expect(LoveRules.partnerLabel('dating', Gender.female), 'Girlfriend');
    expect(LoveRules.partnerLabel('dating', Gender.male), 'Boyfriend');
    expect(LoveRules.partnerLabel('engaged', Gender.female), 'Fiancée');
    expect(LoveRules.partnerLabel('engaged', Gender.male), 'Fiancé');
    expect(LoveRules.partnerLabel('married', Gender.female), 'Wife');
    expect(LoveRules.partnerLabel('married', Gender.male), 'Husband');
    expect(LoveRules.exLabel(Gender.female, wasSpouse: true), 'Ex-wife');
    expect(LoveRules.exLabel(Gender.male), 'Ex');

    expect(
      MaritalInfo.rows(age: 30, partnerName: 'Dewi', stage: 'engaged')
          .first
          .value,
      'Engaged to Dewi',
    );
    expect(
      MaritalInfo.rows(age: 30, partnerName: 'Dewi', stage: 'married')
          .map((row) => row.key),
      ['Marital Status', 'Children'],
    );
    expect(MaritalInfo.rows(age: 30, divorced: true).first.value, 'Divorced');
  });

  test('love state keeps the new fields in a save', () {
    const love = LoveState(
      partnerId: 'pal-1',
      stage: 'married',
      stageSince: 2025,
      prenup: 'fair',
      exSpouseIds: {'old-1'},
      divorced: true,
    );
    final back = LoveState.fromJson(love.toJson());

    expect(back.stage, 'married');
    expect(back.stageSince, 2025);
    expect(back.prenup, 'fair');
    expect(back.exSpouseIds, {'old-1'});
    expect(back.divorced, isTrue);
    expect(LoveState.fromJson(const {'partnerId': 'x'}).stage, 'dating');
  });

  test('a long, close couple can get engaged, and it costs the ring', () {
    final engine = engineWith(progress: progressFor(), cash: 100000000);

    expect(engine.canGetEngaged('pal-1'), isTrue);

    final result = engine.proposeEngagement(npcId: 'pal-1', ringId: 'luxury');

    expect(result.isSuccess, isTrue);
    expect(engine.state.lifeProgress.love.stage, 'engaged');
    expect(engine.state.lifeProgress.flags, contains('engaged'));
    expect(engine.state.player.money.minorUnits, lessThan(100000000));
    expect(engine.state.player.debt.minorUnits, 0);
    expect(engine.canGetEngaged('pal-1'), isFalse);
  });

  test('it is too soon to propose in the first year', () {
    final engine = engineWith(progress: progressFor(since: 2026));

    expect(engine.canGetEngaged('pal-1'), isFalse);
    expect(
      engine.proposeEngagement(npcId: 'pal-1', ringId: 'simple').isFailure,
      isTrue,
    );
  });

  test('marriage needs an engagement of at least a year', () {
    final soon = engineWith(
      progress: progressFor(stage: 'engaged', since: 2026),
    );

    expect(soon.canGetMarried('pal-1'), isFalse);
    expect(
      soon
          .marry(npcId: 'pal-1', prenupId: 'none', weddingId: 'courthouse')
          .isFailure,
      isTrue,
    );

    final ready = engineWith(
      progress: progressFor(stage: 'engaged', since: 2024),
    );

    expect(
      ready
          .marry(npcId: 'pal-1', prenupId: 'none', weddingId: 'elope')
          .isSuccess,
      isTrue,
    );

    final love = ready.state.lifeProgress.love;

    expect(love.isMarried, isTrue);
    expect(love.prenup, 'none');
    expect(ready.state.player.debt.minorUnits, 0);
    expect(ready.state.lifeProgress.flags, contains('married'));
    expect(ready.state.lifeProgress.flags, isNot(contains('engaged')));
  });

  test('nothing is bought on credit: no cash, no ring and no big wedding', () {
    final broke = engineWith(progress: progressFor());

    expect(
      broke.proposeEngagement(npcId: 'pal-1', ringId: 'luxury').isFailure,
      isTrue,
    );
    expect(broke.state.lifeProgress.love.stage, 'dating');

    final noWedding = engineWith(
      progress: progressFor(stage: 'engaged', since: 2024),
    );

    expect(
      noWedding
          .marry(npcId: 'pal-1', prenupId: 'fair', weddingId: 'grand')
          .isFailure,
      isTrue,
    );
    expect(noWedding.state.player.debt.minorUnits, 0);
  });

  test('chatting with an engaged partner keeps the engaged label', () {
    final engine = engineWith(
      progress: progressFor(stage: 'engaged', since: 2024, score: 60),
    );
    final result = engine.interactWithNpc(npcId: 'pal-1', action: 'Talk');
    final outcome = (result as Success<NpcInteractionOutcome>).value;

    expect(outcome.stage, 'engaged');
    expect(outcome.romance, 'partner');
    expect(outcome.prompt, isNull);
  });

  test('a partner is never asked to become a best friend', () {
    final engine = engineWith(
      progress: progressFor(stage: 'married', prenup: 'none', score: 99),
    );
    final result = engine.interactWithNpc(npcId: 'pal-1', action: 'Talk');
    final outcome = (result as Success<NpcInteractionOutcome>).value;

    expect(outcome.prompt, isNull);
    expect(outcome.stage, 'married');
  });

  test('a married couple cannot simply break up', () {
    final engine = engineWith(
      progress: progressFor(stage: 'married', prenup: 'none'),
    );

    expect(
      engine.interactWithNpc(npcId: 'pal-1', action: 'Break Up').isFailure,
      isTrue,
    );
  });

  test('divorcing without grounds splits the cash and pays a fine', () {
    final engine = engineWith(
      progress: progressFor(stage: 'married', prenup: 'none'),
      cash: 1000000,
    );

    expect(engine.divorce(npcId: 'pal-1').isSuccess, isTrue);

    final progress = engine.state.lifeProgress;

    expect(progress.love.partnerId, isNull);
    expect(progress.love.exIds, contains('pal-1'));
    expect(progress.love.exSpouseIds, contains('pal-1'));
    expect(progress.love.divorced, isTrue);
    expect(progress.flags, contains('divorced'));
    expect(progress.flags, isNot(contains('married')));
    expect(
      progress.friends.firstWhere((f) => f.id == 'pal-1').relationshipPercent,
      0,
    );
    expect(engine.state.player.money.minorUnits, lessThan(500000));
  });

  test('an ironclad prenup protects my cash, but the fine still applies', () {
    final engine = engineWith(
      progress: progressFor(stage: 'married', prenup: 'ironclad'),
      cash: 1000000,
    );

    expect(engine.divorce(npcId: 'pal-1').isSuccess, isTrue);
    expect(engine.state.player.money.minorUnits, lessThan(1000000));
    expect(engine.state.player.money.minorUnits, greaterThan(0));
  });

  test('divorcing a cheating spouse costs nothing', () {
    final engine = engineWith(
      progress: progressFor(
        stage: 'married',
        prenup: 'none',
        flags: {'married', 'spouse_cheated'},
      ),
      cash: 1000000,
    );

    expect(engine.divorce(npcId: 'pal-1').isSuccess, isTrue);
    expect(engine.state.player.money.minorUnits, 1000000);
    expect(engine.state.lifeProgress.flags, isNot(contains('spouse_cheated')));
  });

  test('a spouse who asks for a divorce in an event gets one', () {
    final engine = engineWith(
      progress: progressFor(
        stage: 'married',
        prenup: 'none',
        flags: {'married'},
        pending: const PendingLifeEvent(
          eventId: 'marriage_wants_out',
          year: 2026,
          subjectNpcId: 'pal-1',
          subjectName: 'Dewi Lestari',
          subjectFirst: 'Dewi',
          subjectRole: 'my wife',
          subjectGender: 'female',
        ),
      ),
      cash: 1000000,
    );

    expect(engine.resolveLifeChoice('agree').isSuccess, isTrue);

    final progress = engine.state.lifeProgress;

    expect(progress.love.partnerId, isNull);
    expect(progress.love.exSpouseIds, contains('pal-1'));
    expect(progress.flags, isNot(contains('divorce_filed_unclear')));
    expect(
      engine.state.events.any((event) => event.title == 'Divorce'),
      isTrue,
    );
  });

  test('married-life events only appear with a spouse', () {
    final single = engineWith(progress: const LifeProgress());
    final married = engineWith(
      progress: progressFor(stage: 'married', flags: {'married'}),
    );

    expect(
      EventSubjects.isAvailable(EventSubjectKind.partner, single.state),
      isFalse,
    );
    expect(
      EventSubjects.isAvailable(EventSubjectKind.partner, married.state),
      isTrue,
    );
  });
}
