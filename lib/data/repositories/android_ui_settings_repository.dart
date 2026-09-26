import '../storage/android_ui_settings_storage.dart';
import 'ui_settings_repository.dart';

class AndroidUiSettingsRepository
    implements UiSettingsRepository {
  AndroidUiSettingsRepository({
    AndroidUiSettingsStorage? storage,
  }) : _storage =
          storage ?? AndroidUiSettingsStorage();

  final AndroidUiSettingsStorage _storage;

  static const double defaultUiScale = 1.0;

  @override
  Future<double> loadUiScale() async {
    final value =
        await _storage.readUiScale();

    if (value == null) {
      return defaultUiScale;
    }

    return _sanitize(value);
  }

  @override
  Future<void> saveUiScale(
    double value,
  ) async {
    await _storage.writeUiScale(
      _sanitize(value),
    );
  }

  double _sanitize(double value) {
    if (value < 0.8) {
      return 0.8;
    }

    if (value > 1.2) {
      return 1.2;
    }

    return value;
  }
}
