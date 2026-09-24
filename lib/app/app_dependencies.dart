import '../data/repositories/json_save_repository.dart';
import '../data/repositories/save_repository.dart';
import '../data/storage/android_json_save_storage.dart';

class AppDependencies {
  const AppDependencies({
    this.saveRepository,
  });

  final SaveRepository? saveRepository;

  SaveRepository createSaveRepository() {
    return saveRepository ??
        JsonSaveRepository(
          storage: AndroidJsonSaveStorage(),
        );
  }
}
