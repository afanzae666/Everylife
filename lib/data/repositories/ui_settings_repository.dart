
abstract interface class UiSettingsRepository {
  Future<double> loadUiScale();

  Future<void> saveUiScale(double value);

  Future<String?> loadThemeMode();

  Future<void> saveThemeMode(String value);
}
