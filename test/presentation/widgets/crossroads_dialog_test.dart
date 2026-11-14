import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/presentation/widgets/crossroads_dialog.dart';

Future<CrossroadsChoice?> _open(
  WidgetTester tester, {
  required Finder tap,
  bool canStudy = true,
  String? sportsClub,
}) async {
  CrossroadsChoice? result;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const Key('open'),
            onPressed: () async {
              result = await showCrossroadsDialog(
                context,
                seed: 3,
                canStudy: canStudy,
                sportsClub: sportsClub,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
  await tester.tap(tap);
  await tester.pumpAndSettle();

  return result;
}

void main() {
  testWidgets('offers university, work and a break', (tester) async {
    await _open(tester, tap: find.byKey(const Key('crossroads-work')));

    // Chosen above; open again to look at the three options.
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('crossroads-university')), findsOneWidget);
    expect(find.byKey(const Key('crossroads-work')), findsOneWidget);
    expect(find.byKey(const Key('crossroads-rest')), findsOneWidget);
  });

  testWidgets('each option returns its choice', (tester) async {
    expect(
      await _open(tester, tap: find.byKey(const Key('crossroads-university'))),
      CrossroadsChoice.university,
    );
  });

  testWidgets('work returns work', (tester) async {
    expect(
      await _open(tester, tap: find.byKey(const Key('crossroads-work'))),
      CrossroadsChoice.work,
    );
  });

  testWidgets('a break returns rest', (tester) async {
    expect(
      await _open(tester, tap: find.byKey(const Key('crossroads-rest'))),
      CrossroadsChoice.rest,
    );
  });

  testWidgets('without a diploma there is no university', (tester) async {
    await _open(
      tester,
      canStudy: false,
      tap: find.byKey(const Key('crossroads-work')),
    );

    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('crossroads-university')), findsNothing);
  });

  testWidgets('an offer shows in the university option', (tester) async {
    await _open(
      tester,
      sportsClub: 'Basketball Team',
      tap: find.byKey(const Key('crossroads-work')),
    );

    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Basketball Team'), findsOneWidget);
  });
}
