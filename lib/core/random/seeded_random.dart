class SeededRandom {
  SeededRandom(int seed) : _state = seed & 0x7fffffff;

  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(
        max,
        'max',
        'Must be greater than zero.',
      );
    }

    _state = (1103515245 * _state + 12345) & 0x7fffffff;

    return _state % max;
  }

  bool nextBool() {
    return nextInt(2) == 0;
  }

  double nextDouble() {
    return nextInt(1000000) / 1000000;
  }

  int get state => _state;
}
