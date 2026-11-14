import 'package:flutter/material.dart';

import 'package:everylife/core/money/game_currency.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/presentation/widgets/page_top_bar.dart';
import '../widgets/notice_overlay.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/result/result.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';

/// Every job in the game, grouped by sector, each with its picture.
/// Jobs the player qualifies for can be applied to from here.
class JobsScreen extends StatefulWidget {
  const JobsScreen({
    required this.engine,
    required this.zoom,
    this.onChanged,
    this.headerBuilder,
    super.key,
  });

  final SimulationEngine engine;
  final double zoom;
  final Future<void> Function()? onChanged;
  final WidgetBuilder? headerBuilder;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  SimulationEngine get engine => widget.engine;

  double s(double value) => value * widget.zoom;

  String _formatBase(int baseMinorUnits) {
    final countryCode = engine.state.player.location?.countryCode ?? '';
    final currency = GameCurrency.forCountryCurrency(
      CountryCatalog.findByCode(countryCode)?.currencyCode,
    );
    final scaled = LifeEffectApplier.scaleMoney(engine.state, baseMinorUnits);

    return CurrencyFormatter.format(
      Money.fromMinorUnits(scaled),
      currencyCode: currency,
    );
  }

  void _apply(JobDefinition job) {
    final result = engine.applyForJob(job.id);
    final text = switch (result) {
      Success<String>(:final value) => value,
      Failure<String>(:final message) => message,
    };

    setState(() {});

    if (result.isSuccess) {
      widget.onChanged?.call();
    }

    showNotice(context, text, problem: result.isFailure);
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final career = state.lifeProgress.career;
    final year = state.clock.currentYear;
    final available = {for (final job in engine.availableJobs) job.id};
    final appliedThisYear = career.lastApplicationYear == year;
    final theme = Theme.of(context);

    final children = <Widget>[];

    for (final sector in JobSector.values) {
      final jobs = [
        for (final job in JobCatalog.all)
          if (job.sector == sector) job,
      ];

      if (jobs.isEmpty) {
        continue;
      }

      children.add(
        Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHighest,
          padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(3)),
          child: Text(
            sector.label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      );

      for (final job in jobs) {
        final isCurrent = career.jobId == job.id;
        final canApply = available.contains(job.id) &&
            !career.hasJob &&
            !career.retired &&
            !appliedThisYear;
        final qualifies = available.contains(job.id);

        final agePart = job.minAge != 18 ? 'Age ${job.minAge}+ · ' : '';
        final requirement = '$agePart${JobCatalog.requirementLabel(job)}';

        children.add(
          Card(
            key: Key('job-${job.id}'),
            margin: EdgeInsets.zero,
            elevation: 0,
            color: isCurrent ? theme.colorScheme.primaryContainer : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(s(4)),
              child: Row(
                children: [
                  SizedBox(
                    width: s(34),
                    child: Center(
                      child: Text(
                        job.emoji,
                        style: TextStyle(fontSize: s(24)),
                      ),
                    ),
                  ),
                  SizedBox(width: s(6)),
                  Expanded(
                    child: Opacity(
                      opacity: qualifies || isCurrent ? 1 : 0.55,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'From ${_formatBase(job.baseSalary)} per year',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            requirement,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Text(
                      'YOUR JOB',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (qualifies)
                    FilledButton.tonal(
                      key: Key('apply-${job.id}'),
                      onPressed: canApply ? () => _apply(job) : null,
                      child: Text('APPLY ${engine.hiringChance(job)}%'),
                    )
                  else
                    Icon(
                      Icons.lock_outline,
                      size: s(20),
                      color: theme.disabledColor,
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }

    String? note;

    if (career.retired) {
      note = 'I am retired and no longer looking for work.';
    } else if (career.hasJob) {
      note = 'I already have a job. I would need to quit first.';
    } else if (state.lifeProgress.education.isStudent) {
      note = 'I cannot work full time while I am still studying.';
    } else if (appliedThisYear) {
      note = 'I already applied this year.';
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(title: 'Jobs', zoom: widget.zoom),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (note != null)
                      Padding(
                        padding: EdgeInsets.all(s(8)),
                        child: Text(
                          note,
                          key: const Key('jobs-note'),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ...children,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
