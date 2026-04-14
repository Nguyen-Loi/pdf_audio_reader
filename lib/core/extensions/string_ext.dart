extension StringExt on String {
  /// Trims, collapses multiple whitespace, and normalizes newlines.
  String normalizeWhitespace() =>
      replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Returns true if the string is null or only whitespace.
  bool get isBlank => trim().isEmpty;

  /// Capitalizes the first letter.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncates to [maxLength] with an ellipsis.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 1)}…';
  }
}
