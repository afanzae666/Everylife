import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/simulation/generation/npc_wealth.dart';

void main() {
  test('minors have no net worth', () {
    final money = NpcWealth.estimate(id: 'x', age: 12, countryCode: 'ID');

    expect(money.minorUnits, 0);
  });

  test('an adult estimate is stable and grows with age', () {
    final a = NpcWealth.estimate(id: 'npc-1', age: 30, countryCode: 'US');
    final b = NpcWealth.estimate(id: 'npc-1', age: 30, countryCode: 'US');
    final older = NpcWealth.estimate(id: 'npc-1', age: 50, countryCode: 'US');

    expect(a.minorUnits, b.minorUnits);
    expect(a.minorUnits, greaterThan(0));
    expect(older.minorUnits, greaterThan(a.minorUnits));
  });

  test('a bigger multiplier means more money', () {
    final teacher = NpcWealth.estimate(
      id: 'npc-2',
      age: 40,
      countryCode: 'US',
      multiplier: 3,
    );
    final student = NpcWealth.estimate(id: 'npc-2', age: 40, countryCode: 'US');

    expect(teacher.minorUnits, closeTo(student.minorUnits * 3, 3));
  });
}
