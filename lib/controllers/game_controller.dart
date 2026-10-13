import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/game_state.dart';
import '../models/game_history.dart';
import '../logic/game_rules.dart';
import '../services/storage_service.dart';

class GameController extends ChangeNotifier {
  GameState _state = GameState.initial();
  bool _isOfflineMode = true;
  String _currentSeed = '';
  List<GameMove> _moveLog = [];
  final StorageService _storage = StorageService();
  bool _hasInProgressGame = false;
  bool _isInitialized = false;

  GameState get state => _state;
  bool get isOfflineMode => _isOfflineMode;
  String get currentSeed => _currentSeed;
  List<GameMove> get moveLog => _moveLog;
  bool get hasInProgressGame => _hasInProgressGame;
  bool get isInitialized => _isInitialized;

  GameController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _hasInProgressGame = await _storage.hasInProgressGame();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> newGame() async {
    _currentSeed = _generateSeed();
    _state = GameState.initial();
    _moveLog = [];
    await _storage.clearInProgressGame();
    _hasInProgressGame = false;
    notifyListeners();
    await _saveInProgress();
  }

  Future<void> forceSaveInProgress() async {
    await _saveInProgress();
  }

  Future<void> loadInProgressGame() async {
    final data = await _storage.loadInProgressGame();
    if (data != null) {
      _currentSeed = data['seed'] as String;
      _state = _storage.decodeGameState(data['state'] as String);
      _moveLog = (data['moveLog'] as List)
          .map((m) => GameMove.fromJson(m as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  void testWinGame() {
    _currentSeed = 'test';
    _state = GameState.testWin();
    _moveLog = [];
    notifyListeners();
  }

  void dealCards() async {
    if (_state.canDeal()) {
      _state = _state.deal();
      _moveLog.add(GameMove(
        fromPileIndex: -1,
        toPileIndex: -1,
        cardCount: 6,
        type: 'deal',
      ));
      notifyListeners();
      await _saveInProgress();
    }
  }

  void moveCard(int fromPileIndex, int toPileIndex) async {
    final newState = GameRules.moveCard(_state, fromPileIndex, toPileIndex);
    if (newState != _state) {
      _state = newState;
      _moveLog.add(GameMove(
        fromPileIndex: fromPileIndex,
        toPileIndex: toPileIndex,
        cardCount: 1,
        type: 'moveCard',
      ));
      notifyListeners();
      await _saveInProgress();
    }
  }

  void moveCards(int fromPileIndex, int toPileIndex, int cardCount) async {
    final newState = GameRules.moveCards(_state, fromPileIndex, toPileIndex, cardCount);
    if (newState != _state) {
      _state = newState;
      _moveLog.add(GameMove(
        fromPileIndex: fromPileIndex,
        toPileIndex: toPileIndex,
        cardCount: cardCount,
        type: 'moveCards',
      ));
      notifyListeners();
      await _saveInProgress();
    }
  }

  void autoMoveToFoundation(int pileIndex, int cardIndex) {
    final newState = GameRules.autoMoveToFoundation(_state, pileIndex, cardIndex);
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  Future<void> forfeitGame() async {
    final finalState = _storage.encodeGameState(_state);
    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      seed: _currentSeed,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: GameStatus.forfeited,
      moves: _state.moves,
      moveLog: List.from(_moveLog),
      finalState: finalState,
    );
    await _storage.saveToHistory(record);
    await _storage.clearInProgressGame();
    _hasInProgressGame = false;
    notifyListeners();
  }

  Future<void> completeGame() async {
    final finalState = _storage.encodeGameState(_state);
    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      seed: _currentSeed,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: GameStatus.won,
      moves: _state.moves,
      moveLog: List.from(_moveLog),
      finalState: finalState,
    );
    await _storage.saveToHistory(record);
    await _storage.clearInProgressGame();
    _hasInProgressGame = false;
    notifyListeners();
  }

  void setOfflineMode(bool isOffline) {
    _isOfflineMode = isOffline;
    notifyListeners();
  }

  void undo() {
  }

  void reset() {
    _state = GameState.initial();
    notifyListeners();
  }

  String _generateSeed() {
    final random = Random();
    return random.nextInt(1000000).toString();
  }

  Future<void> _saveInProgress() async {
    if (!_state.isWon) {
      await _storage.saveInProgressGame(_state, _currentSeed, _moveLog);
      _hasInProgressGame = true;
    } else {
      await completeGame();
    }
  }
}
