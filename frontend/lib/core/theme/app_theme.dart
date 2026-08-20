import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(
    0xFF059669,
  );
  static const Color backgroundColor = Color(
    0xFFF8FAFC,
  );
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color foregroundColor = Color(
    0xFF0F172A,
  );
  static const Color mutedForegroundColor = Color(
    0xFF64748B,
  );
  static const Color borderColor = Color(
    0xFFE2E8F0,
  );
  static const Color secondaryColor = Color(
    0xFFF1F5F9,
  );
  static const Color errorColor = Color(0xFFE11D48);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: foregroundColor,
        surface: cardColor,
        onSurface: foregroundColor,
        error: errorColor,
        onError: Colors.white,
        outline: borderColor,
      ),

      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        shape: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
        titleTextStyle: TextStyle(
          color: foregroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shadowColor: foregroundColor.withValues(alpha: 0.05),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: borderColor, width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: const TextStyle(color: mutedForegroundColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: mutedForegroundColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
      ),
    );
  }
}
