/// Utility class for validating user input
/// Follows the Utility Pattern - groups related validation methods
abstract class Validators {
  /// Validates a game title
  static ValidationResult validateGameTitle(String title) {
    if (title.isEmpty) {
      return ValidationResult.invalid('Game title is required.');
    }
    if (title.length < 3) {
      return ValidationResult.invalid(
        'Game title must be at least 3 characters.',
      );
    }
    if (title.length > 100) {
      return ValidationResult.invalid(
        'Game title must be less than 100 characters.',
      );
    }
    return ValidationResult.valid();
  }

  /// Validates a player name
  static ValidationResult validatePlayerName(String name) {
    if (name.isEmpty) {
      return ValidationResult.invalid('Player name is required.');
    }
    if (name.length > 50) {
      return ValidationResult.invalid(
        'Player name must be less than 50 characters.',
      );
    }
    return ValidationResult.valid();
  }

  /// Validates a score value
  static ValidationResult validateScore(String score) {
    if (score.isEmpty) {
      return ValidationResult.valid(); // Allow empty (will default to 0)
    }
    final value = int.tryParse(score);
    if (value == null) {
      return ValidationResult.invalid('Score must be a number.');
    }
    if (value < 0 || value > 26) {
      return ValidationResult.invalid('Score must be between 0 and 26.');
    }
    return ValidationResult.valid();
  }
}

/// Result wrapper for validation operations
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult._({required this.isValid, this.error});

  factory ValidationResult.valid() {
    return ValidationResult._(isValid: true);
  }

  factory ValidationResult.invalid(String error) {
    return ValidationResult._(isValid: false, error: error);
  }
}
