import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/job_catalog.dart';
import 'package:everylife/domain/career/major_catalog.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/family/family_household.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
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
        expect(major.tuitionPerYear, greaterThan(0), reason: major.id);
        expect(MajorCatalog.byId(major.id), same(major));
      }

      expect(MajorCatalog.byId('nope'), isNull);
      expect(MajorCatalog.byId(null), isNull);
    });

    test('majors differ in length and cost', () {
      expect(MajorCatalog.all.map((m) => m.years).toSet().length, greaterThan(1));
      expect(
        MajorCatalog.all.map((m) => m.tuitionPerYear).toSet().length,
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
    test('an unknown major is refused', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(education: _graduate),
      );

      expect(engine.applyForUniversity('nope').isFailure, isTrue);
      expect(engine.state.lifeProgress.education.isStudent, isFalse);
    });

    test('low grades block a demanding major', () {
      final engine = _engineAt(
        age: 18,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            highest: EducationLevel.highSchool,
            grades: 20,
          ),
        ),
      );
      final law = MajorCatalog.byId('law')!;

      expect(engine.majorBlocker(law), isNotNull);
      expect(engine.applyForUniversity('law').isFailure, isTrue);
      expect(engine.state.lifeProgress.education.isStudent, isFalse);
    });

    test('an accepted student is enrolled in the chosen major', () {
      var accepted = 0;

      for (var seed = 0; seed < 40; seed++) {
        final engine = _engineAt(
          age: 18,
          seed: seed,
          progress: const LifeProgress(education: _graduate),
        );

        expect(engine.applyForUniversity('business').isSuccess, isTrue);

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

    test('a turned down student can apply again in the same year', () {
      var retried = false;

      for (var seed = 0; seed < 200 && !retried; seed++) {
        final engine = _engineAt(
          age: 18,
          seed: seed,
          progress: const LifeProgress(education: _graduate),
        );

        expect(engine.applyForUniversity('business').isSuccess, isTrue);

        if (engine.state.lifeProgress.education.isStudent) continue;

        expect(engine.applyForUniversity('education').isSuccess, isTrue);
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
    test('medicine asks for strong grades', () {
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

      expect(engine.majorBlocker(MajorCatalog.byId('medicine')!), isNotNull);
      expect(engine.majorBlocker(MajorCatalog.byId('nursing')!), isNull);
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

    test('a student with cash pays tuition from it', () {
      final engine = _engineAt(
        age: 19,
        money: 10000000,
        progress: const LifeProgress(education: _businessStudent),
      );
      final tuition = engine.tuitionFor(business);

      final next = EducationSystem(random: SeededRandom(1)).process(
        state: engine.state,
        command: const AgeUpCommand(),
      );

      expect(next.player.money.minorUnits, 10000000 - tuition);
      expect(next.player.debt.minorUnits, 0);
      expect(next.events.any((event) => event.title == 'Tuition'), isTrue);
    });

    test('a student without cash borrows the tuition', () {
      final engine = _engineAt(
        age: 19,
        progress: const LifeProgress(education: _businessStudent),
      );
      final tuition = engine.tuitionFor(business);

      final next = EducationSystem(random: SeededRandom(1)).process(
        state: engine.state,
        command: const AgeUpCommand(),
      );

      expect(next.player.money.minorUnits, 0);
      expect(next.player.debt.minorUnits, tuition);
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

    test('nobody pays tuition outside university', () {
      final engine = _engineAt(
        age: 19,
        money: 500,
        progress: const LifeProgress(education: _graduate),
      );

      final next = EducationSystem(random: SeededRandom(1)).process(
        state: engine.state,
        command: const AgeUpCommand(),
      );

      expect(next.player.money.minorUnits, 500);
      expect(next.player.debt.minorUnits, 0);
    });
  });

  group('scholarships and help from parents', () {
    final business = MajorCatalog.byId('business')!;

    WorldState payOneYear(SimulationEngine engine) =>
        EducationSystem(random: SeededRandom(1)).process(
          state: engine.state,
          command: const AgeUpCommand(),
        );

    test('scholarships grow with grades', () {
      expect(MajorCatalog.scholarshipPercentFor(60), 0);
      expect(MajorCatalog.scholarshipPercentFor(70), 20);
      expect(MajorCatalog.scholarshipPercentFor(80), 40);
      expect(MajorCatalog.scholarshipPercentFor(95), 70);
    });

    test('a scholarship covers part of the tuition', () {
      final engine = _engineAt(
        age: 19,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            stage: SchoolStage.university,
            highest: EducationLevel.highSchool,
            majorId: 'business',
            grades: 85,
            scholarshipPercent: 40,
          ),
        ),
      );
      final tuition = engine.tuitionFor(business);

      final next = payOneYear(engine);

      expect(next.player.debt.minorUnits, tuition - tuition * 40 ~/ 100);
    });

    test('a scholarship is lost when grades slip', () {
      final engine = _engineAt(
        age: 19,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            stage: SchoolStage.university,
            highest: EducationLevel.highSchool,
            majorId: 'business',
            grades: 40,
            scholarshipPercent: 40,
          ),
        ),
      );
      final tuition = engine.tuitionFor(business);

      final next = payOneYear(engine);

      expect(next.lifeProgress.education.scholarshipPercent, 0);
      expect(next.player.debt.minorUnits, tuition);
      expect(
        next.events.any((event) => event.title == 'Scholarship lost'),
        isTrue,
      );
    });

    test('close parents with savings pay a share of the tuition', () {
      final engine = _engineAt(
        age: 19,
        parents: [
          _parent(id: 'm', role: FamilyRole.mother, cash: 10000000),
          _parent(id: 'f', role: FamilyRole.father, cash: 10000000),
        ],
        progress: const LifeProgress(education: _businessStudent),
      );
      final tuition = engine.tuitionFor(business);
      final each = tuition * 30 ~/ 100;

      final next = payOneYear(engine);
      final parents = next.familyHousehold!.parents;

      expect(parents[0].cashBalance.minorUnits, 10000000 - each);
      expect(parents[1].cashBalance.minorUnits, 10000000 - each);
      expect(next.player.debt.minorUnits, tuition - 2 * each);
    });

    test('a parent never gives more than half of their savings', () {
      final engine = _engineAt(
        age: 19,
        parents: [_parent(id: 'm', role: FamilyRole.mother, cash: 100000)],
        progress: const LifeProgress(education: _businessStudent),
      );
      final tuition = engine.tuitionFor(business);

      final next = payOneYear(engine);

      expect(next.familyHousehold!.parents.single.cashBalance.minorUnits, 50000);
      expect(next.player.debt.minorUnits, tuition - 50000);
    });

    test('a distant parent does not help', () {
      final engine = _engineAt(
        age: 19,
        parents: [
          _parent(
            id: 'm',
            role: FamilyRole.mother,
            cash: 10000000,
            relationship: 10,
          ),
        ],
        progress: const LifeProgress(education: _businessStudent),
      );
      final tuition = engine.tuitionFor(business);

      final next = payOneYear(engine);

      expect(
        next.familyHousehold!.parents.single.cashBalance.minorUnits,
        10000000,
      );
      expect(next.player.debt.minorUnits, tuition);
    });

    test('an accepted student with top grades gets the best scholarship', () {
      for (var seed = 0; seed < 40; seed++) {
        final engine = _engineAt(
          age: 18,
          seed: seed,
          progress: const LifeProgress(education: _graduate),
        );

        engine.applyForUniversity('business');

        final education = engine.state.lifeProgress.education;

        if (education.isStudent) {
          expect(education.scholarshipPercent, 70);
          return;
        }
      }

      fail('Nobody was accepted in 40 tries.');
    });

    test('the scholarship ends with the degree', () {
      final engine = _engineAt(
        age: 19,
        money: 100000000,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            stage: SchoolStage.university,
            highest: EducationLevel.highSchool,
            majorId: 'business',
            grades: 90,
            scholarshipPercent: 70,
          ),
        ),
      );
      final system = EducationSystem(random: SeededRandom(1));
      var state = engine.state;

      for (var year = 0; year < business.years; year++) {
        state = _advanceYear(
          system.process(state: state, command: const AgeUpCommand()),
        );
      }

      expect(state.lifeProgress.education.highest, EducationLevel.bachelor);
      expect(state.lifeProgress.education.scholarshipPercent, 0);
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
