import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/storage/android_json_save_storage.dart';

void main() {
  group('AndroidJsonSaveStorage', () {
    late Directory temporaryDirectory;
    late AndroidJsonSaveStorage storage;

    setUp(() async {
      temporaryDirectory =
          await Directory.systemTemp.createTemp(
        'everylife_storage_test_',
      );

      storage = AndroidJsonSaveStorage(
        directoryProvider: () async =>
            temporaryDirectory,
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
        final result =
            await storage.read();

        expect(result, isNull);
      },
    );

    test(
      'writes and reads saved JSON',
      () async {
        const json =
            '{"currentYear":2050}';

        await storage.write(json);

        final result =
            await storage.read();

        expect(result, json);
      },
    );

    test(
      'overwrites the previous saved JSON',
      () async {
        const firstJson =
            '{"currentYear":2050}';

        const secondJson =
            '{"currentYear":2051}';

        await storage.write(firstJson);
        await storage.write(secondJson);

        final result =
            await storage.read();

        expect(result, secondJson);
      },
    );

    test(
      'creates the expected autosave file',
      () async {
        const json =
            '{"currentYear":2050}';

        await storage.write(json);

        final saveFile = File(
          '${temporaryDirectory.path}/everylife_autosave.json',
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
      'creates the expected manual slot file',
      () async {
        const json =
            '{"currentYear":2050}';

        await storage.write(
          json,
          slotKey: 'manual_1',
        );

        final saveFile = File(
          '${temporaryDirectory.path}/everylife_manual_1.json',
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
      'keeps autosave and manual slots separate',
      () async {
        const autosaveJson =
            '{"currentYear":2050}';

        const manualJson =
            '{"currentYear":2045}';

        await storage.write(
          autosaveJson,
        );

        await storage.write(
          manualJson,
          slotKey: 'manual_1',
        );

        expect(
          await storage.read(),
          autosaveJson,
        );

        expect(
          await storage.read(
            slotKey: 'manual_1',
          ),
          manualJson,
        );
      },
    );

    test(
      'overwrites only the selected slot',
      () async {
        const autosaveJson =
            '{"currentYear":2050}';

        const firstManualJson =
            '{"currentYear":2045}';

        const secondManualJson =
            '{"currentYear":2046}';

        await storage.write(
          autosaveJson,
        );

        await storage.write(
          firstManualJson,
          slotKey: 'manual_1',
        );

        await storage.write(
          secondManualJson,
          slotKey: 'manual_1',
        );

        expect(
          await storage.read(),
          autosaveJson,
        );

        expect(
          await storage.read(
            slotKey: 'manual_1',
          ),
          secondManualJson,
        );
      },
    );

    test(
      'deletes only the selected slot',
      () async {
        const autosaveJson =
            '{"currentYear":2050}';

        const manualJson =
            '{"currentYear":2045}';

        await storage.write(
          autosaveJson,
        );

        await storage.write(
          manualJson,
          slotKey: 'manual_1',
        );

        await storage.delete(
          slotKey: 'manual_1',
        );

        expect(
          await storage.read(),
          autosaveJson,
        );

        expect(
          await storage.read(
            slotKey: 'manual_1',
          ),
          isNull,
        );
      },
    );

    test(
      'deletes the saved JSON',
      () async {
        const json =
            '{"currentYear":2050}';

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

    test(
      'migrates legacy save to autosave',
      () async {
        const legacyJson =
            '{"currentYear":2040}';

        final legacyFile = File(
          '${temporaryDirectory.path}/everylife_save.json',
        );

        await legacyFile.writeAsString(
          legacyJson,
        );

        final result =
            await storage.read();

        expect(
          result,
          legacyJson,
        );

        final autosaveFile = File(
          '${temporaryDirectory.path}/everylife_autosave.json',
        );

        expect(
          await autosaveFile.exists(),
          isTrue,
        );

        expect(
          await autosaveFile.readAsString(),
          legacyJson,
        );

        expect(
          await legacyFile.exists(),
          isFalse,
        );
      },
    );

    test(
      'does not overwrite existing autosave with legacy save',
      () async {
        const autosaveJson =
            '{"currentYear":2050}';

        const legacyJson =
            '{"currentYear":2040}';

        await storage.write(
          autosaveJson,
        );

        final legacyFile = File(
          '${temporaryDirectory.path}/everylife_save.json',
        );

        await legacyFile.writeAsString(
          legacyJson,
        );

        final result =
            await storage.read();

        expect(
          result,
          autosaveJson,
        );

        expect(
          await legacyFile.exists(),
          isTrue,
        );

        expect(
          await legacyFile.readAsString(),
          legacyJson,
        );
      },
    );
  });
}
