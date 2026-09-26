import '../../core/money/money.dart';
import 'character_stats.dart';
import 'gender.dart';
import 'life_stage.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    this.gender = Gender.male,
    required this.birthYear,
    required this.stats,
    required this.money,
  });

  final String id;

  /// Full name used for display and backward-compatible saves.
  final String name;

  /// First name of the character.
  ///
  /// Empty when loading an older save that only contained [name].
  final String firstName;

  /// Family/last name of the character.
  ///
  /// Empty when loading an older save that only contained [name].
  final String lastName;

  final Gender gender;
  final int birthYear;
  final CharacterStats stats;
  final Money money;

  String get fullName {
    final first = resolvedFirstName;
    final last = resolvedLastName;

    if (first.isEmpty) {
      return name.trim();
    }

    if (last.isEmpty) {
      return first;
    }

    return '$first $last';
  }

  String get resolvedFirstName {
    if (firstName.trim().isNotEmpty) {
      return firstName.trim();
    }

    final parts = _nameParts(name);

    if (parts.isEmpty) {
      return '';
    }

    return parts.first;
  }

  String get resolvedLastName {
    if (lastName.trim().isNotEmpty) {
      return lastName.trim();
    }

    final parts = _nameParts(name);

    if (parts.length <= 1) {
      return '';
    }

    return parts.sublist(1).join(' ');
  }

  int ageAt(int year) {
    final age = year - birthYear;

    if (age < 0) {
      throw StateError(
        'Character birth year cannot be after current year.',
      );
    }

    return age;
  }

  LifeStage lifeStageAt(int year) {
    return LifeStageAge.fromAge(
      ageAt(year),
    );
  }

  Character copyWith({
    String? name,
    String? firstName,
    String? lastName,
    Gender? gender,
    int? birthYear,
    CharacterStats? stats,
    Money? money,
  }) {
    final nextFirstName =
        firstName ?? this.firstName;

    final nextLastName =
        lastName ?? this.lastName;

    final nextName = name ??
        _buildFullName(
          nextFirstName,
          nextLastName,
          fallback: this.name,
        );

    return Character(
      id: id,
      name: nextName,
      firstName: nextFirstName,
      lastName: nextLastName,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      stats: stats ?? this.stats,
      money: money ?? this.money,
    );
  }

  static Character create({
    required String id,
    String? name,
    String? firstName,
    String? lastName,
    Gender gender = Gender.male,
    required int birthYear,
    CharacterStats? stats,
  }) {
    var resolvedFirstName =
        firstName?.trim() ?? '';

    var resolvedLastName =
        lastName?.trim() ?? '';

    if (resolvedFirstName.isEmpty &&
        name != null &&
        name.trim().isNotEmpty) {
      final parts = _nameParts(name);

      resolvedFirstName =
          parts.isEmpty ? '' : parts.first;

      resolvedLastName = parts.length <= 1
          ? ''
          : parts.sublist(1).join(' ');
    }

    if (resolvedFirstName.isEmpty) {
      throw ArgumentError(
        'First name cannot be empty.',
      );
    }

    final fullName = _buildFullName(
      resolvedFirstName,
      resolvedLastName,
      fallback: name?.trim() ?? '',
    );

    return Character(
      id: id,
      name: fullName,
      firstName: resolvedFirstName,
      lastName: resolvedLastName,
      gender: gender,
      birthYear: birthYear,
      stats: stats ?? const CharacterStats(),
      money: const Money.zero(),
    );
  }

  static List<String> _nameParts(
    String value,
  ) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList(growable: false);
  }

  static String _buildFullName(
    String firstName,
    String lastName, {
    required String fallback,
  }) {
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isEmpty && last.isEmpty) {
      return fallback.trim();
    }

    if (last.isEmpty) {
      return first;
    }

    return '$first $last';
  }
}
