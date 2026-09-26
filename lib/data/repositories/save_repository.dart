import '../../domain/world/world_state.dart';

enum SaveSlot {
  autosave,
  manual1,
  manual2,
  manual3,
  manual4,
}

class SaveData {
  const SaveData({
    required this.state,
    required this.randomState,
    required this.nextTickId,
    this.savedAt,
  });

  final WorldState state;
  final int randomState;
  final int nextTickId;
  final DateTime? savedAt;
}

abstract interface class SaveRepository {
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
    SaveSlot slot = SaveSlot.autosave,
  });

  Future<SaveData?> load({
    SaveSlot slot = SaveSlot.autosave,
  });

  Future<void> delete({
    SaveSlot slot = SaveSlot.autosave,
  });
}

class InMemorySaveRepository implements SaveRepository {
  final Map<SaveSlot, SaveData> _data = {};

  @override
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
    SaveSlot slot = SaveSlot.autosave,
  }) async {
    _data[slot] = SaveData(
      state: state,
      randomState: randomState,
      nextTickId: nextTickId,
      savedAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<SaveData?> load({
    SaveSlot slot = SaveSlot.autosave,
  }) async {
    return _data[slot];
  }

  @override
  Future<void> delete({
    SaveSlot slot = SaveSlot.autosave,
  }) async {
    _data.remove(slot);
  }
}
