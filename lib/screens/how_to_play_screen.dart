import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D4037),
      appBar: AppBar(
        title: const Text(
          'How to Play',
          style: TextStyle(color: Color(0xFFFFB74D)),
        ),
        backgroundColor: const Color(0xFF3E2723),
        iconTheme: const IconThemeData(color: Color(0xFFFFB74D)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleCard(
              'Card Movement',
              'Move any card from the top of one pile onto the top of another pile if the suits match and the card being moved is of a lower number (Aces are low).',
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Face-Down Cards',
              'When there are no more face-up cards on a pile, turn the topmost face-down card face-up.',
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Empty Piles',
              'Any card can be placed in an empty pile.',
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Block Movement',
              'A descending run of cards in the same suit can be moved as a block.',
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Dealing',
              'At any time you may deal out the next 6 of the left-over cards: one onto each pile (even if a pile is empty).',
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Winning',
              'The game is won if each of the four suits is gathered together into a run from King down to Ace.',
            ),
            const SizedBox(height: 16),
            _buildRuleCard(
              'Initial Deal',
              '22 cards are dealt into 6 piles:\n• Columns 1, 2, 5, 6: 4 cards each (top card face-up)\n• Columns 3, 4: 3 cards each (top card face-up)\n• Remaining 30 cards go to the stock pile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(String title, String content) {
    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
