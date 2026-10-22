import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/repository/books_repository.dart';

enum BookDetailsStatus { loading, found, notFound, failure }

class BookDetailsState extends Equatable {
  const BookDetailsState({this.status = BookDetailsStatus.loading, this.book});

  final BookDetailsStatus status;
  final Book? book;

  @override
  List<Object?> get props => [status, book];
}

class BookDetailsCubit extends Cubit<BookDetailsState> {
  BookDetailsCubit(this._repository, this.bookId)
    : super(const BookDetailsState()) {
    watch();
  }

  final BooksRepository _repository;
  final String bookId;
  StreamSubscription<Book?>? _subscription;

  void watch() {
    _subscription?.cancel();
    emit(const BookDetailsState());
    _subscription = _repository
        .watchBook(bookId)
        .listen(
          (book) => emit(
            book == null
                ? const BookDetailsState(status: BookDetailsStatus.notFound)
                : BookDetailsState(status: BookDetailsStatus.found, book: book),
          ),
          onError: (Object _) =>
              emit(const BookDetailsState(status: BookDetailsStatus.failure)),
        );
  }

  Future<bool> delete() => _repository.deleteBook(bookId);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
