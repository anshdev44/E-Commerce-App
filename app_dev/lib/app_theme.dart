import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui_tokens.dart';

/// Minimal, clean color palette
class AppColors {
  AppColors._();

  // Primary colors (max 2)
  static const Color primary = Color(0xFF4A90E2); // Soft Blue
  static const Color primaryDark = Color(0xFF357ABD);

  // Neutral colors (2)
  static const Color neutralLight = Color(0xFFF5F7FA); // Very Light Gray
  static const Color neutralDark = Color(0xFF2C3E50); // Dark Gray

  // Surface colors
  static const Color background = Color(0xFFFAFBFC); // Light background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Light surface variant

  // Text colors
  static const Color onSurface = Color(0xFF1A1A1A); // Dark text
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Medium gray text
  static const Color onPrimary = Color(0xFFFFFFFF); // White on primary

  // Semantic colors
  static const Color error = Color(0xFFE74C3C); // Soft Red
  static const Color success = Color(0xFF27AE60); // Soft Green
  static const Color warning = Color(0xFFF39C12); // Soft Orange
  static const Color info = Color(0xFF4A90E2); // Info Blue (same as primary)

  // Compatibility colors (for backward compatibility with existing code)
  static const Color secondary = Color(0xFF4A90E2); // Same as primary
  static const Color accent = Color(0xFF27AE60); // Same as success for accent

  // Border
  static const Color border = Color(0xFFE5E7EB); // Light border
}

/// Global app theme with minimal, consistent design
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,

  // Color Scheme
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    primaryContainer: AppColors.primaryDark,
    secondary: AppColors.primary,
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    onBackground: AppColors.onSurface,
    outline: AppColors.border,
  ),

  // Typography scale (balanced) with modern font family
  textTheme: GoogleFonts.poppinsTextTheme(
    const TextTheme(
    // Headlines: 20-22
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.onSurface,
      letterSpacing: -0.5,
      fontFamily: 'Poppins',
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
      letterSpacing: -0.5,
      fontFamily: 'Poppins',
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
      fontFamily: 'Poppins',
    ),

    // Subtitles: 16-18
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurface,
      fontFamily: 'Poppins',
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
      fontFamily: 'Poppins',
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
      fontFamily: 'Poppins',
    ),

    // Body: 14-16
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurface,
      height: 1.5,
      fontFamily: 'Poppins',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurfaceVariant,
      height: 1.5,
      fontFamily: 'Poppins',
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.onSurfaceVariant,
      fontFamily: 'Poppins',
    ),

    // Labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurface,
      fontFamily: 'Poppins',
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
      fontFamily: 'Poppins',
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
    ),
  )),

  // Input Decoration Theme (clean, consistent)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: UITokens.spacing16,
      vertical: UITokens.spacing12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      borderSide: const BorderSide(color: AppColors.border, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle: const TextStyle(
      color: AppColors.onSurfaceVariant,
      fontSize: 14,
    ),
    labelStyle: const TextStyle(
      color: AppColors.onSurfaceVariant,
      fontSize: 14,
    ),
  ),

  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: UITokens.elevationSmall,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spacing24,
        vertical: UITokens.spacing12,
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.radiusSmall),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spacing24,
        vertical: UITokens.spacing12,
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spacing16,
        vertical: UITokens.spacing8,
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Card Theme (8dp radius, subtle shadow)
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: UITokens.elevationSmall,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UITokens.radiusSmall),
    ),
    margin: const EdgeInsets.symmetric(
      vertical: UITokens.spacing4,
      horizontal: UITokens.spacing8,
    ),
  ),

  // AppBar Theme (clean, minimal)
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: UITokens.elevationNone,
    shadowColor: Colors.black.withOpacity(0.05),
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(color: AppColors.onSurface),
    titleTextStyle: const TextStyle(
      color: AppColors.onSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
  ),

  // Icon Theme
  iconTheme: const IconThemeData(
    color: AppColors.onSurface,
    size: 24,
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
    thickness: 1,
    space: 1,
  ),
);

