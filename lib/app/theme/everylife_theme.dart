
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'everylife_colors.dart';
import 'everylife_dimensions.dart';

abstract final class EveryLifeTheme {
  EveryLifeTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
  }) {
    final isLight = brightness == Brightness.light;

    final background = isLight
        ? EveryLifeColors.lightBackground
        : EveryLifeColors.darkBackground;
    final surface = isLight
        ? EveryLifeColors.lightSurface
        : EveryLifeColors.darkSurface;
    final primary = isLight
        ? EveryLifeColors.lightPrimary
        : EveryLifeColors.darkPrimary;
    final onPrimary = isLight
        ? Colors.white
        : const Color(0xFF17251B);
    final text = isLight
        ? EveryLifeColors.lightText
        : EveryLifeColors.darkText;
    final secondaryText = isLight
        ? EveryLifeColors.lightSecondaryText
        : EveryLifeColors.darkSecondaryText;
    final border = isLight
        ? EveryLifeColors.lightBorder
        : EveryLifeColors.darkBorder;
    final gold = isLight
        ? EveryLifeColors.lightGold
        : EveryLifeColors.darkGold;
    final error = isLight
        ? EveryLifeColors.lightError
        : EveryLifeColors.darkError;
    final success = isLight
        ? EveryLifeColors.lightSuccess
        : EveryLifeColors.darkSuccess;
    final primarySoft = isLight
        ? EveryLifeColors.lightPrimarySoft
        : EveryLifeColors.darkPrimarySoft;

    final seededScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );

    final colorScheme = seededScheme.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: success,
      onSecondary: Colors.white,
      tertiary: gold,
      onTertiary: isLight
          ? EveryLifeColors.lightText
          : const Color(0xFF17251B),
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      outline: border,
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
        color: text,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 21.6,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 16.2,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 15.3,
        color: text,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14.4,
        color: text,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12.6,
        color: secondaryText,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 12.6,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 11.7,
        fontWeight: FontWeight.w600,
        color: secondaryText,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        EveryLifeDimensions.radiusSmall,
      ),
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: EveryLifeDimensions.elevationFlat,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 19.8,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: EveryLifeDimensions.elevationFlat,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: border,
            width: EveryLifeDimensions.borderThin,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: border,
          disabledForegroundColor: secondaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
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
          foregroundColor: primary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              EveryLifeDimensions.radiusSmall,
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusSmall,
          ),
          borderSide: BorderSide(
            color: primary,
            width: EveryLifeDimensions.borderEmphasis,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: success,
        linearTrackColor: primarySoft,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: success,
        thumbColor: primary,
        overlayColor: success.withValues(alpha: 0.12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight
            ? EveryLifeColors.lightText
            : EveryLifeColors.darkSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isLight ? Colors.white : text,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            EveryLifeDimensions.radiusSmall,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
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
