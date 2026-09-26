abstract interface class UiSettingsRepository {
  Future<double> loadUiScale();

  Future<void> saveUiScale(double value);
}

class InMemoryUiSettingsRepository
    implements UiSettingsRepository {
  InMemoryUiSettingsRepository({
    double initialUiScale = 1.0,
  }) : _uiScale = initialUiScale;

  double _uiScale;

  @override
  Future<double> loadUiScale() async {
    return _uiScale;
  }

  @override
  Future<void> saveUiScale(double value) async {
    _uiScale = value;
  }
}
