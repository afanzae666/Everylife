import '../../domain/world/world_state.dart';

/// One place in Life Storage. Every life autosaves into its own slot.
enum SaveSlot {
  slot1,
  slot2,
  slot3,
  slot4,
  slot5,
  slot6,
  slot7,
  slot8,
  slot9,
  slot10,
}

/// How many lives Life Storage can hold.
final int lifeStorageCapacity = SaveSlot.values.length;

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
    SaveSlot slot = SaveSlot.slot1,
  });

  Future<SaveData?> load({
    SaveSlot slot = SaveSlot.slot1,
  });

  Future<void> delete({
    SaveSlot slot = SaveSlot.slot1,
  });
}

class InMemorySaveRepository implements SaveRepository {
  final Map<SaveSlot, SaveData> _data = {};

  @override
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
    SaveSlot slot = SaveSlot.slot1,
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
    SaveSlot slot = SaveSlot.slot1,
  }) async {
    return _data[slot];
  }

  @override
  Future<void> delete({
    SaveSlot slot = SaveSlot.slot1,
  }) async {
    _data.remove(slot);
  }
}
