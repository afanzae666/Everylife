import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'json_save_storage.dart';

class AndroidJsonSaveStorage implements JsonSaveStorage {
  const AndroidJsonSaveStorage();

  static const String _fileName = 'everylife_save.json';

  Future<File> _getSaveFile() async {
    final directory = await getApplicationDocumentsDirectory();

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
