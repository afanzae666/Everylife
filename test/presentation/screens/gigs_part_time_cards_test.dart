import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/presentation/screens/career_screen.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

SimulationEngine _engineAt(int age) {
  final base = SimulationEngine.create(
    player: Character.create(id: 'p', name: 'Test Player', birthYear: 2000),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  );

  return SimulationEngine(
    initialState: base.state.copyWith(
      clock: SimulationClock(currentYear: 2000 + age),
      lifeProgress: LifeProgress(
        education: EducationState(
          initialized: true,
          stage: age < 18 ? SchoolStage.high : SchoolStage.none,
          highest: EducationLevel.highSchool,
        ),
      ),
    ),
    random: SeededRandom(1),
    saveRepository: InMemorySaveRepository(),
  );
}

Future<void> _pump(WidgetTester tester, SimulationEngine engine) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(home: CareerScreen(engine: engine, zoom: 1)),
  );
}

void main() {
  testWidgets('a child sees no gigs card and no part-time card', (
    tester,
  ) async {
    await _pump(tester, _engineAt(11));

    expect(find.byKey(const Key('gigs-card')), findsNothing);
    expect(find.byKey(const Key('parttime-card')), findsNothing);
  });

  testWidgets('a twelve-year-old sees gigs but no part-time job yet', (
    tester,
  ) async {
    await _pump(tester, _engineAt(12));

    expect(find.byKey(const Key('gigs-card')), findsOneWidget);
    expect(find.byKey(const Key('parttime-card')), findsNothing);
  });

  testWidgets('the gigs card opens a list and a gig pays', (tester) async {
    final engine = _engineAt(12);

    await _pump(tester, engine);
    await tester.tap(find.byKey(const Key('gigs-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('gigs-dialog')), findsOneWidget);
    expect(find.byKey(const Key('gig-mow_lawns')), findsOneWidget);
    expect(find.byKey(const Key('gig-courier_run')), findsNothing);
    expect(find.byKey(const Key('gigs-next-unlock')), findsOneWidget);

    final before = engine.state.player.money.minorUnits;

    await tester.tap(find.byKey(const Key('gig-mow_lawns')));
    await tester.pumpAndSettle();

    expect(engine.state.player.money.minorUnits, greaterThan(before));
    expect(find.byKey(const Key('notice-overlay')), findsOneWidget);
  });

  testWidgets('a sixteen-year-old student can take a part-time job', (
    tester,
  ) async {
    final engine = _engineAt(16);

    await _pump(tester, engine);

    expect(find.byKey(const Key('parttime-card')), findsOneWidget);

    await tester.tap(find.byKey(const Key('parttime-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('parttime-dialog')), findsOneWidget);
    expect(find.byKey(const Key('parttime-cashier_pt')), findsOneWidget);
    expect(find.byKey(const Key('parttime-delivery_rider')), findsNothing);

    await tester.tap(find.byKey(const Key('parttime-cashier_pt')));
    await tester.pumpAndSettle();

    expect(engine.state.lifeProgress.career.partTimeId, 'cashier_pt');
  });
}
