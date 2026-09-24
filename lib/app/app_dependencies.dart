import '../data/repositories/json_save_repository.dart';
import '../data/repositories/save_repository.dart';
import '../data/storage/android_json_save_storage.dart';

class AppDependencies {
  const AppDependencies();

  SaveRepository createSaveRepository() {
    return JsonSaveRepository(
      storage: AndroidJsonSaveStorage(),
    );
  }
}
