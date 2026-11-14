import 'package:flutter/material.dart';

import '../../domain/career/resume.dart';
import 'animated_dialog.dart';
import 'themed_cards.dart';

/// A short line for the resume card: how many schools, degrees and jobs.
String resumeSummary(List<ResumeEntry> resume) {
  if (resume.isEmpty) return 'Nothing on it yet';

  final schools = resume.where((e) => e.kind == ResumeKind.school).length;
  final degrees = resume.where((e) => e.isDegree).length;
  final jobs = resume.where((e) => e.kind == ResumeKind.job).length;

  String count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

  return [
    count(schools, 'school', 'schools'),
    count(degrees, 'degree', 'degrees'),
    count(jobs, 'job', 'jobs'),
  ].join(' · ');
}

String _years(ResumeEntry entry) {
  final end = entry.endYear;

  if (end == null) return '${entry.startYear} - now';

  return end == entry.startYear ? '$end' : '${entry.startYear} - $end';
}

/// The resume: schools, degrees and jobs of the player's life.
Future<void> showResumeDialog(
  BuildContext context, {
  required List<ResumeEntry> resume,
  String? currentSchool,
}) {
  final schools = [
    for (final entry in resume)
      if (entry.kind == ResumeKind.school) entry,
  ];
  final degrees = [
    for (final entry in resume)
      if (entry.isDegree) entry,
  ];
  final jobs = [
    for (final entry in resume)
      if (entry.kind == ResumeKind.job) entry,
  ];

  return showAnimatedDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      Widget line(
        String title,
        String? detail,
        String when, {
        Key? key,
      }) =>
          Padding(
            key: key,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
                if (detail != null && detail.isNotEmpty) Text(detail),
                Text(when, style: theme.textTheme.bodySmall),
              ],
            ),
          );

      List<Widget> section(String heading, List<Widget> children, String empty) =>
          [
            SectionDivider(title: heading),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(empty, style: theme.textTheme.bodySmall),
              )
            else
              ...children,
          ];

      return ThemedDialog(
        title: 'Resume',
        child: SizedBox(
          key: const Key('resume-dialog'),
          width: 560,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            children: [
              ...section(
                'EDUCATION',
                [
                  for (final entry in schools)
                    line(
                      entry.detail == null
                          ? entry.title
                          : '${entry.title}: ${entry.detail}',
                      entry.place ?? (entry.isOngoing ? currentSchool : null),
                      entry.outcome == null
                          ? _years(entry)
                          : '${_years(entry)} · ${entry.outcome}',
                    ),
                ],
                'No school yet.',
              ),
              ...section(
                'DEGREES',
                [
                  for (final entry in degrees)
                    line(
                      'Bachelor: ${entry.detail ?? 'General studies'}',
                      entry.place,
                      'Graduated ${entry.endYear}',
                    ),
                ],
                'No degree yet.',
              ),
              ...section(
                'WORK',
                [
                  for (final entry in jobs)
                    line(
                      entry.title,
                      entry.detail,
                      entry.outcome == null
                          ? _years(entry)
                          : '${_years(entry)} · ${entry.outcome}',
                    ),
                ],
                'No job yet.',
              ),
            ],
          ),
        ),
      );
    },
  );
}
