import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFFFF6B35);
  static const saffron = Color(0xFFF4A62A);
  static const teal = Color(0xFF147C72);
  static const blue = Color(0xFF2F6F9F);
  static const ink = Color(0xFF202124);
  static const muted = Color(0xFF6F747C);
  static const faint = Color(0xFFF6F3EF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFFBFAF8);
  static const border = Color(0xFFE3DFD7);
  static const danger = Color(0xFFC84C3E);
  static const success = Color(0xFF27845E);
}

ThemeData buildAppTheme({
  String primaryColorHex = '#FF6B35',
  String secondaryColorHex = '#F6F3EF',
}) {
  final base = ThemeData.light(useMaterial3: true);
  final textTheme = _mediumTextTheme(base.textTheme);
  final primary = colorFromHex(primaryColorHex, fallback: AppColors.primary);
  final secondary = colorFromHex(secondaryColorHex, fallback: AppColors.teal);
  final faint = colorFromHex(secondaryColorHex, fallback: AppColors.faint);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      tertiary: AppColors.blue,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    scaffoldBackgroundColor: faint,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium,
      

    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border, width: 0.5),
        minimumSize: const Size(44, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 1),
      ),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      ),
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 0.5,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

Color colorFromHex(String hex, {required Color fallback}) {
  final normalized = hex.trim().replaceFirst('#', '');
  if (normalized.length != 6 && normalized.length != 8) return fallback;
  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return fallback;
  return Color(normalized.length == 6 ? 0xFF000000 | value : value);
}

TextTheme _mediumTextTheme(TextTheme base) {
  const weight = FontWeight.w500;
  TextStyle? medium(TextStyle? style) => style?.copyWith(
    fontWeight: weight,
    color: AppColors.ink,
    letterSpacing: 0,
  );

  return base.copyWith(
    displayLarge: medium(base.displayLarge),
    displayMedium: medium(base.displayMedium),
    displaySmall: medium(base.displaySmall),
    headlineLarge: medium(base.headlineLarge),
    headlineMedium: medium(base.headlineMedium),
    headlineSmall: medium(base.headlineSmall),
    titleLarge: medium(base.titleLarge),
    titleMedium: medium(base.titleMedium),
    titleSmall: medium(base.titleSmall),
    bodyLarge: medium(base.bodyLarge),
    bodyMedium: medium(base.bodyMedium),
    bodySmall: medium(base.bodySmall),
    labelLarge: medium(base.labelLarge),
    labelMedium: medium(base.labelMedium),
    labelSmall: medium(base.labelSmall),
  );
}
