import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/education_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/economy/expense_breakdown.dart';
import 'package:everylife/simulation/economy/income_breakdown.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/systems/career_system.dart';

SimulationEngine _engineAt(int age, {LifeProgress? progress, int debt = 0}) {
  final base = SimulationEngine.create(
    player: Character.create(id: 'p', name: 'Test Player', birthYear: 2000),
    seed: 5,
    saveRepository: InMemorySaveRepository(),
  );

  return SimulationEngine(
    initialState: base.state.copyWith(
      clock: SimulationClock(currentYear: 2000 + age),
      player: base.state.player.copyWith(
        debt: Money.fromMinorUnits(debt),
      ),
      lifeProgress: progress ?? const LifeProgress(),
    ),
    random: SeededRandom(1),
    saveRepository: InMemorySaveRepository(),
  );
}

void main() {
  group('expense breakdown', () {
    test('the lines add up to exactly the living cost', () {
      for (final living in [1, 7, 999, 1000000, 1234567]) {
        final lines = ExpenseBreakdown.split(living);

        expect(lines.fold<int>(0, (sum, l) => sum + l.amount), living);
        expect(lines.length, greaterThan(4));
      }

      expect(ExpenseBreakdown.split(0), isEmpty);
    });

    test('living costs include housing, food and more', () {
      final breakdown = ExpenseBreakdown.of(
        _engineAt(
          30,
          progress: const LifeProgress(
            education: EducationState(
              initialized: true,
              highest: EducationLevel.highSchool,
            ),
          ),
        ).state,
      );
      final labels = breakdown.lines.map((line) => line.label);

      expect(labels, containsAll(['Housing', 'Food', 'Transport']));
      expect(breakdown.coveredByFamily, isFalse);
      expect(breakdown.living, greaterThan(0));
    });

    test('a child pays no living costs', () {
      final breakdown = ExpenseBreakdown.of(_engineAt(10).state);

      expect(breakdown.coveredByFamily, isTrue);
      expect(breakdown.lines, isEmpty);
      expect(breakdown.total, 0);
    });

    test('debt adds interest', () {
      final breakdown = ExpenseBreakdown.of(_engineAt(30, debt: 100000).state);

      expect(breakdown.interest, 6000);
      expect(breakdown.total, breakdown.living + 6000);
    });

    test('the career system charges the same living cost', () {
      final base = _engineAt(30).state;
      final state = base.copyWith(
        player: base.player.copyWith(
          money: const Money.fromMinorUnits(900000000),
        ),
      );
      final living = ExpenseBreakdown.of(state).living;
      final benefit = IncomeBreakdown.of(state).benefit;
      final after = CareerSystem(random: SeededRandom(2)).process(
        state: state,
        command: const AgeUpCommand(),
      );

      expect(living, greaterThan(0));
      expect(benefit, greaterThan(0));
      expect(
        after.player.money.minorUnits,
        900000000 + benefit - living,
      );
    });
  });
}
