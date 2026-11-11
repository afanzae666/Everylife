import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/love/breakup_summary.dart';
import 'package:everylife/presentation/widgets/breakup_overlay.dart';

void main() {
  const summary = BreakupSummary(
    npcId: 'pal-1',
    name: 'Dewi Test',
    kind: BreakupKind.divorce,
    title: 'Divorced',
    story: 'The papers are signed.',
    quip: 'The ring is now a paperweight.',
    facts: [
      MapEntry('Married for', '7 years'),
      MapEntry('Children', '2'),
      MapEntry('Now', 'Ex-wife'),
    ],
  );

  testWidgets('shows the story and every fact, and closes on tap',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showBreakupOverlay(context, summary),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('breakup-overlay')), findsOneWidget);
    expect(find.text('Divorced'), findsWidgets);
    expect(find.text('The papers are signed.'), findsOneWidget);
    expect(find.text('Married for'), findsOneWidget);
    expect(find.text('7 years'), findsOneWidget);
    expect(find.text('Ex-wife'), findsOneWidget);
    expect(find.text('The ring is now a paperweight.'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('breakup-overlay')), findsNothing);
  });
}
