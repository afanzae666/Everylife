import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';

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

  test('nextBool does not strictly alternate', () {
    final random = SeededRandom(42);
    final values = [for (var i = 0; i < 64; i++) random.nextBool()];

    var alternations = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] != values[i - 1]) alternations++;
    }

    // A generator that only used the lowest LCG bit would alternate on all
    // 63 transitions.
    expect(alternations, lessThan(60));
    expect(values.where((value) => value).length, inInclusiveRange(16, 48));
  });

  test('small power-of-two ranges do not repeat with a short period', () {
    final random = SeededRandom(7);
    final values = [for (var i = 0; i < 16; i++) random.nextInt(8)];

    expect(values.sublist(0, 8), isNot(equals(values.sublist(8))));
  });

  test('nextInt stays in range and covers bounds above 2^31', () {
    final random = SeededRandom(1);
    const bound = 6000000000;
    var sawLargeValue = false;

    for (var i = 0; i < 200; i++) {
      final value = random.nextInt(bound);
      expect(value, inInclusiveRange(0, bound - 1));
      if (value > 0x7fffffff) sawLargeValue = true;
    }

    expect(sawLargeValue, isTrue);
  });

  test('nextInt rejects invalid bounds', () {
    final random = SeededRandom(1);

    expect(() => random.nextInt(0), throwsArgumentError);
    expect(() => random.nextInt(-5), throwsArgumentError);
    expect(
      () => random.nextInt(SeededRandom.maxBound + 1),
      throwsArgumentError,
    );
  });

  test('restoring state replays the same sequence', () {
    final random = SeededRandom(99);
    random.nextInt(100);
    final saved = random.state;
    final expected = [for (var i = 0; i < 5; i++) random.nextInt(1000)];

    final restored = SeededRandom.fromState(saved);
    final actual = [for (var i = 0; i < 5; i++) restored.nextInt(1000)];

    expect(actual, expected);
  });
}
