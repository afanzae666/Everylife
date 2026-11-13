import 'package:flutter/material.dart';

import 'package:everylife/core/money/game_currency.dart';
import 'package:everylife/core/money/money.dart';
import 'package:everylife/presentation/widgets/page_top_bar.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/result/result.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';
import '../widgets/life_event_dialogs.dart';
import '../widgets/themed_cards.dart';
import 'jobs_screen.dart';

/// The page of the player's job, like the school page: the job card on top
/// and what the player can do at work.
class WorkScreen extends StatefulWidget {
  const WorkScreen({
    required this.engine,
    required this.zoom,
    this.onChanged,
    this.headerBuilder,
    super.key,
  });

  final SimulationEngine engine;
  final double zoom;

  /// Called after an action changed the game (the caller can auto-save).
  final Future<void> Function()? onChanged;
  final WidgetBuilder? headerBuilder;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  SimulationEngine get engine => widget.engine;

  String _currencyCode() {
    final countryCode = engine.state.player.location?.countryCode ?? '';

    return GameCurrency.forCountryCurrency(
      CountryCatalog.findByCode(countryCode)?.currencyCode,
    );
  }

  /// Formats a baseline amount after country cost-of-living scaling.
  String _formatBase(int baseMinorUnits) {
    final scaled = LifeEffectApplier.scaleMoney(engine.state, baseMinorUnits);

    return CurrencyFormatter.format(
      Money.fromMinorUnits(scaled),
      currencyCode: _currencyCode(),
    );
  }

  /// Tells what happened in a pop-up, like the school page does.
  Future<void> _announce(
    Result<String> result, {
    required String title,
    required String emoji,
    bool leaveAfter = false,
  }) async {
    final ok = result.isSuccess;
    final text = switch (result) {
      Success<String>(:final value) => value,
      Failure<String>(:final message) => message,
    };

    setState(() {});

    if (ok) widget.onChanged?.call();

    await showTapToCloseOverlay(
      context,
      title: ok ? title : 'Not Now',
      emoji: ok ? emoji : '⏳',
      text: text,
    );

    if (!mounted) return;

    if (ok && leaveAfter) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  void _openJobs() {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => JobsScreen(
              engine: engine,
              zoom: widget.zoom,
              onChanged: widget.onChanged,
              headerBuilder: widget.headerBuilder,
            ),
          ),
        )
        .then((_) {
      if (!mounted) return;

      // Taking a new job leaves this page, because it is about the old one.
      if (!engine.state.lifeProgress.career.hasJob) {
        Navigator.of(context).pop();
      } else {
        setState(() {});
      }
    });
  }

  Widget _activity({
    required Key key,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return AccentCard(
      key: key,
      zoom: widget.zoom,
      child: InteractionRow(
        emoji: emoji,
        title: title,
        description: subtitle,
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final career = state.lifeProgress.career;
    final job = career.hasJob ? JobCatalog.byId(career.jobId!) : null;
    final year = state.clock.currentYear;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(title: 'Job', zoom: widget.zoom),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (job == null)
                      Padding(
                        padding: EdgeInsets.all(8 * widget.zoom),
                        child: const Text('I do not have a job right now.'),
                      )
                    else ...[
                      ActionCard(
                        key: const Key('work-card'),
                        zoom: widget.zoom,
                        emoji: job.emoji,
                        title: job.titleAt(career.rank),
                        subtitle:
                            'Salary: ${_formatBase(career.salaryBase)} per year',
                        footer: MeterFooter(
                          label: '◆ PERFORMANCE',
                          valueText: '${career.performance}/100',
                          value: career.performance / 100,
                          barKey: const Key('performance-bar'),
                          zoom: widget.zoom,
                        ),
                      ),
                      SectionDivider(title: 'ACTIVITIES', zoom: widget.zoom),
                      _activity(
                        key: const Key('ask-raise'),
                        emoji: '💰',
                        title: 'Ask for a Raise',
                        subtitle: career.lastRaiseRequestYear == year
                            ? 'Done for this year'
                            : 'Ask my boss for more pay',
                        onTap: career.lastRaiseRequestYear == year
                            ? null
                            : () => _announce(
                                  engine.askForRaise(),
                                  title: 'Raise',
                                  emoji: '💰',
                                ),
                      ),
                      _activity(
                        key: const Key('find-another-job'),
                        emoji: '🔎',
                        title: 'Find Another Job',
                        subtitle: 'See every job I can apply for',
                        onTap: _openJobs,
                      ),
                      _activity(
                        key: const Key('quit-job'),
                        emoji: '🚪',
                        title: 'Quit My Job',
                        subtitle: 'Leave this job for good',
                        onTap: () => _announce(
                          engine.quitJob(),
                          title: 'Resigned',
                          emoji: '🚪',
                          leaveAfter: true,
                        ),
                      ),
                    ],
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
