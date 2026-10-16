import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/pile_widget.dart';
import '../logic/game_rules.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int? selectedPileIndex;
  int? selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      appBar: AppBar(
        title: const Text('Autumn Leaves'),
        backgroundColor: Colors.green[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await context.read<GameController>().forceSaveInProgress();
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () async {
              final confirmed = await _showForfeitDialog(context);
              if (confirmed == true && context.mounted) {
                await context.read<GameController>().forfeitGame();
                Navigator.pop(context);
              }
            },
            tooltip: 'Forfeit',
          ),
        ],
      ),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (controller.state.isWon) {
            return _buildWinDialog(controller);
          }

          return Column(
            children: [
              _buildTopBar(controller),
              Expanded(
                child: _buildGameBoard(controller),
              ),
              _buildBottomBar(controller),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(GameController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.green[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Moves: ${controller.state.moves}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Score: ${controller.state.score}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Stock: ${controller.state.stock.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(GameController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final totalPadding = 16; // 8px horizontal padding on each side
        final columnSpacing = 4; // 2px on each side of each column
        final availableWidth = screenWidth - totalPadding - (columnSpacing * 12);
        final columnWidth = (availableWidth / 6).clamp(40.0, 80.0);
        final cardWidth = columnWidth - 4; // Account for 2px padding on each side
        final cardHeight = cardWidth * 1.5;
        final cardSpacing = cardHeight * 0.25;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.state.piles.asMap().entries.map((entry) {
              final index = entry.key;
              final pile = entry.value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => _handlePileTap(controller, index),
                    child: PileWidget(
                      pile: pile,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      cardSpacing: cardSpacing,
                      selectedIndex: selectedPileIndex == index ? selectedCardIndex : null,
                      onCardTap: (cardIndex) => _handleCardTap(controller, index, cardIndex),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(GameController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.green[800],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: controller.state.canDeal()
                ? () {
                    controller.dealCards();
                    _clearSelection();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green[900],
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            child: const Text(
              'Deal Cards',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinDialog(GameController controller) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You Win!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Moves: ${controller.state.moves}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                controller.newGame();
                _clearSelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'New Game',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(GameController controller, int pileIndex, int cardIndex) {
    final pile = controller.state.piles[pileIndex];
    final card = pile.cards[cardIndex];

    if (!card.faceUp) return;

    if (selectedPileIndex == null) {
      setState(() {
        selectedPileIndex = pileIndex;
        selectedCardIndex = cardIndex;
      });
    } else if (selectedPileIndex == pileIndex) {
      if (selectedCardIndex == cardIndex) {
        _clearSelection();
      } else {
        setState(() {
          selectedCardIndex = cardIndex;
        });
      }
    } else {
      _attemptMove(controller, pileIndex);
    }
  }

  void _handlePileTap(GameController controller, int pileIndex) {
    if (selectedPileIndex != null && selectedPileIndex != pileIndex) {
      _attemptMove(controller, pileIndex);
    }
  }

  void _attemptMove(GameController controller, int toPileIndex) {
    if (selectedPileIndex == null || selectedCardIndex == null) return;

    final fromPileIndex = selectedPileIndex!;
    final fromCardIndex = selectedCardIndex!;
    final fromPile = controller.state.piles[fromPileIndex];

    final cardCount = fromPile.cards.length - fromCardIndex;
    final cardsToMove = fromPile.cards.sublist(fromCardIndex);

    if (GameRules.isValidRun(cardsToMove)) {
      controller.moveCards(fromPileIndex, toPileIndex, cardCount);
    } else {
      controller.moveCard(fromPileIndex, toPileIndex);
    }

    _clearSelection();
  }

  void _clearSelection() {
    setState(() {
      selectedPileIndex = null;
      selectedCardIndex = null;
    });
  }

  Future<bool?> _showForfeitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forfeit Game?'),
        content: const Text('Are you sure you want to forfeit this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Forfeit'),
          ),
        ],
      ),
    );
  }
}
