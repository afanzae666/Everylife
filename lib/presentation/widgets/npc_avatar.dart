import 'package:flutter/material.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import 'character_avatar.dart';

/// The game's own character avatar for any NPC. The whole face is shown
/// (never cropped); [size] is the avatar width and the height is 1.25x.
class NpcAvatar extends StatelessWidget {
  const NpcAvatar({
    required this.character,
    required this.currentYear,
    required this.size,
    super.key,
  });

  final Character character;
  final int currentYear;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CharacterPaletteService>(
      future: CharacterPaletteService.load(),
      builder: (context, snapshot) {
        final palette = snapshot.data;
        final box = SizedBox(width: size, height: size * 1.25);

        if (palette == null || snapshot.hasError) {
          return box;
        }

        final appearance = character.appearance;
        final skin = palette.skinColor(appearance.skinTone);
        final eyes = palette.eyeColor(appearance.eyeColor);
        final hair = palette.hairColor(appearance.hairColor);

        if (skin == null || eyes == null || hair == null) {
          return box;
        }

        return CharacterAvatar(
          character: character,
          currentYear: currentYear,
          size: size,
          skinColor: skin,
          eyeColor: eyes,
          hairColor: hair,
        );
      },
    );
  }
}
