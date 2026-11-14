import 'package:everylife/presentation/widgets/page_top_bar.dart';
import 'package:everylife/core/money/game_currency.dart';
import 'package:flutter/material.dart';

import '../../core/money/currency_formatter.dart';
import 'package:everylife/core/money/money.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/major_catalog.dart';
import '../../domain/career/resume.dart';
import '../../domain/world/country_catalog.dart';
import 'jobs_screen.dart';
import 'school_screen.dart';
import 'work_screen.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';
import '../../simulation/narrative/tuition_narratives.dart';
import '../widgets/themed_cards.dart';
import '../widgets/resume_dialog.dart';
import '../widgets/notice_overlay.dart';
import '../widgets/university_picker.dart';

/// What the Occupation page opens on its own.
enum CareerStart { university, jobs, sportsOffer }

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
    this.start,
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

  /// What to open as soon as the page shows (the choice made at 18).
  final CareerStart? start;

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  SimulationEngine get engine => widget.engine;

  @override
  void initState() {
    super.initState();

    final start = widget.start;

    if (start == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      switch (start) {
        case CareerStart.university:
          _openUniversityPicker();
        case CareerStart.jobs:
          _openJobs();
        case CareerStart.sportsOffer:
          _openUniversityPicker(sports: true);
      }
    });
  }

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

  /// The university overlay: one list of majors, then how to pay.
  Future<void> _openUniversityPicker({bool sports = false}) async {
    final state = engine.state;
    final year = state.clock.currentYear;
    final options = [
      for (final major in MajorCatalog.all)
        () {
          final total = _formatMoney(
            Money.fromMinorUnits(engine.tuitionFor(major)),
          );

          return UniversityMajorOption(
            major: major,
            tuitionLabel: total,
            prompt: TuitionNarratives.prompt(
              seed: year + major.id.length * 7 + major.years,
              major: major.name,
              total: total,
            ),
          );
        }(),
    ];

    final choice = await showUniversityPicker(
      context,
      options: options,
      ask: engine.askTuitionFunding,
      sportsClub: sports ? engine.state.lifeProgress.education.sportsOffer : null,
    );

    if (!mounted || choice == null) return;

    _run(engine.applyForUniversity(choice.majorId, choice.funding));
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
                    if (!isSchoolAge) _buildResume(progress.resume),
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

  Widget _buildResume(List<ResumeEntry> resume) {
    return ActionCard(
      key: const Key('resume-card'),
      zoom: widget.zoom,
      emoji: '📄',
      title: 'Resume',
      subtitle: resumeSummary(resume),
      onTap: () => showResumeDialog(
        context,
        resume: resume,
        birthYear: engine.state.player.birthYear,
        currentSchool: engine.state.lifeProgress.education.schoolName,
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
    // Graduates keep the card: they may study another major.
    final canApply =
        education.highest.index >= EducationLevel.highSchool.index &&
            age >= 18;

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

  void _openWork() {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => WorkScreen(
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
    final age = state.player.ageAt(state.clock.currentYear);
    final career = state.lifeProgress.career;
    final job = career.hasJob ? JobCatalog.byId(career.jobId!) : null;

    var emoji = '💼';
    var title = 'Job';
    String? subtitle;
    Key? subtitleKey;
    Widget? footer;
    var working = false;

    if (career.retired) {
      emoji = '🏖️';
      title = 'Retired';
      subtitle = 'Pension: ${_formatBase(career.pensionBase)} per year';
    } else if (job != null) {
      working = true;
      emoji = job.emoji;
      title = job.titleAt(career.rank);
      subtitle = 'Salary: ${_formatBase(career.salaryBase)} per year';
      footer = MeterFooter(
        label: '◆ PERFORMANCE',
        valueText: '${career.performance}/100',
        value: career.performance / 100,
        barKey: const Key('performance-bar'),
        zoom: widget.zoom,
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
      onTap: working ? _openWork : _openJobs,
      footer: footer,
    );
  }
}
