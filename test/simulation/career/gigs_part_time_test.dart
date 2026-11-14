import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/gig_catalog.dart';
import 'package:everylife/domain/career/part_time_catalog.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/systems/career_system.dart';

SimulationEngine _engineAt({
  required int age,
  LifeProgress progress = const LifeProgress(),
  int seed = 1,
}) {
  final base = SimulationEngine.create(
    player: Character.create(id: 'p', name: 'Test Player', birthYear: 2000),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  );

  return SimulationEngine(
    initialState: base.state.copyWith(
      clock: SimulationClock(currentYear: 2000 + age),
      lifeProgress: progress,
    ),
    random: SeededRandom(seed),
    saveRepository: InMemorySaveRepository(),
  );
}

const EducationState _graduate = EducationState(
  initialized: true,
  highest: EducationLevel.highSchool,
  grades: 70,
);

void main() {
  group('gigs', () {
    test('they unlock with age, starting at twelve', () {
      expect(_engineAt(age: 11).availableGigs, isEmpty);
      expect(_engineAt(age: 12).availableGigs, isNotEmpty);

      var previous = 0;

      for (final age in [12, 13, 14, 15, 16, 17, 18]) {
        final count = _engineAt(age: age).availableGigs.length;

        expect(count, greaterThan(previous), reason: 'age $age');
        previous = count;
      }

      for (final gig in _engineAt(age: 14).availableGigs) {
        expect(gig.minAge, lessThanOrEqualTo(14));
      }
    });

    test('every gig has a sensible age and pay', () {
      final ids = <String>{};

      for (final gig in GigCatalog.all) {
        expect(ids.add(gig.id), isTrue, reason: gig.id);
        expect(gig.minAge, inInclusiveRange(12, 18), reason: gig.id);
        expect(gig.maxPay, greaterThan(gig.minPay), reason: gig.id);
        expect(gig.win, isNotEmpty);
        expect(gig.lose, isNotEmpty);
      }

      expect(GigCatalog.all.map((gig) => gig.minAge).toSet().length, 7);
    });

    test('a gig pays at once and is written in the life log', () {
      final engine = _engineAt(age: 12);
      final before = engine.state.player.money.minorUnits;
      final events = engine.state.events.length;

      final result = engine.doGig('mow_lawns');

      expect(result.isSuccess, isTrue);
      expect(engine.state.player.money.minorUnits, greaterThan(before));
      expect(engine.state.events.length, events + 1);
      expect(engine.gigsLeft, GigCatalog.perYear - 1);
    });

    test('the yearly limit stops further gigs until the next year', () {
      final engine = _engineAt(age: 14);

      for (var i = 0; i < GigCatalog.perYear; i++) {
        expect(engine.doGig('yard_work').isSuccess, isTrue);
      }

      expect(engine.gigsLeft, 0);
      expect(engine.doGig('yard_work').isFailure, isTrue);

      final next = _engineAt(
        age: 15,
        progress: engine.state.lifeProgress,
      );

      expect(next.gigsLeft, GigCatalog.perYear);
      expect(next.doGig('yard_work').isSuccess, isTrue);
    });

    test('a gig for an older player is refused', () {
      final engine = _engineAt(age: 12);

      expect(engine.doGig('courier_run').isFailure, isTrue);
      expect(engine.doGig('nope').isFailure, isTrue);
    });
  });

  group('part-time jobs', () {
    test('they unlock gradually from fourteen', () {
      expect(_engineAt(age: 13).availablePartTimeJobs, isEmpty);

      var previous = 0;

      for (final age in [14, 15, 16, 17, 18, 20]) {
        final count = _engineAt(age: age).availablePartTimeJobs.length;

        expect(count, greaterThan(previous), reason: 'age $age');
        previous = count;
      }

      expect(PartTimeCatalog.firstAge, 14);
    });

    test('a student can take one and it pays every year', () {
      final engine = _engineAt(
        age: 16,
        progress: const LifeProgress(
          education: EducationState(
            initialized: true,
            stage: SchoolStage.high,
            grades: 70,
          ),
        ),
      );

      expect(engine.startPartTime('cashier_pt').isSuccess, isTrue);
      expect(engine.state.lifeProgress.career.partTimeId, 'cashier_pt');

      final before = engine.state.player.money.minorUnits;
      final after = CareerSystem(random: SeededRandom(2)).process(
        state: engine.state,
        command: const AgeUpCommand(),
      );

      expect(after.player.money.minorUnits, greaterThan(before));
      expect(
        after.events.any((event) => event.title == 'Part-time pay'),
        isTrue,
      );
    });

    test('a job the player is too young for is refused', () {
      final engine = _engineAt(age: 15);

      expect(engine.startPartTime('lifeguard').isFailure, isTrue);
      expect(engine.startPartTime('grocery_bagger').isSuccess, isTrue);
      expect(engine.startPartTime('grocery_bagger').isFailure, isTrue);
    });

    test('changing jobs replaces the old one', () {
      final engine = _engineAt(age: 16);

      engine.startPartTime('cashier_pt');
      engine.startPartTime('barista_pt');

      expect(engine.state.lifeProgress.career.partTimeId, 'barista_pt');
    });

    test('quitting stops the pay', () {
      final engine = _engineAt(age: 16);

      engine.startPartTime('cashier_pt');
      expect(engine.quitPartTime().isSuccess, isTrue);
      expect(engine.state.lifeProgress.career.hasPartTime, isFalse);
      expect(engine.quitPartTime().isFailure, isTrue);
    });

    test('a full-time job replaces the part-time one', () {
      for (var seed = 0; seed < 60; seed++) {
        final engine = _engineAt(
          age: 18,
          progress: const LifeProgress(education: _graduate),
          seed: seed,
        );

        engine.startPartTime('delivery_rider');
        engine.applyForJob('cashier');

        final career = engine.state.lifeProgress.career;

        if (career.hasJob) {
          expect(career.hasPartTime, isFalse);

          return;
        }
      }

      fail('Nobody was ever hired for a cashier job.');
    });

    test('part-time work is not possible next to a full-time job', () {
      final engine = _engineAt(
        age: 25,
        progress: const LifeProgress(
          education: _graduate,
          career: CareerState(jobId: 'cashier', salaryBase: 2000000),
        ),
      );

      expect(engine.availablePartTimeJobs, isEmpty);
      expect(engine.startPartTime('delivery_rider').isFailure, isTrue);
    });

    test('the part-time job survives a save and load', () {
      const career = CareerState(
        partTimeId: 'barista_pt',
        gigYear: 2014,
        gigsDone: 2,
      );
      final copy = CareerState.fromJson(career.toJson());

      expect(copy.partTimeId, 'barista_pt');
      expect(copy.gigsIn(2014), 2);
      expect(copy.gigsIn(2015), 0);
    });
  });
}
