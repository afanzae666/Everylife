import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/major_catalog.dart';
import 'package:everylife/presentation/widgets/university_picker.dart';

List<UniversityMajorOption> _options() => [
      for (final major in MajorCatalog.all)
        UniversityMajorOption(
          major: major,
          tuitionLabel: r'$1',
          blocker: major.id == 'law' ? 'Needs grades 70+' : null,
        ),
    ];

Future<List<String>> _pump(WidgetTester tester) async {
  final applied = <String>[];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 420,
          height: 800,
          child: UniversityPickerBody(
            height: 600,
            options: _options(),
            grades: 60,
            intelligence: 60,
            chance: 70,
            year: 2026,
            onApply: applied.add,
          ),
        ),
      ),
    ),
  );

  return applied;
}

void main() {
  testWidgets('starts with a story and the two kinds of institution', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.byKey(const Key('university-intro')), findsOneWidget);
    expect(find.byKey(const Key('institution-general')), findsOneWidget);
    expect(find.byKey(const Key('institution-specialized')), findsOneWidget);
  });

  testWidgets('choosing the general university lists the majors', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('institution-general')));
    await tester.pump();

    for (final major in MajorCatalog.all) {
      expect(find.byKey(Key('major-${major.id}')), findsOneWidget);
    }
    expect(find.byKey(const Key('university-intro')), findsNothing);
  });

  testWidgets('choosing a specialized institution keeps the overlay open', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('institution-specialized')));
    await tester.pump();

    expect(find.byKey(const Key('no-programs')), findsOneWidget);
    expect(find.byKey(const Key('university-back')), findsOneWidget);

    await tester.tap(find.byKey(const Key('university-back')));
    await tester.pump();

    expect(find.byKey(const Key('institution-general')), findsOneWidget);
  });

  testWidgets('a major the player qualifies for can be applied to', (
    tester,
  ) async {
    final applied = await _pump(tester);

    await tester.tap(find.byKey(const Key('institution-general')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('major-business')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('apply-major')));
    await tester.pump();

    expect(applied, ['business']);
  });

  testWidgets('a blocked major shows why and cannot be applied to', (
    tester,
  ) async {
    final applied = await _pump(tester);

    await tester.tap(find.byKey(const Key('institution-general')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('major-law')));
    await tester.pump();

    expect(find.byKey(const Key('major-blocker')), findsOneWidget);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('apply-major')),
    );

    expect(button.onPressed, isNull);
    expect(applied, isEmpty);
  });

  testWidgets('back from a major returns to the list', (tester) async {
    await _pump(tester);

    await tester.tap(find.byKey(const Key('institution-general')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('major-business')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('university-back')));
    await tester.pump();

    expect(find.byKey(const Key('major-business')), findsOneWidget);
    expect(find.byKey(const Key('apply-major')), findsNothing);
  });
}
