import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Government-aligned color palette - professional, trustworthy, not flashy
  static const Color primaryColor = Color(
    0xFF0D47A1,
  ); // Deep blue - government official
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);

  static const Color accentColor = Color(0xFF2E7D32); // Green - agriculture
  static const Color accentLight = Color(0xFF60AD5E);

  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static const Color warningColor = Color(0xFFF57C00);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      fontFamilyFallback: [
        GoogleFonts.notoSans().fontFamily!,
        GoogleFonts.notoSansTamil().fontFamily!,
        GoogleFonts.notoSansTelugu().fontFamily!,
        GoogleFonts.notoSansDevanagari().fontFamily!,
        GoogleFonts.notoSansBengali().fontFamily!,
        GoogleFonts.notoSansKannada().fontFamily!,
        GoogleFonts.notoSansMalayalam().fontFamily!,
      ],
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: errorColor,
      ),

      // Typography - using Noto Sans for full multilingual support
      textTheme: GoogleFonts.notoSansTextTheme(TextTheme(
        displayLarge: GoogleFonts.notoSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.notoSans(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.notoSans(fontSize: 14, color: textSecondary),
      )),

      // Elevated button theme - government style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(8),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
