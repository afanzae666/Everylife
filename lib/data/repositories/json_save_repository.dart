import 'dart:convert';

import '../../domain/world/world_state.dart';
import '../models/world_state_snapshot.dart';
import '../storage/json_save_storage.dart';
import 'save_repository.dart';

class JsonSaveRepository implements SaveRepository {
  const JsonSaveRepository({
    required JsonSaveStorage storage,
  }) : _storage = storage;

  final JsonSaveStorage _storage;

  @override
  Future<void> save(WorldState state) async {
    final snapshot = WorldStateSnapshot.fromWorldState(state);
    final json = jsonEncode(snapshot.toJson());

    await _storage.write(json);
  }

  @override
  Future<WorldState?> load() async {
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

    final snapshot = WorldStateSnapshot.fromJson(decoded);

    return snapshot.toWorldState();
  }

  @override
  Future<void> delete() async {
    await _storage.delete();
  }
}
