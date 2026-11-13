import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/major_catalog.dart';
import 'package:everylife/domain/career/tuition_funding.dart';
import 'package:everylife/presentation/widgets/university_picker.dart';

List<UniversityMajorOption> _options() => [
      for (final major in MajorCatalog.all)
        UniversityMajorOption(
          major: major,
          tuitionLabel: r'$1',
          prompt: 'Who pays for ${major.name}?',
        ),
    ];

/// Pumps the picker. [refuse] lists the ways of paying that get turned down.
Future<List<UniversityChoice>> _pump(
  WidgetTester tester, {
  Set<TuitionFunding> refuse = const {},
}) async {
  final chosen = <UniversityChoice>[];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          height: 800,
          child: UniversityPickerBody(
            height: 700,
            options: _options(),
            ask: (majorId, funding) => refuse.contains(funding)
                ? const TuitionAnswer.refused(
                    title: 'Nope',
                    text: 'That did not work out.',
                  )
                : const TuitionAnswer.approved(),
            onChoose: chosen.add,
          ),
        ),
      ),
    ),
  );

  return chosen;
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

void main() {
  testWidgets('shows one list with two headings', (tester) async {
    await _pump(tester);

    expect(find.text('GENERAL UNIVERSITY'), findsOneWidget);
    expect(find.byKey(const Key('major-business')), findsOneWidget);
    expect(find.byKey(const Key('institution-general')), findsNothing);
    expect(find.byKey(const Key('institution-specialized')), findsNothing);

    await _scrollTo(tester, find.byKey(const Key('major-nursing')));

    expect(find.text('PROFESSIONAL SCHOOLS'), findsOneWidget);
    expect(find.byKey(const Key('major-medicine')), findsOneWidget);
    expect(find.byKey(const Key('major-nursing')), findsOneWidget);
  });

  testWidgets('a major opens its page with four ways to pay', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('major-business')));
    await tester.pump();

    expect(find.byKey(const Key('funding-prompt')), findsOneWidget);
    expect(find.text('Total tuition'), findsOneWidget);

    for (final funding in TuitionFunding.values) {
      await _scrollTo(tester, find.byKey(Key('funding-${funding.name}')));
      expect(find.byKey(Key('funding-${funding.name}')), findsOneWidget);
    }
  });

  testWidgets('the page has no apply button, chance or requirements', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('major-business')));
    await tester.pump();

    expect(find.byKey(const Key('apply-major')), findsNothing);
    expect(find.text('Chance of getting in'), findsNothing);
    expect(find.text('Grades needed'), findsNothing);
    expect(find.text('Intelligence needed'), findsNothing);
    expect(find.byKey(const Key('major-blocker')), findsNothing);
  });

  testWidgets('an approved way of paying is chosen right away', (tester) async {
    final chosen = await _pump(tester);

    await tester.tap(find.byKey(const Key('major-law')));
    await tester.pump();
    await _scrollTo(tester, find.byKey(const Key('funding-loan')));
    await tester.tap(find.byKey(const Key('funding-loan')));
    await tester.pump();

    expect(chosen, hasLength(1));
    expect(chosen.single.majorId, 'law');
    expect(chosen.single.funding, TuitionFunding.loan);
  });

  testWidgets('a refusal shows a scene and hides that option', (tester) async {
    final chosen = await _pump(tester, refuse: {TuitionFunding.parents});

    await tester.tap(find.byKey(const Key('major-business')));
    await tester.pump();
    await _scrollTo(tester, find.byKey(const Key('funding-parents')));
    await tester.tap(find.byKey(const Key('funding-parents')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('funding-refused')), findsOneWidget);
    expect(find.text('That did not work out.'), findsOneWidget);
    expect(chosen, isEmpty);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('funding-refused')), findsNothing);
    expect(find.byKey(const Key('funding-parents')), findsNothing);
    expect(find.byKey(const Key('funding-loan')), findsOneWidget);
    expect(find.byKey(const Key('funding-prompt')), findsOneWidget);
  });

  testWidgets('back returns to the list', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('major-business')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('university-back')));
    await tester.pump();

    expect(find.byKey(const Key('major-business')), findsOneWidget);
    expect(find.byKey(const Key('funding-prompt')), findsNothing);
  });
}
