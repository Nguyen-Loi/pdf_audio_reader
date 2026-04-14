import 'package:flutter/material.dart';

/// App-wide color palette (dark-mode first, premium feel).
class AppColors {
  AppColors._();

  // --- Brand ---
  static const Color primary = Color(0xFF6C63FF);       // Indigo-violet
  static const Color primaryLight = Color(0xFF9C95FF);
  static const Color primaryDark = Color(0xFF3D35CC);
  static const Color accent = Color(0xFFFF6584);        // Coral accent

  // --- Background layers ---
  static const Color bgDark = Color(0xFF0F0F1A);
  static const Color bgSurface = Color(0xFF1A1A2E);
  static const Color bgCard = Color(0xFF22223B);
  static const Color bgCardHover = Color(0xFF2C2C4A);

  // --- Text ---
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFFAAAAAF);
  static const Color textDisabled = Color(0xFF55555A);

  // --- Reader highlight ---
  static const Color wordHighlight = Color(0xFF6C63FF);
  static const Color sentenceHighlight = Color(0x226C63FF);

  // --- Status ---
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3D35CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF22223B), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
