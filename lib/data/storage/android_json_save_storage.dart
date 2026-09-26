import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

import 'json_save_storage.dart';

class AndroidJsonSaveStorage implements JsonSaveStorage {
  AndroidJsonSaveStorage({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
           directoryProvider ??
           path_provider.getApplicationDocumentsDirectory;
  

  final Future<Directory> Function() _directoryProvider;

      Future<File> _getSaveFile(
    String slotKey,
  ) async {
    final directory =
        await _directoryProvider();

    return File(
      '${directory.path}/everylife_$slotKey.json',
    );
  }

    @override
  Future<void> write(
    String json,
    String slotKey,
  ) async {
    final file = await _getSaveFile(
      slotKey,
    );

    await file.writeAsString(
      json,
      flush: true,
    );
  }

    @override
  Future<String?> read(
    String slotKey,
  ) async {
    final file = await _getSaveFile(
      slotKey,
    );

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

    @override
  Future<void> delete(
    String slotKey,
  ) async {
    final file = await _getSaveFile(
      slotKey,
    );

    if (await file.exists()) {
      await file.delete();
    }
  }
