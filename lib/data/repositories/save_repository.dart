import '../../domain/world/world_state.dart';

abstract interface class SaveRepository {
  Future<void> save(WorldState state);

  Future<WorldState?> load();

  Future<void> delete();
}

class InMemorySaveRepository implements SaveRepository {
  WorldState? _state;

  @override
  Future<void> save(WorldState state) async {
    _state = state;
  }

  @override
  Future<WorldState?> load() async {
    return _state;
  }

  @override
  Future<void> delete() async {
    _state = null;
  }
}
