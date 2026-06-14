import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1A73E8);
  static const accent = Color(0xFF00BFA5);
  static const background = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFB8C00);
  static const textPrimary = Color(0xFF1A1F36);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFFADB5BD);
  static const divider = Color(0xFFE9ECEF);
  static const inputFill = Color(0xFFF1F5F9);
  static const cardShadow = Color(0x14000000);

  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF00BFA5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientBlueDiag = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, color: AppColors.textHint,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        prefixIconColor: AppColors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.inputFill,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
