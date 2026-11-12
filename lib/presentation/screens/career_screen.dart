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
import '../../simulation/systems/education_system.dart';
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
      year: state.clock.currentYear,
    );

    if (!mounted || majorId == null) return;

    _run(engine.applyForUniversity(majorId));
  }

  String _stageLabel(EducationState education) {
    int grade(int total) => (education.yearsInStage + 1).clamp(1, total).toInt();

    return switch (education.stage) {
      SchoolStage.none => 'Not enrolled',
      SchoolStage.elementary =>
        'Elementary school (grade ${grade(EducationSystem.elementaryYears)} '
            'of ${EducationSystem.elementaryYears})',
      SchoolStage.middle =>
        'Middle school (grade ${grade(EducationSystem.middleYears)} '
            'of ${EducationSystem.middleYears})',
      SchoolStage.high =>
        'High school (grade ${grade(EducationSystem.highYears)} '
            'of ${EducationSystem.highYears})',
      SchoolStage.university =>
        'University (year ${grade(education.programYears)} '
            'of ${education.programYears})',
    };
  }

  String _levelLabel(EducationLevel level) {
    return switch (level) {
      EducationLevel.none => 'None yet',
      EducationLevel.elementary => 'Elementary school',
      EducationLevel.middle => 'Middle school',
      EducationLevel.highSchool => 'High school diploma',
      EducationLevel.bachelor => "Bachelor's degree",
    };
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
    final canApply = !education.isStudent &&
        education.highest == EducationLevel.highSchool &&
        age >= 18;
    final canDropOut = education.stage == SchoolStage.high ||
        education.stage == SchoolStage.university;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(s(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined),
                SizedBox(width: s(6)),
                Text(
                  age < 18 ? 'School' : 'Education',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: s(4)),
            Text('Now: ${_stageLabel(education)}'),
            Text(
              'Highest completed: ${_levelLabel(education.highest)}'
              '${education.degreeField == null ? '' : ' in ${education.degreeField!.label}'}',
            ),
            if (education.isStudent) ...[
              SizedBox(height: s(4)),
              Text('Grades: ${education.grades}/100'),
              SizedBox(height: s(2)),
              PipBar(value: education.grades / 100),
            ],
            if (canApply || canDropOut) SizedBox(height: s(6)),
            if (canApply && hasJob)
              Padding(
                padding: EdgeInsets.only(bottom: s(4)),
                child: const Text(
                  'I cannot study and work full time. '
                  'I would have to quit my job first.',
                  key: Key('university-needs-quit'),
                ),
              ),
            if (canApply)
              Opacity(
                opacity: hasJob ? 0.5 : 1,
                child: Card(
                  key: const Key('university-card'),
                  margin: EdgeInsets.zero,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: hasJob ? null : _openUniversityPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(s(8)),
                      child: Row(
                        children: [
                          Text('🎓', style: TextStyle(fontSize: s(26))),
                          SizedBox(width: s(8)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'University',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const Text('Tap to see where I could study'),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (canDropOut)
              TextButton(
                key: const Key('drop-out'),
                onPressed: () => _run(engine.dropOutOfSchool()),
                child: const Text('LEAVE SCHOOL'),
              ),
          ],
        ),
      ),
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

    final children = <Widget>[
      Row(
        children: [
          const Icon(Icons.work_outline),
          SizedBox(width: s(6)),
          Expanded(
            child: Text('Job', style: Theme.of(context).textTheme.titleMedium),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      SizedBox(height: s(4)),
    ];

    if (career.retired) {
      children.addAll([
        const Text('Retired'),
        Text('Pension: ${_formatBase(career.pensionBase)} per year'),
      ]);
    } else if (job != null) {
      children.addAll([
        Text('${job.emoji} ${job.titleAt(career.rank)}'),
        Text('Salary: ${_formatBase(career.salaryBase)} per year'),
        Text('Performance: ${career.performance}/100'),
        SizedBox(height: s(2)),
        PipBar(value: career.performance / 100),
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
      ]);
    } else if (age < 16) {
      children.add(const Text('I am too young to work.'));
    } else if (state.lifeProgress.education.isStudent) {
      children.addAll([
        const Text('Student'),
        const Text(
          'I cannot work full time while I am still studying.',
          key: Key('student-cannot-work'),
        ),
      ]);
    } else {
      children.addAll([
        const Text('Unemployed'),
        const Text('Tap to see every job.'),
      ]);
    }

    return Card(
      key: const Key('job-card'),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: _openJobs,
        child: Padding(
          padding: EdgeInsets.all(s(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

}
