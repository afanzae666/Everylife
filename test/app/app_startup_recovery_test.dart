import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/app/app.dart';
import 'package:everylife/app/app_dependencies.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/presentation/screens/character_creation_screen.dart';

/// A repository whose every slot is unreadable, like a damaged save file.
class _UnreadableSaveRepository implements SaveRepository {
  @override
  Future<SaveData?> load({SaveSlot slot = SaveSlot.slot1}) {
    throw const FormatException('damaged save data');
  }

  @override
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
    SaveSlot slot = SaveSlot.slot1,
  }) async {}

  @override
  Future<void> delete({SaveSlot slot = SaveSlot.slot1}) async {}
}

void main() {
  testWidgets(
    'a damaged save shows an error with a way to start a new life',
    (tester) async {
      await tester.pumpWidget(
        LifeSimulationApp(
          dependencies: AppDependencies(
            saveRepository: _UnreadableSaveRepository(),
          ),
        ),
      );

      for (var i = 0; i < 60; i++) {
        if (find.text('START A NEW LIFE').evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Unable to load saved game.'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);
      expect(find.text('START A NEW LIFE'), findsOneWidget);

      await tester.tap(find.text('START A NEW LIFE'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CharacterCreationScreen), findsOneWidget);
    },
  );
}
