import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Renkler
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF2E7D32);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color darkBg = Color(0xFF0A1628);
  static const Color cardDark = Color(0xFF132236);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFF81C784);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentGold,
      surface: cardDark,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.latoTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          color: accentGold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.lato(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: accentGold,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xFFF1F8E9),
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGold,
      surface: cardLight,
    ),
    textTheme: GoogleFonts.latoTextTheme(),
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryGreen,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Gradyanlar
  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF1B2A4A), Color(0xFF0D2137)],
  );

  static const LinearGradient dawnGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A237E), Color(0xFF311B92), Color(0xFF4A148C)],
  );

  static const LinearGradient morningGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1565C0), Color(0xFF0288D1), Color(0xFF29B6F6)],
  );

  static const LinearGradient noonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF90CAF9)],
  );

  static const LinearGradient afternoonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFFB74D)],
  );

  static const LinearGradient eveningGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A148C), Color(0xFF880E4F), Color(0xFFD81B60)],
  );

  static LinearGradient getGradientForHour(int hour) {
    if (hour >= 4 && hour < 6) return dawnGradient;
    if (hour >= 6 && hour < 12) return morningGradient;
    if (hour >= 12 && hour < 15) return noonGradient;
    if (hour >= 15 && hour < 18) return afternoonGradient;
    if (hour >= 18 && hour < 21) return eveningGradient;
    return nightGradient;
  }
}
