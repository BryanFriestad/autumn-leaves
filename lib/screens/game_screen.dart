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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameController>().newGame();
              _clearSelection();
            },
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.state.piles.asMap().entries.map((entry) {
              final index = entry.key;
              final pile = entry.value;
              return SizedBox(
                width: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () => _handlePileTap(controller, index),
                    child: PileWidget(
                      pile: pile,
                      selectedIndex: selectedPileIndex == index ? selectedCardIndex : null,
                      onCardTap: (cardIndex) => _handleCardTap(controller, index, cardIndex),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(GameController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Deal Cards',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
