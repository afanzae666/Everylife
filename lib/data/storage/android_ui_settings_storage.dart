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

  static const String _fileName =
      'everylife_ui_settings.json';

  final Future<Directory> Function()
      _directoryProvider;

  Future<File> _getSettingsFile() async {
    final directory =
        await _directoryProvider();

    return File(
      '${directory.path}/$_fileName',
    );
  }

  Future<double?> readUiScale() async {
    try {
      final file =
          await _getSettingsFile();

      if (!await file.exists()) {
        return null;
      }

      final jsonString =
          await file.readAsString();

      final decoded =
          jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final value =
          decoded['uiScale'];

      if (value is num) {
        return value.toDouble();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUiScale(
    double value,
  ) async {
    try {
      final file =
          await _getSettingsFile();

      await file.writeAsString(
        jsonEncode({
          'uiScale': value,
        }),
        flush: true,
      );
    } catch (_) {
      // UI preferences must never prevent
      // the game from starting.
    }
  }
}
