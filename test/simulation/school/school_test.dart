import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/career/job_catalog.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/world/school_names.dart';
import 'package:everylife/simulation/career/school_actions.dart';
import 'package:everylife/simulation/school/school_appearance.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

SimulationEngine _newEngine() {
  final engine = SimulationEngine.create(
    player: Character.create(
      id: 'school-player',
      name: 'School Kid',
      birthYear: 2000,
    ),
    seed: 4242,
    saveRepository: InMemorySaveRepository(),
  );

  engine.registerGameplaySystems();

  return engine;
}

void _playYear(SimulationEngine engine, Random random) {
  var guard = 0;

  while (engine.state.lifeProgress.pending != null) {
    expect(guard++, lessThan(10));

    final pending = engine.pendingLifeEvent;

    if (pending == null) break;

    final options = pending.choices.where(engine.canAffordChoice).toList();
    engine.resolveLifeChoice(options[random.nextInt(options.length)].id);
  }

  expect(engine.ageUp().isSuccess, isTrue);
}

void _clearPending(SimulationEngine engine, Random random) {
  var guard = 0;

  while (engine.state.lifeProgress.pending != null && guard++ < 10) {
    final pending = engine.pendingLifeEvent;

    if (pending == null) break;

    final options = pending.choices.where(engine.canAffordChoice).toList();
    engine.resolveLifeChoice(options[random.nextInt(options.length)].id);
  }
}

SimulationEngine _studentEngine(SchoolStage stage) {
  final engine = _newEngine();
  final random = Random(3);

  for (var i = 0; i < 40; i++) {
    if (engine.state.lifeProgress.education.stage == stage) {
      _clearPending(engine, random);

      return engine;
    }
    if (engine.state.lifeProgress.ending != null) break;

    _playYear(engine, random);
  }

  fail('never reached $stage');
}

void main() {
  test('school NPC survives a JSON round trip', () {
    const npc = SchoolNpc(
      id: 'sc-1',
      firstName: 'Ayu',
      lastName: 'Putri',
      gender: Gender.female,
      birthYear: 2001,
      role: SchoolRole.teacher,
      relationshipPercent: 55,
    );

    final copy = SchoolNpc.fromJson(npc.toJson())!;

    expect(copy.id, 'sc-1');
    expect(copy.role, SchoolRole.teacher);
    expect(copy.relationshipPercent, 55);
    expect(copy.gender, Gender.female);
  });

  test('education state keeps its school through JSON', () {
    const state = EducationState(
      initialized: true,
      stage: SchoolStage.high,
      schoolName: 'Oakridge High School',
      schoolStage: SchoolStage.high,
      club: 'Drama Club',
      lastClubYear: 2016,
      lastStudyYear: 2015,
      npcs: [
        SchoolNpc(
          id: 'a',
          firstName: 'A',
          lastName: 'B',
          gender: Gender.male,
          birthYear: 2001,
          role: SchoolRole.classmate,
        ),
      ],
    );

    final copy = EducationState.fromJson(state.toJson());

    expect(copy.schoolName, 'Oakridge High School');
    expect(copy.schoolStage, SchoolStage.high);
    expect(copy.club, 'Drama Club');
    expect(copy.lastStudyYear, 2015);
    expect(copy.npcs, hasLength(1));
  });

  test('students get a named school with classmates and faculty', () {
    final engine = _studentEngine(SchoolStage.elementary);

    engine.ensureSchool();

    final education = engine.state.lifeProgress.education;

    expect(education.schoolName, contains('Elementary School'));
    expect(education.classmates, isNotEmpty);
    expect(education.faculty.any((n) => n.role == SchoolRole.teacher), isTrue);
    expect(education.faculty.any((n) => n.role == SchoolRole.principal), isTrue);
  });

  test('study harder works once a year', () {
    final engine = _studentEngine(SchoolStage.elementary);

    expect(engine.studyHarder().isSuccess, isTrue);
    expect(engine.studyHarder().isFailure, isTrue);
  });

  test('extracurriculars exist only for middle and high school', () {
    expect(SchoolActions.hasClubs(SchoolStage.elementary), isFalse);
    expect(SchoolActions.hasClubs(SchoolStage.middle), isTrue);
    expect(SchoolActions.hasClubs(SchoolStage.high), isTrue);
    expect(SchoolActions.hasClubs(SchoolStage.university), isFalse);
  });

  test('a school NPC can be interacted with', () {
    final engine = _studentEngine(SchoolStage.elementary);

    engine.ensureSchool();

    final npc = engine.state.lifeProgress.education.classmates.first;
    final result = engine.interactWithNpc(npcId: npc.id, action: 'Talk');

    expect(result.isSuccess, isTrue);
  });

  test('the soldier job is gone from the catalog', () {
    expect(JobCatalog.all.any((job) => job.id == 'soldier'), isFalse);
  });

  test('school names follow the country', () {
    String name(String code, SchoolStage stage) => SchoolNames.generate(
          countryCode: code,
          stage: stage,
          cityName: 'Testville',
          random: Random(1),
        );

    expect(name('ID', SchoolStage.elementary), startsWith('SD Negeri'));
    expect(name('ID', SchoolStage.high), startsWith('SMA Negeri'));
    expect(name('DE', SchoolStage.elementary), startsWith('Grundschule'));
    expect(name('JP', SchoolStage.middle), contains('Junior High School'));
    expect(name('GB', SchoolStage.university), 'University of Testville');
    expect(name('US', SchoolStage.high), endsWith('High School'));
  });

  test('school NPCs get a stable avatar look from the game assets', () {
    const npc = SchoolNpc(
      id: 'sc-9',
      firstName: 'Budi',
      lastName: 'Santoso',
      gender: Gender.male,
      birthYear: 2001,
      role: SchoolRole.classmate,
    );

    final a = SchoolAppearance.forNpc(npc);
    final b = SchoolAppearance.forNpc(npc);

    expect(a.skinTone, b.skinTone);
    expect(a.hair, b.hair);
    expect(a.hairColor, b.hairColor);
    expect(SchoolAppearance.characterFor(npc).id, 'sc-9');
  });
}
