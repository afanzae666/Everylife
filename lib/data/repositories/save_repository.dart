import '../../domain/world/world_state.dart';

class SaveData {
  const SaveData({
    required this.state,
    required this.randomState,
    required this.nextTickId,
  });

  final WorldState state;
  final int randomState;
  final int nextTickId;
}

abstract interface class SaveRepository {
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
  });

  Future<SaveData?> load();

  Future<void> delete();
}

class InMemorySaveRepository implements SaveRepository {
  SaveData? _data;

  @override
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
  }) async {
    _data = SaveData(
      state: state,
      randomState: randomState,
      nextTickId: nextTickId,
    );
  }

  @override
  Future<SaveData?> load() async {
    return _data;
  }

  @override
  Future<void> delete() async {
    _data = null;
  }
}
