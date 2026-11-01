import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/core/theme/app_palette.dart';

abstract class AppTheme {
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData darkWithAccent(AppAccentColor accent) =>
      _build(AppPalette.forAccent(accent, isDark: true), Brightness.dark);

  static ThemeData lightWithAccent(AppAccentColor accent) =>
      _build(AppPalette.forAccent(accent, isDark: false), Brightness.light);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: brightness,
        ).copyWith(
          primary: p.primary,
          onPrimary: p.onPrimary,
          surface: p.surface,
          onSurface: p.onBackground,
          secondary: isDark ? const Color(0xFF75A995) : const Color(0xFF56836D),
          onSecondary: isDark ? const Color(0xFF10251C) : Colors.white,
          outline: p.secondaryText.withValues(alpha: .35),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: 'Janna',
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface,
      dialogBackgroundColor: p.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.primary),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: p.onBackground,
          fontFamily: 'Janna',
          fontWeight: FontWeight.w900,
          fontSize: 23,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primary,
        unselectedItemColor: p.secondaryText,
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        modalBackgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: TextStyle(color: p.secondaryText),
        hintStyle: TextStyle(color: p.secondaryText.withValues(alpha: .8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.secondaryText.withValues(alpha: .25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.secondaryText.withValues(alpha: .25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
      ),
      iconTheme: IconThemeData(color: p.primary),
      dividerColor: p.secondaryText.withValues(alpha: .2),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: .25),
        selectionHandleColor: p.primary,
      ),
      extensions: [p],
    );
  }
}
