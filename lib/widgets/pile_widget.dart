import 'package:flutter/material.dart';
import '../models/pile.dart';
import '../logic/natural_placement.dart';
import 'card_widget.dart' as card_widget;
import '../theme/app_theme.dart';

class PileWidget extends StatelessWidget {
  final Pile pile;
  final double cardWidth;
  final double cardHeight;
  final double cardSpacing;
  final int? selectedIndex;
  final Function(int)? onCardTap;
  final Set<int>? dimmedCardIndices;
  final bool naturalPlacement;

  const PileWidget({
    super.key,
    required this.pile,
    this.cardWidth = 60,
    this.cardHeight = 90,
    this.cardSpacing = 20,
    this.selectedIndex,
    this.onCardTap,
    this.dimmedCardIndices,
    this.naturalPlacement = false,
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
        // Jittered cards may paint slightly outside the pile bounds.
        clipBehavior: naturalPlacement ? Clip.none : Clip.hardEdge,
        children: _buildCards(cardWidth, cardHeight, cardSpacing),
      ),
    );
  }

  List<Widget> _buildCards(double cardWidth, double cardHeight, double cardSpacing) {
    final children = <Widget>[];
    var previousDy = 0.0;

    for (var index = 0; index < pile.cards.length; index++) {
      final card = pile.cards[index];
      final topOffset = index * cardSpacing;

      Widget cardWidget = card_widget.CardWidget(
        card: card,
        width: cardWidth,
        height: cardHeight,
        isSelected: selectedIndex == index,
        isDimmed: dimmedCardIndices?.contains(index) ?? false,
        onTap: card.faceUp && onCardTap != null ? () => onCardTap!(index) : null,
      );

      if (naturalPlacement) {
        final placement = NaturalPlacement.forCard(
          card,
          cardWidth: cardWidth,
          cardSpacing: cardSpacing,
          previousDy: previousDy,
        );
        previousDy = placement.dy;
        cardWidget = Transform.translate(
          offset: Offset(placement.dx, placement.dy),
          child: Transform.rotate(
            angle: placement.rotation,
            alignment: Alignment.center,
            child: cardWidget,
          ),
        );
      }

      children.add(Positioned(top: topOffset, child: cardWidget));
    }

    return children;
  }

  Widget _buildEmptyPile() {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.emptyPileBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.emptyPileBorder,
          width: 2,
        ),
      ),
    );
  }
}
