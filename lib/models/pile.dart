import 'card.dart';

class Pile {
  final List<Card> cards;

  Pile({List<Card>? cards}) : cards = cards ?? [];

  Pile copyWith({List<Card>? cards}) {
    return Pile(cards: cards ?? List.from(this.cards));
  }

  bool get isEmpty => cards.isEmpty;
  bool get isNotEmpty => cards.isNotEmpty;

  Card? get topCard => cards.isNotEmpty ? cards.last : null;

  Card? get topFaceUpCard {
    for (int i = cards.length - 1; i >= 0; i--) {
      if (cards[i].faceUp) {
        return cards[i];
      }
    }
    return null;
  }

  List<Card> get faceUpCards {
    return cards.where((card) => card.faceUp).toList();
  }

  void addCard(Card card) {
    cards.add(card);
  }

  void addCards(List<Card> newCards) {
    cards.addAll(newCards);
  }

  Card? removeTopCard() {
    if (cards.isEmpty) return null;
    return cards.removeLast();
  }

  List<Card> removeCards(int count) {
    if (count > cards.length) {
      count = cards.length;
    }
    final startIndex = cards.length - count;
    final removed = cards.sublist(startIndex);
    cards.removeRange(startIndex, cards.length);
    return removed;
  }

  void flipTopCard() {
    if (cards.isNotEmpty && !cards.last.faceUp) {
      cards.last = cards.last.copyWith(faceUp: true);
    }
  }

  bool hasFaceUpCards() {
    return cards.any((card) => card.faceUp);
  }

  @override
  String toString() {
    return cards.map((c) => c.toString()).join(' ');
  }
}
