import '../models/card.dart';
import '../models/pile.dart';
import '../models/game_state.dart';
import '../models/game_history.dart';

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

  static List<Card> getMovableCards(Pile pile, List<Pile> allPiles) {
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

    // Filter out cards/runs that have no valid destination
    final filteredMovable = <Card>[];
    for (int i = 0; i < movable.length; i++) {
      final cardsToCheck = movable.sublist(i);
      if (_hasValidDestination(cardsToCheck, pile, allPiles)) {
        filteredMovable.addAll(cardsToCheck);
        break;
      }
    }

    return filteredMovable;
  }

  static bool _hasValidDestination(List<Card> cards, Pile fromPile, List<Pile> allPiles) {
    for (int i = 0; i < allPiles.length; i++) {
      if (allPiles[i] == fromPile) continue;
      if (canMoveCards(cards, allPiles[i])) {
        return true;
      }
    }
    return false;
  }

  static GameState applyMoveLog(GameState initialState, List<GameMove> moveLog) {
    var state = initialState;
    for (final move in moveLog) {
      if (move.type == 'deal') {
        state = state.deal();
      } else if (move.type == 'moveCard') {
        state = moveCard(state, move.fromPileIndex, move.toPileIndex);
      } else if (move.type == 'moveCards') {
        state = moveCards(state, move.fromPileIndex, move.toPileIndex, move.cardCount);
      }
    }
    return state;
  }
}
