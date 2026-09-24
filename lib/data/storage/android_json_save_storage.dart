import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

import 'json_save_storage.dart';

class AndroidJsonSaveStorage implements JsonSaveStorage {
  AndroidJsonSaveStorage({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider =
           directoryProvider ??
           path_provider.getApplicationDocumentsDirectory;

  static const String _fileName = 'everylife_save.json';

  final Future<Directory> Function() _directoryProvider;

  Future<File> _getSaveFile() async {
    final directory = await _directoryProvider();

    return File(
      '${directory.path}/$_fileName',
    );
  }

  @override
  Future<void> write(String json) async {
    final file = await _getSaveFile();

    await file.writeAsString(
      json,
      flush: true,
    );
  }

  @override
  Future<String?> read() async {
    final file = await _getSaveFile();

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }

  @override
  Future<void> delete() async {
    final file = await _getSaveFile();

    if (await file.exists()) {
      await file.delete();
    }
  }
}
