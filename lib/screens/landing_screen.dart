import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import 'game_screen.dart';
import 'stats_screen.dart';
import 'how_to_play_screen.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          if (!controller.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressIndicator),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Autumn Leaves',
                  style: AppTextStyles.landingTitle,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Solitaire',
                  style: AppTextStyles.landingSubtitle,
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
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Forfeit Game?',
          style: AppTextStyles.dialogTitle,
        ),
        content: const Text(
          'You have an in-progress game. Starting a new game will forfeit it. Continue?',
          style: AppTextStyles.dialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: AppTextStyles.dialogButton,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Forfeit & Start',
              style: AppTextStyles.dialogButton,
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
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.buttonForeground,
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
              style: AppTextStyles.buttonText,
            ),
          ],
        ),
      ),
    );
  }
}
