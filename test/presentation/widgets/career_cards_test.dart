import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/presentation/screens/career_screen.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

SimulationEngine _engineAt18({
  EducationLevel highest = EducationLevel.highSchool,
  CareerState career = const CareerState(),
}) {
  final base = SimulationEngine.create(
    player: Character.create(id: 'p', name: 'Test Player', birthYear: 2000),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  );

  return SimulationEngine(
    initialState: base.state.copyWith(
      clock: const SimulationClock(currentYear: 2018),
      lifeProgress: LifeProgress(
        education: EducationState(initialized: true, highest: highest),
        career: career,
      ),
    ),
    random: SeededRandom(1),
    saveRepository: InMemorySaveRepository(),
  );
}

Future<void> _pump(WidgetTester tester, SimulationEngine engine) {
  return tester.pumpWidget(
    MaterialApp(home: CareerScreen(engine: engine, zoom: 1)),
  );
}

void main() {
  testWidgets('a graduate without a job sees the university and job cards', (
    tester,
  ) async {
    await _pump(tester, _engineAt18());

    expect(find.byKey(const Key('university-card')), findsOneWidget);
    expect(find.text('University'), findsOneWidget);
    expect(find.text('Choose where and what to study'), findsOneWidget);
    expect(find.byKey(const Key('grades-bar')), findsNothing);
    expect(find.byKey(const Key('job-card')), findsOneWidget);
    expect(find.text('Unemployed'), findsOneWidget);
  });

  testWidgets('a working player cannot open the university card', (
    tester,
  ) async {
    await _pump(
      tester,
      _engineAt18(
        career: const CareerState(
          jobId: 'cashier',
          salaryBase: 1000000,
          performance: 70,
        ),
      ),
    );

    expect(find.byKey(const Key('university-needs-quit')), findsOneWidget);
    expect(find.byKey(const Key('ask-raise')), findsOneWidget);
    expect(find.byKey(const Key('quit-job')), findsOneWidget);
    expect(find.text('◆ PERFORMANCE'), findsOneWidget);
  });

  testWidgets('a player with a degree has no university card', (tester) async {
    await _pump(tester, _engineAt18(highest: EducationLevel.bachelor));

    expect(find.byKey(const Key('university-card')), findsNothing);
    expect(find.byKey(const Key('job-card')), findsOneWidget);
  });

  testWidgets('the university card opens the university overlay', (
    tester,
  ) async {
    await _pump(tester, _engineAt18());

    await tester.tap(find.byKey(const Key('university-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('university-picker')), findsOneWidget);
    expect(find.byKey(const Key('institution-general')), findsOneWidget);
  });
}
