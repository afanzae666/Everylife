import '../data/repositories/android_ui_settings_repository.dart';
import '../data/repositories/json_save_repository.dart';
import '../data/repositories/save_repository.dart';
import '../data/repositories/ui_settings_repository.dart';
import '../data/services/save_manager.dart';
import '../data/storage/android_json_save_storage.dart';

class AppDependencies {
  const AppDependencies({
    this.saveRepository,
    this.saveManager,
    this.uiSettingsRepository,
  });

  final SaveRepository? saveRepository;

  final SaveManager? saveManager;

  final UiSettingsRepository?
      uiSettingsRepository;

  SaveManager createSaveManager() {
    if (saveManager != null) {
      return saveManager!;
    }

    final repository =
        saveRepository ??
            JsonSaveRepository(
              storage:
                  AndroidJsonSaveStorage(),
            );

    return SaveManager(
      repository: repository,
    );
  }

  SaveRepository createSaveRepository() {
    return createSaveManager();
  }

  UiSettingsRepository
      createUiSettingsRepository() {
    return uiSettingsRepository ??
        AndroidUiSettingsRepository();
  }
}
