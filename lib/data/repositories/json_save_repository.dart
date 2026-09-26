import 'dart:convert';

import '../../domain/world/world_state.dart';
import '../models/simulation_save_snapshot.dart';
import '../models/world_state_snapshot.dart';
import '../storage/json_save_storage.dart';
import 'save_repository.dart';

class JsonSaveRepository implements SaveRepository {
  const JsonSaveRepository({
    required JsonSaveStorage storage,
  }) : _storage = storage;

  final JsonSaveStorage _storage;

  @override
    Future<void> save(
    SaveSlot slot,
    WorldState state, {
    required int randomState,
    required int nextTickId,
  }) async {
    final snapshot = SimulationSaveSnapshot(
      world: WorldStateSnapshot.fromWorldState(state),
      randomState: randomState,
      nextTickId: nextTickId,
    );

    final json = jsonEncode(
      snapshot.toJson(),
    );

        await _storage.write(
      json,
      _slotKey(slot),
    );
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

  @override
    Future<SaveData?> load(
    SaveSlot slot,
  ) async {
    final json = await _storage.read(
      _slotKey(slot),
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

    final snapshot = SimulationSaveSnapshot.fromJson(
      decoded,
    );

    return SaveData(
      state: snapshot.world.toWorldState(),
      randomState: snapshot.randomState,
      nextTickId: snapshot.nextTickId,
    );
  }

    @override
  Future<void> delete(
    SaveSlot slot,
  ) async {
    await _storage.delete(
      _slotKey(slot),
    );
  }
