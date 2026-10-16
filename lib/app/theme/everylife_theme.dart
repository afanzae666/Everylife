
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'everylife_colors.dart';
import 'everylife_dimensions.dart';

/// The shared Material theme for EveryLife.
///
/// The theme centralizes presentation defaults only. It does not alter
/// navigation, save data, character state, or simulation behavior.
abstract final class EveryLifeTheme {
  EveryLifeTheme._();

  static ThemeData get light {
    final seededScheme = ColorScheme.fromSeed(
      seedColor: EveryLifeColors.deepNavy,
      brightness: Brightness.light,
    );

    final colorScheme = seededScheme.copyWith(
      primary: EveryLifeColors.deepNavy,
      onPrimary: EveryLifeColors.warmSurface,
      secondary: EveryLifeColors.sageGreen,
      onSecondary: Colors.white,
      tertiary: EveryLifeColors.softGold,
      onTertiary: EveryLifeColors.deepNavy,
      error: EveryLifeColors.softCoral,
      onError: Colors.white,
      surface: EveryLifeColors.warmSurface,
      onSurface: EveryLifeColors.deepNavy,
      outline: EveryLifeColors.warmBorder,
    );

    final baseTextTheme = GoogleFonts.nunitoTextTheme(
      ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ).textTheme,
    );

    final textTheme = baseTextTheme.copyWith(
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 24.3,
        fontWeight: FontWeight.w700,
        color: EveryLifeColors.deepNavy,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 21.6,
        fontWeight: FontWeight.w700,
        color: EveryLifeColors.deepNavy,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: EveryLifeColors.deepNavy,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 16.2,
        fontWeight: FontWeight.w700,
        color: EveryLifeColors.deepNavy,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 15.3,
        color: EveryLifeColors.deepNavy,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14.4,
        color: EveryLifeColors.deepNavy,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12.6,
        color: EveryLifeColors.mutedText,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12.6,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 11.7,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: EveryLifeColors.warmIvory,
      canvasColor: EveryLifeColors.warmIvory,
      dividerColor: EveryLifeColors.warmBorder,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: EveryLifeColors.warmIvory,
        foregroundColor: EveryLifeColors.deepNavy,
        surfaceTintColor: Colors.transparent,
        elevation: EveryLifeDimensions.elevationFlat,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 19.8,
          fontWeight: FontWeight.w700,
          color: EveryLifeColors.deepNavy,
        ),
      ),
      cardTheme: CardThemeData(
        color: EveryLifeColors.warmSurface,
        surfaceTintColor: Colors.transparent,
        elevation: EveryLifeDimensions.elevationFlat,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusMedium,
          ),
          side: const BorderSide(
            color: EveryLifeColors.warmBorder,
            width: EveryLifeDimensions.borderThin,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EveryLifeColors.deepNavy,
          foregroundColor: EveryLifeColors.warmSurface,
          disabledBackgroundColor: EveryLifeColors.warmBorder,
          disabledForegroundColor: EveryLifeColors.mutedText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EveryLifeColors.deepNavy,
          foregroundColor: EveryLifeColors.warmSurface,
          elevation: EveryLifeDimensions.elevationFlat,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EveryLifeColors.deepNavy,
          side: const BorderSide(
            color: EveryLifeColors.warmBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EveryLifeColors.deepNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EveryLifeColors.warmSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusSmall,
          ),
          borderSide: const BorderSide(
            color: EveryLifeColors.warmBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusSmall,
          ),
          borderSide: const BorderSide(
            color: EveryLifeColors.warmBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusSmall,
          ),
          borderSide: const BorderSide(
            color: EveryLifeColors.deepNavy,
            width: EveryLifeDimensions.borderEmphasis,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: EveryLifeColors.warmBorder,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EveryLifeColors.sageGreen,
        linearTrackColor: Color(0x2763816E),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: EveryLifeColors.sageGreen,
        thumbColor: EveryLifeColors.deepNavy,
        overlayColor: EveryLifeColors.sageGreen.withValues(
          alpha: 0.12,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EveryLifeColors.deepNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: EveryLifeColors.warmSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusSmall,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EveryLifeColors.warmSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusLarge,
          ),
        ),
      ),
    );
  }
}
