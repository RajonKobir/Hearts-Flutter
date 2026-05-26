import '../database.dart';
import '../models.dart';

/// Repository pattern implementation for database operations
/// Abstracts database calls and provides a clean interface for data access
/// Follows Dependency Inversion Principle
abstract class IGameRepository {
  Future<Game?> getGameById(int gameId);
  Future<Game?> getCurrentGame();
  Future<List<Game>> getAllGames();
  Future<int> createGame(Game game);
  Future<void> updateGame(Game game);
  Future<List<RoundScore>> getRoundScores(int gameId);
  Future<void> saveRoundScores(int gameId, List<RoundScore> rounds);
  Future<void> clearAll();
}

/// Concrete implementation of the repository
class GameRepository implements IGameRepository {
  final AppDatabase _database;

  GameRepository(this._database);

  @override
  Future<Game?> getGameById(int gameId) async {
    return await _database.loadGame(gameId);
  }

  @override
  Future<Game?> getCurrentGame() async {
    return await _database.loadCurrentGame();
  }

  @override
  Future<List<Game>> getAllGames() async {
    return await _database.listGames();
  }

  @override
  Future<int> createGame(Game game) async {
    return await _database.createGame(game);
  }

  @override
  Future<void> updateGame(Game game) async {
    await _database.updateGame(game);
  }

  @override
  Future<List<RoundScore>> getRoundScores(int gameId) async {
    return await _database.loadRoundScores(gameId);
  }

  @override
  Future<void> saveRoundScores(int gameId, List<RoundScore> rounds) async {
    await _database.saveRoundScores(gameId, rounds);
  }

  @override
  Future<void> clearAll() async {
    await _database.clearAll();
  }
}
