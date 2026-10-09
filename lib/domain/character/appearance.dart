/// Persistent visual configuration for a character.
///
/// The values are asset identifiers rather than rendered paths. This keeps the
/// character model independent from Flutter's asset system and allows the
/// appearance renderer to evolve without changing saved character data.
class CharacterAppearance {
  const CharacterAppearance({
    this.base = 'default',
    this.skinTone = 'default',
    this.hair = 'default',
    this.infantHair,
    this.toddlerHair,
    this.childHair,
    this.hairColor = 'default',
    this.eyes = 'default',
    this.eyeColor = 'default',
    this.eyebrows = 'default',
    this.beard = 'none',
  });

  /// Base face/body asset identifier.
  final String base;

  /// Skin palette identifier.
  final String skinTone;

  /// Player-selected master hairstyle.
  ///
  /// This is the hairstyle preserved from teen through senior.
  ///
  /// If this is `bald`, bald becomes a permanent player-selected
  /// override for every life stage.
  final String hair;

  /// Automatically generated hairstyle for the infant stage.
  ///
  /// This is intentionally separate from [hair] so a randomly bald
  /// infant does not become permanently bald.
  final String? infantHair;

  /// Automatically generated hairstyle for the toddler stage.
  final String? toddlerHair;

  /// Automatically generated hairstyle for the child stage.
  final String? childHair;

  /// Hair palette identifier.
  final String hairColor;

  /// Eye shape/style asset identifier.
  final String eyes;

  /// Eye color palette identifier.
  final String eyeColor;

  /// Eyebrow style asset identifier.
  final String eyebrows;

  /// Beard style asset identifier.
  ///
  /// `'none'` means that the character has no beard.
  final String beard;

  CharacterAppearance copyWith({
    String? base,
    String? skinTone,
    String? hair,
    String? infantHair,
    String? toddlerHair,
    String? childHair,
    String? hairColor,
    String? eyes,
    String? eyeColor,
    String? eyebrows,
    String? beard,
  }) {
    return CharacterAppearance(
      base: base ?? this.base,
      skinTone: skinTone ?? this.skinTone,
      hair: hair ?? this.hair,
      infantHair: infantHair ?? this.infantHair,
      toddlerHair: toddlerHair ?? this.toddlerHair,
      childHair: childHair ?? this.childHair,
      hairColor: hairColor ?? this.hairColor,
      eyes: eyes ?? this.eyes,
      eyeColor: eyeColor ?? this.eyeColor,
      eyebrows: eyebrows ?? this.eyebrows,
      beard: beard ?? this.beard,
    );
  }
}
