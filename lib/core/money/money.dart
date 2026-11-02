class Money {
  const Money.fromMinorUnits(this.minorUnits);

  const Money.zero() : minorUnits = 0;

  final int minorUnits;

  static const int minorUnitsPerUnit = 100;

  double get asDouble => minorUnits / minorUnitsPerUnit;

  Money operator +(Money other) {
    return Money.fromMinorUnits(
      minorUnits + other.minorUnits,
    );
  }

  Money operator -(Money other) {
    return Money.fromMinorUnits(
      minorUnits - other.minorUnits,
    );
  }

  bool operator <(Money other) => minorUnits < other.minorUnits;

  bool operator <=(Money other) => minorUnits <= other.minorUnits;

  bool operator >(Money other) => minorUnits > other.minorUnits;

  bool operator >=(Money other) => minorUnits >= other.minorUnits;

  Money multiply(int multiplier) {
    return Money.fromMinorUnits(
      minorUnits * multiplier,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Money && other.minorUnits == minorUnits;
  }

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  String toString() {
    final absolute = minorUnits.abs();
    final units = absolute ~/ minorUnitsPerUnit;
    final cents = absolute % minorUnitsPerUnit;
    final sign = minorUnits < 0 ? '-' : '';

    return '$sign\$$units.${cents.toString().padLeft(2, '0')}';
  }
}
