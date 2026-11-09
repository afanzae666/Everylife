import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/appearance.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/domain/love/genetics.dart';
import 'package:everylife/domain/love/love_state.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/school/school_appearance.dart';

void main() {
  SchoolNpc person({
    int birthYear = 2010,
    int score = 70,
    Gender gender = Gender.female,
  }) =>
      SchoolNpc(
        id: 'crush-1',
        firstName: 'Dewi',
        lastName: 'Lestari',
        gender: gender,
        birthYear: birthYear,
        role: SchoolRole.classmate,
        relationshipPercent: score,
      );

  SimulationEngine engineWith({
    required int playerBirthYear,
    required LifeProgress progress,
    int year = 2026,
    Gender gender = Gender.male,
  }) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        gender: gender,
        birthYear: playerBirthYear,
        appearance: const CharacterAppearance(
          skinTone: 'medium',
          hairColor: 'black',
          eyeColor: 'brown',
          eyebrows: 'straight',
        ),
      ),
      seed: 5,
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

  LifeProgress withClassmate(SchoolNpc npc) => LifeProgress(
        education: EducationState(npcs: [npc]),
      );

  test('dating rules protect minors and open at high school age', () {
    expect(LoveRules.canDate(14, 14), isFalse);
    expect(LoveRules.canDate(16, 15), isTrue);
    expect(LoveRules.canDate(16, 25), isFalse);
    expect(LoveRules.canDate(17, 19), isTrue);
    expect(LoveRules.canDate(30, 16), isFalse);
    expect(LoveRules.canDate(30, 40), isTrue);
    expect(LoveRules.canBeIntimate(17, 18), isFalse);
    expect(LoveRules.canBeIntimate(18, 18), isTrue);
  });

  test('a classmate becomes a partner only when close enough', () {
    final far = engineWith(
      playerBirthYear: 2010,
      progress: withClassmate(person(score: 40)),
    );

    expect(
      far.interactWithNpc(npcId: 'crush-1', action: 'Start Dating').isFailure,
      isTrue,
    );

    final engine = engineWith(
      playerBirthYear: 2010,
      progress: withClassmate(person()),
    );
    final result =
        engine.interactWithNpc(npcId: 'crush-1', action: 'Start Dating');

    expect(result.isSuccess, isTrue);
    expect(
      (result as Success<NpcInteractionOutcome>).value.romance,
      'partner',
    );
    expect(engine.state.lifeProgress.love.partnerId, 'crush-1');
    expect(engine.state.lifeProgress.friends.single.id, 'crush-1');

    // One partner at a time.
    expect(
      engine.interactWithNpc(npcId: 'crush-1', action: 'Start Dating').isFailure,
      isTrue,
    );
  });

  test('a teenager cannot date an adult, and cannot be intimate', () {
    final adult = engineWith(
      playerBirthYear: 2010,
      progress: withClassmate(person(birthYear: 2000)),
    );

    expect(
      adult
          .interactWithNpc(npcId: 'crush-1', action: 'Start Dating')
          .isFailure,
      isTrue,
    );

    final teen = engineWith(
      playerBirthYear: 2010,
      progress: withClassmate(person()),
    );

    teen.interactWithNpc(npcId: 'crush-1', action: 'Start Dating');

    expect(
      teen.interactWithNpc(npcId: 'crush-1', action: 'Have Sex').isFailure,
      isTrue,
    );
    expect(
      teen.interactWithNpc(npcId: 'crush-1', action: 'Go on a Date').isSuccess,
      isTrue,
    );
  });

  test('a breakup ends the relationship', () {
    final engine = engineWith(
      playerBirthYear: 2010,
      progress: withClassmate(person()),
    );

    engine.interactWithNpc(npcId: 'crush-1', action: 'Start Dating');

    final result =
        engine.interactWithNpc(npcId: 'crush-1', action: 'Break Up');

    expect(result.isSuccess, isTrue);
    expect(engine.state.lifeProgress.love.partnerId, isNull);
    expect(
      engine.state.lifeProgress.friends.single.relationshipPercent,
      lessThan(70),
    );
  });

  test('adults can be intimate with a partner they are close to', () {
    final engine = engineWith(
      playerBirthYear: 2000,
      progress: withClassmate(person(birthYear: 2000, score: 90)),
    );

    engine.interactWithNpc(npcId: 'crush-1', action: 'Start Dating');

    expect(
      engine.interactWithNpc(npcId: 'crush-1', action: 'Have Sex').isSuccess,
      isTrue,
    );
  });

  test('a baby is born at the next birthday and inherits from both parents',
      () {
    final partner = person(birthYear: 2000, score: 90);
    final engine = engineWith(
      playerBirthYear: 2000,
      progress: LifeProgress(
        friends: [partner],
        love: LoveState(
          partnerId: partner.id,
          partnerSince: 2025,
          pregnancy: Pregnancy(conceivedYear: 2026, partner: partner),
        ),
      ),
    );

    expect(engine.ageUp().isSuccess, isTrue);

    final love = engine.state.lifeProgress.love;

    expect(love.pregnancy, isNull);
    expect(love.children, hasLength(1));
    expect(engine.takeNewborn()?.id, love.children.single.id);
    expect(engine.takeNewborn(), isNull);

    final child = love.children.single;
    final theirs = SchoolAppearance.forNpc(partner);

    expect(['black', theirs.hairColor], contains(child.hairColor));
    expect(['brown', theirs.eyeColor], contains(child.eyeColor));
    expect(['straight', theirs.eyebrows], contains(child.eyebrows));
    expect(child.lastName, engine.state.player.resolvedLastName);
    expect(child.otherParentName, partner.fullName);

    final loaded = LoveState.fromJson(love.toJson());

    expect(loaded.children.single.hairColor, child.hairColor);
    expect(loaded.children.single.looks, child.looks);
  });

  test('a child can be talked to once a year for the bond', () {
    const child = ChildNpc(
      id: 'child-2026-1',
      firstName: 'Mira',
      lastName: 'Lestari',
      gender: Gender.female,
      birthYear: 2026,
      looks: 70,
      smarts: 70,
      fertilityBase: 80,
      skinTone: 'medium',
      hairColor: 'black',
      eyeColor: 'brown',
      eyebrows: 'straight',
      relationshipPercent: 60,
    );
    final engine = engineWith(
      playerBirthYear: 2000,
      progress: const LifeProgress(
        love: LoveState(children: [child]),
      ),
    );

    final result =
        engine.interactWithNpc(npcId: child.id, action: 'Spend Time');

    expect(result.isSuccess, isTrue);
    expect(
      engine.state.lifeProgress.love.children.single.relationshipPercent,
      65,
    );
  });

  test('genetics: children only get what the parents have', () {
    const a = ParentGenes(
      skinTone: 'pale',
      hairColor: 'black',
      eyeColor: 'brown',
      eyebrows: 'comma',
      looks: 80,
      smarts: 60,
      fertility: 90,
    );
    const b = ParentGenes(
      skinTone: 'tan',
      hairColor: 'ginger',
      eyeColor: 'green',
      eyebrows: 'comma',
      looks: 60,
      smarts: 80,
      fertility: 70,
    );

    for (var seed = 0; seed < 40; seed++) {
      final kid = Genetics.inherit(SeededRandom(seed), a, b);
      final skin = Genetics.skinScale.indexOf(kid.skinTone);

      expect(['black', 'ginger'], contains(kid.hairColor));
      expect(['brown', 'green'], contains(kid.eyeColor));
      expect(kid.eyebrows, 'comma');
      expect(skin, inInclusiveRange(0, Genetics.skinScale.indexOf('tan')));
      expect(kid.looks, inInclusiveRange(64, 76));
      expect(kid.smarts, inInclusiveRange(64, 76));
      expect(kid.fertility, inInclusiveRange(74, 86));
    }
  });

  test('a pregnancy asks first: keeping it is remembered, ending clears it',
      () {
    final partner = person(birthYear: 2000, score: 90);

    LifeProgress waiting() => LifeProgress(
          friends: [partner],
          love: LoveState(
            partnerId: partner.id,
            pregnancy: Pregnancy(conceivedYear: 2026, partner: partner),
          ),
        );

    final keep = engineWith(playerBirthYear: 2000, progress: waiting());

    expect(
      keep
          .interactWithNpc(
            npcId: partner.id,
            action: NpcInteractionOutcome.pregnancyKeep,
          )
          .isSuccess,
      isTrue,
    );
    expect(keep.state.lifeProgress.love.pregnancy?.decided, isTrue);

    final end = engineWith(playerBirthYear: 2000, progress: waiting());

    end.interactWithNpc(
      npcId: partner.id,
      action: NpcInteractionOutcome.pregnancyEnd,
    );

    expect(end.state.lifeProgress.love.pregnancy, isNull);
  });

  test('birth control toggles for a female partner and is saved', () {
    final partner = person(birthYear: 2000, score: 90);
    final engine = engineWith(
      playerBirthYear: 2000,
      progress: LifeProgress(
        friends: [partner],
        love: LoveState(partnerId: partner.id),
      ),
    );

    final on = engine.interactWithNpc(npcId: partner.id, action: 'Birth Control');

    expect((on as Success<NpcInteractionOutcome>).value.onBirthControl, isTrue);
    expect(
      LoveState.fromJson(engine.state.lifeProgress.love.toJson())
          .birthControl,
      {partner.id},
    );

    final off = engine.interactWithNpc(npcId: partner.id, action: 'Birth Control');

    expect((off as Success<NpcInteractionOutcome>).value.onBirthControl, isFalse);
  });

  test('a baby can be named, and the name suggestions fit the country', () {
    final partner = person(birthYear: 2000, score: 90);
    final engine = engineWith(
      playerBirthYear: 2000,
      progress: LifeProgress(
        friends: [partner],
        love: LoveState(
          partnerId: partner.id,
          pregnancy: Pregnancy(conceivedYear: 2026, partner: partner),
        ),
      ),
    );

    engine.ageUp();

    final baby = engine.takeNewborn()!;

    expect(engine.newbornNameSuggestions, isNotEmpty);
    expect(engine.randomNameFor(baby), isNotEmpty);
    expect(engine.nameChild(baby.id, '   ').isFailure, isTrue);
    expect(engine.nameChild(baby.id, 'Bintang').isSuccess, isTrue);
    expect(
      engine.state.lifeProgress.love.children.single.firstName,
      'Bintang',
    );
    expect(
      engine.state.events.any((e) => e.title == 'Baby named'),
      isTrue,
    );
  });

  test('old saves without love data still load', () {
    final loaded = LifeProgress.fromJson({'flags': <String>[]});

    expect(loaded.love.isEmpty, isTrue);
  });
}
