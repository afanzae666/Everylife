import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/tuition_funding.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/events/life_effect_applier.dart';
import 'package:everylife/simulation/events/life_event_catalog.dart';
import 'package:everylife/simulation/events/scripted_events.dart';
import 'package:everylife/simulation/systems/education_system.dart';
import 'package:everylife/simulation/systems/funeral_planner.dart';

const ParentNpc _mother = ParentNpc(
  id: 'parent-mother-1',
  firstName: 'Grace',
  lastName: 'Wilson',
  gender: Gender.female,
  birthYear: 1960,
  role: FamilyRole.mother,
  employmentStatus: EmploymentStatus.retired,
  annualIncome: Money.zero(),
  incomeStability: IncomeStability.none,
);

SimulationEngine _engineAtAge(
  int age, {
  LifeProgress progress = const LifeProgress(),
  int money = 0,
}) {
  final base = SimulationEngine.create(
    player: Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: 2000,
    ),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  );

  return SimulationEngine(
    initialState: base.state.copyWith(
      clock: SimulationClock(currentYear: 2000 + age),
      player: base.state.player.copyWith(money: Money.fromMinorUnits(money)),
      lifeProgress: progress,
    ),
    random: SeededRandom(1),
    saveRepository: InMemorySaveRepository(),
  );
}

void main() {
  group('story text', () {
    test('a label becomes a first-person sentence', () {
      const choice = LifeChoice(id: 'a', label: 'Join the team', outcomes: []);

      expect(choice.story, 'I join the team.');
      expect(
        const LifeChoice(
          id: 'b',
          label: 'Coffee and panic',
          narration: 'I fuel up on coffee and panic.',
          outcomes: [],
        ).story,
        'I fuel up on coffee and panic.',
      );
    });

    test('the event log reads as one paragraph without "I chose to"', () {
      final engine = _engineAtAge(
        4,
        progress: const LifeProgress(
          pending: PendingLifeEvent(eventId: 'toddler_tantrum', year: 2004),
        ),
      );
      final event = LifeEventCatalog.byId('toddler_tantrum')!;

      final result = engine.resolveLifeChoice(event.choices.first.id);

      expect(result.isSuccess, isTrue);

      final text = engine.state.events.last.description;

      expect(text, isNot(contains('chose to')));
      expect(text, contains(event.description));
      expect(text, contains(event.choices.first.story));
    });
  });

  group('school', () {
    test('old save names map to the new school stages', () {
      final state = EducationState.fromJson({
        'initialized': true,
        'stage': 'primary',
        'highest': 'secondary',
      });

      expect(state.stage, SchoolStage.elementary);
      expect(state.highest, EducationLevel.highSchool);
    });

    test('a life moves through elementary, middle, and high school', () {
      final engine = _engineAtAge(5)
        ..registerSystem(EducationSystem(random: SeededRandom(3)));
      final stages = <int, SchoolStage>{};

      for (var age = 6; age <= 18; age++) {
        expect(engine.ageUp().isSuccess, isTrue);
        stages[age] = engine.state.lifeProgress.education.stage;
      }

      // The first call only fills in a record that matches the age.
      expect(stages[6], SchoolStage.elementary);
      expect(stages[11], SchoolStage.elementary);
      expect(stages[12], SchoolStage.middle);
      expect(stages[14], SchoolStage.middle);
      expect(stages[15], SchoolStage.high);
      expect(stages[17], SchoolStage.high);
      expect(stages[18], SchoolStage.none);
      expect(
        engine.state.lifeProgress.education.highest,
        EducationLevel.highSchool,
      );
    });
  });

  group('study and work do not mix', () {
    const graduate = EducationState(
      initialized: true,
      highest: EducationLevel.highSchool,
    );

    test('a full-time worker cannot apply to university', () {
      final engine = _engineAtAge(
        20,
        progress: const LifeProgress(
          education: graduate,
          career: CareerState(jobId: 'cashier', salaryBase: 1000000),
          flags: {SystemFlags.employed},
        ),
      );

      final result = engine.applyForUniversity('business', TuitionFunding.loan);

      expect(result.isFailure, isTrue);
      expect(engine.state.lifeProgress.education.isStudent, isFalse);
    });

    test('a student cannot take a full-time job', () {
      final engine = _engineAtAge(
        20,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            stage: SchoolStage.university,
            highest: EducationLevel.highSchool,
          ),
          flags: {SystemFlags.student},
        ),
      );

      expect(engine.availableJobs, isEmpty);
      expect(engine.applyForJob('cashier').isFailure, isTrue);
      expect(engine.state.lifeProgress.career.hasJob, isFalse);
    });

    test('an unemployed graduate can still look for a job', () {
      final engine = _engineAtAge(
        20,
        progress: const LifeProgress(education: graduate),
      );

      expect(engine.availableJobs, isNotEmpty);
    });
  });

  group('interactions', () {
    test('interactions repeat, but each only moves the relationship once a year', () {
      final base = _engineAtAge(12);
      final household = FamilyHousehold(
        id: 'household-1',
        parents: const [_mother],
        cashSavings: const Money.zero(),
        assets: const [],
        housingStatus: HousingStatus.rented,
        annualLivingCosts: const Money.zero(),
        totalDebt: const Money.zero(),
      );
      final engine = SimulationEngine(
        initialState: base.state.copyWith(familyHousehold: household),
        random: SeededRandom(1),
        saveRepository: InMemorySaveRepository(),
      );

      int score() =>
          engine.state.familyHousehold!.parents.first.relationshipPercent;

      final start = score();
      final first = engine.interactWithNpc(npcId: _mother.id, action: 'Talk');
      expect(first.isSuccess, isTrue);
      final afterFirst = score();
      expect(afterFirst, greaterThan(start));

      // Talking again still works but the relationship does not move.
      final second = engine.interactWithNpc(npcId: _mother.id, action: 'Talk');
      expect(second.isSuccess, isTrue);
      expect(score(), afterFirst);
      expect(
        (second as Success<NpcInteractionOutcome>).value.progressed,
        isFalse,
      );

      // A different interaction moves it once.
      expect(
        engine.interactWithNpc(npcId: _mother.id, action: 'Spend Time').isSuccess,
        isTrue,
      );
      final afterSpend = score();
      expect(afterSpend, greaterThan(afterFirst));
      engine.interactWithNpc(npcId: _mother.id, action: 'Spend Time');
      expect(score(), afterSpend);

      // After a birthday the same interaction counts again.
      expect(engine.ageUp().isSuccess, isTrue);
      engine.interactWithNpc(npcId: _mother.id, action: 'Talk');
      expect(score(), greaterThan(afterSpend));
    });
  });

  group('funeral', () {
    WorldState diedAt(int age) =>
        FuneralPlanner.schedule(_engineAtAge(age).state, const [_mother]);

    test('an adult chooses how to say goodbye', () {
      final pending = diedAt(30).lifeProgress.pending;

      expect(pending, isNotNull);
      expect(pending!.eventId, ScriptedEvents.funeral);
      expect(pending.subject, 'my mother, Grace Wilson');
    });

    test('a child watches the funeral, a baby sees nothing', () {
      expect(
        diedAt(9).lifeProgress.pending?.eventId,
        ScriptedEvents.funeralFamily,
      );
      expect(diedAt(3).lifeProgress.pending, isNull);
    });

    test('two parents lost together share one decision', () {
      const father = ParentNpc(
        id: 'parent-father-1',
        firstName: 'Tom',
        lastName: 'Wilson',
        gender: Gender.male,
        birthYear: 1958,
        role: FamilyRole.father,
        employmentStatus: EmploymentStatus.retired,
        annualIncome: Money.zero(),
        incomeStability: IncomeStability.none,
      );

      final pending = FuneralPlanner.schedule(
        _engineAtAge(30).state,
        const [_mother, father],
      ).lifeProgress.pending;

      expect(
        pending!.subject,
        'my mother, Grace Wilson and my father, Tom Wilson',
      );
    });

    test('scripted events never come up at random', () {
      for (var age = 0; age <= 100; age++) {
        final ids = LifeEventCatalog.eligible(
          state: _engineAtAge(age).state,
          age: age,
        ).map((event) => event.id);

        expect(ids, isNot(contains(ScriptedEvents.funeral)));
        expect(ids, isNot(contains(ScriptedEvents.funeralFamily)));
      }
    });

    test('the funeral costs money and names the parent', () {
      const cost = 250000;
      final engine = _engineAtAge(30, money: 100000000);
      final withPending = SimulationEngine(
        initialState: engine.state.copyWith(
          lifeProgress: const LifeProgress(
            pending: PendingLifeEvent(
              eventId: 'funeral',
              year: 2030,
              subject: 'my mother, Grace Wilson',
            ),
          ),
        ),
        random: SeededRandom(1),
        saveRepository: InMemorySaveRepository(),
      );

      final before = withPending.state.player.money.minorUnits;

      expect(withPending.pendingDescription, contains('Grace Wilson'));
      expect(withPending.pendingDescription, isNot(contains('{who}')));

      final result = withPending.resolveLifeChoice('cremation');

      expect(result.isSuccess, isTrue);
      expect(
        withPending.state.player.money.minorUnits,
        before - LifeEffectApplier.scaleMoney(withPending.state, cost),
      );
      expect(withPending.state.lifeProgress.pending, isNull);
      expect(withPending.state.events.last.description, contains('Grace Wilson'));
      expect(withPending.state.events.last.description, isNot(contains('{')));
    });

    test('a free option always exists', () {
      for (final id in [ScriptedEvents.funeral, ScriptedEvents.funeralFamily]) {
        final event = LifeEventCatalog.byId(id)!;

        expect(
          event.choices.any((choice) => choice.requiresMoneyBase == 0),
          isTrue,
          reason: id,
        );
      }
    });
  });
}
