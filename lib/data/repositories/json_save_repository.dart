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

    await _storage.write(json);
  }

  @override
  Future<SaveData?> load() async {
    final json = await _storage.read();

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
  Future<void> delete() async {
    await _storage.delete();
  }
}
