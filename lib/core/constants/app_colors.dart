import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ============================================================
  // BASE THEME
  // ============================================================

  static const Color background = Color.fromARGB(255, 255, 222, 200);

  static const Color ivory = Color(0xFFFFF4D7);
  static const Color cream = Color(0xFFFFE8B8);
  static const Color paper = Color(0xFFFFF2CF);
  static const Color panel = Color(0xFFF7DFA7);
  static const Color panelLight = Color(0xFFFFF7E8);

  static const Color line = Color(0xFFC8783F);
  static const Color paperShadow = Color(0xFFD49A5F);

  // ============================================================
  // TEXT
  // ============================================================

  static const Color ink = Color(0xFF693419);
  static const Color muted = Color(0xFF9A643F);

  // ============================================================
  // BROWN / ORANGE
  // ============================================================

  static const Color spiceBrown = Color(0xFFB86836);
  static const Color darkBrown = Color(0xFF6B351A);
  static const Color terracotta = Color(0xFFE36A43);
  static const Color turmeric = Color(0xFFFFC94A);
  static const Color orange = Color(0xFFFF9D3D);

  static const Color chocolate = Color(0xFF5D2F17);
  static const Color softChocolate = Color(0xFF8D5A38);

  // ============================================================
  // GREEN
  // ============================================================

  static const Color leaf = Color(0xFF4E8D48);
  static const Color success = Color(0xFF2D9B48);

  static const Color buttonGreen = Color(0xFF66DA72);
  static const Color buttonGreenDark = Color(0xFF2D9B48);

  static const Color greenStart = Color(0xFF8AFF8A);
  static const Color greenEnd = Color(0xFF2ECC71);
  static const Color greenShadow = Color(0xFF27AE60);

  // ============================================================
  // PINK RIBBON
  // ============================================================

  static const Color ribbonPink = Color(0xFFFF82B7);
  static const Color ribbonPinkDark = Color(0xFFE65394);
  static const Color ribbonPinkLight = Color(0xFFFFC6DE);

  static const Color ribbonStart = ribbonPink;
  static const Color ribbonEnd = ribbonPinkDark;
  static const Color ribbonShadow = Color(0xFFC03A61);

  // ============================================================
  // BLUE / PURPLE / TEAL
  // ============================================================

  static const Color buttonBlue = Color(0xFF33BFF2);
  static const Color buttonBlueDark = Color(0xFF1687C2);

  static const Color blueStart = Color(0xFF74D7FF);
  static const Color blueEnd = Color(0xFF12A8E8);

  static const Color softViolet = Color(0xFF7567D9);
  static const Color purpleStart = Color(0xFFB388FF);
  static const Color purpleEnd = Color(0xFF7C4DFF);

  static const Color tealStart = Color(0xFF06D6A0);
  static const Color tealEnd = Color(0xFF00B894);

  // ============================================================
  // YELLOW / ORANGE BUTTON
  // ============================================================

  static const Color starYellow = Color(0xFFFFC94A);
  static const Color brightYellow = Color(0xFFFFF176);

  static const Color orangeStart = Color(0xFFFFD54F);
  static const Color orangeEnd = Color(0xFFFF8F00);
  static const Color orangeShadow = Color(0xFFB45309);

  // ============================================================
  // EXTRA OLD ALIASES
  // ============================================================

  static const Color white = Colors.white;
  static const Color danger = Color(0xFFD94A38);

  static const Color warmPeach = Color(0xFFFFD194);
  static const Color warmApricot = Color(0xFFFFB677);

  // ============================================================
  // GRADIENT LISTS
  // ============================================================

  static const List<Color> mainBackgroundGradient = [
    Color(0xFFFFD194),
    Color(0xFFFFB677),
    Color(0xFFC98553),
  ];

  static const List<Color> panelGradient = [
    Color(0xFFFFF4D7),
    Color(0xFFF7DFA7),
  ];

  static const List<Color> ribbonGradient = [
    ribbonPink,
    ribbonPinkDark,
  ];

  static const List<Color> greenGradient = [
    greenStart,
    greenEnd,
  ];

  static const List<Color> blueGradient = [
    blueStart,
    blueEnd,
  ];

  static const List<Color> purpleGradient = [
    purpleStart,
    purpleEnd,
  ];

  static const List<Color> orangeGradient = [
    orangeStart,
    orangeEnd,
  ];

  static const List<Color> tealGradient = [
    tealStart,
    tealEnd,
  ];
}