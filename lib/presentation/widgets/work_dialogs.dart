import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/career/gig_catalog.dart';
import '../../domain/career/part_time_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import 'animated_dialog.dart';
import 'notice_overlay.dart';
import 'themed_cards.dart';

/// A line like "2 of 3 gigs left this year".
String gigsSummary(SimulationEngine engine) {
  final unlocked = engine.availableGigs.length;
  final left = engine.gigsLeft;

  return '$unlocked to choose from · $left of ${GigCatalog.perYear} left this year';
}

/// A line like "Paper Route" or "Nothing yet · 3 to choose from".
String partTimeSummary(
  SimulationEngine engine,
  String Function(int baseMinorUnits) formatBase,
) {
  final career = engine.state.lifeProgress.career;
  final job = PartTimeCatalog.byId(career.partTimeId);

  if (job != null) {
    return '${job.title} · ${formatBase(job.pay)} per year';
  }

  final count = engine.availablePartTimeJobs.length;

  return count == 0
      ? 'Nothing I can do right now'
      : '$count to choose from';
}

Future<void> _show(BuildContext context, Result<String> result) {
  final text = switch (result) {
    Success<String>(:final value) => value,
    Failure<String>(:final message) => message,
  };

  return showNotice(context, text, problem: result.isFailure);
}

/// The list of gigs the player can do. Taking one pays at once; the list
/// stays open so the next one is a tap away.
Future<void> showGigsDialog(
  BuildContext context, {
  required SimulationEngine engine,
  required String Function(int baseMinorUnits) formatBase,
  VoidCallback? onChanged,
}) {
  return showAnimatedDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final age = engine.state.player.ageAt(engine.state.clock.currentYear);
          final gigs = engine.availableGigs;
          final left = engine.gigsLeft;
          final next = GigCatalog.nextUnlockAfter(age);

          return ThemedDialog(
            title: '💸  GIGS',
            child: SingleChildScrollView(
              key: const Key('gigs-dialog'),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    left == 0
                        ? 'I have done all the gigs I can fit in this year. '
                            'More will be there after my next birthday.'
                        : 'Quick jobs for a little cash. I can do $left more '
                            'this year.',
                    key: const Key('gigs-left'),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final gig in gigs)
                    OptionTile(
                      key: Key('gig-${gig.id}'),
                      emoji: gig.emoji,
                      title: gig.title,
                      subtitle:
                          '${gig.blurb}\n${formatBase(gig.minPay)} - ${formatBase(gig.maxPay)}',
                      selected: false,
                      onTap: () {
                        final result = engine.doGig(gig.id);

                        setState(() {});

                        if (result.isSuccess) onChanged?.call();

                        _show(context, result);
                      },
                    ),
                  if (next != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '🔒 More gigs unlock at age $next.',
                        key: const Key('gigs-next-unlock'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// The list of part-time jobs the player can take, and a way to quit the
/// current one.
Future<void> showPartTimeDialog(
  BuildContext context, {
  required SimulationEngine engine,
  required String Function(int baseMinorUnits) formatBase,
  VoidCallback? onChanged,
}) {
  return showAnimatedDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final age = engine.state.player.ageAt(engine.state.clock.currentYear);
          final career = engine.state.lifeProgress.career;
          final current = PartTimeCatalog.byId(career.partTimeId);
          final jobs = engine.availablePartTimeJobs;
          final next = PartTimeCatalog.nextUnlockAfter(age);

          void run(Result<String> result) {
            setState(() {});

            if (result.isSuccess) onChanged?.call();

            _show(context, result);
          }

          return ThemedDialog(
            title: '🕒  PART-TIME JOBS',
            child: SingleChildScrollView(
              key: const Key('parttime-dialog'),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    current == null
                        ? 'A few hours a week, next to school or whatever else '
                            'I do. It pays every year I keep the job.'
                        : 'I work as ${current.title.toLowerCase()} and earn '
                            '${formatBase(current.pay)} per year.',
                    key: const Key('parttime-status'),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  if (jobs.isEmpty)
                    Text(
                      career.hasJob
                          ? 'I already work full time, so there is no room '
                              'for a part-time job.'
                          : 'Nothing is open to me right now.',
                      key: const Key('parttime-none'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  for (final job in jobs)
                    OptionTile(
                      key: Key('parttime-${job.id}'),
                      emoji: job.emoji,
                      title: job.title,
                      subtitle: '${job.blurb}\n${formatBase(job.pay)} per year',
                      selected: job.id == career.partTimeId,
                      onTap: () {
                        if (job.id == career.partTimeId) return;

                        run(engine.startPartTime(job.id));
                      },
                    ),
                  if (current != null)
                    OptionTile(
                      key: const Key('parttime-quit'),
                      emoji: '👋',
                      title: 'Quit my part-time job',
                      subtitle: 'Walk away from ${current.title.toLowerCase()}.',
                      selected: false,
                      onTap: () => run(engine.quitPartTime()),
                    ),
                  if (next != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '🔒 More part-time jobs unlock at age $next.',
                        key: const Key('parttime-next-unlock'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
