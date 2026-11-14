import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every notice is an overlay, never a bar at the bottom', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final source = entity.readAsStringSync();

      if (source.contains('showSnackBar(') ||
          source.contains('showMaterialBanner(')) {
        offenders.add(entity.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Use showNotice (notice_overlay.dart) instead.',
    );
  });
}
