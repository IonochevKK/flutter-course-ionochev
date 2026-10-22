import 'package:equatable/equatable.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/model/book_sort.dart';

enum CatalogStatus { initial, loading, success, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.isRefreshing = false,
    this.books = const [],
    this.allBookIds = const {},
    this.totalCount = 0,
    this.uid,
    this.favoritesOnly = false,
    this.category,
    this.sort = BookSort.byName,
    this.query = '',
  });

  final CatalogStatus status;
  final bool isRefreshing;

  final List<Book> books;

  final Set<String> allBookIds;
  final int totalCount;
  final String? uid;

  final bool favoritesOnly;

  final String? category;
  final BookSort sort;
  final String query;

  List<Book> visibleBooks(Set<String> favoriteIds) {
    final q = query.trim().toLowerCase();
    return books.where((book) {
      if (favoritesOnly && !favoriteIds.contains(book.id)) return false;
      if (q.isNotEmpty && !book.name.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  CatalogState copyWith({
    CatalogStatus? status,
    bool? isRefreshing,
    List<Book>? books,
    Set<String>? allBookIds,
    int? totalCount,
    bool? favoritesOnly,
    String? Function()? category,
    BookSort? sort,
    String? query,
  }) {
    return CatalogState(
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      books: books ?? this.books,
      allBookIds: allBookIds ?? this.allBookIds,
      totalCount: totalCount ?? this.totalCount,
      uid: uid,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      category: category != null ? category() : this.category,
      sort: sort ?? this.sort,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isRefreshing,
    books,
    allBookIds,
    totalCount,
    uid,
    favoritesOnly,
    category,
    sort,
    query,
  ];
}
