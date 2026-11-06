import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/job_catalog.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/simulation/economy/npc_economy.dart';

void main() {
  test('the education jobs exist in the job list', () {
    for (final id in ['teacher', 'professor', 'principal', 'dean']) {
      expect(JobCatalog.byId(id), isNotNull, reason: id);
    }
  });

  test('a new adult sibling has a stable job and no savings yet', () {
    final a = NpcEconomy.forSibling(id: 'sib-1', age: 18, countryCode: 'US');
    final b = NpcEconomy.forSibling(id: 'sib-1', age: 18, countryCode: 'US');

    expect(a.jobId, b.jobId);
    expect(a.cashMinor, 0);
  });

  test('working NPCs save more every year', () {
    var finance = NpcEconomy.startingFinance(
      job: JobCatalog.byId('nurse')!,
      startAge: 24,
      age: 24,
      countryCode: 'US',
    );

    expect(finance.cashMinor, 0);
    expect(finance.annualIncomeMinor, greaterThan(0));

    final before = finance.cashMinor;

    finance = NpcEconomy.advance(finance: finance, age: 25, countryCode: 'US');

    expect(finance.cashMinor, greaterThan(before));
  });

  test('retired NPCs stop earning but keep their savings', () {
    final job = JobCatalog.byId('nurse')!;
    var finance = NpcEconomy.startingFinance(
      job: job,
      startAge: 24,
      age: 65,
      countryCode: 'US',
    );

    expect(finance.annualIncomeMinor, 0);

    final cash = finance.cashMinor;

    finance = NpcEconomy.advance(finance: finance, age: 66, countryCode: 'US');

    expect(finance.cashMinor, cash);
  });

  test('faculty are funded from their job and students have nothing', () {
    const principal = SchoolNpc(
      id: 'p',
      firstName: 'A',
      lastName: 'B',
      gender: Gender.male,
      birthYear: 1970,
      role: SchoolRole.principal,
    );
    const student = SchoolNpc(
      id: 's',
      firstName: 'A',
      lastName: 'B',
      gender: Gender.male,
      birthYear: 2008,
      role: SchoolRole.classmate,
    );

    final funded = NpcEconomy.forFaculty(npc: principal, age: 55)!;

    expect(funded.jobId, 'principal');
    expect(funded.cashMinor, greaterThan(0));
    expect(NpcEconomy.forFaculty(npc: student, age: 18), isNull);
  });
}
