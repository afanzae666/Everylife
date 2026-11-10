import 'package:flutter/material.dart';

import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import 'character_avatar.dart';

/// The game's own character avatar for any NPC. The whole face is shown
/// (never cropped); [size] is the avatar width and the height is 1.25x.
class NpcAvatar extends StatefulWidget {
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
  State<NpcAvatar> createState() => _NpcAvatarState();
}

class _NpcAvatarState extends State<NpcAvatar> {
  // Loaded once and shared, so a rebuild never flashes an empty box.
  static CharacterPaletteService? _cached;
  static Future<CharacterPaletteService>? _loading;

  CharacterPaletteService? _palette = _cached;

  @override
  void initState() {
    super.initState();

    if (_palette == null) {
      _loading ??= CharacterPaletteService.load();
      _loading!.then((value) {
        _cached = value;
        if (mounted) setState(() => _palette = value);
      }).catchError((Object _) {
        _loading = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final character = widget.character;
    final palette = _palette;
    final box = SizedBox(width: size, height: size * 1.25);

    if (palette == null) {
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
      currentYear: widget.currentYear,
      size: size,
      skinColor: skin,
      eyeColor: eyes,
      hairColor: hair,
    );
  }
}
