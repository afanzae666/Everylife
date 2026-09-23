class ValidationError {
  const ValidationError(this.message);

  final String message;

  @override
  String toString() => message;
}

class Validator {
  static ValidationError? requiredText(
    String value, {
    required String fieldName,
  }) {
    if (value.trim().isEmpty) {
      return ValidationError(
        '$fieldName cannot be empty.',
      );
    }

    return null;
  }

  static ValidationError? nonNegative(
    int value, {
    required String fieldName,
  }) {
    if (value < 0) {
      return ValidationError(
        '$fieldName cannot be negative.',
      );
    }

    return null;
  }
}
