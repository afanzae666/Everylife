import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/presentation/screens/more_screen.dart';
import 'package:everylife/presentation/widgets/themed_cards.dart';

void main() {
  testWidgets('Time Machine uses the shared action card and opens on tap', (
    tester,
  ) async {
    var opened = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MoreScreen(
          zoom: 1,
          onTimeMachine: () => opened = true,
        ),
      ),
    );

    final card = find.byKey(const Key('time-machine-card'));
    expect(card, findsOneWidget);
    expect(find.byType(ActionCard), findsOneWidget);

    await tester.tap(card);
    expect(opened, isTrue);
  });

  testWidgets('Birth Control uses the shared action card and saves toggles', (
    tester,
  ) async {
    bool? savedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: MoreScreen(
          zoom: 1,
          showBirthControl: true,
          birthControlOn: false,
          onBirthControl: ({required on}) {
            savedValue = on;
            return on;
          },
        ),
      ),
    );

    final card = find.byKey(const Key('birth-control-card'));
    expect(card, findsOneWidget);
    expect(find.byType(ActionCard), findsNWidgets(2));
    expect(find.text('Disabled · Greatly lowers the chance of pregnancy'),
        findsOneWidget);

    await tester.tap(card);
    await tester.pump();

    expect(savedValue, isTrue);
    expect(find.text('Enabled · Greatly lowers the chance of pregnancy'),
        findsOneWidget);
  });
}
