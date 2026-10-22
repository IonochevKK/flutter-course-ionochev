import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/model/book_sort.dart';
import '../../../entities/book/repository/books_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._books) : super(const CatalogState());

  final BooksRepository _books;
  StreamSubscription<List<Book>>? _booksSubscription;
  int _loadId = 0;

  Future<void> setUser(String? uid) async {
    if (uid == state.uid) return;
    _loadId++;
    _booksSubscription?.cancel();
    _booksSubscription = null;
    emit(CatalogState(uid: uid));
    if (uid == null) return;
    await load();
  }

  Future<void> load() async {
    if (state.uid == null) return;
    final id = ++_loadId;
    _booksSubscription?.cancel();
    _booksSubscription = null;
    emit(state.copyWith(status: CatalogStatus.loading, isRefreshing: false));
    try {
      final books = await _books.fetchBooks(
        category: state.category,
        sort: state.sort,
      );
      if (isClosed || id != _loadId) return;
      _onBooks(books);
      _watch(id);
    } catch (_) {
      if (isClosed || id != _loadId) return;
      emit(state.copyWith(status: CatalogStatus.failure));
    }
  }

  void _watch(int id) {
    _booksSubscription?.cancel();
    _booksSubscription = _books
        .watchBooks(category: state.category, sort: state.sort)
        .listen(
          (books) {
            if (id == _loadId) _onBooks(books);
          },
          onError: (Object _) {
            if (id != _loadId) return;
            emit(
              state.copyWith(
                status: CatalogStatus.failure,
                isRefreshing: false,
              ),
            );
          },
        );
  }

  void _onBooks(List<Book> books) {
    final unfiltered = state.category == null;
    emit(
      state.copyWith(
        status: CatalogStatus.success,
        isRefreshing: false,
        books: books,
        allBookIds: unfiltered ? {for (final book in books) book.id} : null,
        totalCount: unfiltered ? books.length : null,
      ),
    );
    if (!unfiltered) _refreshTotal(_loadId);
  }

  Future<void> _refreshTotal(int id) async {
    try {
      final total = await _books.countBooks();
      if (isClosed || id != _loadId) return;
      emit(state.copyWith(totalCount: total));
    } catch (_) {}
  }

  Future<void> _requery() async {
    if (state.status != CatalogStatus.success) return load();
    emit(state.copyWith(isRefreshing: true));
    _watch(++_loadId);
  }

  Future<void> setCategory(String? category) async {
    if (category == state.category) return;
    emit(state.copyWith(category: () => category));
    await _requery();
  }

  Future<void> setSort(BookSort sort) async {
    if (sort == state.sort) return;
    emit(state.copyWith(sort: sort));
    await _requery();
  }

  void toggleFavoritesOnly() =>
      emit(state.copyWith(favoritesOnly: !state.favoritesOnly));

  void setQuery(String query) => emit(state.copyWith(query: query));

  Future<void> showAll() async {
    emit(state.copyWith(favoritesOnly: false, query: ''));
    await setCategory(null);
  }

  @override
  Future<void> close() {
    _booksSubscription?.cancel();
    return super.close();
  }
}
