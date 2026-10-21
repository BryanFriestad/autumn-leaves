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
  final String shuffleId;
  final DateTime startTime;
  final DateTime? endTime;
  final GameStatus status;
  final int moves;
  final List<GameMove> moveLog;
  final int scorePenalty;

  GameRecord({
    required this.id,
    required this.shuffleId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.moves,
    required this.moveLog,
    this.scorePenalty = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sid': shuffleId,
      'st': startTime.toIso8601String(),
      'et': endTime?.toIso8601String(),
      'stt': status.index,
      'm': moves,
      'ml': moveLog.map((m) => m.toJson()).toList(),
      'sp': scorePenalty,
    };
  }

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      shuffleId: json['sid'] as String,
      startTime: DateTime.parse(json['st'] as String),
      endTime: json['et'] != null ? DateTime.parse(json['et'] as String) : null,
      status: GameStatus.values[json['stt'] as int],
      moves: json['m'] as int,
      moveLog: (json['ml'] as List)
          .map((m) => GameMove.fromJson(m as Map<String, dynamic>))
          .toList(),
      scorePenalty: json['sp'] as int? ?? 0,
    );
  }
}
