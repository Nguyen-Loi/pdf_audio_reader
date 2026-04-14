extension ListExt<T> on List<T> {
  /// Returns null if the list is empty, otherwise the list itself.
  List<T>? get nullIfEmpty => isEmpty ? null : this;

  /// Safe element access — returns null if [index] is out of bounds.
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Groups list items by a key.
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final map = <K, List<T>>{};
    for (final item in this) {
      (map[keyOf(item)] ??= []).add(item);
    }
    return map;
  }
}
