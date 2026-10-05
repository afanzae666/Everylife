import 'dart:convert';

import 'package:flutter/services.dart';

class CharacterPaletteService {
  CharacterPaletteService._({
    required Map<String, Color> skinColors,
    required Map<String, Color> eyeColors,
    required Map<String, Color> hairColors,
  })  : _skinColors = Map.unmodifiable(skinColors),
        _eyeColors = Map.unmodifiable(eyeColors),
        _hairColors = Map.unmodifiable(hairColors);

  static const String _skinAsset =
      'assets/character/palettes/skin_tones.json';

  static const String _eyeAsset =
      'assets/character/palettes/eyes_colors.json';

  static const String _hairAsset =
      'assets/character/palettes/hair_colors.json';

  final Map<String, Color> _skinColors;
  final Map<String, Color> _eyeColors;
  final Map<String, Color> _hairColors;

  static Future<CharacterPaletteService> load() async {
    final String skinJson =
        await rootBundle.loadString(_skinAsset);

    final String eyeJson =
        await rootBundle.loadString(_eyeAsset);

    final String hairJson =
        await rootBundle.loadString(_hairAsset);

    return CharacterPaletteService._(
      skinColors: _parsePalette(skinJson),
      eyeColors: _parsePalette(eyeJson),
      hairColors: _parsePalette(hairJson),
    );
  }

  Map<String, Color> get skinColors =>
      _skinColors;

  Map<String, Color> get eyeColors =>
      _eyeColors;

  Map<String, Color> get hairColors =>
      _hairColors;

  Color? skinColor(String id) =>
      _skinColors[id];

  Color? eyeColor(String id) =>
      _eyeColors[id];

  Color? hairColor(String id) =>
      _hairColors[id];

  static Map<String, Color> _parsePalette(
    String source,
  ) {
    final dynamic decoded =
        jsonDecode(source);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Character palette JSON must contain an object.',
      );
    }

    final Map<String, Color> result =
        <String, Color>{};

    decoded.forEach(
      (
        String id,
        dynamic hexValue,
      ) {
        if (hexValue is! String) {
          throw FormatException(
            'Character palette color for "$id" must be a string.',
          );
        }

        final String normalizedId =
            id.trim();

        if (normalizedId.isEmpty) {
          throw const FormatException(
            'Character palette id cannot be empty.',
          );
        }

        result[normalizedId] =
            _parseHexColor(hexValue);
      },
    );

    if (result.isEmpty) {
      throw const FormatException(
        'Character palette cannot be empty.',
      );
    }

    return result;
  }

  static Color _parseHexColor(
    String value,
  ) {
    String hex = value.trim();

    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    if (hex.length != 8 ||
        !RegExp(
          r'^[0-9a-fA-F]{8}$',
        ).hasMatch(hex)) {
      throw FormatException(
        'Invalid character palette color: $value',
      );
    }

    return Color(
      int.parse(
        hex,
        radix: 16,
      ),
    );
  }
}
