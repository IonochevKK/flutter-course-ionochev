import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/model/book_category.dart';
import '../../../entities/book/repository/books_repository.dart';

enum BookFormStatus { editing, saving, saved, savedOffline, failure }

abstract final class BookLimits {
  static const name = 200;
  static const author = 200;
  static const description = 5000;
  static const coverUrl = 2000;
  static const maxYear = 3000;
}

class BookFormState extends Equatable {
  const BookFormState({
    this.status = BookFormStatus.editing,
    this.nameError,
    this.yearError,
  });

  final BookFormStatus status;
  final String? nameError;
  final String? yearError;

  bool get isSaving => status == BookFormStatus.saving;

  @override
  List<Object?> get props => [status, nameError, yearError];
}

class BookFormCubit extends Cubit<BookFormState> {
  BookFormCubit(this._repository, {required this.uid, this.initial})
    : super(const BookFormState());

  final BooksRepository _repository;
  final String uid;
  final Book? initial;

  bool get isEdit => initial != null;

  void clearErrors() {
    if (state.nameError != null || state.yearError != null) {
      emit(const BookFormState());
    }
  }

  Future<void> submit({
    required String name,
    required String author,
    required String year,
    required String description,
    required String coverUrl,
    required List<String> category,
  }) async {
    final trimmedName = name.trim();
    final parsedYear = int.tryParse(year.trim());
    final nameError = trimmedName.isEmpty
        ? 'Введите название'
        : trimmedName.length > BookLimits.name
        ? 'Не длиннее ${BookLimits.name} символов'
        : null;
    final yearError = parsedYear != null && parsedYear > BookLimits.maxYear
        ? 'Год не больше ${BookLimits.maxYear}'
        : null;
    if (nameError != null || yearError != null) {
      emit(BookFormState(nameError: nameError, yearError: yearError));
      return;
    }
    emit(const BookFormState(status: BookFormStatus.saving));

    final book = _build(
      name: trimmedName,
      author: _limit(author.trim(), BookLimits.author),
      year: parsedYear,
      description: _limit(description.trim(), BookLimits.description),
      coverUrl: coverUrl.trim().isEmpty
          ? null
          : _limit(coverUrl.trim(), BookLimits.coverUrl),
      category: category.isEmpty ? const [BookCategory.other] : category,
    );

    try {
      final synced = isEdit
          ? await _repository.updateBook(book)
          : await _repository.addBook(book);
      if (isClosed) return;
      emit(
        BookFormState(
          status: synced ? BookFormStatus.saved : BookFormStatus.savedOffline,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(const BookFormState(status: BookFormStatus.failure));
    }
  }

  static String _limit(String value, int max) =>
      value.length > max ? value.substring(0, max) : value;

  Book _build({
    required String name,
    required String author,
    required int? year,
    required String description,
    required String? coverUrl,
    required List<String> category,
  }) {
    final book = initial;
    if (book == null) {
      return Book(
        id: '',
        creatorId: uid,
        name: name,
        author: author.isEmpty ? 'Автор неизвестен' : author,
        year: year ?? DateTime.now().year,
        description: description,
        category: category,
        coverUrl: coverUrl,
        createdAt: DateTime.now(),
      );
    }
    return Book(
      id: book.id,
      creatorId: book.creatorId,
      createdAt: book.createdAt,
      name: name,
      author: author.isEmpty ? book.author : author,
      year: year ?? book.year,
      description: description,
      category: category,
      coverUrl: coverUrl,
    );
  }
}
