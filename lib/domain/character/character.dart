import 'package:everylife/core/money/money.dart';

import '../world/character_location.dart';
import 'appearance.dart';
import 'character_stats.dart';
import 'cultural_name_catalog.dart';
import 'gender.dart';
import 'life_stage.dart';
import 'player_asset.dart';

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
this.assets = const <PlayerAsset>[],
this.debt = const Money.zero(),
this.birthMonth = 1,
this.birthDay = 1,
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
final int birthMonth;
final int birthDay;
final CharacterStats stats;

/// Liquid money currently held by the character.
///
/// This is separate from the value of owned assets.
final Money money;

final CharacterAppearance appearance;

/// The character's current country and city.
///
/// Null for characters whose location has not been selected yet,
/// including characters loaded from older saves without location data.
final CharacterLocation? location;

/// Assets personally owned by this character.
///
/// Examples include property, vehicles, businesses, investments,
/// and other valuable possessions. This does not include assets owned
/// by the character's parents or household.
final List<PlayerAsset> assets;

/// Outstanding debt owed by this character.
///
/// This is stored separately from cash and asset values.
/// Older saves default to zero debt when migrated.
final Money debt;

/// Sum of the character's liquid money and owned asset values.
///
/// Debt is intentionally excluded from this gross asset total.
Money get totalAssets {
var total = money;

for (final asset in assets) {
  total = total + asset.value;
}

return total;

}

/// Total assets minus outstanding debt.
///
/// This is a calculated value, not a separately stored balance.
Money get netWorth => totalAssets - debt;

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
List<PlayerAsset>? assets,
Money? debt,
int? birthMonth,
int? birthDay,
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
  assets: assets ?? this.assets,
  debt: debt ?? this.debt,
  birthMonth: birthMonth ?? this.birthMonth,
  birthDay: birthDay ?? this.birthDay,
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
int birthMonth = 1,
int birthDay = 1,
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
  birthMonth: birthMonth,
  birthDay: birthDay,
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
