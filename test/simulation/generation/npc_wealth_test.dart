import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/family/npc_finance.dart';
import 'package:everylife/domain/family/sibling_npc.dart';
import 'package:everylife/simulation/generation/npc_wealth.dart';

void main() {
  test('NPCs without finance are exactly zero', () {
    const sibling = SiblingNpc(
      id: 's',
      firstName: 'A',
      lastName: 'B',
      gender: Gender.male,
      birthYear: 2010,
    );
    const student = SchoolNpc(
      id: 'c',
      firstName: 'A',
      lastName: 'B',
      gender: Gender.female,
      birthYear: 2008,
      role: SchoolRole.classmate,
    );

    expect(NpcWealth.forSibling(sibling).minorUnits, 0);
    expect(NpcWealth.forSchoolNpc(student).minorUnits, 0);
  });

  test('net worth is the savings of the NPC', () {
    const teacher = SchoolNpc(
      id: 't',
      firstName: 'A',
      lastName: 'B',
      gender: Gender.female,
      birthYear: 1980,
      role: SchoolRole.teacher,
      finance: NpcFinance(jobId: 'teacher', cashMinor: 123456),
    );

    expect(NpcWealth.forSchoolNpc(teacher).minorUnits, 123456);
  });

  test('finance survives JSON', () {
    const finance = NpcFinance(
      jobId: 'nurse',
      rank: 2,
      startAge: 24,
      annualIncomeMinor: 5000,
      cashMinor: 9000,
    );

    final copy = NpcFinance.fromJson(finance.toJson())!;

    expect(copy.jobId, 'nurse');
    expect(copy.rank, 2);
    expect(copy.startAge, 24);
    expect(copy.annualIncomeMinor, 5000);
    expect(copy.cashMinor, 9000);
  });
}
