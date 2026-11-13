import 'package:everylife/presentation/widgets/page_top_bar.dart';
import 'package:everylife/core/money/game_currency.dart';
import 'package:flutter/material.dart';

import '../../core/money/currency_formatter.dart';
import 'package:everylife/core/money/money.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/major_catalog.dart';
import '../../domain/world/country_catalog.dart';
import 'jobs_screen.dart';
import 'school_screen.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';
import '../widgets/themed_cards.dart';
import '../widgets/university_picker.dart';

/// School (ages 6-17) or occupation (18+): status, actions, and history.
///
/// Under 18 the page is "School": elementary, middle and high school.
/// From 18 it is "Occupation": university, jobs, money, and pension.
class CareerScreen extends StatefulWidget {
  const CareerScreen({
    required this.engine,
    required this.zoom,
    this.onChanged,
    this.onSceneEnd,
    this.headerBuilder,
    super.key,
  });

  final SimulationEngine engine;
  final double zoom;

  /// Runs after a story closes, to show what follows (the overlay of a
  /// breakup or divorce).
  final Future<void> Function()? onSceneEnd;

  /// Called after an action changed the game (the caller can auto-save).
  final Future<void> Function()? onChanged;

  /// Builds the character profile card shown at the top of the page.
  final WidgetBuilder? headerBuilder;

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  SimulationEngine get engine => widget.engine;

  double s(double value) => value * widget.zoom;

  String _currencyCode() {
    final countryCode = engine.state.player.location?.countryCode ?? '';
    return GameCurrency.forCountryCurrency(
      CountryCatalog.findByCode(countryCode)?.currencyCode,
    );
  }

  String _formatMoney(Money amount) {
    return CurrencyFormatter.format(amount, currencyCode: _currencyCode());
  }

  /// Formats a baseline amount after country cost-of-living scaling.
  String _formatBase(int baseMinorUnits) {
    final scaled = LifeEffectApplier.scaleMoney(engine.state, baseMinorUnits);

    return _formatMoney(Money.fromMinorUnits(scaled));
  }

  void _run(Result<String> result) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final text = switch (result) {
      Success<String>(:final value) => value,
      Failure<String>(:final message) => message,
    };

    messenger.showSnackBar(SnackBar(content: Text(text)));

    setState(() {});

    if (result.isSuccess) {
      widget.onChanged?.call();
    }
  }

  /// The university overlay: kind of institution, then major, then apply.
  Future<void> _openUniversityPicker() async {
    final state = engine.state;
    final options = [
      for (final major in MajorCatalog.all)
        UniversityMajorOption(
          major: major,
          tuitionLabel: _formatMoney(
            Money.fromMinorUnits(engine.tuitionFor(major)),
          ),
          blocker: engine.majorBlocker(major),
        ),
    ];

    final majorId = await showUniversityPicker(
      context,
      options: options,
      grades: state.lifeProgress.education.grades,
      intelligence: state.player.stats.intelligence,
      chance: engine.universityChance,
      scholarship: MajorCatalog.scholarshipPercentFor(
        state.lifeProgress.education.grades,
      ),
    );

    if (!mounted || majorId == null) return;

    _run(engine.applyForUniversity(majorId));
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final progress = state.lifeProgress;
    final player = state.player;
    final age = player.ageAt(state.clock.currentYear);
    final isSchoolAge = age < 18;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(
                title: isSchoolAge ? 'School' : 'Occupation',
                zoom: widget.zoom,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildEducation(
                      progress.education,
                      state.clock.currentYear,
                    ),
                    if (!isSchoolAge) _buildWork(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSchool() {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => SchoolScreen(
              engine: engine,
              zoom: widget.zoom,
              onChanged: widget.onChanged,
              onSceneEnd: widget.onSceneEnd,
              headerBuilder: widget.headerBuilder,
            ),
          ),
        )
        .then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildEducation(EducationState education, int year) {
    if (education.isStudent) {
      engine.ensureSchool();

      return SchoolSummaryCard(
        education: engine.state.lifeProgress.education,
        zoom: widget.zoom,
        onTap: _openSchool,
      );
    }

    final age = engine.state.player.ageAt(year);
    final hasJob = engine.state.lifeProgress.career.hasJob;
    final canApply =
        education.highest == EducationLevel.highSchool && age >= 18;

    if (!canApply) return const SizedBox.shrink();

    return ActionCard(
      key: const Key('university-card'),
      zoom: widget.zoom,
      emoji: '🎓',
      title: 'University',
      subtitle: hasJob
          ? 'Quit my job first to study full time'
          : 'Choose where and what to study',
      subtitleKey: hasJob ? const Key('university-needs-quit') : null,
      enabled: !hasJob,
      onTap: _openUniversityPicker,
    );
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
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildWork() {
    final state = engine.state;
    final year = state.clock.currentYear;
    final age = state.player.ageAt(year);
    final career = state.lifeProgress.career;
    final job = career.hasJob ? JobCatalog.byId(career.jobId!) : null;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    var emoji = '💼';
    var title = 'Job';
    String? subtitle;
    Key? subtitleKey;
    Widget? footer;

    if (career.retired) {
      emoji = '🏖️';
      title = 'Retired';
      subtitle = 'Pension: ${_formatBase(career.pensionBase)} per year';
    } else if (job != null) {
      emoji = job.emoji;
      title = job.titleAt(career.rank);
      subtitle = 'Salary: ${_formatBase(career.salaryBase)} per year';
      footer = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '◆ PERFORMANCE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${career.performance}/100',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: s(3)),
          PipBar(value: career.performance / 100, height: s(8)),
          SizedBox(height: s(6)),
          Wrap(
            spacing: s(8),
            children: [
              FilledButton.tonal(
                key: const Key('ask-raise'),
                onPressed: career.lastRaiseRequestYear == year
                    ? null
                    : () => _run(engine.askForRaise()),
                child: const Text('ASK FOR A RAISE'),
              ),
              TextButton(
                key: const Key('quit-job'),
                onPressed: () => _run(engine.quitJob()),
                child: const Text('QUIT'),
              ),
            ],
          ),
        ],
      );
    } else if (age < 16) {
      subtitle = 'I am too young to work.';
    } else if (state.lifeProgress.education.isStudent) {
      title = 'Student';
      subtitle = 'I cannot work full time while I am still studying.';
      subtitleKey = const Key('student-cannot-work');
    } else {
      title = 'Unemployed';
      subtitle = 'Tap to see every job.';
    }

    return ActionCard(
      key: const Key('job-card'),
      zoom: widget.zoom,
      emoji: emoji,
      title: title,
      subtitle: subtitle,
      subtitleKey: subtitleKey,
      onTap: _openJobs,
      footer: footer,
    );
  }
}
