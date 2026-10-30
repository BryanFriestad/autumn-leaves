import 'package:flutter/material.dart';

// Color Palette - Base colors used throughout the app
class _Palette {
  // Core palette
  static const Color orange = Color(0xFFED8738);         // Primary background
  static const Color orangeDark = Color(0xFFC76A20);     // Darker orange for app bar

  static const Color green = Color(0xFF325E3C);          // Success states
  static const Color greenDark = Color(0xFF22402A);      // Darker green

  static const Color blue = Color(0xFF6F8B93);           // Blue accents

  static const Color tan = Color(0xFFB6A481);            // Secondary elements
  static const Color tanDark = Color(0xFF8F7F5F);         // Darker tan

  static const Color red = Color(0xFFBE4836);            // Accent red

  static const Color yellow = Color(0xFFE9B95C);          // Highlights
  static const Color yellowDark = Color(0xFFC49945);      // Darker yellow

  static const Color brown = Color(0xFF854D27);          // Text and borders
  static const Color brownDark = Color(0xFF5C3519);      // Darker brown

  static const Color white = Color(0xFFF0E6DD);          // Card backgrounds
}

class AppColors {
  // Background colors
  static const Color scaffoldBackground = _Palette.orange;
  static const Color appBarBackground = _Palette.orangeDark;
  static const Color topBarBackground = _Palette.blue;
  static const Color cardBackground = _Palette.white;
  static const Color cardBackgroundDimmed = _Palette.tan;
  static const Color cardBack = _Palette.red;
  static const Color emptyPileBackground = _Palette.orange;

  // Text colors
  static const Color appBarTitle = _Palette.white;
  static const Color appBarIcon = _Palette.yellow;
  static const Color primaryText = _Palette.brown;
  static const Color secondaryText = _Palette.blue;
  static const Color cardTextRed = _Palette.red;
  static const Color cardTextBlack = _Palette.brown;
  static const Color cardBackIcon = _Palette.yellow;
  static const Color titleText = _Palette.white;
  static const Color subtitleText = _Palette.yellow;
  static const Color buttonText = _Palette.brown;
  static const Color white = _Palette.white;
  static const Color dialogTitle = _Palette.blue;
  static const Color dialogContent = _Palette.brown;
  static const Color dialogButton = _Palette.blue;
  static const Color cardLabel = _Palette.brown;
  static const Color cardValue = _Palette.green;
  static const Color sectionTitle = _Palette.blue;
  static const Color winStatus = _Palette.green;
  static const Color forfeitStatus = _Palette.yellow;
  static const Color ruleTitle = _Palette.blue;
  static const Color ruleContent = _Palette.brown;

  // Border colors
  static const Color cardBorder = _Palette.tan;
  static const Color cardBorderSelected = _Palette.yellow;
  static const Color cardBackBorder = _Palette.brown;
  static const Color emptyPileBorder = _Palette.orangeDark;

  // Gradient colors
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.white, _Palette.tan],
  );

  static const LinearGradient cardBackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.yellow, _Palette.red],
  );

  static const LinearGradient emptyPileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_Palette.orange, _Palette.blue],
  );

  // Button colors
  static const Color buttonBackground = _Palette.yellow;
  static const Color buttonForeground = _Palette.brown;

  // Icon colors
  static const Color iconAccent = _Palette.blue;
  static const Color iconDelete = _Palette.red;

  // Progress indicator color
  static const Color progressIndicator = _Palette.yellow;

  // Additional colors for specific uses
  static const Color yellow = _Palette.yellow;
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
    color: _Palette.white,
  );

  static const TextStyle landingSubtitle = TextStyle(
    fontSize: 32,
    color: _Palette.blue,
  );

  // Button text
  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // Card text
  static TextStyle cardRank(double width, {bool isRed = true}) => TextStyle(
        color: isRed ? _Palette.red : _Palette.brownDark,
        fontSize: width * 0.2,
        fontWeight: FontWeight.bold,
      );

  static TextStyle cardSuit(double width, {bool isRed = true}) => TextStyle(
        color: isRed ? _Palette.red : _Palette.brownDark,
        fontSize: width * 0.2,
      );

  static TextStyle cardCenterSuit(double width, {bool isRed = true}) => TextStyle(
        color: isRed ? _Palette.red : _Palette.brownDark,
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
    color: _Palette.green,
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
