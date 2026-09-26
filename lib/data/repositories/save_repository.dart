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
    SaveSlot slot,
    WorldState state, {
    required int randomState,
    required int nextTickId,
  });

  Future<SaveData?> load(
    SaveSlot slot,
  );

  Future<void> delete(
    SaveSlot slot,
  );
}
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
  });

  Future<SaveData?> load();

  Future<void> delete();
}

class InMemorySaveRepository implements SaveRepository {
  enum SaveSlot {
  autosave,
  manual1,
  manual2,
  manual3,
  manual4,
}
  final Map<SaveSlot, SaveData> _data = {};

  @override
  Future<void> save(
    SaveSlot slot,
    WorldState state, {
    required int randomState,
    required int nextTickId,
  }) async {
    _data[slot] = SaveData(
      state: state,
      randomState: randomState,
      nextTickId: nextTickId,
    );
  }

  @override
  Future<SaveData?> load(
    SaveSlot slot,
  ) async {
    return _data[slot];
  }

  @override
  Future<void> delete(
    SaveSlot slot,
  ) async {
    _data.remove(slot);
  }
}
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
