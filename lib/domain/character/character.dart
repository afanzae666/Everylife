
import '../../core/money/money.dart';
import '../world/character_location.dart';
import 'appearance.dart';
import 'character_stats.dart';
import 'cultural_name_catalog.dart';
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
    this.appearance = const CharacterAppearance(),
    this.location,
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
  final CharacterAppearance appearance;

  /// The character's current country and city.
  ///
  /// Null for characters whose location has not been selected yet,
  /// including characters loaded from older saves without location data.
  final CharacterLocation? location;

  String get fullName {
    final first = resolvedFirstName;
    final last = resolvedLastName;

    // Preserve the original full name for older saves that do not have
    // separate given-name and family-name fields.
    if (first.isEmpty) {
      return name.trim();
    }

    // Format the name according to the character's country.
    // When no country is available, the catalog uses its default format.
    return CulturalNameCatalog.formatFullName(
      location?.countryCode ?? '',
      first,
      last,
    );
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
    CharacterAppearance? appearance,
    CharacterLocation? location,
  }) {
    final nextFirstName = firstName ?? this.firstName;
    final nextLastName = lastName ?? this.lastName;
    final nextLocation = location ?? this.location;

    final nextName = name ??
        (nextFirstName.trim().isEmpty &&
                nextLastName.trim().isEmpty
            ? this.name
            : CulturalNameCatalog.formatFullName(
                nextLocation?.countryCode ?? '',
                nextFirstName,
                nextLastName,
              ));

    return Character(
      id: id,
      name: nextName,
      firstName: nextFirstName,
      lastName: nextLastName,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      stats: stats ?? this.stats,
      money: money ?? this.money,
      appearance: appearance ?? this.appearance,
      location: nextLocation,
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
    CharacterAppearance appearance = const CharacterAppearance(),
    CharacterLocation? location,
  }) {
    var resolvedFirstName = firstName?.trim() ?? '';
    var resolvedLastName = lastName?.trim() ?? '';

    if (resolvedFirstName.isEmpty &&
        name != null &&
        name.trim().isNotEmpty) {
      final parts = _nameParts(name);

      resolvedFirstName = parts.isEmpty ? '' : parts.first;

      resolvedLastName = parts.length <= 1
          ? ''
          : parts.sublist(1).join(' ');
    }

    if (resolvedFirstName.isEmpty) {
      throw ArgumentError(
        'First name cannot be empty.',
      );
    }

    final fullName = CulturalNameCatalog.formatFullName(
      location?.countryCode ?? '',
      resolvedFirstName,
      resolvedLastName,
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
      appearance: appearance,
      location: location,
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
}
