import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
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

  test('a single player can get intimate with a friend', () {
    final engine = engineWith(
      progress: progressFor(hasPartner: false),
    );
    final outcome =
        outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex'));

    expect(outcome.romance, 'none');
    expect(engine.state.lifeProgress.love.partnerId, isNull);
  });

  test('with a partner I am only intimate with them', () {
    final engine = engineWith(progress: progressFor());

    expect(
      engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex').isFailure,
      isTrue,
    );
    expect(engine.state.lifeProgress.interactionCounts, isEmpty);
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
}
