import 'package:flutter_test/flutter_test.dart';
import 'package:hearts_flutter/models.dart';
import 'package:hearts_flutter/services/game_service.dart';

void main() {
  test('calculatePlayerTotals sums each player across rounds', () {
    final service = GameService();

    final totals = service.calculatePlayerTotals([
      RoundScore(roundNumber: 1, scores: [1, 2, 3, 20]),
      RoundScore(roundNumber: 2, scores: [4, 5, 6, 11]),
    ]);

    expect(totals, [5, 7, 9, 31]);
  });

  test('updateRoundScore clamps score to remaining round points', () {
    final service = GameService();
    final round = RoundScore(roundNumber: 1, scores: [10, 10, 0, 0]);

    final updatedRound = service.updateRoundScore(round, 2, 20);

    expect(updatedRound.scores, [10, 10, 6, 0]);
    expect(updatedRound.total, 26);
  });

  test('applyMoonHit gives shooter zero and other players twenty six', () {
    final service = GameService();
    final round = RoundScore(roundNumber: 1, scores: [5, 6, 7, 8]);

    final updatedRound = service.applyMoonHit(round, 1);

    expect(updatedRound.scores, [26, 0, 26, 26]);
    expect(updatedRound.isMoonHit, isTrue);
    expect(updatedRound.isComplete, isTrue);
  });

  test('isGameOver is true when any player reaches game over score', () {
    final service = GameService();

    expect(service.isGameOver([99, 10, 20, 30]), isFalse);
    expect(service.isGameOver([99, 100, 20, 30]), isTrue);
  });

  test('getGameResult assigns shared dense ranks for tied scores', () {
    final service = GameService();
    final result = service.getGameResult(
      [
        RoundScore(roundNumber: 1, scores: [26, 26, 26, 26]),
        RoundScore(roundNumber: 2, scores: [26, 26, 26, 26]),
        RoundScore(roundNumber: 3, scores: [0, 0, 26, 26]),
      ],
      const ['Player 1', 'Player 2', 'Player 3', 'Player 4'],
    );

    expect(
      result.results.map((player) => (player.name, player.score, player.rank)),
      [
        ('Player 1', 52, 1),
        ('Player 2', 52, 1),
        ('Player 3', 78, 2),
        ('Player 4', 78, 2),
      ],
    );
  });
}
