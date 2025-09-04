import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFFA29BFE);
  static const Color accentColor = Color(0xFFFF7675);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF00B894);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color textPrimaryColor = Color(0xFF2D3436);
  static const Color textSecondaryColor = Color(0xFF636E72);
  static const Color borderColor = Color(0xFFDDD6FE);
  static const Color dividerColor = Color(0xFFE9ECEF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Text Styles
  static TextStyle get headlineLarge => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static TextStyle get headlineMedium => GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static TextStyle get headlineSmall => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );
  
  static TextStyle get titleLarge => GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );
  
  static TextStyle get titleMedium => GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );
  
  static TextStyle get titleSmall => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );
  
  static TextStyle get bodySmall => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );
  
  static TextStyle get labelLarge => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );
  
  static TextStyle get labelMedium => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );
  
  static TextStyle get labelSmall => GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onError: Colors.white,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: titleLarge,
        iconTheme: const IconThemeData(color: textPrimaryColor),
      ),
      
      // Card Theme - removed for MVP compatibility
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge.copyWith(color: Colors.white),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: labelLarge.copyWith(color: primaryColor),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: labelLarge.copyWith(color: primaryColor),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: bodyMedium.copyWith(color: textSecondaryColor),
        labelStyle: labelMedium,
        errorStyle: bodySmall.copyWith(color: errorColor),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
    );
  }
  
  // Dark Theme (для будущего использования)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      // Здесь можно настроить темную тему
    );
  }
}
