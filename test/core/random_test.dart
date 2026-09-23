import 'package:flutter_test/flutter_test.dart';

import 'package:life_simulation_game/core/random/seeded_random.dart';

void main() {
  test('same seed produces the same sequence', () {
    final first = SeededRandom(12345);
    final second = SeededRandom(12345);

    for (var i = 0; i < 20; i++) {
      expect(
        first.nextInt(1000),
        second.nextInt(1000),
      );
    }
  });

  test('different seeds can produce different sequences', () {
    final first = SeededRandom(1);
    final second = SeededRandom(2);

    final firstValue = first.nextInt(1000000);
    final secondValue = second.nextInt(1000000);

    expect(
      firstValue,
      isNot(equals(secondValue)),
    );
  });
}
