import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/events/life_effect_applier.dart';
import 'package:everylife/simulation/generation/family_household_generator.dart';
import 'package:everylife/simulation/school/npc_place.dart';

void main() {
  SimulationEngine engineAt({
    required int birthYear,
    int year = 2026,
    Gender gender = Gender.female,
    LifeProgress? progress,
  }) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        gender: gender,
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

  test('going into debt is written in the life log', () {
    final engine = engineAt(birthYear: 2000);
    const outcome = LifeOutcome(text: 'Pricey.', moneyBase: -500000);

    final next = LifeEffectApplier.applyOutcome(
      state: engine.state,
      outcome: outcome,
    );

    expect(next.player.debt.minorUnits, greaterThan(0));
    expect(
      next.events.any((event) => event.title == 'Went into debt'),
      isTrue,
    );
  });

  test('no debt entry when the player can pay', () {
    final engine = engineAt(birthYear: 2000);
    const outcome = LifeOutcome(text: 'Free.', moneyBase: 0);

    final next = LifeEffectApplier.applyOutcome(
      state: engine.state,
      outcome: outcome,
    );

    expect(
      next.events.any((event) => event.title == 'Went into debt'),
      isFalse,
    );
  });

  test('a club is left behind when the school changes', () {
    final engine = engineAt(
      birthYear: 2008,
      progress: const LifeProgress(
        education: EducationState(
          stage: SchoolStage.university,
          schoolStage: SchoolStage.high,
          club: 'Soccer Team',
          clubPerformance: 95,
          clubRank: 1,
        ),
      ),
    );

    expect(engine.ageUp().isSuccess, isTrue);

    final education = engine.state.lifeProgress.education;

    expect(education.club, isNull);
    expect(education.clubRank, 0);
  });

  test('a working parent starts with savings, shared assets by both', () {
    var workingParents = 0;

    for (var seed = 0; seed < 60; seed++) {
      final household = FamilyHouseholdGenerator.generate(
        random: SeededRandom(seed),
        birthYear: 2026,
        familyName: 'Santoso',
      );

      for (final parent in household.parents) {
        final yearsWorked = 2026 - parent.birthYear - 20;

        if (parent.annualIncome.minorUnits > 0 && yearsWorked > 0) {
          workingParents++;
          expect(parent.cashBalance.minorUnits, greaterThan(0));
        }
      }
    }

    expect(workingParents, greaterThan(0));
  });

  test('npc places have a city and never change', () {
    final a = NpcPlace.label(countryCode: 'ID', id: 'npc-1');
    final b = NpcPlace.label(countryCode: 'ID', id: 'npc-1');

    expect(a, b);
    expect(a, contains(', '));
  });

  test('a school is public or private and that is saved', () {
    const education = EducationState(isPrivateSchool: true);
    final loaded = EducationState.fromJson(education.toJson());

    expect(loaded.isPrivateSchool, isTrue);
    expect(EducationState.fromJson(const EducationState().toJson())
        .isPrivateSchool, isFalse);
  });

  test('only an adult woman has her own birth control switch', () {
    final adult = engineAt(birthYear: 2000);

    expect(adult.playerCanUseBirthControl, isTrue);
    expect(adult.setPlayerBirthControl(on: true).isSuccess, isTrue);
    expect(adult.playerOnBirthControl, isTrue);
    expect(
      adult.state.events.any((e) => e.title == 'Started birth control'),
      isTrue,
    );
    adult.setPlayerBirthControl(on: false);
    expect(adult.playerOnBirthControl, isFalse);

    expect(
      engineAt(birthYear: 2012).setPlayerBirthControl(on: true).isFailure,
      isTrue,
    );
    expect(
      engineAt(birthYear: 2000, gender: Gender.male)
          .setPlayerBirthControl(on: true)
          .isFailure,
      isTrue,
    );
  });
}
