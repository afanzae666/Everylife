import 'package:flutter_test/flutter_test.dart';

import 'package:life_simulation_game/core/money/money.dart';

void main() {
  group('Money', () {
    test('stores minor units exactly', () {
      const money = Money.fromMinorUnits(10050);

      expect(money.minorUnits, 10050);
      expect(money.toString(), '\$100.50');
    });

    test('adds money without floating point errors', () {
      const first = Money.fromMinorUnits(10);
      const second = Money.fromMinorUnits(20);

      final result = first + second;

      expect(
        result,
        const Money.fromMinorUnits(30),
      );
    });

    test('subtracts money correctly', () {
      const first = Money.fromMinorUnits(1000);
      const second = Money.fromMinorUnits(250);

      final result = first - second;

      expect(
        result,
        const Money.fromMinorUnits(750),
      );
    });
  });
}
