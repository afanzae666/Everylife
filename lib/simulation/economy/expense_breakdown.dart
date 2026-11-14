import '../../domain/world/world_state.dart';
import '../events/life_effect_applier.dart';

/// One kind of yearly spending, in the player's currency (minor units).
class ExpenseLine {
  const ExpenseLine({
    required this.emoji,
    required this.label,
    required this.amount,
  });

  final String emoji;
  final String label;
  final int amount;
}

/// What the player spends in a year.
///
/// The living cost is one number that the career system charges every year.
/// Here it is split into the things people actually spend money on, so the
/// finance overlay can show where the money goes. The lines always add up
/// to exactly the living cost.
class ExpenseBreakdown {
  const ExpenseBreakdown({
    required this.lines,
    required this.interest,
    required this.coveredByFamily,
  });

  /// Baseline yearly living cost of an independent adult.
  static const int livingCostBase = 1000000;

  /// How the living cost is split, in percent. The last entry takes the
  /// remainder so rounding never changes the total.
  static const List<(String, String, int)> _shares = [
    ('🏠', 'Housing', 34),
    ('🍽️', 'Food', 24),
    ('🚌', 'Transport', 10),
    ('💡', 'Utilities', 10),
    ('🏥', 'Healthcare', 8),
    ('🎉', 'Leisure & other', 14),
  ];

  /// Living lines (housing, food, ...). Empty while the family pays.
  final List<ExpenseLine> lines;

  /// Interest the debt will add this year.
  final int interest;

  /// True for a minor: parents pay the household bills.
  final bool coveredByFamily;

  int get living => lines.fold(0, (sum, line) => sum + line.amount);

  int get total => living + interest;

  /// The baseline living cost for a player, before cost-of-living scaling.
  static int livingBase({
    required int age,
    required bool student,
    required bool livingParent,
  }) {
    if (age < 18) return 0;

    if (student) return livingCostBase * 50 ~/ 100;

    if (age < 22 && livingParent) return livingCostBase * 40 ~/ 100;

    return livingCostBase;
  }

  /// Splits a (scaled) living cost into its lines.
  static List<ExpenseLine> split(int living) {
    if (living <= 0) return const <ExpenseLine>[];

    final lines = <ExpenseLine>[];
    var assigned = 0;

    for (var i = 0; i < _shares.length; i++) {
      final (emoji, label, percent) = _shares[i];
      final amount =
          i == _shares.length - 1 ? living - assigned : living * percent ~/ 100;

      assigned += amount;
      lines.add(ExpenseLine(emoji: emoji, label: label, amount: amount));
    }

    return lines;
  }

  /// The expenses of the player in [state] for the coming year.
  static ExpenseBreakdown of(WorldState state) {
    final age = state.player.ageAt(state.clock.currentYear);
    final education = state.lifeProgress.education;
    final livingParent =
        state.familyHousehold?.parents.any((parent) => parent.isAlive) ?? false;
    final base = livingBase(
      age: age,
      student: education.isStudent,
      livingParent: livingParent,
    );
    final living = LifeEffectApplier.scaleMoney(state, base);
    final debt = state.player.debt.minorUnits;

    return ExpenseBreakdown(
      lines: split(living),
      interest: debt > 0 ? debt * 6 ~/ 100 : 0,
      coveredByFamily: age < 18,
    );
  }
}
