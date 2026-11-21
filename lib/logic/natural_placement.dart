import 'dart:math';
import '../models/card.dart';

class NaturalPlacement {
  final double dx;
  final double dy;
  final double rotation;

  const NaturalPlacement({
    required this.dx,
    required this.dy,
    required this.rotation,
  });

  static const NaturalPlacement none = NaturalPlacement(
    dx: 0,
    dy: 0,
    rotation: 0,
  );

  // Deterministic per-card offset so a card's horizontal/rotation placement
  // never changes once it exists. Vertical placement is cumulative: each
  // card steps only slightly from the card below it (previousDy), so the
  // pile drifts naturally instead of scattering. Because cards are only
  // ever added or removed at the top of a pile, already-placed cards keep
  // the same previousDy chain and never move.
  factory NaturalPlacement.forCard(
    Card card, {
    required double cardWidth,
    required double cardSpacing,
    double previousDy = 0,
  }) {
    final key = card.suit.index * 13 + card.rank.index;

    // Horizontal jitter stays well inside the card's column (columns have
    // only a few px of gap between cards).
    final dx = (_unit(key, 1) * 2 - 1) * cardWidth * 0.02;
    // Each card steps a small amount from the card below it, clamped so
    // the pile can't drift far enough to hide or expose cards.
    final step = (_unit(key, 2) * 2 - 1) * cardSpacing * 0.25;
    final dy = (previousDy + step)
        .clamp(-cardSpacing * 0.8, cardSpacing * 0.8)
        .toDouble();
    // Small rotation (~ +/- 1.3 degrees).
    final rotation = (_unit(key, 3) * 2 - 1) * 0.0225;

    return NaturalPlacement(dx: dx, dy: dy, rotation: rotation);
  }

  static double _unit(int key, int salt) {
    final x = sin(key * 12.9898 + salt * 78.233) * 43758.5453;
    return x - x.floorToDouble();
  }
}
