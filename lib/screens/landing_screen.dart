import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'game_screen.dart';
import 'stats_screen.dart';
import 'how_to_play_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D4037),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (!controller.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Autumn Leaves',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB74D),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Solitaire',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFFFFCC80),
                  ),
                ),
                const SizedBox(height: 64),
                if (controller.hasInProgressGame)
                  _buildButton(
                    context,
                    'Resume Game',
                    Icons.refresh,
                    () async {
                      await controller.loadInProgressGame();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen()),
                        );
                      }
                    },
                  ),
                if (controller.hasInProgressGame) const SizedBox(height: 16),
                _buildButton(
                  context,
                  'New Game',
                  Icons.play_arrow,
                  () async {
                    if (controller.hasInProgressGame) {
                      final confirmed = await _showNewGameDialog(context);
                      if (confirmed != true || !context.mounted) return;
                      await controller.forfeitGame();
                    }
                    await controller.newGame();
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  'Stats',
                  Icons.bar_chart,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  'How to Play',
                  Icons.help_outline,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HowToPlayScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildButton(
                  context,
                  'Exit',
                  Icons.exit_to_app,
                  () {
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showNewGameDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          'Forfeit Game?',
          style: TextStyle(color: Color(0xFFE65100)),
        ),
        content: const Text(
          'You have an in-progress game. Starting a new game will forfeit it. Continue?',
          style: TextStyle(color: Color(0xFF3E2723)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFE65100)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Forfeit & Start',
              style: TextStyle(color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 220,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB74D),
          foregroundColor: const Color(0xFF3E2723),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
