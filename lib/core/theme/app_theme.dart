import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryGradientStart = Color(0xFF4F46E5);
  static const Color primaryGradientEnd = Color(0xFF7C3AED);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color cardBorder = Color(0xFFE2E8F0); // Slate 200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status Colors
  static const Color present = Color(0xFF10B981); // Emerald 500
  static const Color presentBg = Color(0xFFECFDF5); // Emerald 50
  static const Color presentBorder = Color(0xFFA7F3D0); // Emerald 200

  static const Color absent = Color(0xFFEF4444); // Rose 500
  static const Color absentBg = Color(0xFFFEF2F2); // Rose 50
  static const Color absentBorder = Color(0xFFFECACA); // Rose 200

  static const Color onLeave = Color(0xFF8B5CF6); // Violet 500
  static const Color onLeaveBg = Color(0xFFF5F3FF); // Violet 50
  static const Color onLeaveBorder = Color(0xFFDDD6FE); // Violet 200

  static const Color holiday = Color(0xFF06B6D4); // Cyan 500
  static const Color holidayBg = Color(0xFFECFEFF); // Cyan 50
  static const Color holidayBorder = Color(0xFFA5F3FC); // Cyan 200

  static const Color pending = Color(0xFFF59E0B); // Amber 500
  static const Color pendingBg = Color(0xFFFFFBEB); // Amber 50
  static const Color pendingBorder = Color(0xFFFDE68A); // Amber 200

  static const Color approved = Color(0xFF10B981);
  static const Color approvedBg = Color(0xFFECFDF5);
  static const Color approvedBorder = Color(0xFFA7F3D0);

  static const Color rejected = Color(0xFFEF4444);
  static const Color rejectedBg = Color(0xFFFEF2F2);
  static const Color rejectedBorder = Color(0xFFFECACA);

  // Leave Type Colors
  static const Color casualLeave = Color(0xFF3B82F6); // Blue
  static const Color sickLeave = Color(0xFFEC4899); // Pink
  static const Color earnedLeave = Color(0xFF8B5CF6); // Violet
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.absent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.absent, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
