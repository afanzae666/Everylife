import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
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

    return SimulationEngine(
      initialState: base.state.copyWith(lifeProgress: progress),
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

    final friends = engine.state.lifeProgress.friends;

    expect(friends, hasLength(1));
    expect(friends.single.id, person.id);
    expect(friends.single.relationshipPercent, greaterThanOrEqualTo(50));
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
