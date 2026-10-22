import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.field});

  final String message;

  final AuthField? field;

  static const _wrongCredentials = AuthFailure('Неверный email или пароль');
  static const _unknown = AuthFailure(
    'Что-то пошло не так. Попробуйте ещё раз',
  );

  static const _byCode = <String, AuthFailure>{
    'invalid-email': AuthFailure('Некорректный email', field: AuthField.email),
    'email-already-in-use': AuthFailure(
      'Этот email уже зарегистрирован',
      field: AuthField.email,
    ),
    'weak-password': AuthFailure(
      'Минимум 6 символов',
      field: AuthField.password,
    ),
    'user-not-found': _wrongCredentials,
    'wrong-password': _wrongCredentials,
    'invalid-credential': _wrongCredentials,
    'user-disabled': AuthFailure('Аккаунт заблокирован'),
    'too-many-requests': AuthFailure('Слишком много попыток. Попробуйте позже'),
    'network-request-failed': _network,
    'unavailable': _network,
    'deadline-exceeded': _network,
  };

  static const _network = AuthFailure('Нет подключения к интернету');

  factory AuthFailure.fromCode(String code) => _byCode[code] ?? _unknown;

  @override
  String toString() => message;
}

enum AuthField { email, password }

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) {
    return _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    Role role = Role.user,
  }) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await _users
          .doc(user.uid)
          .set(_newProfile(user, role: role).toMap(), SetOptions(merge: true));
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) {
    return _guard(() => _auth.sendPasswordResetEmail(email: email));
  }

  Stream<AppUser> watchProfile(User user) {
    return _users.doc(user.uid).snapshots().map((doc) {
      if (doc.exists) return AppUser.fromFirestore(doc);
      final profile = _newProfile(user);
      _users.doc(user.uid).set({
        'email': profile.email,
        'name': profile.name,
      }, SetOptions(merge: true)).ignore();
      return profile;
    });
  }

  AppUser _newProfile(User user, {Role role = Role.user}) {
    final email = user.email ?? '';
    return AppUser(
      uid: user.uid,
      email: email,
      name: email.split('@').first,
      role: role,
    );
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseException catch (e) {
      throw AuthFailure.fromCode(e.code);
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw AuthFailure._unknown;
    }
  }
}
