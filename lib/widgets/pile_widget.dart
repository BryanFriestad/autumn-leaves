import 'package:flutter/material.dart';
import '../models/pile.dart';
import '../models/card.dart';
import 'card_widget.dart';

class PileWidget extends StatelessWidget {
  final Pile pile;
  final double cardWidth;
  final double cardHeight;
  final double cardSpacing;
  final int? selectedIndex;
  final Function(int)? onCardTap;

  const PileWidget({
    super.key,
    required this.pile,
    this.cardWidth = 60,
    this.cardHeight = 90,
    this.cardSpacing = 20,
    this.selectedIndex,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pile.isEmpty) {
      return _buildEmptyPile();
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight + (pile.cards.length - 1) * cardSpacing,
      child: Stack(
        children: pile.cards.asMap().entries.map((entry) {
          final index = entry.key;
          final card = entry.value;
          final topOffset = index * cardSpacing;

          return Positioned(
            top: topOffset,
            child: CardWidget(
              card: card,
              width: cardWidth,
              height: cardHeight,
              isSelected: selectedIndex == index,
              onTap: card.faceUp && onCardTap != null
                  ? () => onCardTap!(index)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyPile() {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green[900]!,
          width: 2,
        ),
      ),
    );
  }
}
