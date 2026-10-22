import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _radius = 12.0;

  static final light = _build(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1F5E56),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE1EFEA),
      onPrimaryContainer: Color(0xFF1F5E56),
      secondary: Color(0xFF1F5E56),
      onSecondary: Colors.white,
      error: Color(0xFFE5484D),
      onError: Colors.white,
      errorContainer: Color(0xFFFDECEC),
      onErrorContainer: Color(0xFFD13438),
      surface: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      onSurfaceVariant: Color(0xFF6B6B6B),
      surfaceContainerLowest: Color(0xFFF4F3EF),
      outline: Color(0xFFD9D7D0),
      outlineVariant: Color(0xFFECEAE4),
    ),
  );

  static final dark = _build(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7FD1C1),
      onPrimary: Color(0xFF0E2E29),
      primaryContainer: Color(0xFF1E3D38),
      onPrimaryContainer: Color(0xFF9EE3D5),
      secondary: Color(0xFF7FD1C1),
      onSecondary: Color(0xFF0E2E29),
      error: Color(0xFFFF6B6F),
      onError: Color(0xFF3A0B0C),
      errorContainer: Color(0xFF4A1C1E),
      onErrorContainer: Color(0xFFFFB3B5),
      surface: Color(0xFF26292B),
      onSurface: Color(0xFFF2F2F2),
      onSurfaceVariant: Color(0xFFA5A9AB),
      surfaceContainerLowest: Color(0xFF1B1D1F),
      outline: Color(0xFF3D4144),
      outlineVariant: Color(0xFF33373A),
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: buttonShape,
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.surface,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle: TextStyle(fontSize: 13, color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(fontSize: 13, color: scheme.onPrimary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
