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
    SaveSlot slot = SaveSlot.slot1,
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
    SaveSlot slot = SaveSlot.slot1,
  }) {
    return _repository.load(
      slot: slot,
    );
  }

  @override
  Future<void> delete({
    SaveSlot slot = SaveSlot.slot1,
  }) {
    return _repository.delete(
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
}
