import 'package:flutter/material.dart';
import 'package:islami/core/theme/app_colors.dart';

enum AppAccentColor { gold }

extension AppAccentColorDetails on AppAccentColor {
  Color get color => switch (this) {
    AppAccentColor.gold => AppColors.gold,
  };

  String get arabicName => switch (this) {
    AppAccentColor.gold => 'ذهبي',
  };

  Color get lightModeColor => switch (this) {
    AppAccentColor.gold => AppColors.brown,
  };
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color primary;
  final Color onBackground;
  final Color secondaryText;
  final Color onPrimary;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.primary,
    required this.onBackground,
    required this.secondaryText,
    required this.onPrimary,
  });

  static const dark = AppPalette(
    background: AppColors.black,
    surface: Color(0xFF2A2A2A),
    primary: AppColors.gold,
    onBackground: AppColors.white,
    secondaryText: AppColors.gray,
    onPrimary: AppColors.black,
  );

  static const light = AppPalette(
    background: Color(0xFFF4F7F2),
    surface: Color(0xFFFFFFFF),
    primary: AppColors.brown,
    onBackground: Color(0xFF24322B),
    secondaryText: Color(0xFF63736A),
    onPrimary: Color(0xFF000000),
  );

  static AppPalette forAccent(AppAccentColor accent, {required bool isDark}) {
    final base = isDark ? dark : light;
    return base.copyWith(
      primary: isDark ? accent.color : accent.lightModeColor,
      onPrimary: accent == AppAccentColor.gold ? Colors.black : Colors.white,
    );
  }

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? onBackground,
    Color? secondaryText,
    Color? onPrimary,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      onBackground: onBackground ?? this.onBackground,
      secondaryText: secondaryText ?? this.secondaryText,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
