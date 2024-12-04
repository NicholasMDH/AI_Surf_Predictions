import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Background colors
      scaffoldBackgroundColor: const Color(0xFF1A1C1E),

      // Primary colors - warm orange/copper tones
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE68F50), // Warm orange
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF2D2420), // Dark warm container

        secondary: Color(0xFFBB7F5B), // Muted copper
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF252322),

        surface: Color(0xFF1E2023), // Slightly lighter than background
        surfaceContainerHighest: Color(0xFF252628),
        onSurface: Colors.white,
        error: Color(0xFFE57373),

        // Custom accent colors
        tertiary: Color(0xFFD4A373), // Light copper
      ),

      // Card theme
      cardTheme: CardTheme(
        color: const Color(0xFF1E2023),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1C1E),
        elevation: 0,
        centerTitle: false,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252628),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE68F50),
            width: 1,
          ),
        ),
      ),

      // Text themes
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white70,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFE68F50),
        linearTrackColor: Color(0xFF252628),
      ),
    );
  }
}
