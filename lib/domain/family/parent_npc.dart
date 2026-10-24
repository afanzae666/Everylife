
import 'package:everylife/core/money/money.dart';

import '../character/appearance.dart';
import '../character/gender.dart';
import '../character/cultural_name_catalog.dart';
import 'family_asset.dart';

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
    required this.annualIncome,
    required this.incomeStability,
    this.occupation,
    this.appearance = const CharacterAppearance(),
    this.countryCode = 'ID',
    this.cashBalance = const Money.zero(),
    this.annualExpenses = const Money.zero(),
    this.assets = const <FamilyAsset>[],
    this.isAlive = true,
    this.deathYear,
    this.siblingCount = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final Gender gender;
  final int birthYear;
  final FamilyRole role;

  final EmploymentStatus employmentStatus;
  final String? occupation;

  /// Total income earned in one full year.
  final Money annualIncome;

  final IncomeStability incomeStability;

  /// Stable modular appearance used to render this NPC consistently.
  final CharacterAppearance appearance;

  /// Country used for culturally correct display order.
  final String countryCode;

  /// Personal liquid savings. Never shared with another parent automatically.
  final Money cashBalance;

  /// Annual personal contribution to living costs.
  final Money annualExpenses;

  /// Assets owned personally by this parent.
  final List<FamilyAsset> assets;

  final bool isAlive;
  final int? deathYear;

  /// Number of other eligible siblings for estate-share calculation.
  final int siblingCount;

  String get fullName => CulturalNameCatalog.formatFullName(
        countryCode,
        firstName,
        lastName,
      );

  ParentNpc copyWith({
    String? firstName, String? lastName, Gender? gender, int? birthYear,
    FamilyRole? role, EmploymentStatus? employmentStatus, String? occupation,
    Money? annualIncome, IncomeStability? incomeStability,
    CharacterAppearance? appearance, String? countryCode, Money? cashBalance,
    Money? annualExpenses, List<FamilyAsset>? assets, bool? isAlive,
    int? deathYear, int? siblingCount, bool clearDeathYear = false,
  }) => ParentNpc(
    id: id, firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName, gender: gender ?? this.gender,
    birthYear: birthYear ?? this.birthYear, role: role ?? this.role,
    employmentStatus: employmentStatus ?? this.employmentStatus,
    occupation: occupation ?? this.occupation,
    annualIncome: annualIncome ?? this.annualIncome,
    incomeStability: incomeStability ?? this.incomeStability,
    appearance: appearance ?? this.appearance,
    countryCode: countryCode ?? this.countryCode,
    cashBalance: cashBalance ?? this.cashBalance,
    annualExpenses: annualExpenses ?? this.annualExpenses,
    assets: List.unmodifiable(assets ?? this.assets),
    isAlive: isAlive ?? this.isAlive,
    deathYear: clearDeathYear ? null : (deathYear ?? this.deathYear),
    siblingCount: siblingCount ?? this.siblingCount,
  );

  bool get hasIncome {
    return annualIncome.minorUnits > 0;
  }
}
