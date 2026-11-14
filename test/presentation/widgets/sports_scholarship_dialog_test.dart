import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/presentation/widgets/sports_scholarship_dialog.dart';

Future<bool?> _open(WidgetTester tester, Finder tap) async {
  bool? result;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const Key('open'),
            onPressed: () async {
              result = await showSportsScholarshipDialog(
                context,
                seed: 2,
                club: 'Basketball Team',
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

  expect(find.byKey(const Key('sports-scholarship-dialog')), findsOneWidget);
  expect(find.textContaining('Basketball Team'), findsWidgets);

  await tester.tap(tap);
  await tester.pumpAndSettle();

  return result;
}

void main() {
  testWidgets('accepting returns true', (tester) async {
    expect(await _open(tester, find.byKey(const Key('sports-accept'))), isTrue);
  });

  testWidgets('turning it down returns false', (tester) async {
    expect(
      await _open(tester, find.byKey(const Key('sports-decline'))),
      isFalse,
    );
  });
}
