enum BookSort {
  byName('По названию', field: 'name'),
  newest('Сначала новые', field: 'createdAt', descending: true),
  oldest('Сначала старые', field: 'createdAt');

  const BookSort(this.label, {required this.field, this.descending = false});

  final String label;
  final String field;
  final bool descending;
}
