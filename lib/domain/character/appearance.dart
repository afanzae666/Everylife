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
    this.hairColor = 'default',
    this.eyes = 'default',
    this.eyeColor = 'default',
    this.eyebrows = 'default',
  });

  /// Base face/body asset identifier.
  final String base;

  /// Skin palette identifier.
  final String skinTone;

  /// Hair style asset identifier.
  final String hair;

  /// Hair palette identifier.
  final String hairColor;

  /// Eye shape/style asset identifier.
  final String eyes;

  /// Eye color palette identifier.
  final String eyeColor;

  /// Eyebrow style asset identifier.
  final String eyebrows;

  CharacterAppearance copyWith({
    String? base,
    String? skinTone,
    String? hair,
    String? hairColor,
    String? eyes,
    String? eyeColor,
    String? eyebrows,
  }) {
    return CharacterAppearance(
      base: base ?? this.base,
      skinTone: skinTone ?? this.skinTone,
      hair: hair ?? this.hair,
      hairColor: hairColor ?? this.hairColor,
      eyes: eyes ?? this.eyes,
      eyeColor: eyeColor ?? this.eyeColor,
      eyebrows: eyebrows ?? this.eyebrows,
    );
  }
}
