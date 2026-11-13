import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/presentation/screens/school_screen.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/school/school_setup.dart';

SimulationEngine _universityEngine({String? club}) {
  final repository = InMemorySaveRepository();
  final base = SimulationEngine.create(
    player: Character.create(
      id: 'university-screen-player',
      name: 'University Student',
      birthYear: 2000,
    ),
    seed: 12,
    saveRepository: repository,
  );
  var state = base.state.copyWith(
    clock: const SimulationClock(currentYear: 2018),
    lifeProgress: base.state.lifeProgress.copyWith(
      education: const EducationState(
        initialized: true,
        stage: SchoolStage.university,
        schoolStage: SchoolStage.university,
        schoolName: 'Oakridge University',
        majorId: 'business',
        isPrivateSchool: true,
      ),
    ),
  );
  state = SchoolSetup.ensure(state);
  state = state.copyWith(
    lifeProgress: state.lifeProgress.copyWith(
      education: state.lifeProgress.education.copyWith(
        isPrivateSchool: true,
        club: club,
        clubPerformance: club == null ? 0 : 45,
      ),
    ),
  );

  return SimulationEngine(
    initialState: state,
    random: SeededRandom(12),
    saveRepository: repository,
  );
}

void main() {
  testWidgets('university information shows the major instead of school type',
      (tester) async {
    final engine = _universityEngine();

    await tester.pumpWidget(
      MaterialApp(home: SchoolScreen(engine: engine, zoom: 1)),
    );

    await tester.tap(find.byKey(const Key('school-card')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Major: Business & Economics'), findsOneWidget);
    expect(find.textContaining('School: Private'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('university students can join a club from activities',
      (tester) async {
    final engine = _universityEngine();

    await tester.pumpWidget(
      MaterialApp(home: SchoolScreen(engine: engine, zoom: 1)),
    );

    final joinClub = find.byKey(const Key('activity-club'));
    expect(joinClub, findsOneWidget);
    await tester.ensureVisible(joinClub);
    await tester.tap(joinClub);
    await tester.pumpAndSettle();

    final debateClub = find.byKey(const Key('club-debate'));
    expect(debateClub, findsOneWidget);
    await tester.ensureVisible(debateClub);
    await tester.tap(debateClub);
    await tester.pumpAndSettle();

    expect(engine.state.lifeProgress.education.club, 'Debate Club');
  });

  testWidgets('university students see and can open their club card',
      (tester) async {
    final engine = _universityEngine(club: 'Debate Club');

    await tester.pumpWidget(
      MaterialApp(home: SchoolScreen(engine: engine, zoom: 1)),
    );

    final clubCard = find.byKey(const Key('club-card'));
    expect(clubCard, findsOneWidget);
    await tester.tap(clubCard);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('club-info')), findsOneWidget);
    expect(find.byKey(const Key('club-train')), findsOneWidget);
    expect(find.byKey(const Key('club-leave')), findsOneWidget);
  });
}
