/// deck_shuffle: uniform, reproducible, identifiable shuffles of a 52-card deck.
///
/// Every ordering of the deck corresponds to exactly one integer ID in
/// [0, 52! - 1] (a Lehmer code / factorial number system). Shuffling means
/// drawing a uniformly random ID; the ID can be stored, shared, or typed back
/// in to recreate the exact same deck.
///
/// Public API
/// ----------
///   getRandomShuffle()      -> (deck, id)
///   getShuffleById(id)      -> deck
///   getIdForDeck(deck)      -> id            (inverse; handy for saved games)
///   parseShuffleId(string)  -> BigInt        (validates user-typed IDs)
///
/// IMPORTANT: ID 0 is the deck in [canonicalDeck] order, and every other ID is
/// defined relative to that order. Never change [ranks] / [suits] once IDs
/// have been saved anywhere, or old IDs will map to different decks.
///
/// IDs are [BigInt] because 52! (~8.07e67) overflows a 64-bit int, and on
/// Flutter web `int` is a double. Store IDs as `id.toString()`.

import 'dart:math';
import '../models/card.dart';

/// Fixed reference order. Card strings look like "A♠", "10♥", "K♣".
/// Uses the same order as defined in card.dart (Suit.values, Rank.values).
final List<String> canonicalDeck = List.unmodifiable([
  for (final suit in Suit.values)
    for (final rank in Rank.values) '${_rankToString(rank)}${_suitToString(suit)}',
]);

String _rankToString(Rank rank) {
  switch (rank) {
    case Rank.ace: return 'A';
    case Rank.two: return '2';
    case Rank.three: return '3';
    case Rank.four: return '4';
    case Rank.five: return '5';
    case Rank.six: return '6';
    case Rank.seven: return '7';
    case Rank.eight: return '8';
    case Rank.nine: return '9';
    case Rank.ten: return '10';
    case Rank.jack: return 'J';
    case Rank.queen: return 'Q';
    case Rank.king: return 'K';
  }
}

String _suitToString(Suit suit) {
  switch (suit) {
    case Suit.hearts: return '♥';
    case Suit.diamonds: return '♦';
    case Suit.clubs: return '♣';
    case Suit.spades: return '♠';
  }
}

/// Converts a Card to its string representation for deck_shuffle.
String cardToString(Card card) {
  return '${_rankToString(card.rank)}${_suitToString(card.suit)}';
}

/// Converts a string representation from deck_shuffle to a Card.
Card stringToCard(String cardString) {
  final suitSymbol = cardString.substring(cardString.length - 1);
  final rankSymbol = cardString.substring(0, cardString.length - 1);

  Suit suit;
  switch (suitSymbol) {
    case '♥': suit = Suit.hearts; break;
    case '♦': suit = Suit.diamonds; break;
    case '♣': suit = Suit.clubs; break;
    case '♠': suit = Suit.spades; break;
    default: throw ArgumentError('Invalid suit symbol: $suitSymbol');
  }

  Rank rank;
  switch (rankSymbol) {
    case 'A': rank = Rank.ace; break;
    case '2': rank = Rank.two; break;
    case '3': rank = Rank.three; break;
    case '4': rank = Rank.four; break;
    case '5': rank = Rank.five; break;
    case '6': rank = Rank.six; break;
    case '7': rank = Rank.seven; break;
    case '8': rank = Rank.eight; break;
    case '9': rank = Rank.nine; break;
    case '10': rank = Rank.ten; break;
    case 'J': rank = Rank.jack; break;
    case 'Q': rank = Rank.queen; break;
    case 'K': rank = Rank.king; break;
    default: throw ArgumentError('Invalid rank symbol: $rankSymbol');
  }

  return Card(suit: suit, rank: rank);
}

/// Converts a list of Card objects to a list of string representations.
List<String> cardsToStrings(List<Card> cards) {
  return cards.map(cardToString).toList();
}

/// Converts a list of string representations to a list of Card objects.
List<Card> stringsToCards(List<String> cardStrings) {
  return cardStrings.map(stringToCard).toList();
}

final int _n = canonicalDeck.length; // 52

final List<BigInt> _factorials = () {
  final f = <BigInt>[BigInt.one];
  for (var i = 1; i <= _n; i++) {
    f.add(f[i - 1] * BigInt.from(i));
  }
  return List<BigInt>.unmodifiable(f);
}();

/// Total number of distinct shuffles: 52! (~8.07e67).
/// Valid IDs are 0 .. numShuffles - 1.
final BigInt numShuffles = _factorials[_n];

final Map<String, int> _cardIndex = {
  for (var i = 0; i < canonicalDeck.length; i++) canonicalDeck[i]: i,
};

Random? _defaultRandom;

/// Uniform random BigInt in [0, max) via rejection sampling (no modulo bias).
BigInt _randomBelow(BigInt max, Random rng) {
  final bits = max.bitLength;
  final byteCount = (bits + 7) ~/ 8;
  final topMask = (1 << (bits - 8 * (byteCount - 1))) - 1; // keep only needed top bits
  while (true) {
    var value = BigInt.zero;
    for (var i = 0; i < byteCount; i++) {
      var byte = rng.nextInt(256);
      if (i == 0) byte &= topMask;
      value = (value << 8) | BigInt.from(byte);
    }
    if (value < max) return value; // accepted ~75% of the time for 52!
  }
}

/// Parses and validates a user-typed or stored ID string.
/// Throws [FormatException] if it isn't a plain non-negative decimal integer,
/// or [RangeError] if it is >= 52!.
BigInt parseShuffleId(String text) {
  final s = text.trim();
  if (!RegExp(r'^[0-9]+$').hasMatch(s)) {
    throw const FormatException(
        'Shuffle ID must contain only decimal digits.');
  }
  final id = BigInt.parse(s);
  _checkRange(id);
  return id;
}

void _checkRange(BigInt id) {
  if (id < BigInt.zero || id >= numShuffles) {
    throw RangeError('Shuffle ID out of range (must be 0 <= id < 52!).');
  }
}

/// Returns the deck (52 card strings, top of deck first) for [id].
List<String> getShuffleById(BigInt id) {
  _checkRange(id);
  var n = id;
  final pool = List<String>.of(canonicalDeck);
  final deck = <String>[];
  for (var remaining = _n; remaining > 0; remaining--) {
    // n < remaining! holds here, so k is always a valid index into pool.
    final f = _factorials[remaining - 1];
    final k = (n ~/ f).toInt();
    n = n % f;
    deck.add(pool.removeAt(k));
  }
  return deck;
}

/// Returns the ID of [deck]. Throws [ArgumentError] unless it is a valid
/// permutation of the 52 cards.
BigInt getIdForDeck(List<String> deck) {
  if (deck.length != _n ||
      deck.toSet().length != _n ||
      !deck.every(_cardIndex.containsKey)) {
    throw ArgumentError('Deck must contain each of the 52 cards exactly once.');
  }
  final remaining = List<int>.generate(_n, (i) => i); // unused canonical indices
  var id = BigInt.zero;
  for (var pos = 0; pos < _n; pos++) {
    final k = remaining.indexOf(_cardIndex[deck[pos]]!);
    id += BigInt.from(k) * _factorials[_n - pos - 1];
    remaining.removeAt(k);
  }
  return id;
}

/// Returns a uniformly random shuffle and its ID.
///
/// Uses [Random.secure] (OS CSPRNG) with rejection sampling, so the ID is
/// exactly uniform over all 52! values. Pass [random] only for testing.
({List<String> deck, BigInt id}) getRandomShuffle({Random? random}) {
  final id = getRandomShuffleId(random: random);
  return (deck: getShuffleById(id), id: id);
}

/// Returns a uniformly random shuffle ID without creating the deck.
///
/// Uses [Random.secure] (OS CSPRNG) with rejection sampling, so the ID is
/// exactly uniform over all 52! values. Pass [random] only for testing.
BigInt getRandomShuffleId({Random? random}) {
  final rng = random ?? (_defaultRandom ??= Random.secure());
  return _randomBelow(numShuffles, rng);
}