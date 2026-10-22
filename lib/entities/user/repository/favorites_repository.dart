import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection('users').doc(uid);

  Stream<Set<String>> watchFavorites(String uid) {
    return _user(uid)
        .snapshots()
        .map((doc) => {...List<String>.from(doc.data()?['favorites'] ?? [])});
  }

  Future<void> setFavorite({
    required String uid,
    required String bookId,
    required bool liked,
  }) async {
    await _user(uid).set({
      'favorites': liked
          ? FieldValue.arrayUnion([bookId])
          : FieldValue.arrayRemove([bookId]),
    }, SetOptions(merge: true));
  }
}
