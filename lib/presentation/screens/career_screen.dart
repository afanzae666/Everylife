import 'package:flutter/material.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/money/fixed_exchange_rates.dart';
import '../../core/money/money.dart';
import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/events/life_effect_applier.dart';
import '../../simulation/systems/education_system.dart';

/// School, university, and work: status, actions, and history.
class CareerScreen extends StatefulWidget {
  const CareerScreen({
    required this.engine,
    required this.zoom,
    this.onChanged,
    super.key,
  });

  final SimulationEngine engine;
  final double zoom;

  /// Called after an action changed the game (the caller can auto-save).
  final Future<void> Function()? onChanged;

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  SimulationEngine get engine => widget.engine;

  double s(double value) => value * widget.zoom;

  String _currencyCode() {
    final countryCode = engine.state.player.location?.countryCode ?? '';
    final code = CountryCatalog.findByCode(countryCode)?.currencyCode ?? 'USD';

    if (FixedExchangeRates.snapshot.rateFor(code) == null) {
      return 'USD';
    }

    return code;
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

  String _stageLabel(EducationState education) {
    return switch (education.stage) {
      SchoolStage.none => 'Not enrolled',
      SchoolStage.primary => 'Primary school',
      SchoolStage.secondary => 'High school',
      SchoolStage.university =>
        'University (year ${education.yearsInStage + 1} of ${EducationSystem.universityYears})',
    };
  }

  String _levelLabel(EducationLevel level) {
    return switch (level) {
      EducationLevel.none => 'None yet',
      EducationLevel.primary => 'Primary school',
      EducationLevel.secondary => 'High school diploma',
      EducationLevel.bachelor => "Bachelor's degree",
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = engine.state;
    final progress = state.lifeProgress;
    final player = state.player;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Career')),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(s(8), s(6), s(8), s(12)),
            children: [
              _buildFinances(player.money, player.debt),
              SizedBox(height: s(6)),
              _buildEducation(progress.education, state.clock.currentYear),
              SizedBox(height: s(6)),
              _buildWork(),
              SizedBox(height: s(6)),
              _buildHistory(state.events),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinances(Money cash, Money debt) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: const Key('career-finances'),
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: Text('Cash: ${_formatMoney(cash)}'),
        subtitle: Text(
          debt.minorUnits > 0
              ? 'Debt: ${_formatMoney(debt)}'
              : 'No debt',
        ),
      ),
    );
  }

  Widget _buildEducation(EducationState education, int year) {
    final age = engine.state.player.ageAt(year);
    final canApply = !education.isStudent &&
        education.highest == EducationLevel.secondary &&
        age >= 18;
    final appliedThisYear = education.lastUniversityApplicationYear == year;
    final canDropOut = education.stage == SchoolStage.secondary ||
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
                Text('Education', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: s(4)),
            Text('Now: ${_stageLabel(education)}'),
            Text('Highest completed: ${_levelLabel(education.highest)}'),
            if (education.isStudent) ...[
              SizedBox(height: s(4)),
              Text('Grades: ${education.grades}/100'),
              SizedBox(height: s(2)),
              LinearProgressIndicator(value: education.grades / 100),
            ],
            if (canApply || canDropOut) SizedBox(height: s(6)),
            if (canApply)
              FilledButton.tonal(
                key: const Key('apply-university'),
                onPressed: appliedThisYear
                    ? null
                    : () => _run(engine.applyForUniversity()),
                child: Text(
                  appliedThisYear
                      ? 'Applied this year'
                      : 'APPLY TO UNIVERSITY (${engine.universityChance}% chance)',
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
          Text('Work', style: Theme.of(context).textTheme.titleMedium),
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
        Text(job.titleAt(career.rank)),
        Text('Salary: ${_formatBase(career.salaryBase)} per year'),
        Text('Performance: ${career.performance}/100'),
        SizedBox(height: s(2)),
        LinearProgressIndicator(value: career.performance / 100),
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
    } else {
      children.add(const Text('Unemployed'));

      final appliedThisYear = career.lastApplicationYear == year;

      for (final available in engine.availableJobs) {
        children.add(
          ListTile(
            key: Key('job-${available.id}'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(available.title),
            subtitle: Text(
              'Starts at ${_formatBase(available.baseSalary)} per year '
              '· ${engine.hiringChance(available)}% chance',
            ),
            trailing: FilledButton.tonal(
              onPressed: appliedThisYear
                  ? null
                  : () => _run(engine.applyForJob(available.id)),
              child: const Text('APPLY'),
            ),
          ),
        );
      }

      if (appliedThisYear) {
        children.add(const Text('I already applied this year.'));
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(s(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildHistory(List<SimulationEvent> events) {
    final history = events
        .where(
          (event) =>
              event.type == SimulationEventType.career ||
              event.type == SimulationEventType.education,
        )
        .toList()
        .reversed
        .take(10)
        .toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(s(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history),
                SizedBox(width: s(6)),
                Text('History', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: s(4)),
            if (history.isEmpty) const Text('Nothing yet.'),
            for (final event in history)
              Padding(
                padding: EdgeInsets.only(bottom: s(2)),
                child: Text('${event.year}: ${event.description}'),
              ),
          ],
        ),
      ),
    );
  }
}
