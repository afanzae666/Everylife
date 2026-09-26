import 'dart:convert';

import '../../domain/world/world_state.dart';
import '../models/simulation_save_snapshot.dart';
import '../models/world_state_snapshot.dart';
import '../storage/json_save_storage.dart';
import 'save_repository.dart';

class JsonSaveRepository
    implements SaveRepository {
  const JsonSaveRepository({
    required JsonSaveStorage storage,
  }) : _storage = storage;

  final JsonSaveStorage _storage;

  @override
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
    SaveSlot slot = SaveSlot.autosave,
  }) async {
    final snapshot =
        SimulationSaveSnapshot(
      world:
          WorldStateSnapshot.fromWorldState(
        state,
      ),
      randomState: randomState,
      nextTickId: nextTickId,
      savedAt: DateTime.now().toUtc(),
    );

    final json = jsonEncode(
      snapshot.toJson(),
    );

    await _storage.write(
      json,
      slotKey: _slotKey(slot),
    );
  }

  @override
  Future<SaveData?> load({
    SaveSlot slot = SaveSlot.autosave,
  }) async {
    final json = await _storage.read(
      slotKey: _slotKey(slot),
    );

    if (json == null) {
      return null;
    }

    final decoded = jsonDecode(json);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Saved game data must be a JSON object.',
      );
    }

    final snapshot =
        SimulationSaveSnapshot.fromJson(
      decoded,
    );

    return SaveData(
      state:
          snapshot.world.toWorldState(),
      randomState:
          snapshot.randomState,
      nextTickId:
          snapshot.nextTickId,
      savedAt:
          snapshot.savedAt,
    );
  }

  @override
  Future<void> delete({
    SaveSlot slot = SaveSlot.autosave,
  }) async {
    await _storage.delete(
      slotKey: _slotKey(slot),
    );
  }

  String _slotKey(
    SaveSlot slot,
  ) {
    switch (slot) {
      case SaveSlot.autosave:
        return 'autosave';

      case SaveSlot.manual1:
        return 'manual_1';

      case SaveSlot.manual2:
        return 'manual_2';

      case SaveSlot.manual3:
        return 'manual_3';

      case SaveSlot.manual4:
        return 'manual_4';
    }
  }
}
