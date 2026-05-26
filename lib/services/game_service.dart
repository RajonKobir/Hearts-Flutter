import '../models.dart';

/// Service for handling game logic and scoring
/// Follows Single Responsibility Principle - only handles game operations
abstract class IGameService {
  List<int> calculatePlayerTotals(List<RoundScore> rounds);
  bool isGameOver(List<int> totals);
  bool isRoundLocked(RoundScore round);
  GameResult getGameResult(List<RoundScore> rounds, List<String> playerNames);
  RoundScore updateRoundScore(RoundScore round, int playerIndex, int value);
  RoundScore applyMoonHit(RoundScore round, int shooterIndex);
}

class GameService implements IGameService {
  static const int gameOverScore = 100;
  static const int pointsPerRound = 26;
  static const int playerCount = 4;

  @override
  List<int> calculatePlayerTotals(List<RoundScore> rounds) {
    final totals = List<int>.filled(playerCount, 0);
    for (final round in rounds) {
      for (var i = 0; i < playerCount; i++) {
        totals[i] += round.scores[i];
      }
    }
    return totals;
  }

  @override
  bool isGameOver(List<int> totals) {
    return totals.any((score) => score >= gameOverScore);
  }

  @override
  bool isRoundLocked(RoundScore round) {
    return round.isComplete;
  }

  @override
  GameResult getGameResult(List<RoundScore> rounds, List<String> playerNames) {
    final totals = calculatePlayerTotals(rounds);
    final results = <PlayerResult>[];

    for (var i = 0; i < playerCount; i++) {
      results.add(
        PlayerResult(
          rank: 0, // Will be set after sorting
          name: playerNames[i],
          score: totals[i],
        ),
      );
    }

    // Sort by score (ascending - lower score is better in Hearts)
    results.sort((a, b) => a.score.compareTo(b.score));

    var nextRank = 0;
    int? previousScore;
    for (var i = 0; i < results.length; i++) {
      if (results[i].score != previousScore) {
        nextRank++;
        previousScore = results[i].score;
      }
      results[i] = results[i].copyWith(rank: nextRank);
    }

    return GameResult(results: results);
  }

  @override
  RoundScore updateRoundScore(RoundScore round, int playerIndex, int value) {
    final scores = List<int>.from(round.scores);
    final otherPlayersTotal = round.total - round.scores[playerIndex];
    final maxAllowed = (pointsPerRound - otherPlayersTotal).clamp(
      0,
      pointsPerRound,
    );
    scores[playerIndex] = value.clamp(0, maxAllowed).toInt();
    return RoundScore(roundNumber: round.roundNumber, scores: scores);
  }

  @override
  RoundScore applyMoonHit(RoundScore round, int shooterIndex) {
    final scores = List<int>.generate(
      playerCount,
      (index) => index == shooterIndex ? 0 : 26,
    );
    return RoundScore(roundNumber: round.roundNumber, scores: scores);
  }
}

/// Data class representing game result with ranked players
class GameResult {
  final List<PlayerResult> results;

  GameResult({required this.results});

  /// Get the winner (lowest score)
  PlayerResult? get winner => results.isNotEmpty ? results.first : null;
}

/// Immutable data class for individual player results
class PlayerResult {
  final int rank;
  final String name;
  final int score;

  PlayerResult({required this.rank, required this.name, required this.score});

  PlayerResult copyWith({int? rank, String? name, int? score}) {
    return PlayerResult(
      rank: rank ?? this.rank,
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }
}
