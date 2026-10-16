
/// Shared spacing, radius, and elevation tokens for EveryLife.
///
/// Keep these values centralized so future screens can share a consistent
/// visual rhythm without changing gameplay or simulation logic.
abstract final class EveryLifeDimensions {
  EveryLifeDimensions._();

  static const double space2 = 4;
  static const double space3 = 8;
  static const double space4 = 12;
  static const double space5 = 16;
  static const double space6 = 20;
  static const double space7 = 24;
  static const double space8 = 32;

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 18;
  static const double radiusPill = 999;

  static const double borderThin = 1;
  static const double borderEmphasis = 1.5;

  static const double elevationFlat = 0;
  static const double elevationRaised = 2;
}
