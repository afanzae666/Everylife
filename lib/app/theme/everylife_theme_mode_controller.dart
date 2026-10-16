
import 'dart:async';

import 'package:flutter/material.dart';

abstract final class EveryLifeThemeModeController {
  EveryLifeThemeModeController._();

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> Function(ThemeMode mode)? _saveMode;

  static void configure(
    Future<void> Function(ThemeMode mode) saveMode,
  ) {
    _saveMode = saveMode;
  }

  static void setLoadedMode(ThemeMode value) {
    mode.value = value;
  }

  static void updateMode(ThemeMode value) {
    mode.value = value;

    final saveMode = _saveMode;
    if (saveMode != null) {
      unawaited(saveMode(value));
    }
  }
}
