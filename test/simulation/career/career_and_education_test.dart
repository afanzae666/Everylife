import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

SimulationEngine _newEngine(int seed, {bool gameplay = true}) {
  final engine = SimulationEngine.create(
    player: Character.create(
      id: 'player-$seed',
      name: 'Test Player',
      birthYear: 2000,
    ),
    seed: seed * 7919,
    saveRepository: InMemorySaveRepository(),
  );

  if (gameplay) engine.registerGameplaySystems();

  return engine;
}

/// Plays one year: resolves any decision with a random choice, then ages up.
/// Returns false when the life has ended.
bool _playYear(SimulationEngine engine, Random random) {
  var guard = 0;

  while (engine.state.lifeProgress.pending != null) {
    expect(guard++, lessThan(10));

    final pending = engine.pendingLifeEvent;

    if (pending == null) break;

    final options = pending.choices.where(engine.canAffordChoice).toList();
    final resolved =
        engine.resolveLifeChoice(options[random.nextInt(options.length)].id);

    expect(resolved.isSuccess, isTrue, reason: pending.id);
  }

  if (engine.state.lifeProgress.ending != null) return false;

  expect(engine.ageUp().isSuccess, isTrue);

  return engine.state.lifeProgress.ending == null;
}

void main() {
  test('education state survives a JSON round trip', () {
    const state = EducationState(
      initialized: true,
      stage: SchoolStage.university,
      highest: EducationLevel.highSchool,
      grades: 77,
      yearsInStage: 2,
    );

    final copy = EducationState.fromJson(state.toJson());

    expect(copy.stage, SchoolStage.university);
    expect(copy.highest, EducationLevel.highSchool);
    expect(copy.grades, 77);
    expect(copy.yearsInStage, 2);
    expect(EducationState.fromJson(null).initialized, isFalse);
  });

  test('career state survives a JSON round trip', () {
    const state = CareerState(
      jobId: 'cashier',
      rank: 1,
      salaryBase: 123456,
      performance: 70,
    );

    final copy = CareerState.fromJson(state.toJson());

    expect(copy.jobId, 'cashier');
    expect(copy.rank, 1);
    expect(copy.salaryBase, 123456);
    expect(copy.performance, 70);
    expect(CareerState.fromJson('bad').hasJob, isFalse);
  });

  test('repeating an interaction works but only moves the bond once a year', () {
    final engine = _newEngine(3, gameplay: false);

    for (var i = 0; i < 10; i++) {
      expect(engine.ageUp().isSuccess, isTrue);
    }

    final household = engine.state.familyHousehold;
    expect(household, isNotNull);

    final npcId = household!.parents.first.id;

    int bond() => engine.state.familyHousehold!.parents
        .firstWhere((npc) => npc.id == npcId)
        .relationshipPercent;

    final start = bond();
    expect(engine.interactWithNpc(npcId: npcId, action: 'Talk').isSuccess,
        isTrue);
    final afterFirst = bond();
    expect(afterFirst, greaterThan(start));

    expect(engine.interactWithNpc(npcId: npcId, action: 'Talk').isSuccess,
        isTrue);
    expect(bond(), afterFirst);

    expect(engine.ageUp().isSuccess, isTrue);
    expect(engine.interactWithNpc(npcId: npcId, action: 'Talk').isSuccess,
        isTrue);
    expect(bond(), greaterThan(afterFirst));
  });

  test('a job can be applied for once a year, held, and quit', () {
    final engine = _newEngine(11);
    final random = Random(5);

    // Students cannot apply for jobs, so wait until school is over.
    while (engine.state.player.ageAt(engine.state.clock.currentYear) < 17 ||
        engine.availableJobs.isEmpty) {
      if (engine.state.player.ageAt(engine.state.clock.currentYear) > 40) {
        return;
      }
      if (!_playYear(engine, random)) return;
    }

    expect(engine.availableJobs, isNotEmpty);

    final first = engine.availableJobs.first;
    var hired = false;

    for (var attempt = 0; attempt < 15 && !hired; attempt++) {
      final result = engine.applyForJob(first.id);

      if (result.isSuccess) {
        // The same year may not be used twice.
        expect(engine.applyForJob(first.id).isFailure, isTrue);
        hired = engine.state.lifeProgress.career.hasJob;
      }

      if (!hired && !_playYear(engine, random)) return;
    }

    if (!hired) return;

    expect(engine.state.lifeProgress.career.jobId, first.id);
    expect(engine.quitJob().isSuccess, isTrue);
    expect(engine.state.lifeProgress.career.hasJob, isFalse);
  });

  test('whole lives keep a valid world, schooling, and non-negative cash', () {
    final random = Random(21);
    var graduates = 0;
    var workers = 0;

    for (var seed = 1; seed <= 40; seed++) {
      final engine = _newEngine(seed);
      var guard = 0;

      while (true) {
        expect(guard++, lessThan(300), reason: 'Life $seed never ended.');

        final age = engine.state.player.ageAt(engine.state.clock.currentYear);

        if (age >= 16 && !engine.state.lifeProgress.career.hasJob) {
          final jobs = engine.availableJobs;

          if (jobs.isNotEmpty) {
            engine.applyForJob(jobs[random.nextInt(jobs.length)].id);
          }
        }

        if (!_playYear(engine, random)) break;

        expect(engine.state.player.money.minorUnits, greaterThanOrEqualTo(0),
            reason: 'Life $seed age $age');
        expect(engine.state.player.debt.minorUnits, greaterThanOrEqualTo(0),
            reason: 'Life $seed age $age');
      }

      final progress = engine.state.lifeProgress;
      final diedAge = engine.state.player.ageAt(engine.state.clock.currentYear);

      if (diedAge >= 19 &&
          !progress.flags.contains('school_dropout') &&
          !progress.flags.contains('dropout')) {
        expect(
          progress.education.highest.index,
          greaterThanOrEqualTo(EducationLevel.highSchool.index),
          reason: 'Life $seed',
        );
        graduates++;
      }

      if (progress.career.totalYearsWorked > 0) workers++;
    }

    expect(graduates, greaterThan(10));
    expect(workers, greaterThan(10));
  });
}
