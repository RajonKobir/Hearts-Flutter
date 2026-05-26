import 'dart:convert';

/// Base class for all domain models
/// Provides common interface for serialization
abstract class BaseModel {
  /// Serializes the model to a map
  /// Subclasses can override with different signatures as needed
  Map<String, Object?> toMap();
}

/// Game model representing a Hearts card game session
/// Encapsulates game state and metadata
class Game extends BaseModel {
  final int? id;
  final String title;
  final List<String> playerNames;
  final bool isFinished;
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    this.id,
    required this.title,
    required this.playerNames,
    required this.isFinished,
    required this.createdAt,
    required this.updatedAt,
  }) {
    // Validate in constructor
    if (title.isEmpty) {
      throw ArgumentError('Game title cannot be empty');
    }
    if (playerNames.length != 4) {
      throw ArgumentError('Game must have exactly 4 players');
    }
  }

  /// Creates a copy of this game with modified fields
  /// Implements the copyWith pattern for immutability
  Game copyWith({
    int? id,
    String? title,
    List<String>? playerNames,
    bool? isFinished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      playerNames: playerNames ?? this.playerNames,
      isFinished: isFinished ?? this.isFinished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'player_names': jsonEncode(playerNames),
      'is_finished': isFinished ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Game.fromMap(Map<String, Object?> map) {
    final names = jsonDecode(map['player_names'] as String) as List<dynamic>;
    return Game(
      id: map['id'] as int?,
      title: map['title'] as String,
      playerNames: names.map((entry) => entry.toString()).toList(),
      isFinished: (map['is_finished'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() => 'Game(id: $id, title: $title, isFinished: $isFinished)';
}

/// RoundScore model representing scores for a single round
/// Encapsulates round state and computed properties
/// Note: Does not inherit from BaseModel due to different toMap signature
class RoundScore {
  final int roundNumber;
  final List<int> scores;

  RoundScore({required this.roundNumber, required this.scores})
    : assert(scores.length == 4, 'There must be exactly 4 player scores.') {
    // Validate scores are in valid range
    for (final score in scores) {
      if (score < 0 || score > 26) {
        throw ArgumentError('Score must be between 0 and 26');
      }
    }
    if (roundNumber <= 0) {
      throw ArgumentError('Round number must be positive');
    }
  }

  /// Calculates total points in this round
  int get total => scores.fold(0, (sum, value) => sum + value);

  /// Checks if this round was finished by a moon hit.
  bool get isMoonHit =>
      scores.where((score) => score == 0).length == 1 &&
      scores.where((score) => score == 26).length == 3;

  /// Checks if round is complete.
  bool get isComplete => total == 26 || isMoonHit;

  /// Checks if round is locked (all 26 points distributed or moon hit).
  bool get isLocked => isComplete;

  Map<String, Object?> toMap(int gameId, int playerIndex) {
    return {
      'game_id': gameId,
      'round_number': roundNumber,
      'player_index': playerIndex,
      'score': scores[playerIndex],
    };
  }

  @override
  String toString() => 'RoundScore(round: $roundNumber, total: $total)';
}
