import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/game_history.dart';
import '../logic/game_rules.dart';
import '../logic/deck_shuffle.dart';
import '../services/storage_service.dart';

class GameController extends ChangeNotifier {
  late String _currentShuffleId;
  late GameState _state;
  bool _isOfflineMode = true;
  List<GameMove> _moveLog = [];
  final StorageService _storage = StorageService();
  bool _hasInProgressGame = false;
  bool _isInitialized = false;
  bool _showMoveHints = true;
  int _scorePenalty = 0;

  GameState get state => _state;
  bool get isOfflineMode => _isOfflineMode;
  String get currentShuffleId => _currentShuffleId;
  List<GameMove> get moveLog => _moveLog;
  bool get hasInProgressGame => _hasInProgressGame;
  bool get isInitialized => _isInitialized;
  bool get showMoveHints => _showMoveHints;
  int get totalScore => _state.score - _scorePenalty;

  GameController() {
    _currentShuffleId = getRandomShuffleId().toString();
    _state = GameState.fromShuffleId(_currentShuffleId);
    _initialize();
  }

  Future<void> _initialize() async {
    _hasInProgressGame = await _storage.hasInProgressGame();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> newGame() async {
    _currentShuffleId = getRandomShuffleId().toString();
    _state = GameState.fromShuffleId(_currentShuffleId);
    _moveLog = [];
    _scorePenalty = 0;
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
      _currentShuffleId = data['shuffleId'] as String;
      _state = _storage.decodeGameState(data['state'] as String);
      _moveLog = (data['moveLog'] as List)
          .map((m) => GameMove.fromJson(m as Map<String, dynamic>))
          .toList();
      _scorePenalty = data['scorePenalty'] as int? ?? 0;
      notifyListeners();
    }
  }

  void testWinGame() {
    _currentShuffleId = 'test';
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

  // TODO: this and complete game are too similar, refactor
  Future<void> forfeitGame() async {
    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      shuffleId: _currentShuffleId,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: GameStatus.forfeited,
      moves: _state.moves,
      moveLog: List.from(_moveLog),
      scorePenalty: _scorePenalty,
    );
    await _storage.saveToHistory(record);
    await _storage.clearInProgressGame();
    _hasInProgressGame = false;
    notifyListeners();
  }

  Future<void> completeGame() async {
    final record = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      shuffleId: _currentShuffleId,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: GameStatus.won,
      moves: _state.moves,
      moveLog: List.from(_moveLog),
      scorePenalty: _scorePenalty,
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

  void undo() async {
    if (_moveLog.isEmpty) return;

    _moveLog.removeLast();
    _scorePenalty += 25;

    final initialState = GameState.fromShuffleId(_currentShuffleId);
    _state = GameRules.applyMoveLog(initialState, _moveLog);

    notifyListeners();
    await _saveInProgress();
  }

  void reset() {
    _currentShuffleId = getRandomShuffleId().toString();
    _state = GameState.fromShuffleId(_currentShuffleId);
    _moveLog = [];
    _scorePenalty = 0;
    notifyListeners();
  }

  Future<void> _saveInProgress() async {
    if (!_state.isWon) {
      await _storage.saveInProgressGame(_state, _moveLog, _currentShuffleId, scorePenalty: _scorePenalty);
      _hasInProgressGame = true;
    } else {
      await completeGame();
    }
  }

  void toggleMoveHints() {
    _showMoveHints = !_showMoveHints;
    notifyListeners();
  }

  bool canMoveCard(int pileIndex, int cardIndex) {
    return GameRules.getMovableCards(_state.piles[pileIndex], _state.piles).isNotEmpty &&
           cardIndex >= _state.piles[pileIndex].cards.length - GameRules.getMovableCards(_state.piles[pileIndex], _state.piles).length;
  }

  List<int> getValidDestinations(int fromPileIndex, int cardIndex) {
    final pile = _state.piles[fromPileIndex];
    if (cardIndex >= pile.cards.length) return [];

    final card = pile.cards[cardIndex];
    if (!card.faceUp) return [];

    final validDestinations = <int>[];
    for (int i = 0; i < _state.piles.length; i++) {
      if (i == fromPileIndex) continue;
      if (GameRules.canMoveCard(card, _state.piles[i])) {
        validDestinations.add(i);
      }
    }
    return validDestinations;
  }
}
