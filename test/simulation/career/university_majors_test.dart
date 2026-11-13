import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/job_catalog.dart';
import 'package:everylife/domain/career/major_catalog.dart';
import 'package:everylife/domain/career/tuition_funding.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/career/career_actions.dart';
import 'package:everylife/simulation/events/life_event_catalog.dart';
import 'package:everylife/simulation/systems/education_system.dart';

ParentNpc _parent({
  required String id,
  required FamilyRole role,
  int cash = 0,
  int relationship = 80,
}) {
  return ParentNpc(
    id: id,
    firstName: role == FamilyRole.mother ? 'Grace' : 'Henry',
    lastName: 'Wilson',
    gender: role == FamilyRole.mother ? Gender.female : Gender.male,
    birthYear: 1965,
    role: role,
    employmentStatus: EmploymentStatus.unemployed,
    annualIncome: const Money.zero(),
    incomeStability: IncomeStability.none,
    cashBalance: Money.fromMinorUnits(cash),
    relationshipPercent: relationship,
  );
}

FamilyHousehold _household(List<ParentNpc> parents) => FamilyHousehold(
      id: 'household-test',
      parents: parents,
      cashSavings: const Money.zero(),
      assets: const [],
      housingStatus: HousingStatus.rented,
      annualLivingCosts: const Money.zero(),
      totalDebt: const Money.zero(),
    );

SimulationEngine _engineAt({
  required int age,
  required LifeProgress progress,
  int money = 0,
  int seed = 1,
  List<ParentNpc>? parents,
}) {
  final base = SimulationEngine.create(
    player: Character.create(id: 'p', name: 'Test Player', birthYear: 2000),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  );

  return SimulationEngine(
    initialState: base.state.copyWith(
      clock: SimulationClock(currentYear: 2000 + age),
      player: base.state.player.copyWith(money: Money.fromMinorUnits(money)),
      lifeProgress: progress,
      familyHousehold: _household(
        parents ?? [_parent(id: 'default-mother', role: FamilyRole.mother)],
      ),
    ),
    random: SeededRandom(seed),
    saveRepository: InMemorySaveRepository(),
  );
}

WorldState _advanceYear(WorldState state) =>
    state.copyWith(clock: state.clock.advanceYear());

const EducationState _graduate = EducationState(
  initialized: true,
  highest: EducationLevel.highSchool,
  grades: 100,
);

const EducationState _businessStudent = EducationState(
  initialized: true,
  stage: SchoolStage.university,
  highest: EducationLevel.highSchool,
  majorId: 'business',
  grades: 80,
);

void main() {
  group('major catalog', () {
    test('every major has a unique id and sensible numbers', () {
      final ids = MajorCatalog.all.map((major) => major.id).toSet();

      expect(ids.length, MajorCatalog.all.length);

      for (final major in MajorCatalog.all) {
        expect(major.years, inInclusiveRange(1, 8), reason: major.id);
        expect(major.tuition, greaterThan(0), reason: major.id);
        expect(MajorCatalog.byId(major.id), same(major));
      }

      expect(MajorCatalog.byId('nope'), isNull);
      expect(MajorCatalog.byId(null), isNull);
    });

    test('majors differ in length and cost', () {
      expect(MajorCatalog.all.map((m) => m.years).toSet().length, greaterThan(1));
      expect(
        MajorCatalog.all.map((m) => m.tuition).toSet().length,
        greaterThan(1),
      );
    });

    test('medicine and nursing are the specialized programs', () {
      final specialized = MajorCatalog.at(InstitutionType.specialized);

      expect(specialized.map((major) => major.id), ['medicine', 'nursing']);
      expect(
        specialized.map((major) => major.campusName),
        ['Medical School', 'Nursing College'],
      );
      expect(MajorCatalog.at(InstitutionType.general), hasLength(6));
    });

    test('medicine is the longest and hardest program', () {
      final medicine = MajorCatalog.byId('medicine')!;

      for (final major in MajorCatalog.all) {
        expect(medicine.years, greaterThanOrEqualTo(major.years));
        expect(medicine.minGrades, greaterThanOrEqualTo(major.minGrades));
      }
    });
  });

  group('education state', () {
    test('the major survives a JSON round trip', () {
      final copy = EducationState.fromJson(_businessStudent.toJson());

      expect(copy.majorId, 'business');
      expect(copy.programYears, 3);
      expect(copy.degreeField, isNull, reason: 'not graduated yet');
    });

    test('the degree field exists only after graduating', () {
      const graduated = EducationState(
        highest: EducationLevel.bachelor,
        majorId: 'law',
      );

      expect(graduated.degreeField, StudyField.law);
      expect(graduated.copyWith(clearMajor: true).majorId, isNull);
    });
  });

  group('jobs and degrees', () {
    JobDefinition job(String id) => JobCatalog.byId(id)!;

    const lawDegree = EducationState(
      highest: EducationLevel.bachelor,
      majorId: 'law',
    );
    const csDegree = EducationState(
      highest: EducationLevel.bachelor,
      majorId: 'computer_science',
    );

    test('a lawyer needs a law degree', () {
      expect(JobCatalog.qualifies(lawDegree, job('lawyer')), isTrue);
      expect(JobCatalog.qualifies(csDegree, job('lawyer')), isFalse);
      expect(JobCatalog.qualifies(_graduate, job('lawyer')), isFalse);
    });

    test('a software engineer needs computer science or engineering', () {
      expect(JobCatalog.qualifies(csDegree, job('software_engineer')), isTrue);
      expect(JobCatalog.qualifies(lawDegree, job('software_engineer')), isFalse);
    });

    test('jobs without a field accept any degree but not no degree', () {
      expect(JobCatalog.qualifies(lawDegree, job('pilot')), isTrue);
      expect(JobCatalog.qualifies(_graduate, job('pilot')), isFalse);
    });

    test('doctors need medicine and nurses need nursing', () {
      const medicine = EducationState(
        highest: EducationLevel.bachelor,
        majorId: 'medicine',
      );
      const nursing = EducationState(
        highest: EducationLevel.bachelor,
        majorId: 'nursing',
      );

      expect(JobCatalog.qualifies(medicine, job('doctor')), isTrue);
      expect(JobCatalog.qualifies(nursing, job('doctor')), isFalse);
      expect(JobCatalog.qualifies(nursing, job('nurse')), isTrue);
      expect(JobCatalog.qualifies(medicine, job('nurse')), isFalse);
      expect(JobCatalog.qualifies(lawDegree, job('doctor')), isFalse);
    });

    test('a pharmacist may come from medicine or nursing', () {
      const medicine = EducationState(
        highest: EducationLevel.bachelor,
        majorId: 'medicine',
      );
      const nursing = EducationState(
        highest: EducationLevel.bachelor,
        majorId: 'nursing',
      );

      expect(JobCatalog.qualifies(medicine, job('pharmacist')), isTrue);
      expect(JobCatalog.qualifies(nursing, job('pharmacist')), isTrue);
      expect(JobCatalog.qualifies(lawDegree, job('pharmacist')), isFalse);
    });

    test('the requirement text names the field', () {
      expect(
        JobCatalog.requirementLabel(job('lawyer')),
        "Bachelor's degree in Law",
      );
      expect(
        JobCatalog.requirementLabel(job('cashier')),
        'No diploma needed',
      );
    });
  });

  group('applying', () {
    const loan = TuitionFunding.loan;

    test('an unknown major is refused', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );

      expect(engine.applyForUniversity('nope', loan).isFailure, isTrue);
      expect(engine.state.lifeProgress.education.isStudent, isFalse);
    });

    test('low grades lower the chance but never lock a major', () {
      final weak = _engineAt(
        age: 18,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            highest: EducationLevel.highSchool,
            grades: 20,
          ),
        ),
      );
      final strong = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );
      final law = MajorCatalog.byId('law')!;

      expect(
        CareerActions.admissionChance(weak.state, law),
        lessThan(CareerActions.admissionChance(strong.state, law)),
      );
      expect(CareerActions.admissionChance(weak.state, law), greaterThan(0));
      expect(weak.applyForUniversity('law', loan).isSuccess, isTrue);
    });

    test('an accepted student is enrolled in the chosen major', () {
      var accepted = 0;

      for (var seed = 0; seed < 40; seed++) {
        final engine = _engineAt(
          age: 18,
          seed: seed,
          progress: const LifeProgress(education: _graduate),
        );

        expect(engine.applyForUniversity('business', loan).isSuccess, isTrue);

        final education = engine.state.lifeProgress.education;

        if (education.isStudent) {
          accepted++;
          expect(education.stage, SchoolStage.university);
          expect(education.majorId, 'business');
        } else {
          expect(education.majorId, isNull);
        }
      }

      expect(accepted, greaterThan(0));
    });

    test('a turned down student pays nothing and can apply again', () {
      var retried = false;

      for (var seed = 0; seed < 200 && !retried; seed++) {
        final engine = _engineAt(
          age: 18,
          seed: seed,
          progress: const LifeProgress(education: _graduate),
        );

        expect(engine.applyForUniversity('business', loan).isSuccess, isTrue);

        if (engine.state.lifeProgress.education.isStudent) continue;

        expect(engine.state.player.debt.minorUnits, 0);
        expect(engine.applyForUniversity('education', loan).isSuccess, isTrue);
        retried = true;
      }

      expect(retried, isTrue);
    });

    test('leaving university forgets the major', () {
      final engine = _engineAt(
        age: 19,
        progress: const LifeProgress(education: _businessStudent),
      );

      expect(engine.dropOutOfSchool().isSuccess, isTrue);
      expect(engine.state.lifeProgress.education.majorId, isNull);
    });
  });

  group('specialized schools', () {
    test('medicine is harder to get into than nursing', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            highest: EducationLevel.highSchool,
            grades: 60,
          ),
        ),
      );

      expect(
        CareerActions.admissionChance(
          engine.state,
          MajorCatalog.byId('medicine')!,
        ),
        lessThan(
          CareerActions.admissionChance(
            engine.state,
            MajorCatalog.byId('nursing')!,
          ),
        ),
      );
    });

    test('a medical student attends the medical school', () {
      final engine = _engineAt(
        age: 19,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            stage: SchoolStage.university,
            highest: EducationLevel.highSchool,
            majorId: 'medicine',
            grades: 90,
          ),
        ),
      );

      engine.ensureSchool();

      expect(
        engine.state.lifeProgress.education.schoolName,
        endsWith('Medical School'),
      );
    });
  });

  group('studying', () {
    final business = MajorCatalog.byId('business')!;

    test('there is no yearly tuition while studying', () {
      final engine = _engineAt(
        age: 19,
        money: 500,
        progress: const LifeProgress(education: _businessStudent),
      );

      final next = EducationSystem(random: SeededRandom(1)).process(
        state: engine.state,
        command: const AgeUpCommand(),
      );

      expect(next.player.money.minorUnits, 500);
      expect(next.player.debt.minorUnits, 0);
      expect(next.events.any((event) => event.title == 'Tuition'), isFalse);
    });

    test('a three year major ends with a degree in that field', () {
      final engine = _engineAt(
        age: 19,
        money: 100000000,
        progress: const LifeProgress(education: _businessStudent),
      );
      final system = EducationSystem(random: SeededRandom(1));
      var state = engine.state;

      for (var year = 0; year < business.years; year++) {
        state = system.process(
          state: state,
          command: const AgeUpCommand(),
        );
        state = _advanceYear(state);
      }

      final education = state.lifeProgress.education;

      expect(education.highest, EducationLevel.bachelor);
      expect(education.isStudent, isFalse);
      expect(education.degreeField, StudyField.business);
    });
  });

  group('paying the tuition once', () {
    final business = MajorCatalog.byId('business')!;

    /// Applies until the university says yes; returns the engine.
    SimulationEngine enroll({
      required TuitionFunding funding,
      int money = 0,
      List<ParentNpc>? parents,
      EducationState education = _graduate,
    }) {
      // A parent's mood depends on the year, so try a few years too.
      for (var age = 18; age < 40; age++) {
        for (var seed = 0; seed < 100; seed++) {
          final engine = _engineAt(
            age: age,
            seed: seed,
            money: money,
            parents: parents,
            progress: LifeProgress(education: education),
          );

          engine.applyForUniversity('business', funding);

          if (engine.state.lifeProgress.education.isStudent) return engine;
        }
      }

      fail('Nobody was accepted.');
    }

    test('a loan puts the whole tuition into debt', () {
      final engine = enroll(funding: TuitionFunding.loan);

      expect(
        engine.state.player.debt.minorUnits,
        engine.tuitionFor(business),
      );
      expect(engine.state.player.money.minorUnits, 0);
    });

    test('the total is the price of every year together', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );

      expect(engine.tuitionFor(business), greaterThan(0));
      expect(
        engine.tuitionFor(MajorCatalog.byId('medicine')!),
        greaterThan(engine.tuitionFor(business)),
      );
    });

    test('paying myself takes the whole sum from my cash', () {
      final probe = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );
      final total = probe.tuitionFor(business);
      final engine = enroll(
        funding: TuitionFunding.self,
        money: total + 1000,
      );

      expect(engine.state.player.money.minorUnits, 1000);
      expect(engine.state.player.debt.minorUnits, 0);
    });

    test('paying myself without the cash is refused', () {
      final engine = _engineAt(
        age: 18,
        money: 100,
        progress: const LifeProgress(education: _graduate),
      );

      final answer =
          engine.askTuitionFunding('business', TuitionFunding.self);

      expect(answer.approved, isFalse);
      expect(answer.text, isNotEmpty);
      expect(
        engine.applyForUniversity('business', TuitionFunding.self).isFailure,
        isTrue,
      );
      expect(engine.state.lifeProgress.education.isStudent, isFalse);
    });

    test('a loan is always possible', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );

      for (final major in MajorCatalog.all) {
        expect(
          engine.askTuitionFunding(major.id, TuitionFunding.loan).approved,
          isTrue,
          reason: major.id,
        );
      }
    });

    test('parents without savings cannot pay', () {
      final engine = _engineAt(
        age: 18,
        parents: [_parent(id: 'm', role: FamilyRole.mother, cash: 1000)],
        progress: const LifeProgress(education: _graduate),
      );

      final answer =
          engine.askTuitionFunding('business', TuitionFunding.parents);

      expect(answer.approved, isFalse);
      expect(answer.title, isNotEmpty);
    });

    test('parents who are gone cannot pay', () {
      final engine = _engineAt(
        age: 18,
        parents: [
          ParentNpc(
            id: 'm',
            firstName: 'Grace',
            lastName: 'Wilson',
            gender: Gender.female,
            birthYear: 1965,
            role: FamilyRole.mother,
            employmentStatus: EmploymentStatus.unemployed,
            annualIncome: const Money.zero(),
            incomeStability: IncomeStability.none,
            cashBalance: const Money.fromMinorUnits(900000000),
            isAlive: false,
          ),
        ],
        progress: const LifeProgress(education: _graduate),
      );

      expect(
        engine.askTuitionFunding('business', TuitionFunding.parents).approved,
        isFalse,
      );
    });

    test('willing parents pay everything from their savings', () {
      final parents = [
        _parent(
          id: 'm',
          role: FamilyRole.mother,
          cash: 900000000,
          relationship: 100,
        ),
      ];
      final engine = enroll(
        funding: TuitionFunding.parents,
        parents: parents,
      );
      final total = engine.tuitionFor(business);

      expect(
        engine.state.familyHousehold!.parents.single.cashBalance.minorUnits,
        900000000 - total,
      );
      expect(engine.state.player.debt.minorUnits, 0);
      expect(engine.state.player.money.minorUnits, 0);
    });

    test('the same question gets the same answer in the same year', () {
      final engine = _engineAt(
        age: 18,
        parents: [
          _parent(
            id: 'm',
            role: FamilyRole.mother,
            cash: 900000000,
            relationship: 40,
          ),
        ],
        progress: const LifeProgress(education: _graduate),
      );

      final first =
          engine.askTuitionFunding('business', TuitionFunding.parents);

      for (var i = 0; i < 10; i++) {
        final again =
            engine.askTuitionFunding('business', TuitionFunding.parents);

        expect(again.approved, first.approved);
        expect(again.text, first.text);
      }
    });

    test('a refusal reads differently for different reasons', () {
      final poor = _engineAt(
        age: 18,
        parents: [_parent(id: 'm', role: FamilyRole.mother, cash: 10)],
        progress: const LifeProgress(education: _graduate),
      );
      final broke = _engineAt(
        age: 18,
        money: 0,
        progress: const LifeProgress(education: _graduate),
      );

      expect(
        poor.askTuitionFunding('business', TuitionFunding.parents).title,
        isNot(broke.askTuitionFunding('business', TuitionFunding.self).title),
      );
    });

    test('top grades earn a scholarship and the rest is paid by me', () {
      final sample = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );
      final total = sample.tuitionFor(business);

      // The roll depends on the year, so look for a year it works.
      for (var age = 18; age < 70; age++) {
        final engine = _engineAt(
          age: age,
          money: total,
          progress: const LifeProgress(education: _graduate),
        );
        final share = CareerActions.scholarshipShare(engine.state, 'business');

        if (share == 0) continue;

        expect(
          engine.askTuitionFunding('business', TuitionFunding.scholarship)
              .approved,
          isTrue,
        );

        for (var seed = 0; seed < 200; seed++) {
          final tried = _engineAt(
            age: age,
            seed: seed,
            money: total,
            progress: const LifeProgress(education: _graduate),
          );

          tried.applyForUniversity('business', TuitionFunding.scholarship);

          if (!tried.state.lifeProgress.education.isStudent) continue;

          final covered = total * share ~/ 100;

          expect(tried.state.player.money.minorUnits, covered);
          expect(tried.state.player.debt.minorUnits, 0);
          return;
        }
      }

      fail('No scholarship was ever granted.');
    });

    test('weak grades and a weak mind earn no scholarship', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            highest: EducationLevel.highSchool,
            grades: 5,
          ),
        ),
      );
      final weak = engine.state.copyWith(
        player: engine.state.player.copyWith(
          stats: engine.state.player.stats.copyWith(intelligence: 5),
        ),
      );

      expect(CareerActions.scholarshipShare(weak, 'business'), 0);
    });

    test('a refused way of paying charges nothing', () {
      final engine = _engineAt(
        age: 18,
        money: 50,
        progress: const LifeProgress(education: _graduate),
      );

      engine.applyForUniversity('business', TuitionFunding.self);

      expect(engine.state.player.money.minorUnits, 50);
      expect(engine.state.player.debt.minorUnits, 0);
    });
  });

  group('field of study flags and events', () {
    test('a student carries the flag of the major they study', () {
      final engine = _engineAt(
        age: 19,
        money: 100000000,
        progress: const LifeProgress(education: _businessStudent),
      );

      final next = EducationSystem(random: SeededRandom(1)).process(
        state: engine.state,
        command: const AgeUpCommand(),
      );

      expect(
        next.lifeProgress.flags,
        contains(SystemFlags.studying(StudyField.business)),
      );
      expect(next.lifeProgress.flags, contains(SystemFlags.universityStudent));
      expect(
        next.lifeProgress.flags,
        isNot(contains(SystemFlags.studying(StudyField.law))),
      );
    });

    test('every field has its own university events', () {
      for (final field in StudyField.values) {
        final flag = SystemFlags.studying(field);
        final events = LifeEventCatalog.all
            .where((event) => event.requiredFlags.contains(flag));

        expect(events.length, greaterThanOrEqualTo(2), reason: field.name);

        for (final event in events) {
          expect(event.id, startsWith('uni_'));
          expect(
            event.requiredFlags,
            contains(SystemFlags.universityStudent),
            reason: event.id,
          );
        }
      }
    });
  });
}
