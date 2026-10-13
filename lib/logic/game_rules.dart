import '../models/card.dart';
import '../models/pile.dart';
import '../models/game_state.dart';

class GameRules {
  static bool canMoveCard(Card card, Pile targetPile) {
    if (targetPile.isEmpty) {
      return true;
    }

    final targetCard = targetPile.topCard;
    if (targetCard == null) return false;

    return card.suit == targetCard.suit && card.value < targetCard.value;
  }

  static bool canMoveCards(List<Card> cards, Pile targetPile) {
    if (cards.isEmpty) return false;

    final bottomCard = cards.first;
    return canMoveCard(bottomCard, targetPile);
  }

  static bool isValidRun(List<Card> cards) {
    if (cards.isEmpty) return false;
    if (cards.length == 1) return true;

    for (int i = 0; i < cards.length - 1; i++) {
      final current = cards[i];
      final next = cards[i + 1];

      if (current.suit != next.suit) return false;
      if (current.value != next.value + 1) return false;
    }

    return true;
  }

  static GameState moveCard(
    GameState state,
    int fromPileIndex,
    int toPileIndex,
  ) {
    final newPiles = List<Pile>.from(state.piles.map((p) => p.copyWith()));
    final fromPile = newPiles[fromPileIndex];
    final toPile = newPiles[toPileIndex];

    final card = fromPile.removeTopCard();
    if (card == null) return state;

    if (!canMoveCard(card, toPile)) {
      return state;
    }

    toPile.addCard(card);

    if (!fromPile.hasFaceUpCards()) {
      fromPile.flipTopCard();
    }

    return state.copyWith(
      piles: newPiles,
      moves: state.moves + 1,
    ).checkWinCondition();
  }

  static GameState moveCards(
    GameState state,
    int fromPileIndex,
    int toPileIndex,
    int cardCount,
  ) {
    final newPiles = List<Pile>.from(state.piles.map((p) => p.copyWith()));
    final fromPile = newPiles[fromPileIndex];
    final toPile = newPiles[toPileIndex];

    final cards = fromPile.removeCards(cardCount);
    if (cards.isEmpty) return state;

    if (!isValidRun(cards)) return state;
    if (!canMoveCards(cards, toPile)) return state;

    toPile.addCards(cards);

    if (!fromPile.hasFaceUpCards()) {
      fromPile.flipTopCard();
    }

    return state.copyWith(
      piles: newPiles,
      moves: state.moves + 1,
    ).checkWinCondition();
  }

  static bool canAutoMoveToFoundation(Card card, GameState state) {
    for (final foundation in state.foundations) {
      if (foundation.isEmpty) {
        return card.rank == Rank.king;
      }

      final topCard = foundation.topCard;
      if (topCard != null &&
          topCard.suit == card.suit &&
          topCard.value == card.value + 1) {
        return true;
      }
    }
    return false;
  }

  static GameState autoMoveToFoundation(
    GameState state,
    int pileIndex,
    int cardIndex,
  ) {
    final pile = state.piles[pileIndex];
    if (cardIndex >= pile.cards.length) return state;

    final card = pile.cards[cardIndex];
    if (!card.faceUp) return state;

    if (!canAutoMoveToFoundation(card, state)) return state;

    final newPiles = List<Pile>.from(state.piles.map((p) => p.copyWith()));
    final newFoundations = List<Pile>.from(state.foundations.map((f) => f.copyWith()));

    for (int i = 0; i < newFoundations.length; i++) {
      final foundation = newFoundations[i];
      if (foundation.isEmpty && card.rank == Rank.king) {
        foundation.addCard(card);
        newPiles[pileIndex].cards.removeAt(cardIndex);
        break;
      } else {
        final topCard = foundation.topCard;
        if (topCard != null &&
            topCard.suit == card.suit &&
            topCard.value == card.value + 1) {
          foundation.addCard(card);
          newPiles[pileIndex].cards.removeAt(cardIndex);
          break;
        }
      }
    }

    if (!newPiles[pileIndex].hasFaceUpCards()) {
      newPiles[pileIndex].flipTopCard();
    }

    return state.copyWith(
      piles: newPiles,
      foundations: newFoundations,
      moves: state.moves + 1,
    ).checkWinCondition();
  }

  static List<Card> getMovableCards(Pile pile) {
    final movable = <Card>[];
    final faceUpCards = pile.faceUpCards;

    if (faceUpCards.isEmpty) return movable;

    movable.add(faceUpCards.last);

    for (int i = faceUpCards.length - 2; i >= 0; i--) {
      final current = faceUpCards[i];
      final next = faceUpCards[i + 1];

      if (current.suit == next.suit && current.value == next.value + 1) {
        movable.insert(0, current);
      } else {
        break;
      }
    }

    return movable;
  }
}
