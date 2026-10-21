import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_history.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StorageService _storage = StorageService();
  List<GameRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final history = await _storage.loadHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5D4037),
      appBar: AppBar(
        title: const Text(
          'Stats',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: const Color(0xFFFFB74D),
            onPressed: () async {
              final confirmed = await _showClearHistoryDialog();
              if (confirmed == true && mounted) {
                await _clearHistory();
              }
            },
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildDetailedStats(),
                  const SizedBox(height: 16),
                  _buildStorageInfo(),
                  const SizedBox(height: 16),
                  _buildRecentGames(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final totalGames = _history.length;
    final wins = _history.where((r) => r.status == GameStatus.won).length;
    final forfeits = _history.where((r) => r.status == GameStatus.forfeited).length;
    final winRate = totalGames > 0 ? (wins / totalGames * 100).toStringAsFixed(1) : '0.0';

    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow('Total Games', totalGames.toString()),
            _buildStatRow('Wins', wins.toString()),
            _buildStatRow('Forfeits', forfeits.toString()),
            _buildStatRow('Win Rate', winRate),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    final wins = _history.where((r) => r.status == GameStatus.won).toList();
    final forfeits = _history.where((r) => r.status == GameStatus.forfeited).toList();

    final avgWinMoves = wins.isNotEmpty
        ? (wins.map((r) => _countNonDealMoves(r)).reduce((a, b) => a + b) / wins.length).toStringAsFixed(1)
        : 'N/A';
    final avgForfeitMoves = forfeits.isNotEmpty
        ? (forfeits.map((r) => _countNonDealMoves(r)).reduce((a, b) => a + b) / forfeits.length).toStringAsFixed(1)
        : 'N/A';

    final bestGame = wins.isNotEmpty
        ? wins.reduce((a, b) => _countNonDealMoves(a) < _countNonDealMoves(b) ? a : b)
        : null;

    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow('Avg Moves (Wins)', avgWinMoves),
            _buildStatRow('Avg Moves (Forfeits)', avgForfeitMoves),
            if (bestGame != null) ...[
              const SizedBox(height: 8),
              Text(
                'Best Game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              _buildStatRow('Moves', _countNonDealMoves(bestGame).toString()),
              _buildStatRow('Date', _formatDate(bestGame.endTime)),
            ],
          ],
        ),
      ),
    );
  }

  int _countNonDealMoves(GameRecord record) {
    return record.moveLog.where((m) => m.type != 'deal').length;
  }

  Widget _buildStorageInfo() {
    final totalSize = _calculateStorageSize();
    final totalMoves = _history.fold<int>(0, (sum, r) => sum + r.moveLog.length);

    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage Info',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatRow('History Size', _formatBytes(totalSize)),
            _buildStatRow('Total Moves Recorded', totalMoves.toString()),
            _buildStatRow('Games Stored', _history.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGames() {
    final recentGames = _history.length >= 5
        ? _history.sublist(_history.length - 5)
        : _history;

    return Card(
      color: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Games',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 12),
            if (recentGames.isEmpty)
              const Text('No games played yet')
            else
              ...recentGames.map((game) => _buildGameItem(game)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(GameRecord game) {
    final statusColor = game.status == GameStatus.won ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
    final statusText = game.status == GameStatus.won ? 'Won' : 'Forfeited';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$statusText - ${game.moves} moves',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                Text(
                  _formatDate(game.endTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFE65100)),
            onPressed: () async {
              final confirmed = await _showDeleteGameDialog();
              if (confirmed == true && mounted) {
                await _deleteGame(game.id);
              }
            },
            tooltip: 'Delete Game',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF3E2723)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  int _calculateStorageSize() {
    int totalSize = 0;
    for (final record in _history) {
      totalSize += record.toJson().toString().length;
    }
    return totalSize;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<bool?> _showClearHistoryDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          'Clear History?',
          style: TextStyle(color: Color(0xFFE65100)),
        ),
        content: const Text(
          'This will permanently delete all game history. This action cannot be undone.',
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
              'Clear',
              style: TextStyle(color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_history');
    await _loadStats();
  }

  Future<bool?> _showDeleteGameDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          'Delete Game?',
          style: TextStyle(color: Color(0xFFE65100)),
        ),
        content: const Text(
          'This will permanently delete this game from history. This action cannot be undone.',
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
              'Delete',
              style: TextStyle(color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGame(String id) async {
    await _storage.deleteFromHistory(id);
    await _loadStats();
  }
}
