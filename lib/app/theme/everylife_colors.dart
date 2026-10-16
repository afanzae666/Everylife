
import 'package:flutter/material.dart';

/// Shared color tokens for EveryLife's Modern Natural visual system.
abstract final class EveryLifeColors {
  EveryLifeColors._();

  // Light mode.
  static const Color lightBackground = Color(0xFFF7F8F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF315B43);
  static const Color lightPrimaryDark = Color(0xFF243F30);
  static const Color lightPrimarySoft = Color(0xFFE5EEE6);
  static const Color lightText = Color(0xFF24342B);
  static const Color lightSecondaryText = Color(0xFF626B64);
  static const Color lightBorder = Color(0xFFE2E7E1);
  static const Color lightGold = Color(0xFFB99450);
  static const Color lightCoral = Color(0xFFC97868);
  static const Color lightSuccess = Color(0xFF397653);
  static const Color lightError = Color(0xFFB54740);

  // Dark mode.
  static const Color darkBackground = Color(0xFF171D19);
  static const Color darkSurface = Color(0xFF222B24);
  static const Color darkPrimary = Color(0xFF78A783);
  static const Color darkPrimaryDark = Color(0xFF527C5C);
  static const Color darkPrimarySoft = Color(0xFF2C4434);
  static const Color darkText = Color(0xFFF0F4F0);
  static const Color darkSecondaryText = Color(0xFFB1BDB3);
  static const Color darkBorder = Color(0xFF37453A);
  static const Color darkGold = Color(0xFFD6B779);
  static const Color darkCoral = Color(0xFFE39A8B);
  static const Color darkSuccess = Color(0xFF8BC49A);
  static const Color darkError = Color(0xFFF08E85);

  // Temporary compatibility aliases for older UI code.
  static const Color warmIvory = lightBackground;
  static const Color warmSurface = lightSurface;
  static const Color deepNavy = lightText;
  static const Color sageGreen = lightSuccess;
  static const Color softGold = lightGold;
  static const Color softCoral = lightCoral;
  static const Color warmBorder = lightBorder;
  static const Color mutedText = lightSecondaryText;
}
