class SeededRandom {
  SeededRandom(int seed) : _state = seed & _stateMask;

  SeededRandom.fromState(int state) : _state = _validateState(state);

  static const int _stateMask = 0x7fffffff;

  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(
        max,
        'max',
        'Must be greater than zero.',
      );
    }

    _state = (1103515245 * _state + 12345) & _stateMask;

    return _state % max;
  }

  bool nextBool() {
    return nextInt(2) == 0;
  }

  double nextDouble() {
    return nextInt(1000000) / 1000000;
  }

  int get state => _state;

  void restoreState(int state) {
    _state = _validateState(state);
  }

  static int _validateState(int state) {
    if (state < 0 || state > _stateMask) {
      throw ArgumentError.value(
        state,
        'state',
        'Must be between 0 and $_stateMask.',
      );
    }

    return state;
  }
}
