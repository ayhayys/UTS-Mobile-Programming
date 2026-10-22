import 'package:flutter/material.dart';

class AppColors {
  static const Color lime = Color(0xFFC8F135);
  static const Color limeDark = Color(0xFF9CC20F);
  static const Color accent = Color(0xFF2F63E0);
  static const Color ink = Color(0xFF111111);
  static const Color darkCard = Color(0xFF1B1B1B);
  static const Color background = Color(0xFFF3F4F0);
  static const Color surface = Colors.white;
  static const Color muted = Color(0xFF8A8D86);
  static const Color border = Color(0xFFE6E8E1);
  static const Color live = Color(0xFFE5484D);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lime,
        brightness: Brightness.light,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
