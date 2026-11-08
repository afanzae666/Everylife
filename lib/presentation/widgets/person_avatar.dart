import 'package:flutter/material.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import '../../domain/character/appearance.dart';
import '../../domain/character/gender.dart';
import 'character_avatar.dart';

/// The avatar of a family member, built from the data every NPC has.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthYear,
    required this.appearance,
    required this.currentYear,
    this.size = 112,
    super.key,
  });

  final String id;
  final String firstName;
  final String lastName;
  final Gender gender;
  final int birthYear;
  final CharacterAppearance appearance;
  final int currentYear;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = SizedBox(
      width: size,
      height: size * 1.25,
      child: const Icon(Icons.person_outline, size: 56),
    );

    return FutureBuilder<CharacterPaletteService>(
      future: CharacterPaletteService.load(),
      builder: (context, snapshot) {
        final palette = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            palette == null) {
          return fallback;
        }

        final skin = palette.skinColor(appearance.skinTone);
        final eyes = palette.eyeColor(appearance.eyeColor);
        final hair = palette.hairColor(appearance.hairColor);

        if (skin == null || eyes == null || hair == null) return fallback;

        return CharacterAvatar(
          character: Character.create(
            id: id,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            birthYear: birthYear,
            appearance: appearance,
          ),
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
