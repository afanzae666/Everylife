import '../repositories/save_repository.dart';
import '../../domain/world/world_state.dart';

class SaveManager implements SaveRepository {
  const SaveManager({
    required SaveRepository repository,
  }) : _repository = repository;

  final SaveRepository _repository;

  @override
  Future<void> save(
    WorldState state, {
    required int randomState,
    required int nextTickId,
    SaveSlot slot = SaveSlot.autosave,
  }) {
    return _repository.save(
      state,
      randomState: randomState,
      nextTickId: nextTickId,
      slot: slot,
    );
  }

  @override
  Future<SaveData?> load({
    SaveSlot slot = SaveSlot.autosave,
  }) {
    return _repository.load(
      slot: slot,
    );
  }

  @override
  Future<void> delete({
    SaveSlot slot = SaveSlot.autosave,
  }) {
    return _repository.delete(
      slot: slot,
    );
  }

  Future<void> saveAutosave(
    WorldState state, {
    required int randomState,
    required int nextTickId,
  }) {
    return save(
      state,
      randomState: randomState,
      nextTickId: nextTickId,
      slot: SaveSlot.autosave,
    );
  }

  Future<void> saveManual(
    SaveSlot slot,
    WorldState state, {
    required int randomState,
    required int nextTickId,
  }) {
    _validateManualSlot(slot);

    return save(
      state,
      randomState: randomState,
      nextTickId: nextTickId,
      slot: slot,
    );
  }

  Future<SaveData?> loadSlot(
    SaveSlot slot,
  ) {
    return load(
      slot: slot,
    );
  }

  Future<void> deleteSlot(
    SaveSlot slot,
  ) {
    return delete(
      slot: slot,
    );
  }

  Future<bool> hasSave(
    SaveSlot slot,
  ) async {
    final data = await load(
      slot: slot,
    );

    return data != null;
  }

  void _validateManualSlot(
    SaveSlot slot,
  ) {
    switch (slot) {
      case SaveSlot.autosave:
        throw ArgumentError(
          'saveManual() cannot use the autosave slot.',
        );

      case SaveSlot.manual1:
      case SaveSlot.manual2:
      case SaveSlot.manual3:
      case SaveSlot.manual4:
        return;
    }
  }
}
