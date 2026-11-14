import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/resume.dart';
import 'package:everylife/presentation/widgets/resume_dialog.dart';

const _resume = [
  ResumeEntry(
    kind: ResumeKind.school,
    title: 'High School',
    place: 'Lincoln High',
    startYear: 2014,
    endYear: 2018,
    outcome: 'Graduated',
  ),
  ResumeEntry(
    kind: ResumeKind.school,
    title: 'University',
    detail: 'Law',
    place: 'Lincoln Law Hall',
    startYear: 2018,
    endYear: 2022,
    outcome: 'Graduated',
  ),
  ResumeEntry(
    kind: ResumeKind.job,
    title: 'Cashier',
    detail: 'Trainee',
    startYear: 2023,
  ),
];

Future<void> _open(WidgetTester tester, List<ResumeEntry> resume) async {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const Key('open'),
            onPressed: () => showResumeDialog(
              context,
              resume: resume,
              birthYear: 2000,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the resume opens on three categories', (tester) async {
    await _open(tester, _resume);

    expect(find.byKey(const Key('resume-hub')), findsOneWidget);
    expect(find.byKey(const Key('resume-tab-education')), findsOneWidget);
    expect(find.byKey(const Key('resume-tab-degrees')), findsOneWidget);
    expect(find.byKey(const Key('resume-tab-work')), findsOneWidget);
  });

  testWidgets('education lists every school by age, with no years', (
    tester,
  ) async {
    await _open(tester, _resume);
    await tester.tap(find.byKey(const Key('resume-tab-education')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('resume-education')), findsOneWidget);
    expect(find.text('High School'), findsOneWidget);
    expect(find.text('University: Law'), findsOneWidget);
    expect(find.text('Lincoln High'), findsOneWidget);
    expect(find.textContaining('From age 14 to 18'), findsOneWidget);
    expect(find.textContaining('201'), findsNothing);
    expect(find.textContaining('202'), findsNothing);
  });

  testWidgets('degrees show the major and the age it was earned', (
    tester,
  ) async {
    await _open(tester, _resume);
    await tester.tap(find.byKey(const Key('resume-tab-degrees')));
    await tester.pumpAndSettle();

    expect(find.text('Bachelor: Law'), findsOneWidget);
    expect(find.text('Earned at age 22'), findsOneWidget);
  });

  testWidgets('work shows the rank and that the job is still going', (
    tester,
  ) async {
    await _open(tester, _resume);
    await tester.tap(find.byKey(const Key('resume-tab-work')));
    await tester.pumpAndSettle();

    expect(find.text('Cashier'), findsOneWidget);
    expect(find.text('Trainee'), findsOneWidget);
    expect(find.textContaining('Since age 23'), findsOneWidget);
  });

  testWidgets('every category opens even when it is empty', (tester) async {
    await _open(tester, const []);

    for (final name in ['education', 'degrees', 'work']) {
      await tester.tap(find.byKey(Key('resume-tab-$name')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('resume-$name')), findsOneWidget, reason: name);

      await tester.tap(find.byTooltip('Close').last);
      await tester.pumpAndSettle();
    }
  });

  test('the summary counts schools, degrees and jobs', () {
    expect(resumeSummary(const []), 'Nothing on it yet');
    expect(resumeSummary(_resume), '2 schools · 1 degree · 1 job');
  });

  test('ages read naturally', () {
    expect(resumeSpan(_resume[0], 2000), 'From age 14 to 18');
    expect(resumeSpan(_resume[2], 2000), 'Since age 23');
    expect(
      resumeSpan(
        const ResumeEntry(
          kind: ResumeKind.job,
          title: 'Odd Job',
          startYear: 2021,
          endYear: 2021,
        ),
        2000,
      ),
      'At age 21',
    );
  });
}
