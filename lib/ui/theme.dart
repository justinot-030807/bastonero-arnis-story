// lib/ui/theme.dart
// Bright, cozy retro UI theme conforming to Section 13 specification.

import 'package:flutter/material.dart';

class RetroColors {
  // Primary Blue Panel Gradient
  static const Color panelTop = Color(0xFF3E8BEA);
  static const Color panelBottom = Color(0xFF1B4DB0);

  // Background and borders
  static const Color darkOutline = Color(0xFF1A1C2C);
  static const Color deepBackground = Color(0xFF0F172A);
  static const Color panelBevel = Color(0xFF60A5FA);

  // Text and Highlights
  static const Color textCream = Color(0xFFFFF4D6);
  static const Color textDark = Color(0xFF1A1C2C);
  static const Color textMuted = Color(0xFF94A3B8);

  // Accents
  static const Color gold = Color(0xFFFFC83D);
  static const Color red = Color(0xFFE63946);
  static const Color green = Color(0xFF4CAF50);
  static const Color cyan = Color(0xFF38BDF8);
}

class RetroTheme {
  static const String fontPixel = 'PressStart2P';
  static const String fontSilkscreen = 'Silkscreen';

  static TextStyle pixelStyle({
    double fontSize = 10,
    Color color = RetroColors.textCream,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0.5,
  }) {
    return TextStyle(
      fontFamily: fontPixel,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  static TextStyle silkStyle({
    double fontSize = 11,
    Color color = RetroColors.textCream,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0.5,
  }) {
    return TextStyle(
      fontFamily: fontSilkscreen,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  static BoxDecoration panelDecoration({
    Color borderColor = RetroColors.darkOutline,
    Color bevelColor = RetroColors.panelBevel,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [RetroColors.panelTop, RetroColors.panelBottom],
      ),
      border: Border.all(color: borderColor, width: 2.5),
      boxShadow: const [
        BoxShadow(
          color: RetroColors.darkOutline,
          offset: Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  static BoxDecoration creamCardDecoration() {
    return BoxDecoration(
      color: RetroColors.textCream,
      border: Border.all(color: RetroColors.darkOutline, width: 2.0),
      boxShadow: const [
        BoxShadow(
          color: RetroColors.darkOutline,
          offset: Offset(1.5, 1.5),
          blurRadius: 0,
        ),
      ],
    );
  }
}
