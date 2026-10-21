
import 'package:everylife/core/money/money.dart';

import '../character/gender.dart';

enum FamilyRole {
  father,
  mother,
  guardian,
}

enum EmploymentStatus {
  employed,
  selfEmployed,
  unemployed,
  retired,
  homemaker,
  unableToWork,
}

enum IncomeStability {
  stable,
  variable,
  seasonal,
  none,
}

class ParentNpc {
  const ParentNpc({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthYear,
    required this.role,
    required this.employmentStatus,
    required this.monthlyIncome,
    required this.incomeStability,
    this.occupation,
  });

  final String id;
  final String firstName;
  final String lastName;
  final Gender gender;
  final int birthYear;
  final FamilyRole role;

  final EmploymentStatus employmentStatus;
  final String? occupation;
  final Money monthlyIncome;
  final IncomeStability incomeStability;

  String get fullName {
    return [
      firstName.trim(),
      lastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  bool get hasIncome {
    return monthlyIncome.minorUnits > 0;
  }
}
