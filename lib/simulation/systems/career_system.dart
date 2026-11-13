import 'package:everylife/core/money/money.dart';
import '../../core/random/seeded_random.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../events/life_effect_applier.dart';
import '../events/money_text.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Pays salary and pension, charges living costs, and handles
/// promotions, layoffs, retirement, debt interest, and bankruptcy.
///
/// All money amounts are baseline values scaled by country cost of living.
class CareerSystem implements SimulationSystem {
  CareerSystem({
    required SeededRandom random,
  }) : _random = random;

  final SeededRandom _random;

  /// Baseline yearly living cost of an independent adult.
  static const int livingCostBase = 1000000;

  /// Baseline yearly benefit for an adult without work.
  static const int unemploymentBenefitBase = 400000;

  /// Baseline yearly state pension, the minimum for a retired player.
  static const int statePensionBase = 500000;


  static const int retirementAge = 65;
  static const int forcedRetirementAge = 70;

  @override
  String get id => 'career';

  @override
  int get priority => SystemPriority.career.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final progress = state.lifeProgress;

    if (progress.ending != null) {
      return state;
    }

    final year = state.clock.currentYear;
    final age = state.player.ageAt(year);
    final flags = <String>{...progress.flags};
    final logs = <SimulationEvent>[];

    int scale(int base) => LifeEffectApplier.scaleMoney(state, base);

    void log(String key, String title, String text) {
      logs.add(
        SimulationEvent(
          id: 'career-$key-$year',
          type: SimulationEventType.career,
          year: year,
          title: title,
          description: text,
        ),
      );
    }

    var career = progress.career;
    var stats = state.player.stats;
    var money = state.player.money.minorUnits;
    var debt = state.player.debt.minorUnits;
    var income = 0;

    // --- Retirement ------------------------------------------------------
    final wantsRetirement = flags.contains('retired') && age >= 60;

    if (!career.retired &&
        (age >= forcedRetirementAge ||
            (age >= retirementAge && !career.hasJob) ||
            wantsRetirement)) {
      final lastSalary = career.salaryBase;
      final pension = lastSalary * 45 ~/ 100;

      career = career.copyWith(
        clearJob: true,
        salaryBase: 0,
        retired: true,
        pensionBase: pension > statePensionBase ? pension : statePensionBase,
      );
      log(
        'retired',
        'Retirement',
        lastSalary > 0
            ? 'I retired after a long career and began living on my pension.'
            : 'I began living on my pension.',
      );
    }

    // --- Work or pension ---------------------------------------------------
    if (career.retired) {
      income += scale(career.pensionBase);
    } else if (career.hasJob) {
      final job = JobCatalog.byId(career.jobId!);

      if (job == null) {
        career = career.copyWith(clearJob: true, salaryBase: 0);
      } else {
        income += scale(career.salaryBase);

        var performance = career.performance +
            _random.nextInt(11) -
            5 +
            (stats.willpower - 50) ~/ 10;
        performance = performance.clamp(0, 100).toInt();

        var rank = career.rank;
        var salaryBase = career.salaryBase;
        var yearsInRole = career.yearsInRole + 1;

        final laidOff = _random.nextInt(100) < (performance < 40 ? 12 : 3);

        if (laidOff) {
          log('laid-off', 'Laid off', 'The company let me go from my job as ${job.titleAt(rank)}.');
          stats = stats.copyWith(happiness: stats.happiness - 6);
          career = career.copyWith(
            clearJob: true,
            salaryBase: 0,
            rank: 0,
            performance: 60,
            yearsInRole: 0,
            totalYearsWorked: career.totalYearsWorked + 1,
          );
        } else {
          if (yearsInRole >= 2 &&
              rank < JobCatalog.rankMultipliers.length - 1 &&
              performance >= 65 &&
              _random.nextInt(100) < 30) {
            rank += 1;
            salaryBase = job.salaryAt(rank);
            yearsInRole = 0;
            stats = stats.copyWith(happiness: stats.happiness + 4);
            log('promoted', 'Promotion', 'I was promoted to ${job.titleAt(rank)}.');
          }

          career = career.copyWith(
            rank: rank,
            salaryBase: salaryBase,
            performance: performance,
            yearsInRole: yearsInRole,
            totalYearsWorked: career.totalYearsWorked + 1,
          );
        }
      }
    } else if (age >= 18) {
      income += scale(unemploymentBenefitBase);
    }

    // --- Costs -------------------------------------------------------------
    final education = progress.education;
    var living = 0;

    if (age >= 18) {
      var base = livingCostBase;

      if (education.isStudent) {
        base = base * 50 ~/ 100;
      } else if (age < 22 && _hasLivingParent(state)) {
        base = base * 40 ~/ 100;
      }

      living = scale(base);
    }

    // --- Settle the year ---------------------------------------------------
    money += income;
    final outflow = living;

    if (money >= outflow) {
      money -= outflow;
    } else {
      final borrowed = outflow - money;

      debt += borrowed;
      money = 0;

      log(
        'borrowed',
        'Went into debt',
        'My living costs this year were more than I earned and saved, so I had '
            'to borrow ${MoneyText.of(state, borrowed)}.',
      );
    }

    if (debt > 0) {
      final interest = debt * 6 ~/ 100;

      debt += interest;

      if (interest > 0) {
        log(
          'interest',
          'Debt interest',
          'My debt grew by ${MoneyText.of(state, interest)} in interest.',
        );
      }

      final repayment = money ~/ 2 < debt ? money ~/ 2 : debt;
      money -= repayment;
      debt -= repayment;
    }

    final livingYear = scale(livingCostBase);

    if (debt > livingYear * 5) {
      debt = 0;
      money = 0;
      stats = stats.copyWith(happiness: stats.happiness - 10);
      flags.add(SystemFlags.bankrupt);
      log(
        'bankrupt',
        'Bankruptcy',
        'My debts became unmanageable and I had to declare bankruptcy.',
      );
    } else if (debt > livingYear * 2) {
      stats = stats.copyWith(happiness: stats.happiness - 2);
    }

    if (career.hasJob) {
      flags.add(SystemFlags.employed);
    } else {
      flags.remove(SystemFlags.employed);
    }

    var next = state.copyWith(
      player: state.player.copyWith(
        stats: stats,
        money: Money.fromMinorUnits(money),
        debt: Money.fromMinorUnits(debt),
      ),
      lifeProgress: progress.copyWith(
        career: career,
        flags: flags,
      ),
    );

    for (final entry in logs) {
      next = next.addEvent(entry);
    }

    return next;
  }

  bool _hasLivingParent(WorldState state) {
    return state.familyHousehold?.parents.any((parent) => parent.isAlive) ?? false;
  }
}
