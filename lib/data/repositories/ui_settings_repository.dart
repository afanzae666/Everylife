abstract interface class UiSettingsRepository {
  Future<double> loadUiScale();

  Future<void> saveUiScale(double value);
}
