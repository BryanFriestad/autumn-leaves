import 'package:flutter/material.dart';
import '../models/card.dart' as game_models;
import '../theme/app_theme.dart';

class CardWidget extends StatelessWidget {
  final game_models.Card card;
  final double width;
  final double height;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 60,
    this.height = 90,
    this.isSelected = false,
    this.isDimmed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = card.faceUp
        ? (isDimmed ? AppColors.cardBackgroundDimmed : AppColors.cardBackground)
        : AppColors.cardBack;

    final hasGradient = card.faceUp && !isDimmed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: hasGradient ? null : cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.cardBorderSelected : AppColors.cardBorder,
            width: isSelected ? 3 : 1,
          ),
          gradient: hasGradient ? AppColors.cardGradient : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: card.faceUp
            ? _buildFaceUpCard()
            : _buildFaceDownCard(),
      ),
    );
  }

  Widget _buildFaceUpCard() {
    final textColor = card.isRed() ? AppColors.cardTextRed : AppColors.cardTextBlack;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                card.rankSymbol,
                style: TextStyle(
                  color: textColor,
                  fontSize: width * 0.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                card.suitSymbol,
                style: TextStyle(
                  color: textColor,
                  fontSize: width * 0.2,
                ),
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: Text(
              card.suitSymbol,
              style: TextStyle(
                color: textColor,
                fontSize: width * 0.4,
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          Transform.rotate(
            angle: 3.14159,
            child: Row(
              children: [
                Text(
                  card.rankSymbol,
                  style: TextStyle(
                    color: textColor,
                    fontSize: width * 0.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  card.suitSymbol,
                  style: TextStyle(
                    color: textColor,
                    fontSize: width * 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceDownCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBackBorder, width: 2),
        gradient: AppColors.cardBackGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              color: AppColors.cardBackIcon,
              size: width * 0.35,
            ),
            SizedBox(height: width * 0.05),
            Icon(
              Icons.eco,
              color: AppColors.cardBackIcon.withOpacity(0.6),
              size: width * 0.25,
            ),
          ],
        ),
      ),
    );
  }
}
