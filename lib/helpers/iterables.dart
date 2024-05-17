
extension IterablesExtension<E> on Iterable<E>? {
  bool isNullOrEmpty() => this?.isEmpty ?? true;

  E? firstOrNull() => isNullOrEmpty() ? null : this?.first;

  Iterable<E> orEmpty() => isNullOrEmpty() ? List.empty() : this!;

  List<E> toImmutableList() => this?.toList(growable: false) ?? List.empty();
  E? getOrNull(int index) {
    try {
      return this?.elementAt(index);
    } catch (_) {
      return null;
    }
  }

  E? lastOrNull() => isNullOrEmpty() ? null : this?.last;
}
