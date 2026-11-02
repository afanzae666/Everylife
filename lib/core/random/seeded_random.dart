class SeededRandom {
  SeededRandom(int seed) : _state = seed & _stateMask;

  SeededRandom.fromState(int state) : _state = _validateState(state);

  static const int _stateMask = 0x7fffffff;

  int _state;

  /// Largest supported exclusive upper bound for [nextInt].
  static const int maxBound = 1 << 48;

  /// Advances the generator and returns the new raw 31-bit state.
  int _advance() {
    _state = (1103515245 * _state + 12345) & _stateMask;

    return _state;
  }

  /// Returns a value in the range 0 (inclusive) to [max] (exclusive).
  ///
  /// The low bits of a power-of-two LCG have very short periods (the lowest
  /// bit simply alternates), so only the high 16 bits of each step are used.
  /// Bounds above 65536 combine several steps so large ranges are fully
  /// covered instead of being truncated to the 31-bit state size.
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(
        max,
        'max',
        'Must be greater than zero.',
      );
    }

    if (max > maxBound) {
      throw ArgumentError.value(
        max,
        'max',
        'Must not exceed $maxBound.',
      );
    }

    var value = _advance() >> 15;
    var span = 1 << 16;

    while (span < max) {
      value = (value << 16) | (_advance() >> 15);
      span <<= 16;
    }

    return value % max;
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
