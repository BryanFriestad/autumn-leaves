import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../models/game_history.dart';
import '../models/card.dart';
import '../models/pile.dart';
import '../logic/game_rules.dart';

class StorageService {
  static const String _inProgressKey = 'in_progress_game';
  static const String _historyKey = 'game_history';

  Future<void> saveInProgressGame(GameState state, List<GameMove> moveLog, String shuffleId, {int scorePenalty = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'shuffleId': shuffleId,
      'moveLog': moveLog.map((m) => m.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'scorePenalty': scorePenalty,
    };
    await prefs.setString(_inProgressKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadInProgressGame() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_inProgressKey);
    if (data == null) return null;

    final decoded = jsonDecode(data) as Map<String, dynamic>;
    final shuffleId = decoded['shuffleId'] as String;
    final moveLog = (decoded['moveLog'] as List)
        .map((m) => GameMove.fromJson(m as Map<String, dynamic>))
        .toList();
    final scorePenalty = decoded['scorePenalty'] as int? ?? 0;

    // Reconstruct the game state from shuffleId and moveLog
    final initialState = GameState.fromShuffleId(shuffleId);
    final state = GameRules.applyMoveLog(initialState, moveLog);

    return {
      'shuffleId': shuffleId,
      'moveLog': moveLog,
      'state': encodeGameState(state),
      'scorePenalty': scorePenalty,
    };
  }

  Future<void> clearInProgressGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_inProgressKey);
  }

  Future<bool> hasInProgressGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_inProgressKey);
  }

  Future<void> saveToHistory(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    List<GameRecord> history = [];

    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      history = decoded.map((r) => GameRecord.fromJson(r as Map<String, dynamic>)).toList();
    }

    history.add(record);

    // Keep only last 100 games to manage storage
    if (history.length > 100) {
      history = history.sublist(history.length - 100);
    }

    await prefs.setString(_historyKey, jsonEncode(history.map((r) => r.toJson()).toList()));
  }

  Future<List<GameRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return [];

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((r) => GameRecord.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> deleteFromHistory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson == null) return;

    final List<dynamic> decoded = jsonDecode(historyJson);
    final history = decoded.map((r) => GameRecord.fromJson(r as Map<String, dynamic>)).toList();

    history.removeWhere((record) => record.id == id);

    await prefs.setString(_historyKey, jsonEncode(history.map((r) => r.toJson()).toList()));
  }

  String encodeGameState(GameState state) {
    return jsonEncode({
      'piles': state.piles.map((p) => _encodePile(p)).toList(),
      'stock': state.stock.map((c) => _encodeCard(c)).toList(),
      'moves': state.moves,
    });
  }

  List<dynamic> _encodePile(Pile pile) {
    return pile.cards.map((c) => _encodeCard(c)).toList();
  }

  Map<String, dynamic> _encodeCard(Card card) {
    return {
      's': card.suit.index,
      'r': card.rank.index,
      'f': card.faceUp,
    };
  }

  GameState decodeGameState(String encoded) {
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    return GameState(
      piles: (data['piles'] as List)
          .map((p) => _decodePile(p as List))
          .toList(),
      stock: (data['stock'] as List)
          .map((c) => _decodeCard(c as Map<String, dynamic>))
          .toList(),
      moves: data['moves'] as int,
    );
  }

  Pile _decodePile(List<dynamic> data) {
    return Pile(
      cards: data.map((c) => _decodeCard(c as Map<String, dynamic>)).toList(),
    );
  }

  Card _decodeCard(Map<String, dynamic> data) {
    return Card(
      suit: Suit.values[data['s'] as int],
      rank: Rank.values[data['r'] as int],
      faceUp: data['f'] as bool,
    );
  }
}
