import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart'
    as path_provider;

class AutoSaveSettings {
  AutoSaveSettings({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider = directoryProvider ??
            path_provider.getApplicationDocumentsDirectory;

  static const String _fileName =
      'everylife_auto_save_settings.json';

  static const String _autoSaveKey = 'autoSaveEnabled';

  final Future<Directory> Function() _directoryProvider;

  Future<bool> load() async {
    try {
      final directory = await _directoryProvider();

      final file = File(
        '${directory.path}/$_fileName',
      );

      if (!await file.exists()) {
        return true;
      }

      final jsonString = await file.readAsString();

      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return true;
      }

      final value = decoded[_autoSaveKey];

      if (value is! bool) {
        return true;
      }

      return value;
    } catch (_) {
      return true;
    }
  }

  Future<void> save(bool enabled) async {
    try {
      final directory = await _directoryProvider();

      final file = File(
        '${directory.path}/$_fileName',
      );

      final data = <String, dynamic>{
        _autoSaveKey: enabled,
      };

      await file.writeAsString(
        jsonEncode(data),
        flush: true,
      );
    } catch (_) {
      // Auto-save preference must never break the game.
    }
  }
}
