enum SortDirection {
  ascending,
  descending,
}

class SortOption<T> {
  final String label;
  final int Function(T a, T b) comparator;
  const SortOption({
    required this.label,
    required this.comparator,
  });
}

class FilterOption<T> {
  final String label;
  final bool Function(T item) predicate;
  const FilterOption({
    required this.label,
    required this.predicate,
  });
}
