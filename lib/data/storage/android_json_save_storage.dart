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
    final temporaryFile = File(
      '${file.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}',
    );

    try {
      await temporaryFile.writeAsString(
        json,
        flush: true,
      );

      // The temporary file is in the same directory so the final rename
      // can replace the destination atomically on Android/Linux filesystems.
      await temporaryFile.rename(file.path);
    } catch (_) {
      // Never delete the previous save when the new write/rename fails.
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
      rethrow;
    }
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

    // Use the same atomic write path as normal saves. Keep the legacy file
    // as a recovery backup instead of deleting the only known-good copy
    // before the repository has successfully parsed the migrated data.
    await write(
      json,
      slotKey: 'autosave',
    );

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
