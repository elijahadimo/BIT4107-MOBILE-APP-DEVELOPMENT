import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color orange = Color(0xFFFF8C00);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: orange,
        primary: orange,
        secondary: skyBlue,
        surface: white,
      ),
      scaffoldBackgroundColor: skyBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: orange,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: const TextStyle(fontSize: 16, color: Colors.black),
        bodyMedium: const TextStyle(fontSize: 14, color: Colors.black),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: orange, width: 2),
        ),
      ),
    );
  }
}
