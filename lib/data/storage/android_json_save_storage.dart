import 'dart:io';

import 'package:path_provider/path_provider.dart'
    as path_provider;

import 'json_save_storage.dart';

class AndroidJsonSaveStorage
    implements JsonSaveStorage {
  AndroidJsonSaveStorage({
    Future<Directory> Function()?
        directoryProvider,
  }) : _directoryProvider =
            directoryProvider ??
                path_provider
                    .getApplicationDocumentsDirectory;

  final Future<Directory> Function()
      _directoryProvider;

  @override
  Future<void> write(
    String json, {
    String slotKey = 'autosave',
  }) async {
    final file = await _getSaveFile(
      slotKey,
    );

    await file.writeAsString(
      json,
      flush: true,
    );
  }

  @override
  Future<String?> read({
    String slotKey = 'autosave',
  }) async {
    final file = await _getSaveFile(
      slotKey,
    );

    if (await file.exists()) {
      return file.readAsString();
    }

    if (slotKey != 'autosave') {
      return null;
    }

    return _migrateLegacySave();
  }

  @override
  Future<void> delete({
    String slotKey = 'autosave',
  }) async {
    final file = await _getSaveFile(
      slotKey,
    );

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String?> _migrateLegacySave() async {
    final legacyFile =
        await _getLegacySaveFile();

    if (!await legacyFile.exists()) {
      return null;
    }

    final json =
        await legacyFile.readAsString();

    final autosaveFile =
        await _getSaveFile('autosave');

    await autosaveFile.writeAsString(
      json,
      flush: true,
    );

    await legacyFile.delete();

    return json;
  }

  Future<File> _getSaveFile(
    String slotKey,
  ) async {
    final directory =
        await _directoryProvider();

    return File(
      '${directory.path}/everylife_$slotKey.json',
    );
  }

  Future<File> _getLegacySaveFile() async {
    final directory =
        await _directoryProvider();

    return File(
      '${directory.path}/everylife_save.json',
    );
  }
}
