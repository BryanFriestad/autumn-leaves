import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color scaffoldBackground = Color(0xFF5D4037);
  static const Color appBarBackground = Color(0xFF3E2723);
  static const Color topBarBackground = Color(0xFF4E342E);
  static const Color cardBackground = Color(0xFFFFF8E1);
  static const Color cardBackgroundDimmed = Color(0xFFE0E0E0);
  static const Color cardBack = Color(0xFFE65100);
  static const Color emptyPileBackground = Color(0xFF5D4037);

  // Text colors
  static const Color appBarTitle = Color(0xFFFFB74D);
  static const Color appBarIcon = Color(0xFFFFB74D);
  static const Color primaryText = Color(0xFF3E2723);
  static const Color secondaryText = Color(0xFF8D6E63);
  static const Color cardTextRed = Color(0xFFBF360C);
  static const Color cardTextBlack = Color(0xFF3E2723);
  static const Color cardBackIcon = Color(0xFFFFF8E1);
  static const Color titleText = Color(0xFFFFB74D);
  static const Color subtitleText = Color(0xFFFFCC80);
  static const Color buttonText = Color(0xFF3E2723);
  static const Color white = Colors.white;
  static const Color dialogTitle = Color(0xFFE65100);
  static const Color dialogContent = Color(0xFF3E2723);
  static const Color dialogButton = Color(0xFFE65100);
  static const Color cardLabel = Color(0xFF3E2723);
  static const Color cardValue = Color(0xFFE65100);
  static const Color sectionTitle = Color(0xFFE65100);
  static const Color winStatus = Color(0xFF4CAF50);
  static const Color forfeitStatus = Color(0xFFFF9800);
  static const Color ruleTitle = Color(0xFFE65100);
  static const Color ruleContent = Color(0xFF3E2723);

  // Border colors
  static const Color cardBorder = Color(0xFF8D6E63);
  static const Color cardBorderSelected = Color(0xFFFF6F00);
  static const Color cardBackBorder = Color(0xFFBF360C);
  static const Color emptyPileBorder = Color(0xFF3E2723);

  // Gradient colors
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
  );

  static const LinearGradient cardBackGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
  );

  static const LinearGradient emptyPileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
  );

  // Button colors
  static const Color buttonBackground = Color(0xFFFFB74D);
  static const Color buttonForeground = Color(0xFF3E2723);

  // Icon colors
  static const Color iconAccent = Color(0xFFFFB74D);
  static const Color iconDelete = Color(0xFFE65100);

  // Progress indicator color
  static const Color progressIndicator = Color(0xFFFFB74D);
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
  static TextStyle cardRank(double width) => TextStyle(
        color: AppColors.cardTextRed,
        fontSize: width * 0.2,
        fontWeight: FontWeight.bold,
      );

  static TextStyle cardSuit(double width) => TextStyle(
        color: AppColors.cardTextRed,
        fontSize: width * 0.2,
      );

  static TextStyle cardCenterSuit(double width) => TextStyle(
        color: AppColors.cardTextRed,
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
    color: Color(0xFF2E7D32),
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
