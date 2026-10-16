
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart'
    as path_provider;

class AndroidUiSettingsStorage {
  AndroidUiSettingsStorage({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
           directoryProvider ??
           path_provider.getApplicationDocumentsDirectory;

  static const String _fileName = 'everylife_ui_settings.json';

  final Future<Directory> Function() _directoryProvider;

  Future<File> _getSettingsFile() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/$_fileName');
  }

  Future<Map<String, dynamic>> _readSettings() async {
    try {
      final file = await _getSettingsFile();

      if (!await file.exists()) {
        return {};
      }

      final decoded = jsonDecode(await file.readAsString());

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Invalid or unavailable preferences use defaults.
    }

    return {};
  }

  Future<void> _writeSetting(
    String key,
    Object value,
  ) async {
    try {
      final file = await _getSettingsFile();
      final settings = await _readSettings();

      settings[key] = value;

      await file.writeAsString(
        jsonEncode(settings),
        flush: true,
      );
    } catch (_) {
      // UI preferences must never prevent the game from starting.
    }
  }

  Future<double?> readUiScale() async {
    final value = (await _readSettings())['uiScale'];

    if (value is num) {
      return value.toDouble();
    }

    return null;
  }

  Future<void> writeUiScale(double value) {
    return _writeSetting('uiScale', value);
  }

  Future<String?> readThemeMode() async {
    final value = (await _readSettings())['themeMode'];

    if (value is String &&
        const {'system', 'light', 'dark'}.contains(value)) {
      return value;
    }

    return null;
  }

  Future<void> writeThemeMode(String value) {
    return _writeSetting('themeMode', value);
  }
}
