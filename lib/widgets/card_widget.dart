import 'package:flutter/material.dart';
import '../models/card.dart' as game_models;

class CardWidget extends StatelessWidget {
  final game_models.Card card;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.width = 60,
    this.height = 90,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: card.faceUp ? Colors.white : Colors.blue[700],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.black,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
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
    final textColor = card.isRed() ? Colors.red : Colors.black;

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
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[900]!, width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.pattern,
          color: Colors.blue[400],
          size: width * 0.4,
        ),
      ),
    );
  }
}
