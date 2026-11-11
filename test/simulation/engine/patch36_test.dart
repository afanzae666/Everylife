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

void main() {
  SimulationEngine engineWith({
    required LifeProgress progress,
    int cash = 0,
    int seed = 1,
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
      random: SeededRandom(seed),
      saveRepository: InMemorySaveRepository(),
    );
  }

  SchoolNpc npc(String id, {int score = 100, Gender? gender}) => SchoolNpc(
        id: id,
        firstName: 'Dewi',
        lastName: id,
        gender: gender ?? Gender.female,
        birthYear: 2000,
        role: SchoolRole.classmate,
        relationshipPercent: score,
      );

  PendingLifeEvent pendingFor(String eventId) => PendingLifeEvent(
        eventId: eventId,
        year: 2026,
        subjectNpcId: 'pal-1',
        subjectName: 'Dewi pal-1',
        subjectFirst: 'Dewi',
        subjectRole: 'my wife',
        subjectGender: 'female',
      );

  LifeProgress progressFor({
    String stage = LoveRules.stageDating,
    Set<String> flags = const {},
    PendingLifeEvent? pending,
    List<SchoolNpc>? friends,
    bool hasPartner = true,
    String? prenup,
  }) =>
      LifeProgress(
        friends: friends ?? [npc('pal-1'), npc('fr-2', score: 80)],
        flags: flags,
        pending: pending,
        love: LoveState(
          partnerId: hasPartner ? 'pal-1' : null,
          partnerSince: 2023,
          stage: stage,
          stageSince: 2023,
          prenup: prenup,
        ),
      );

  NpcInteractionOutcome outcomeOf(Result<NpcInteractionOutcome> result) {
    expect(result.isSuccess, isTrue);

    return (result as Success<NpcInteractionOutcome>).value;
  }

  test('a friend who is never asked is offered best friendship', () {
    final engine = engineWith(
      progress: LifeProgress(friends: [npc('fr-2', score: 90)]),
    );

    expect(
      outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Talk')).prompt,
      'bestFriend',
    );
  });

  test('a perfect friend I once said no to asks again, in some years', () {
    var asked = 0;

    for (var seed = 1; seed <= 40; seed++) {
      final friend = npc('fr-2').copyWith(bestFriendAsked: true);
      final engine = engineWith(
        seed: seed,
        progress: LifeProgress(friends: [friend]),
      );
      final prompt =
          outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Talk'))
              .prompt;

      if (prompt == 'bestFriend') asked++;
    }

    expect(asked, greaterThan(0));
    expect(asked, lessThan(40));
  });

  test('getting intimate counts twice a year, then nothing happens', () {
    final engine = engineWith(progress: progressFor());

    expect(
      outcomeOf(engine.interactWithNpc(npcId: 'pal-1', action: 'Have Sex'))
          .progressed,
      isTrue,
    );
    expect(
      outcomeOf(engine.interactWithNpc(npcId: 'pal-1', action: 'Have Sex'))
          .progressed,
      isTrue,
    );
    expect(
      outcomeOf(engine.interactWithNpc(npcId: 'pal-1', action: 'Have Sex'))
          .progressed,
      isFalse,
    );
  });

  test('a single player can hook up with a friend, which is not cheating', () {
    final engine = engineWith(
      progress: progressFor(hasPartner: false),
    );
    final outcome =
        outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex'));

    expect(outcome.romance, 'none');
    expect(engine.state.lifeProgress.flags, isNot(contains('player_cheated')));
  });

  test('hooking up with someone else while taken is cheating', () {
    final engine = engineWith(progress: progressFor());

    outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex'));

    expect(engine.state.lifeProgress.flags, contains('player_cheated'));
    expect(engine.state.lifeProgress.love.partnerId, 'pal-1');
  });

  test('it takes some closeness to get intimate with a friend', () {
    final engine = engineWith(
      progress: progressFor(
        friends: [npc('pal-1'), npc('fr-2', score: 20)],
      ),
    );

    expect(
      engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex').isFailure,
      isTrue,
    );
  });

  test('cheating is sometimes found out, and the partner confronts me', () {
    var caught = 0;

    for (var seed = 1; seed <= 40; seed++) {
      final engine = engineWith(seed: seed, progress: progressFor());

      outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex'));

      if ((engine.state.lifeProgress.pending?.eventId ?? '')
              .startsWith('cheating_caught')) {
        caught++;
      }
    }

    expect(caught, greaterThan(0));
    expect(caught, lessThan(40));
  });

  test('being caught can end a relationship', () {
    var ended = 0;

    for (var seed = 1; seed <= 30; seed++) {
      final engine = engineWith(
        seed: seed,
        progress: progressFor(
          flags: {'player_cheated'},
          pending: pendingFor('cheating_caught'),
        ),
      );

      expect(engine.resolveLifeChoice('deny').isSuccess, isTrue);

      if (engine.state.lifeProgress.love.partnerId == null) {
        ended++;

        expect(engine.state.lifeProgress.love.exIds, contains('pal-1'));
        expect(
          engine.state.lifeProgress.flags,
          isNot(contains('player_cheated')),
        );
      }
    }

    expect(ended, greaterThan(0));
  });

  test('a proven affair asks me to divorce or stay', () {
    var asked = 0;

    for (var seed = 1; seed <= 30; seed++) {
      final engine = engineWith(
        seed: seed,
        progress: progressFor(
          stage: 'married',
          prenup: 'none',
          flags: {'married'},
          pending: pendingFor('marriage_suspicious_phone'),
        ),
      );

      expect(engine.resolveLifeChoice('confront').isSuccess, isTrue);

      final next = engine.state.lifeProgress.pending?.eventId ?? '';

      if (next.startsWith('marriage_divorce_choice')) {
        asked++;

        expect(engine.state.lifeProgress.flags, contains('spouse_cheated'));
        expect(
          engine.state.lifeProgress.flags,
          isNot(contains('cheating_proven')),
        );
      } else {
        // Not proven: only the relationship suffers.
        expect(engine.state.lifeProgress.love.isMarried, isTrue);
        expect(engine.state.lifeProgress.flags,
            isNot(contains('spouse_cheated')));
      }
    }

    expect(asked, greaterThan(0));
    expect(asked, lessThan(30));
  });

  test('divorcing a cheater from the decision costs nothing and is saved '
      'in the log', () {
    final engine = engineWith(
      cash: 1000000,
      progress: progressFor(
        stage: 'married',
        prenup: 'none',
        flags: {'married', 'spouse_cheated'},
        pending: pendingFor('marriage_divorce_choice_a'),
      ),
    );

    expect(engine.resolveLifeChoice('divorce').isSuccess, isTrue);
    expect(engine.state.lifeProgress.love.partnerId, isNull);
    expect(engine.state.lifeProgress.love.exSpouseIds, contains('pal-1'));
    expect(engine.state.player.money.minorUnits, 1000000);
    expect(
      engine.state.events.any((event) => event.title == 'Divorce'),
      isTrue,
    );
  });

  test('forgiving a cheating spouse keeps the marriage', () {
    final engine = engineWith(
      progress: progressFor(
        stage: 'married',
        prenup: 'none',
        flags: {'married', 'spouse_cheated'},
        pending: pendingFor('marriage_divorce_choice_b'),
      ),
    );

    expect(engine.resolveLifeChoice('stay').isSuccess, isTrue);
    expect(engine.state.lifeProgress.love.isMarried, isTrue);
    expect(engine.state.lifeProgress.flags, isNot(contains('spouse_cheated')));
  });
}
