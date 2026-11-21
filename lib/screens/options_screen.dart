import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Options', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: AppIconThemes.appBar,
      ),
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: AppColors.cardBackground,
                child: SwitchListTile(
                  title: const Text(
                    'Card Hints',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  subtitle: const Text(
                    'Highlight movable cards and valid destinations',
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  value: controller.showMoveHints,
                  onChanged: (_) => controller.toggleMoveHints(),
                  activeThumbColor: AppColors.buttonBackground,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startTestWinGame(context, controller),
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Start Test Win Game'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: AppColors.buttonForeground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _startTestWinGame(
    BuildContext context,
    GameController controller,
  ) async {
    if (controller.hasInProgressGame) {
      final confirmed = await _showForfeitDialog(context);
      if (confirmed != true || !context.mounted) return;
      await controller.forfeitGame();
    }
    await controller.testWinGame();
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    }
  }

  Future<bool?> _showForfeitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Forfeit Game?', style: AppTextStyles.dialogTitle),
        content: const Text(
          'You have an in-progress game. Starting a test game will forfeit it. Continue?',
          style: AppTextStyles.dialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: AppTextStyles.dialogButton),
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
}
