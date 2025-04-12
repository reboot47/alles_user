import 'package:flutter/material.dart';

/// Color constants for the Alles app
class AllesColors {
  // Main colors
  static const Color babyPink = Color(0xFFFAD6E8);
  static const Color lavender = Color(0xFFCDB4DB);
  static const Color rosePink = Color(0xFFF8A1C4);
  static const Color navyBlue = Color(0xFF2E2A5E);
  static const Color grayishLavender = Color(0xFF8675A9);
  static const Color milkyWhite = Color(0xFFFFF7FA);
  static const Color pearlGold = Color(0xFFE6D3B3);
  static const Color fairyBlue = Color(0xFFD1E0F3);

  // Gradient colors for backgrounds
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      milkyWhite,
      babyPink,
      fairyBlue,
    ],
    stops: [0.0, 0.7, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      babyPink,
      lavender,
    ],
  );

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    color: navyBlue,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: grayishLavender,
    fontSize: 16,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: milkyWhite,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

/// App-wide constants
class AllesConstants {
  static const String appName = 'Alles';
  static const String appTagline = '占いとの出会いは最高です';  // "Make your encounter with fortune-telling more beautiful"
  static const Duration splashDuration = Duration(seconds: 3);
}
