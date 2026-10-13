enum GameStatus {
  inProgress,
  won,
  forfeited,
}

class GameMove {
  final int fromPileIndex;
  final int toPileIndex;
  final int cardCount;
  final String type; // 'moveCard' or 'moveCards' or 'deal'

  GameMove({
    required this.fromPileIndex,
    required this.toPileIndex,
    required this.cardCount,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'f': fromPileIndex,
      't': toPileIndex,
      'c': cardCount,
      'ty': type,
    };
  }

  factory GameMove.fromJson(Map<String, dynamic> json) {
    return GameMove(
      fromPileIndex: json['f'] as int,
      toPileIndex: json['t'] as int,
      cardCount: json['c'] as int,
      type: json['ty'] as String,
    );
  }
}

class GameRecord {
  final String id;
  final String seed;
  final DateTime startTime;
  final DateTime? endTime;
  final GameStatus status;
  final int moves;
  final List<GameMove> moveLog;
  final String? finalState;

  GameRecord({
    required this.id,
    required this.seed,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.moves,
    required this.moveLog,
    this.finalState,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      's': seed,
      'st': startTime.toIso8601String(),
      'et': endTime?.toIso8601String(),
      'stt': status.index,
      'm': moves,
      'ml': moveLog.map((m) => m.toJson()).toList(),
      'fs': finalState,
    };
  }

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      seed: json['s'] as String,
      startTime: DateTime.parse(json['st'] as String),
      endTime: json['et'] != null ? DateTime.parse(json['et'] as String) : null,
      status: GameStatus.values[json['stt'] as int],
      moves: json['m'] as int,
      moveLog: (json['ml'] as List)
          .map((m) => GameMove.fromJson(m as Map<String, dynamic>))
          .toList(),
      finalState: json['fs'] as String?,
    );
  }
}
