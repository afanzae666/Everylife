import '../data/repositories/android_ui_settings_repository.dart';
import '../data/repositories/json_save_repository.dart';
import '../data/repositories/save_repository.dart';
import '../data/repositories/ui_settings_repository.dart';
import '../data/storage/android_json_save_storage.dart';

class AppDependencies {
  const AppDependencies({
    this.saveRepository,
    this.uiSettingsRepository,
  });

  final SaveRepository? saveRepository;

  final UiSettingsRepository?
      uiSettingsRepository;

  SaveRepository createSaveRepository() {
    return saveRepository ??
        JsonSaveRepository(
          storage:
              AndroidJsonSaveStorage(),
        );
  }

  UiSettingsRepository
      createUiSettingsRepository() {
    return uiSettingsRepository ??
        AndroidUiSettingsRepository();
  }
}
