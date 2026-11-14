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

/// When it happened, in the player's ages. The game has no calendar years.
String resumeSpan(ResumeEntry entry, int birthYear) {
  final start = entry.startYear - birthYear;
  final end = entry.endYear;

  if (end == null) return 'Since age $start';

  final stop = end - birthYear;

  return stop == start ? 'At age $start' : 'From age $start to $stop';
}

String _outcome(ResumeEntry entry) {
  final outcome = entry.outcome;

  if (outcome == null) {
    return entry.kind == ResumeKind.school
        ? 'Still studying'
        : 'Still working here';
  }

  return switch (outcome) {
    'Graduated' => 'Finished with a diploma',
    'Retired' => 'Retired',
    _ when entry.kind == ResumeKind.school => 'Left before finishing',
    _ => 'Moved on',
  };
}

/// The resume. It opens on the three categories; each category is an overlay
/// of its own, and opens even when there is nothing in it yet.
Future<void> showResumeDialog(
  BuildContext context, {
  required List<ResumeEntry> resume,
  required int birthYear,
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
    builder: (hubContext) {
      final theme = Theme.of(hubContext);

      Widget tile(
        String keyName,
        String emoji,
        String title,
        String story,
        int count,
        VoidCallback onTap,
      ) =>
          OptionTile(
            key: Key('resume-tab-$keyName'),
            emoji: emoji,
            title: title,
            subtitle: count == 0 ? story : '$story · $count',
            selected: false,
            onTap: onTap,
          );

      return ThemedDialog(
        title: 'Resume',
        child: SingleChildScrollView(
          key: const Key('resume-hub'),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Every classroom, diploma and paycheck of my life so far, '
                'written down in one place. Which page of my story do I '
                'want to read?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              tile(
                'education',
                '🏫',
                'Education',
                'Every classroom I ever sat in.',
                schools.length,
                () => _showCategory(
                  hubContext,
                  dialogKey: const Key('resume-education'),
                  title: 'Education',
                  emoji: '🏫',
                  empty: 'No classroom has seen me yet. My school days are '
                      'still waiting to begin.',
                  lines: [
                    for (final entry in schools)
                      _Line(
                        entry.detail == null
                            ? entry.title
                            : '${entry.title}: ${entry.detail}',
                        entry.place ??
                            (entry.isOngoing ? currentSchool : null),
                        '${resumeSpan(entry, birthYear)} · ${_outcome(entry)}',
                      ),
                  ],
                ),
              ),
              tile(
                'degrees',
                '🎓',
                'Degrees',
                'The diplomas on my wall.',
                degrees.length,
                () => _showCategory(
                  hubContext,
                  dialogKey: const Key('resume-degrees'),
                  title: 'Degrees',
                  emoji: '🎓',
                  empty: 'No diploma hangs on my wall yet. Maybe one day, '
                      'with my name printed on it.',
                  lines: [
                    for (final entry in degrees)
                      _Line(
                        'Bachelor: ${entry.detail ?? 'General studies'}',
                        entry.place,
                        'Earned at age ${(entry.endYear ?? entry.startYear) - birthYear}',
                      ),
                  ],
                ),
              ),
              tile(
                'work',
                '💼',
                'Work',
                'Every place that ever paid me.',
                jobs.length,
                () => _showCategory(
                  hubContext,
                  dialogKey: const Key('resume-work'),
                  title: 'Work',
                  emoji: '💼',
                  empty: 'My first paycheck is still ahead of me. The job '
                      'list is waiting.',
                  lines: [
                    for (final entry in jobs)
                      _Line(
                        entry.title,
                        entry.detail,
                        '${resumeSpan(entry, birthYear)} · ${_outcome(entry)}',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Line {
  const _Line(this.title, this.detail, this.when);

  final String title;
  final String? detail;
  final String when;
}

Future<void> _showCategory(
  BuildContext context, {
  required Key dialogKey,
  required String title,
  required String emoji,
  required String empty,
  required List<_Line> lines,
}) {
  return showAnimatedDialog<void>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return ThemedDialog(
        title: '$emoji  ${title.toUpperCase()}',
        child: SingleChildScrollView(
          key: dialogKey,
          padding: const EdgeInsets.all(14),
          child: lines.isEmpty
              ? Text(empty, style: theme.textTheme.bodyLarge)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final line in lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(line.title, style: theme.textTheme.titleSmall),
                            if (line.detail != null && line.detail!.isNotEmpty)
                              Text(line.detail!),
                            Text(line.when, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      );
    },
  );
}
