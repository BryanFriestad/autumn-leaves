import '../models/game_state.dart';

abstract class ServerService {
  Future<List<SolvableGame>> getSolvableGames();
  Future<void> submitScore(ScoreSubmission submission);
  Future<Leaderboard> getLeaderboard();
  Future<SolvableGame?> getNextSolvableGame();
}

class SolvableGame {
  final String id;
  final String seed;
  final int difficulty;
  final DateTime createdAt;

  SolvableGame({
    required this.id,
    required this.seed,
    required this.difficulty,
    required this.createdAt,
  });

  factory SolvableGame.fromJson(Map<String, dynamic> json) {
    return SolvableGame(
      id: json['id'] as String,
      seed: json['seed'] as String,
      difficulty: json['difficulty'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seed': seed,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ScoreSubmission {
  final String gameId;
  final int moves;
  final int timeInSeconds;
  final String playerName;
  final DateTime completedAt;

  ScoreSubmission({
    required this.gameId,
    required this.moves,
    required this.timeInSeconds,
    required this.playerName,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'moves': moves,
      'timeInSeconds': timeInSeconds,
      'playerName': playerName,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

class LeaderboardEntry {
  final String playerName;
  final int moves;
  final int timeInSeconds;
  final DateTime completedAt;
  final int rank;

  LeaderboardEntry({
    required this.playerName,
    required this.moves,
    required this.timeInSeconds,
    required this.completedAt,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String,
      moves: json['moves'] as int,
      timeInSeconds: json['timeInSeconds'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      rank: json['rank'] as int,
    );
  }
}

class Leaderboard {
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  Leaderboard({
    required this.entries,
    required this.lastUpdated,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class MockServerService implements ServerService {
  @override
  Future<List<SolvableGame>> getSolvableGames() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  @override
  Future<void> submitScore(ScoreSubmission submission) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<Leaderboard> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Leaderboard(
      entries: [],
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<SolvableGame?> getNextSolvableGame() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }
}
