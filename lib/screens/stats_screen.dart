import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_history.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const double _itemExtent = 68;

  final StorageService _storage = StorageService();
  List<GameRecord> _history = [];
  bool _isLoading = true;
  static const int _initialVisibleCount = 50;
  static const int _visibleCountStep = 50;
  int _visibleCount = _initialVisibleCount;

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
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Game Log', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBarBackground,
        iconTheme: AppIconThemes.appBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            color: AppColors.iconAccent,
            onPressed: _showStatsDialog,
            tooltip: 'Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: AppColors.iconAccent,
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.progressIndicator,
                ),
              ),
            )
          : _buildGameLog(),
    );
  }

  Widget _buildGameLog() {
    final games = _history.reversed.toList();
    final pageGames = games.take(_visibleCount).toList();
    final hasMore = _visibleCount < games.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Reserve space for padding, two-line header, and spacing
        final chrome = 110.0;
        final maxCardHeight = (constraints.maxHeight - chrome).clamp(
          0.0,
          double.infinity,
        );
        final contentHeight =
            pageGames.length * _itemExtent + 16 + (hasMore ? 56 : 0);
        final cardHeight = contentHeight < maxCardHeight
            ? contentHeight
            : maxCardHeight;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderStat('Overall win rate', _winRate(_history)),
              _buildHeaderStat(
                'Last 50 games',
                _winRate(_history.reversed.take(50).toList()),
              ),
              const SizedBox(height: 12),
              if (pageGames.isEmpty)
                const Expanded(
                  child: Center(child: Text('No games played yet')),
                )
              else
                SizedBox(
                  height: cardHeight,
                  child: Card(
                    color: AppColors.cardBackground,
                    margin: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            ...pageGames.map((game) => _buildGameItem(game)),
                            if (hasMore)
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => setState(
                                    () => _visibleCount += _visibleCountStep,
                                  ),
                                  icon: const Icon(Icons.expand_more),
                                  label: const Text('Show older games'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.statLabel),
          const SizedBox(width: 8),
          Text(value, style: AppTextStyles.statValue),
        ],
      ),
    );
  }

  String _winRate(List<GameRecord> games) {
    if (games.isEmpty) return '—';
    final wins = games.where((g) => g.status == GameStatus.won).length;
    return '${(wins / games.length * 100).round()}% ($wins / ${games.length})';
  }

  Widget _buildGameItem(GameRecord game) {
    final statusColor = game.status == GameStatus.won
        ? AppColors.winStatus
        : AppColors.forfeitStatus;
    final statusText = game.status == GameStatus.won ? 'Won' : 'Forfeited';

    return SizedBox(
      height: _itemExtent,
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
            child: InkWell(
              onTap: () => _showGameDetails(game),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$statusText - ${game.moves} moves',
                    style: AppTextStyles.gameStatus,
                  ),
                  Text(
                    _formatDate(game.endTime),
                    style: AppTextStyles.gameDate,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.iconDelete,
            ),
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

  void _showGameDetails(GameRecord game) {
    final statusColor = game.status == GameStatus.won
        ? AppColors.winStatus
        : AppColors.forfeitStatus;
    final statusText = game.status == GameStatus.won ? 'Won' : 'Forfeited';

    final deals = game.moveLog.where((m) => m.type == 'deal').length;
    final singleMoves = game.moveLog.where((m) => m.type == 'moveCard').length;
    final multiMoves = game.moveLog.where((m) => m.type == 'moveCards').length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        actionsPadding: const EdgeInsets.only(bottom: 8),
        title: Text('Game Details', style: AppTextStyles.dialogTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', statusText, valueColor: statusColor),
              _buildDetailRow('Date', _formatDateTime(game.endTime)),
              _buildDetailRow('Moves', game.moves.toString()),
              _buildDetailRow(
                'Non-deal moves',
                _countNonDealMoves(game).toString(),
              ),
              _buildDetailRow('Deals', deals.toString()),
              _buildDetailRow('Single-card moves', singleMoves.toString()),
              _buildDetailRow('Multi-card moves', multiMoves.toString()),
              _buildDetailRow('Deal rating', _formatRating(game.dealRating)),
              _buildDetailRow('Deal type', _formatDealType(game.dealType)),
              _buildDetailRow('Shuffle ID', game.shuffleId),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: AppTextStyles.dialogButton),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: AppTextStyles.statLabel)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.statValue.copyWith(color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRating(DealRating? rating) {
    switch (rating) {
      case DealRating.positive:
        return 'Thumbs up';
      case DealRating.negative:
        return 'Thumbs down';
      case null:
        return 'Not rated';
    }
  }

  String _formatDealType(DealType type) {
    switch (type) {
      case DealType.random:
        return 'Random';
      case DealType.test:
        return 'Test';
    }
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        actionsPadding: const EdgeInsets.only(bottom: 8),
        title: Text('Statistics', style: AppTextStyles.dialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 12),
                _buildDetailedStats(),
                const SizedBox(height: 12),
                _buildMoveStatsCard(),
                const SizedBox(height: 12),
                _buildStorageInfo(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: AppTextStyles.dialogButton),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalGames = _history.length;
    final wins = _history.where((r) => r.status == GameStatus.won).length;
    final forfeits = _history
        .where((r) => r.status == GameStatus.forfeited)
        .length;
    final winRate = totalGames > 0
        ? (wins / totalGames * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: AppTextStyles.sectionTitle),
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
    final forfeits = _history
        .where((r) => r.status == GameStatus.forfeited)
        .toList();

    final avgWinMoves = wins.isNotEmpty
        ? (wins.map((r) => _countNonDealMoves(r)).reduce((a, b) => a + b) /
                  wins.length)
              .toStringAsFixed(1)
        : 'N/A';
    final avgForfeitMoves = forfeits.isNotEmpty
        ? (forfeits.map((r) => _countNonDealMoves(r)).reduce((a, b) => a + b) /
                  forfeits.length)
              .toStringAsFixed(1)
        : 'N/A';

    final bestGame = wins.isNotEmpty
        ? wins.reduce(
            (a, b) => _countNonDealMoves(a) < _countNonDealMoves(b) ? a : b,
          )
        : null;

    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            _buildStatRow('Avg Moves (Wins)', avgWinMoves),
            _buildStatRow('Avg Moves (Forfeits)', avgForfeitMoves),
            if (bestGame != null) ...[
              const SizedBox(height: 8),
              Text('Best Game', style: AppTextStyles.bestGameLabel),
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

  Widget _buildMoveStatsCard() {
    final winMoves =
        _history
            .where((r) => r.status == GameStatus.won)
            .map(_countNonDealMoves)
            .toList()
          ..sort();

    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move Stats (Wins)', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            if (winMoves.isEmpty)
              const Text('No won games yet')
            else ...[
              _buildStatRow('Games', winMoves.length.toString()),
              _buildStatRow('Min', winMoves.first.toString()),
              _buildStatRow(
                'Q1 (25%)',
                _formatStat(_percentile(winMoves, 0.25)),
              ),
              _buildStatRow('Median', _formatStat(_percentile(winMoves, 0.5))),
              _buildStatRow(
                'Q3 (75%)',
                _formatStat(_percentile(winMoves, 0.75)),
              ),
              _buildStatRow('Max', winMoves.last.toString()),
              _buildStatRow(
                'Mean',
                _formatStat(winMoves.reduce((a, b) => a + b) / winMoves.length),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _percentile(List<int> sorted, double p) {
    final index = (sorted.length - 1) * p;
    final lower = index.floor();
    final upper = index.ceil();
    if (lower == upper) return sorted[lower].toDouble();
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (index - lower);
  }

  String _formatStat(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  Widget _buildStorageInfo() {
    final totalSize = _calculateStorageSize();
    final totalMoves = _history.fold<int>(
      0,
      (sum, r) => sum + r.moveLog.length,
    );

    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Storage Info', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            _buildStatRow('History Size', _formatBytes(totalSize)),
            _buildStatRow('Total Moves Recorded', totalMoves.toString()),
            _buildStatRow('Games Stored', _history.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.statLabel)),
          const SizedBox(width: 8),
          Text(value, style: AppTextStyles.statValue),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.month}/${date.day}/${date.year} $hour:$minute';
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
        backgroundColor: AppColors.cardBackground,
        title: const Text('Clear History?', style: AppTextStyles.dialogTitle),
        content: const Text(
          'This will permanently delete all game history. This action cannot be undone.',
          style: AppTextStyles.dialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: AppTextStyles.dialogButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: AppTextStyles.dialogButton),
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('game_history');
    setState(() => _visibleCount = _initialVisibleCount);
    await _loadStats();
  }

  Future<bool?> _showDeleteGameDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete Game?', style: AppTextStyles.dialogTitle),
        content: const Text(
          'This will permanently delete this game from history. This action cannot be undone.',
          style: AppTextStyles.dialogContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: AppTextStyles.dialogButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: AppTextStyles.dialogButton),
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
