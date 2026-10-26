import 'package:flutter/material.dart';

// Color Palette - Base colors used throughout the app
class _Palette {
  // Brown shades
  static const Color brownDark = Color(0xFF3E2723);
  static const Color brownMedium = Color(0xFF5D4037);
  static const Color brownLight = Color(0xFF4E342E);
  static const Color brownTan = Color(0xFF8D6E63);

  // Orange shades
  static const Color orangeDark = Color(0xFFE65100);
  static const Color orangeMedium = Color(0xFFBF360C);
  static const Color orangeLight = Color(0xFFFFB74D);
  static const Color orangeAccent = Color(0xFFFF6F00);
  static const Color orangePale = Color(0xFFFFCC80);

  // Cream shades
  static const Color cream = Color(0xFFFFF8E1);
  static const Color creamLight = Color(0xFFFFECB3);
  static const Color grayLight = Color(0xFFE0E0E0);

  // Status colors
  static const Color green = Color(0xFF4CAF50);
  static const Color greenDark = Color(0xFF2E7D32);
  static const Color amber = Color(0xFFFF9800);

  // System colors
  static const Color white = Colors.white;
}

class AppColors {
  // Background colors
  static const Color scaffoldBackground = _Palette.brownMedium;
  static const Color appBarBackground = _Palette.brownDark;
  static const Color topBarBackground = _Palette.brownLight;
  static const Color cardBackground = _Palette.cream;
  static const Color cardBackgroundDimmed = _Palette.grayLight;
  static const Color cardBack = _Palette.orangeDark;
  static const Color emptyPileBackground = _Palette.brownMedium;

  // Text colors
  static const Color appBarTitle = _Palette.orangeLight;
  static const Color appBarIcon = _Palette.orangeLight;
  static const Color primaryText = _Palette.brownDark;
  static const Color secondaryText = _Palette.brownTan;
  static const Color cardTextRed = _Palette.orangeMedium;
  static const Color cardTextBlack = _Palette.brownDark;
  static const Color cardBackIcon = _Palette.cream;
  static const Color titleText = _Palette.orangeLight;
  static const Color subtitleText = _Palette.orangePale;
  static const Color buttonText = _Palette.brownDark;
  static const Color white = _Palette.white;
  static const Color dialogTitle = _Palette.orangeDark;
  static const Color dialogContent = _Palette.brownDark;
  static const Color dialogButton = _Palette.orangeDark;
  static const Color cardLabel = _Palette.brownDark;
  static const Color cardValue = _Palette.orangeDark;
  static const Color sectionTitle = _Palette.orangeDark;
  static const Color winStatus = _Palette.green;
  static const Color forfeitStatus = _Palette.amber;
  static const Color ruleTitle = _Palette.orangeDark;
  static const Color ruleContent = _Palette.brownDark;

  // Border colors
  static const Color cardBorder = _Palette.brownTan;
  static const Color cardBorderSelected = _Palette.orangeAccent;
  static const Color cardBackBorder = _Palette.orangeMedium;
  static const Color emptyPileBorder = _Palette.brownDark;

  // Gradient colors
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.cream, _Palette.creamLight],
  );

  static const LinearGradient cardBackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.orangeLight, _Palette.orangeDark],
  );

  static const LinearGradient emptyPileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.brownMedium, _Palette.brownDark],
  );

  // Button colors
  static const Color buttonBackground = _Palette.orangeLight;
  static const Color buttonForeground = _Palette.brownDark;

  // Icon colors
  static const Color iconAccent = _Palette.orangeLight;
  static const Color iconDelete = _Palette.orangeDark;

  // Progress indicator color
  static const Color progressIndicator = _Palette.orangeLight;
}

class AppTextStyles {
  // AppBar title
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.appBarTitle,
  );

  // Top bar stats
  static const TextStyle topBarStats = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  // Landing screen title
  static const TextStyle landingTitle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.titleText,
  );

  static const TextStyle landingSubtitle = TextStyle(
    fontSize: 32,
    color: AppColors.subtitleText,
  );

  // Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Card text
  static TextStyle cardRank(double width, {bool isRed = true}) => TextStyle(
        color: isRed ? AppColors.cardTextRed : AppColors.cardTextBlack,
        fontSize: width * 0.2,
        fontWeight: FontWeight.bold,
      );

  static TextStyle cardSuit(double width, {bool isRed = true}) => TextStyle(
        color: isRed ? AppColors.cardTextRed : AppColors.cardTextBlack,
        fontSize: width * 0.2,
      );

  static TextStyle cardCenterSuit(double width, {bool isRed = true}) => TextStyle(
        color: isRed ? AppColors.cardTextRed : AppColors.cardTextBlack,
        fontSize: width * 0.4,
      );

  // Stats screen
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.sectionTitle,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 16,
    color: AppColors.cardLabel,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.cardValue,
  );

  static const TextStyle gameStatus = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.cardLabel,
  );

  static const TextStyle gameDate = TextStyle(
    fontSize: 12,
    color: AppColors.secondaryText,
  );

  static const TextStyle bestGameLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: _Palette.greenDark,
  );

  // Dialog styles
  static const TextStyle dialogTitle = TextStyle(
    color: AppColors.dialogTitle,
  );

  static const TextStyle dialogContent = TextStyle(
    color: AppColors.dialogContent,
  );

  static const TextStyle dialogButton = TextStyle(
    color: AppColors.dialogButton,
  );

  // How to play screen
  static const TextStyle ruleTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.ruleTitle,
  );

  static const TextStyle ruleContent = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: AppColors.ruleContent,
  );
}

class AppButtonStyles {
  static ButtonStyle elevatedButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonBackground,
    foregroundColor: AppColors.buttonForeground,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

class AppIconThemes {
  static const IconThemeData appBar = IconThemeData(color: AppColors.appBarIcon);
}
