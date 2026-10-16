import 'card.dart';
import 'pile.dart';

class GameState {
  final List<Pile> piles;
  final List<Card> stock;
  final bool isWon;
  final bool isLost;
  final int moves;

  GameState({
    required this.piles,
    required this.stock,
    this.isWon = false,
    this.isLost = false,
    this.moves = 0,
  });

  factory GameState.initial() {
    final deck = _createDeck();
    deck.shuffle();

    final piles = List.generate(6, (_) => Pile());
    final stock = <Card>[];

    final cardsPerPile = [4, 4, 3, 3, 4, 4];
    int cardIndex = 0;

    for (int pileIndex = 0; pileIndex < 6; pileIndex++) {
      final cardCount = cardsPerPile[pileIndex];
      for (int i = 0; i < cardCount; i++) {
        if (cardIndex < deck.length) {
          final isTopCard = i == cardCount - 1;
          piles[pileIndex].addCard(deck[cardIndex].copyWith(faceUp: isTopCard));
          cardIndex++;
        }
      }
    }

    while (cardIndex < deck.length) {
      stock.add(deck[cardIndex]);
      cardIndex++;
    }

    return GameState(
      piles: piles,
      stock: stock,
    );
  }

  factory GameState.testWin() {
    final piles = List.generate(6, (_) => Pile());
    final stock = <Card>[];

    final suits = Suit.values;

    for (int i = 0; i < 4; i++) {
      final suit = suits[i];
      for (int rank = 12; rank > 0; rank--) {
        piles[i].addCard(Card(suit: suit, rank: Rank.values[rank], faceUp: true));
      }
    }

    piles[4].addCard(Card(suit: suits[0], rank: Rank.ace, faceUp: true));
    piles[4].addCard(Card(suit: suits[2], rank: Rank.ace, faceUp: true));
    piles[5].addCard(Card(suit: suits[1], rank: Rank.ace, faceUp: true));
    piles[5].addCard(Card(suit: suits[3], rank: Rank.ace, faceUp: true));

    return GameState(
      piles: piles,
      stock: stock,
    );
  }

  static List<Card> _createDeck() {
    final deck = <Card>[];
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        deck.add(Card(suit: suit, rank: rank));
      }
    }
    return deck;
  }

  GameState copyWith({
    List<Pile>? piles,
    List<Card>? stock,
    bool? isWon,
    bool? isLost,
    int? moves,
  }) {
    return GameState(
      piles: piles ?? List.from(this.piles.map((p) => p.copyWith())),
      stock: stock ?? List.from(this.stock),
      isWon: isWon ?? this.isWon,
      isLost: isLost ?? this.isLost,
      moves: moves ?? this.moves,
    );
  }

  bool canDeal() {
    return stock.length >= 6;
  }

  GameState deal() {
    if (!canDeal()) return this;

    final newPiles = List<Pile>.from(piles.map((p) => p.copyWith()));
    final newStock = List<Card>.from(stock);

    for (int i = 0; i < 6; i++) {
      newPiles[i].addCard(newStock.removeLast().copyWith(faceUp: true));
    }

    return copyWith(
      piles: newPiles,
      stock: newStock,
      moves: moves + 1,
    ).checkWinCondition();
  }

  GameState checkWinCondition() {
    if (stock.isNotEmpty) {
      return this;
    }

    final totalCardsInPiles = piles.fold(0, (sum, pile) => sum + pile.cards.length);
    if (totalCardsInPiles != 52) {
      return this;
    }

    final completedSuits = <Suit>{};

    for (final pile in piles) {
      if (pile.cards.length == 13) {
        final suit = pile.cards.first.suit;
        bool isCompleteRun = true;

        for (int i = 0; i < 13; i++) {
          if (pile.cards[i].suit != suit) {
            isCompleteRun = false;
            break;
          }
          if (pile.cards[i].rank.index != 12 - i) {
            isCompleteRun = false;
            break;
          }
        }

        if (isCompleteRun) {
          completedSuits.add(suit);
        }
      }
    }

    if (completedSuits.length == 4) {
      return copyWith(isWon: true);
    }

    return this;
  }

  int get score {
    int score = 0;
    for (final pile in piles) {
      for (int i = 0; i < pile.cards.length; i++) {
        final card = pile.cards[i];
        if (!card.faceUp) continue;
        
        // Add a point for sequential cards above and below
        if (i > 0) {
          final previousCard = pile.cards[i - 1];
          if (previousCard.faceUp && previousCard.suit == card.suit && previousCard.rank.index == card.rank.index + 1) {
            score++;
          }
        }
        if (i < pile.cards.length - 1) {
          final nextCard = pile.cards[i + 1];
          if (nextCard.faceUp && nextCard.suit == card.suit && nextCard.rank.index == card.rank.index - 1) {
            score++;
          }
        }
      }
    }
    return score;
  }
}
