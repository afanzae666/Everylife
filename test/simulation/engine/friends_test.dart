import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/fertility.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  const person = SchoolNpc(
    id: 'stranger-2026-1',
    firstName: 'Dewi',
    lastName: 'Lestari',
    gender: Gender.female,
    birthYear: 2010,
    role: SchoolRole.classmate,
    relationshipPercent: 20,
  );

  SimulationEngine engineWith(LifeProgress progress) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2010,
      ),
      seed: 5,
      saveRepository: InMemorySaveRepository(),
    );

    // The clock starts at the birth year, so move it to age 16.
    return SimulationEngine(
      initialState: base.state.copyWith(
        clock: const SimulationClock(currentYear: 2026),
        lifeProgress: progress,
      ),
      random: SeededRandom(1),
      saveRepository: InMemorySaveRepository(),
    );
  }

  test('friends survive save and load, and old saves have none', () {
    final progress = LifeProgress(
      friends: [person.copyWith(relationshipPercent: 60)],
    );
    final loaded = LifeProgress.fromJson(progress.toJson());

    expect(loaded.friends.single.id, person.id);
    expect(loaded.friends.single.relationshipPercent, 60);
    expect(LifeProgress.fromJson({'flags': <String>[]}).friends, isEmpty);
  });

  test('a friend event outcome adds the person as a friend', () {
    final engine = engineWith(
      LifeProgress(
        pending: PendingLifeEvent(
          eventId: 'school_new_friend',
          year: 2026,
          subjectNpcId: person.id,
          subjectKind: EventSubjectKind.stranger.name,
          subjectName: 'Dewi Lestari',
          subjectFirst: 'Dewi',
          subjectRole: 'a stranger',
          subjectGender: Gender.female.name,
          subjectPerson: person,
        ),
      ),
    );

    final result = engine.resolveLifeChoice('trade');

    expect(result.isSuccess, isTrue);

    // The event only offers; nobody is a friend until I say yes.
    expect(engine.state.lifeProgress.friends, isEmpty);
    expect(engine.friendOffer?.id, person.id);

    final accepted = engine.acceptFriendOffer();

    expect(accepted.isSuccess, isTrue);
    expect(engine.friendOffer, isNull);

    final friends = engine.state.lifeProgress.friends;

    expect(friends, hasLength(1));
    expect(friends.single.id, person.id);
    expect(friends.single.relationshipPercent, greaterThanOrEqualTo(50));
  });

  test('declining a friend offer keeps the person out of the list', () {
    final engine = engineWith(
      LifeProgress(
        pending: PendingLifeEvent(
          eventId: 'school_new_friend',
          year: 2026,
          subjectNpcId: person.id,
          subjectKind: EventSubjectKind.stranger.name,
          subjectName: 'Dewi Lestari',
          subjectFirst: 'Dewi',
          subjectRole: 'a stranger',
          subjectGender: Gender.female.name,
          subjectPerson: person,
        ),
      ),
    );

    engine.resolveLifeChoice('trade');
    engine.declineFriendOffer();

    expect(engine.friendOffer, isNull);
    expect(engine.state.lifeProgress.friends, isEmpty);
    expect(engine.acceptFriendOffer().isFailure, isTrue);
    expect(
      engine.state.events.any((e) => e.title == 'Said no to a friend'),
      isTrue,
    );
  });

  test('a classmate becomes a friend only through the interaction', () {
    final engine = engineWith(
      LifeProgress(
        education: EducationState(
          npcs: [person.copyWith(relationshipPercent: 30)],
        ),
      ),
    );

    expect(
      engine
          .interactWithNpc(npcId: person.id, action: 'Become Friends')
          .isFailure,
      isTrue,
    );

    final ready = engineWith(
      LifeProgress(
        education: EducationState(
          npcs: [person.copyWith(relationshipPercent: 55)],
        ),
      ),
    );

    final result = ready.interactWithNpc(
      npcId: person.id,
      action: 'Become Friends',
    );

    expect(result.isSuccess, isTrue);
    expect(ready.state.lifeProgress.friends.single.id, person.id);
  });

  test('a best friend is asked first, and the answer is remembered', () {
    final engine = engineWith(
      LifeProgress(
        friends: [person.copyWith(relationshipPercent: 83)],
      ),
    );

    final talk = engine.interactWithNpc(
      npcId: person.id,
      action: 'Spend Time',
    );
    final outcome = (talk as Success<NpcInteractionOutcome>).value;

    expect(outcome.relationshipPercent, greaterThanOrEqualTo(85));
    expect(outcome.prompt, 'bestFriend');

    engine.interactWithNpc(
      npcId: person.id,
      action: NpcInteractionOutcome.bestFriendYes,
    );

    final friend = engine.state.lifeProgress.friends.single;

    expect(friend.bestFriend, isTrue);

    final again = engine.interactWithNpc(
      npcId: person.id,
      action: 'Spend Time',
    );

    expect((again as Success<NpcInteractionOutcome>).value.prompt, isNull);
  });

  test('best friend flags survive save and load', () {
    final progress = LifeProgress(
      friends: [person.copyWith(bestFriend: true, bestFriendAsked: true)],
    );
    final loaded = LifeProgress.fromJson(progress.toJson());

    expect(loaded.friends.single.bestFriend, isTrue);
    expect(loaded.friends.single.bestFriendAsked, isTrue);
  });

  test('fertility is steady per person and follows age', () {
    final a = Fertility.baselineFor('someone');

    expect(Fertility.baselineFor('someone'), a);
    expect(a, inInclusiveRange(60, 100));
    expect(Fertility.effective(a, 5, Gender.female), 0);
    expect(
      Fertility.effective(a, 25, Gender.female),
      greaterThan(Fertility.effective(a, 45, Gender.female)),
    );

    final traits = NpcTraits.forPerson(
      id: person.id,
      gender: person.gender,
      birthYear: person.birthYear,
      currentYear: 2026,
    );

    expect(traits.looks, inInclusiveRange(35, 90));
    expect(traits.smarts, inInclusiveRange(35, 90));
  });

  test('a friend can be talked to and the score is saved', () {
    final engine = engineWith(
      LifeProgress(
        friends: [person.copyWith(relationshipPercent: 50)],
      ),
    );

    final result = engine.interactWithNpc(
      npcId: person.id,
      action: 'Spend Time',
    );

    expect(result.isSuccess, isTrue);
    expect(engine.state.lifeProgress.friends.single.relationshipPercent, 55);
  });

  test('unknown people are still rejected', () {
    final engine = engineWith(const LifeProgress());

    final result = engine.interactWithNpc(npcId: 'nobody', action: 'Talk');

    expect(result.isSuccess, isFalse);
  });
}
