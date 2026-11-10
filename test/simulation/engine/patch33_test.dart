import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/love/love_state.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  SimulationEngine engineAt({
    required int birthYear,
    int year = 2026,
    LifeProgress? progress,
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
        lifeProgress: progress ?? base.state.lifeProgress,
      ),
      random: SeededRandom(1),
      saveRepository: InMemorySaveRepository(),
    );
  }

  SchoolNpc person({int birthYear = 2010, int score = 70}) => SchoolNpc(
        id: 'crush-1',
        firstName: 'Dewi',
        lastName: 'Lestari',
        gender: Gender.female,
        birthYear: birthYear,
        role: SchoolRole.classmate,
        relationshipPercent: score,
      );

  test('marital rows start at 15 and name the partner', () {
    expect(MaritalInfo.rows(age: 14), isEmpty);
    expect(MaritalInfo.rows(age: 15).single.value, 'Single');

    final dating = MaritalInfo.rows(age: 20, partnerName: 'Dewi Lestari');

    expect(dating.single.value, 'Dating Dewi Lestari');

    final married = MaritalInfo.rows(
      age: 40,
      partnerName: 'Budi',
      married: true,
      children: 2,
    );

    expect(married.first.value, 'Married to Budi');
    expect(married.last, const MapEntry('Children', '2'));
  });

  test('a breakup moves the person to the exes for good', () {
    final engine = engineAt(
      birthYear: 2010,
      progress: LifeProgress(
        education: EducationState(npcs: [person()]),
      ),
    );

    engine.interactWithNpc(npcId: 'crush-1', action: 'Start Dating');
    engine.interactWithNpc(npcId: 'crush-1', action: 'Break Up');

    final love = engine.state.lifeProgress.love;

    expect(love.partnerId, isNull);
    expect(love.exIds, {'crush-1'});
    expect(
      engine.state.lifeProgress.friends.single.relationshipPercent,
      lessThan(20),
    );
    expect(
      engine
          .interactWithNpc(npcId: 'crush-1', action: 'Start Dating')
          .isFailure,
      isTrue,
    );
    expect(LoveState.fromJson(love.toJson()).exIds, {'crush-1'});
  });

  test('a baby player can only play and cry', () {
    final engine = engineAt(birthYear: 2026);
    final parent = engine.state.familyHousehold!.parents.first;

    expect(
      engine.interactWithNpc(npcId: parent.id, action: 'Talk').isFailure,
      isTrue,
    );
    expect(
      engine.interactWithNpc(npcId: parent.id, action: 'Play').isSuccess,
      isTrue,
    );
    expect(
      engine.interactWithNpc(npcId: parent.id, action: 'Cry').isSuccess,
      isTrue,
    );
  });

  test('a baby NPC can only be played with', () {
    final baby = person(birthYear: 2025);
    final engine = engineAt(
      birthYear: 2010,
      progress: LifeProgress(friends: [baby]),
    );

    expect(
      engine.interactWithNpc(npcId: baby.id, action: 'Talk').isFailure,
      isTrue,
    );
    expect(
      engine.interactWithNpc(npcId: baby.id, action: 'Play').isSuccess,
      isTrue,
    );
    // An older person cannot be "played" with.
    expect(
      engineAt(
        birthYear: 2010,
        progress: LifeProgress(friends: [person()]),
      ).interactWithNpc(npcId: 'crush-1', action: 'Play').isFailure,
      isTrue,
    );
  });

  test('spend time with everyone: one log entry, once a year', () {
    final engine = engineAt(
      birthYear: 2006,
      progress: LifeProgress(friends: [person(birthYear: 2006)]),
    );

    expect(engine.canSpendTimeWithEveryone, isTrue);

    final before = engine.state.events.length;
    final result = engine.spendTimeWithEveryone();

    expect(result.isSuccess, isTrue);
    expect(engine.state.events.length, before + 1);
    expect(engine.state.events.last.title, 'Time with everyone');
    expect(engine.canSpendTimeWithEveryone, isFalse);
    expect(engine.spendTimeWithEveryone().isFailure, isTrue);
  });
}
