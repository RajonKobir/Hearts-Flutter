import 'dart:async';

import 'package:flutter/material.dart';

import '../models.dart';
import '../services/game_repository.dart';
import '../services/game_service.dart';

class GameController extends ChangeNotifier {
  final IGameRepository _repository;
  final IGameService _gameService;

  final playerNameControllers = List.generate(
    GameService.playerCount,
    (index) => TextEditingController(text: 'Player ${index + 1}'),
  );
  final Map<String, TextEditingController> _scoreControllers = {};

  late Game _currentGame;
  List<RoundScore> _rounds = [];
  Future<void> _pendingGameSave = Future.value();
  bool _isGameOver = false;
  bool _isInitialized = false;

  GameController({
    required IGameRepository repository,
    required IGameService gameService,
  }) : _repository = repository,
       _gameService = gameService;

  Game get currentGame => _currentGame;
  List<RoundScore> get rounds => List.unmodifiable(_rounds);
  bool get isGameOver => _isGameOver;
  bool get isInitialized => _isInitialized;
  List<int> get playerTotals => _gameService.calculatePlayerTotals(_rounds);
  bool get canAddRound => _rounds.isNotEmpty && _rounds.last.isComplete;
  bool get canRemoveRound => _rounds.length > 1;

  Future<void> initialize() async {
    try {
      final existingGame = await _loadCurrentGame();
      final game = existingGame ?? await _createNewGame();
      final savedRounds = game.id == null
          ? <RoundScore>[]
          : await _loadSavedRounds(game.id!);
      final rounds = savedRounds.isEmpty
          ? [
              RoundScore(roundNumber: 1, scores: [0, 0, 0, 0]),
            ]
          : savedRounds;

      _currentGame = game;
      _rounds = rounds;
      _isGameOver =
          game.isFinished ||
          _gameService.isGameOver(_gameService.calculatePlayerTotals(rounds));
      _isInitialized = true;
      _syncPlayerNameControllers();
      _syncScoreControllers(overwriteText: true);
      notifyListeners();

      await _saveRoundScoresToDB();
    } catch (e) {
      _currentGame = _fallbackGame();
      _rounds = [
        RoundScore(roundNumber: 1, scores: [0, 0, 0, 0]),
      ];
      _isInitialized = true;
      _syncPlayerNameControllers();
      _syncScoreControllers(overwriteText: true);
      notifyListeners();
    }
  }

  Future<void> savePlayerName(int playerIndex) async {
    final typedName = playerNameControllers[playerIndex].text.trim();
    final normalizedName = typedName.isEmpty
        ? 'Player ${playerIndex + 1}'
        : typedName;
    final updatedNames = List<String>.from(_currentGame.playerNames);
    updatedNames[playerIndex] = normalizedName;
    _currentGame = _currentGame.copyWith(
      playerNames: updatedNames,
      updatedAt: DateTime.now(),
    );
    playerNameControllers[playerIndex].text = normalizedName;
    notifyListeners();

    await _queueGameSave();
  }

  void updatePlayerName(int playerIndex, String value) {
    final updatedNames = List<String>.from(_currentGame.playerNames);
    updatedNames[playerIndex] = value.trim().isEmpty
        ? 'Player ${playerIndex + 1}'
        : value.trim();
    _currentGame = _currentGame.copyWith(
      playerNames: updatedNames,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    unawaited(_queueGameSave());
  }

  Future<bool> updateRoundScore(
    int roundIndex,
    int playerIndex,
    int value,
  ) async {
    _rounds[roundIndex] = _gameService.updateRoundScore(
      _rounds[roundIndex],
      playerIndex,
      value,
    );
    final score = _rounds[roundIndex].scores[playerIndex];
    final controller = scoreControllerFor(roundIndex, playerIndex);
    final scoreText = score == 0 ? '' : score.toString();
    if (controller.text != scoreText) {
      controller.value = TextEditingValue(
        text: scoreText,
        selection: TextSelection.collapsed(offset: scoreText.length),
      );
    }
    notifyListeners();
    return await _saveCurrentRound();
  }

  Future<bool> applyMoonHit(int roundIndex, int shooterIndex) async {
    _rounds[roundIndex] = _gameService.applyMoonHit(
      _rounds[roundIndex],
      shooterIndex,
    );
    for (
      var playerIndex = 0;
      playerIndex < GameService.playerCount;
      playerIndex++
    ) {
      final score = _rounds[roundIndex].scores[playerIndex];
      scoreControllerFor(roundIndex, playerIndex).text = score == 0
          ? ''
          : score.toString();
    }
    notifyListeners();
    return await _saveCurrentRound();
  }

  Future<void> addRound() async {
    if (!canAddRound) return;

    final nextRoundNumber = _rounds.length + 1;
    _rounds.add(
      RoundScore(
        roundNumber: nextRoundNumber,
        scores: List.filled(GameService.playerCount, 0),
      ),
    );
    _currentGame = _currentGame.copyWith(updatedAt: DateTime.now());
    _syncScoreControllers();
    notifyListeners();
    await _persistCurrentState();
  }

  Future<void> removeRound(int roundIndex) async {
    if (!canRemoveRound || roundIndex < 0 || roundIndex >= _rounds.length) {
      return;
    }

    _rounds.removeAt(roundIndex);
    _rounds = List.generate(_rounds.length, (index) {
      final round = _rounds[index];
      return RoundScore(roundNumber: index + 1, scores: round.scores);
    });

    final isStillGameOver = _gameService.isGameOver(playerTotals);
    _isGameOver = _isGameOver && isStillGameOver;
    _currentGame = _currentGame.copyWith(
      isFinished: _isGameOver,
      updatedAt: DateTime.now(),
    );
    _syncScoreControllers(overwriteText: true);
    notifyListeners();
    await _persistCurrentState();
  }

  Future<void> restartGame() async {
    final game = await _resetStoredGame();
    _rounds = [
      RoundScore(roundNumber: 1, scores: [0, 0, 0, 0]),
    ];
    _isGameOver = false;
    _currentGame = game;
    _syncPlayerNameControllers();
    _syncScoreControllers(overwriteText: true);
    notifyListeners();
    await _persistCurrentState();
  }

  Future<void> markGameOver() async {
    _isGameOver = true;
    _currentGame = _currentGame.copyWith(
      isFinished: true,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _persistCurrentState();
  }

  List<PlayerResult> resultRows() {
    return _gameService
        .getGameResult(_rounds, _currentGame.playerNames)
        .results;
  }

  TextEditingController scoreControllerFor(int roundIndex, int playerIndex) {
    final key = _scoreKey(roundIndex, playerIndex);
    return _scoreControllers.putIfAbsent(key, () {
      final score = _rounds[roundIndex].scores[playerIndex];
      return TextEditingController(text: score == 0 ? '' : score.toString());
    });
  }

  Future<Game?> _loadCurrentGame() async {
    try {
      return await _repository.getCurrentGame();
    } catch (e) {
      return null;
    }
  }

  Future<Game> _createNewGame() async {
    final game = _fallbackGame();
    try {
      final gameId = await _repository.createGame(game);
      return game.copyWith(id: gameId);
    } catch (e) {
      return game.copyWith(id: DateTime.now().millisecondsSinceEpoch ~/ 1000);
    }
  }

  Future<List<RoundScore>> _loadSavedRounds(int gameId) async {
    try {
      return await _repository.getRoundScores(gameId);
    } catch (e) {
      return [];
    }
  }

  Future<bool> _saveCurrentRound() async {
    final isNowGameOver = _gameService.isGameOver(playerTotals);
    final didClearGameOver = _isGameOver && !isNowGameOver;
    if (didClearGameOver) {
      _isGameOver = false;
    }
    _currentGame = _currentGame.copyWith(
      isFinished: _isGameOver,
      updatedAt: DateTime.now(),
    );
    await _persistCurrentState();
    if (didClearGameOver) {
      notifyListeners();
    }
    return isNowGameOver && !_isGameOver;
  }

  Future<void> _persistCurrentState() async {
    await _queueGameSave();
    await _saveRoundScoresToDB();
  }

  Future<void> _queueGameSave() {
    _pendingGameSave = _pendingGameSave.then((_) => _tryUpdateGame());
    return _pendingGameSave;
  }

  Future<void> _saveRoundScoresToDB() async {
    if (_currentGame.id == null) return;
    try {
      await _repository.saveRoundScores(_currentGame.id!, _rounds);
    } catch (e) {
      // Database not available - keep in-memory state usable.
    }
  }

  Future<void> _tryUpdateGame() async {
    try {
      await _repository.updateGame(_currentGame);
    } catch (e) {
      // Database not available - keep in-memory state usable.
    }
  }

  Future<Game> _resetStoredGame() async {
    try {
      await _repository.clearAll();
    } catch (e) {
      // Database not available - continue with a fresh in-memory game.
    }
    return _createNewGame();
  }

  void _syncPlayerNameControllers() {
    for (var i = 0; i < playerNameControllers.length; i++) {
      playerNameControllers[i].text = _currentGame.playerNames[i];
    }
  }

  void _syncScoreControllers({bool overwriteText = false}) {
    final activeKeys = <String>{};
    for (var roundIndex = 0; roundIndex < _rounds.length; roundIndex++) {
      for (
        var playerIndex = 0;
        playerIndex < GameService.playerCount;
        playerIndex++
      ) {
        final key = _scoreKey(roundIndex, playerIndex);
        activeKeys.add(key);
        final score = _rounds[roundIndex].scores[playerIndex];
        final controller = _scoreControllers.putIfAbsent(
          key,
          () => TextEditingController(text: score == 0 ? '' : score.toString()),
        );
        if (overwriteText) {
          controller.text = score == 0 ? '' : score.toString();
        }
      }
    }

    final staleKeys = _scoreControllers.keys
        .where((key) => !activeKeys.contains(key))
        .toList();
    for (final key in staleKeys) {
      _scoreControllers.remove(key)?.dispose();
    }
  }

  String _scoreKey(int roundIndex, int playerIndex) =>
      '$roundIndex-$playerIndex';

  Game _fallbackGame() {
    return Game(
      title: 'Hearts Game',
      playerNames: const ['Player 1', 'Player 2', 'Player 3', 'Player 4'],
      isFinished: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    for (final controller in playerNameControllers) {
      controller.dispose();
    }
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
