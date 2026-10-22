import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/book.dart';
import '../model/book_sort.dart';

class BooksRepository {
  BooksRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _requestTimeout = Duration(seconds: 10);

  CollectionReference<Map<String, dynamic>> get _books =>
      _firestore.collection('books');

  Query<Map<String, dynamic>> _query({
    String? category,
    required BookSort sort,
  }) {
    Query<Map<String, dynamic>> query = _books;
    if (category != null) {
      query = query.where('category', arrayContains: category);
    }
    return query.orderBy(sort.field, descending: sort.descending);
  }

  Future<List<Book>> fetchBooks({
    String? category,
    required BookSort sort,
  }) async {
    final snapshot = await _query(
      category: category,
      sort: sort,
    ).get(const GetOptions(source: Source.server)).timeout(_requestTimeout);
    return snapshot.docs.map(Book.fromFirestore).toList();
  }

  Stream<List<Book>> watchBooks({String? category, required BookSort sort}) {
    return _query(category: category, sort: sort).snapshots().map(
      (snapshot) => snapshot.docs.map(Book.fromFirestore).toList(),
    );
  }

  Future<int> countBooks() async {
    final snapshot = await _books.count().get().timeout(_requestTimeout);
    return snapshot.count ?? 0;
  }

  Stream<Book?> watchBook(String id) {
    return _books
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Book.fromFirestore(doc) : null);
  }

  Future<bool> addBook(Book book) {
    return _commit(_books.doc().set(book.toCreateMap()));
  }

  Future<bool> updateBook(Book book) {
    return _commit(_books.doc(book.id).update(book.toUpdateMap()));
  }

  Future<bool> deleteBook(String bookId) {
    return _commit(_books.doc(bookId).delete());
  }

  Future<bool> _commit(Future<void> write) async {
    try {
      await write.timeout(_requestTimeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }
}
