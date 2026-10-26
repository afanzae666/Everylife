import '../character/appearance.dart';
import '../character/cultural_name_catalog.dart';
import '../character/gender.dart';

/// Relationship of a sibling NPC to the player character.
enum SiblingRelationship {
  fullSibling,
  halfSibling,
  stepSibling,
}

/// Persistent identity for a sibling shown in the existing Siblings card.
class SiblingNpc {
  const SiblingNpc({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthYear,
    required this.relationship,
    this.appearance = const CharacterAppearance(),
    this.countryCode = 'ID',
    this.relationshipPercent = 50,
    this.isTwin = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final Gender gender;
  final int birthYear;
  final SiblingRelationship relationship;
  final CharacterAppearance appearance;
  final String countryCode;

  /// Placeholder relationship score until the relationship simulation is built.
  final int relationshipPercent;

  /// True when this sibling belongs to a generated twin birth.
  final bool isTwin;

  String get fullName => CulturalNameCatalog.formatFullName(
        countryCode,
        firstName,
        lastName,
      );

  bool isOlderThan(int playerBirthYear) => birthYear < playerBirthYear;
}
