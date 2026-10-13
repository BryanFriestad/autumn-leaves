enum Suit {
  hearts,
  diamonds,
  clubs,
  spades,
}

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

class Card {
  final Suit suit;
  final Rank rank;
  bool faceUp;

  Card({
    required this.suit,
    required this.rank,
    this.faceUp = false,
  });

  int get value => rank.index;

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  String get rankSymbol {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
    }
  }

  bool isRed() {
    return suit == Suit.hearts || suit == Suit.diamonds;
  }

  Card copyWith({Suit? suit, Rank? rank, bool? faceUp}) {
    return Card(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
      faceUp: faceUp ?? this.faceUp,
    );
  }

  @override
  String toString() {
    return '${rankSymbol}${suitSymbol}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card &&
        other.suit == suit &&
        other.rank == rank &&
        other.faceUp == faceUp;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode ^ faceUp.hashCode;
}
