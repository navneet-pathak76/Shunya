class SunyaValidators {
  const SunyaValidators._();

  static double positiveNumber(double value, {String field = 'value'}) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError('$field must be a finite non-negative number');
    }
    return value;
  }

  static int positiveInt(int value, {String field = 'value'}) {
    if (value < 0) throw ArgumentError('$field must be non-negative');
    return value;
  }

  static String requiredText(String value, {String field = 'value'}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) throw ArgumentError('$field is required');
    return trimmed;
  }
}
