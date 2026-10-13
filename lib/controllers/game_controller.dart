import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../logic/game_rules.dart';

class GameController extends ChangeNotifier {
  GameState _state = GameState.initial();
  bool _isOfflineMode = true;

  GameState get state => _state;
  bool get isOfflineMode => _isOfflineMode;

  void newGame() {
    _state = GameState.initial();
    notifyListeners();
  }

  void testWinGame() {
    _state = GameState.testWin();
    notifyListeners();
  }

  void dealCards() {
    if (_state.canDeal()) {
      _state = _state.deal();
      notifyListeners();
    }
  }

  void moveCard(int fromPileIndex, int toPileIndex) {
    final newState = GameRules.moveCard(_state, fromPileIndex, toPileIndex);
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  void moveCards(int fromPileIndex, int toPileIndex, int cardCount) {
    final newState = GameRules.moveCards(_state, fromPileIndex, toPileIndex, cardCount);
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  void autoMoveToFoundation(int pileIndex, int cardIndex) {
    final newState = GameRules.autoMoveToFoundation(_state, pileIndex, cardIndex);
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
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
}
