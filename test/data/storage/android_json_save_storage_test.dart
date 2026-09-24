import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/storage/android_json_save_storage.dart';

void main() {
  group('AndroidJsonSaveStorage', () {
    late Directory temporaryDirectory;
    late AndroidJsonSaveStorage storage;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'everylife_storage_test_',
      );

      storage = AndroidJsonSaveStorage(
        directoryProvider: () async => temporaryDirectory,
      );
    });

    tearDown(() async {
      if (await temporaryDirectory.exists()) {
        await temporaryDirectory.delete(
          recursive: true,
        );
      }
    });

    test(
      'returns null when no save file exists',
      () async {
        final result = await storage.read();

        expect(result, isNull);
      },
    );

    test(
      'writes and reads saved JSON',
      () async {
        const json = '{"currentYear":2050}';

        await storage.write(json);

        final result = await storage.read();

        expect(result, json);
      },
    );

    test(
      'overwrites the previous saved JSON',
      () async {
        const firstJson = '{"currentYear":2050}';
        const secondJson = '{"currentYear":2051}';

        await storage.write(firstJson);
        await storage.write(secondJson);

        final result = await storage.read();

        expect(result, secondJson);
      },
    );

    test(
      'creates the expected save file',
      () async {
        const json = '{"currentYear":2050}';

        await storage.write(json);

        final saveFile = File(
          '${temporaryDirectory.path}/everylife_save.json',
        );

        expect(
          await saveFile.exists(),
          isTrue,
        );

        expect(
          await saveFile.readAsString(),
          json,
        );
      },
    );

    test(
      'deletes the saved JSON',
      () async {
        const json = '{"currentYear":2050}';

        await storage.write(json);

        expect(
          await storage.read(),
          json,
        );

        await storage.delete();

        expect(
          await storage.read(),
          isNull,
        );
      },
    );

    test(
      'delete is safe when no save file exists',
      () async {
        await storage.delete();

        expect(
          await storage.read(),
          isNull,
        );
      },
    );
  });
}
