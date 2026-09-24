import 'package:flutter_test/flutter_test.dart';

import '../../lib/app/app.dart';

void main() {
  group('LifeSimulationApp startup', () {
    testWidgets(
      'starts without duplicate simulation system registration',
      (tester) async {
        await tester.pumpWidget(
          const LifeSimulationApp(),
        );

        await tester.pump();

        expect(
          find.text('Life Simulation'),
          findsOneWidget,
        );

        expect(
          find.text('Newborn'),
          findsOneWidget,
        );

        expect(
          find.text('Age 0'),
          findsOneWidget,
        );

        expect(
          find.text('Year 2026'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'can perform the first age up after startup',
      (tester) async {
        await tester.pumpWidget(
          const LifeSimulationApp(),
        );

        await tester.pump();

        expect(
          find.text('Age 0'),
          findsOneWidget,
        );

        await tester.tap(
          find.text('AGE UP'),
        );

        await tester.pump();

        expect(
          find.text('Age 1'),
          findsOneWidget,
        );

        expect(
          find.text('Year 2027'),
          findsOneWidget,
        );
      },
    );
  });
}
