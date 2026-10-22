import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/user.dart';
import '../repository/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._(this.status, [this.user]);

  const AuthState.unknown() : this._(AuthStatus.unknown);
  const AuthState.authenticated(AppUser user)
    : this._(AuthStatus.authenticated, user);
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated);

  final AuthStatus status;
  final AppUser? user;

  @override
  List<Object?> get props => [status, user];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, {this.retryDelay = const Duration(seconds: 3)})
    : super(const AuthState.unknown()) {
    _authSubscription = _repository.authStateChanges().listen(_onUserChanged);
  }

  final AuthRepository _repository;
  final Duration retryDelay;
  late final StreamSubscription<User?> _authSubscription;
  StreamSubscription<AppUser>? _profileSubscription;
  Timer? _retryTimer;

  void _onUserChanged(User? user) {
    _stopProfile();
    if (user == null) {
      emit(const AuthState.unauthenticated());
      return;
    }
    _watchProfile(user);
  }

  void _watchProfile(User user) {
    _profileSubscription = _repository
        .watchProfile(user)
        .listen(
          (profile) => emit(AuthState.authenticated(profile)),
          onError: (Object _) => _onProfileError(user),
        );
  }

  void _onProfileError(User user) {
    _stopProfile();
    if (isClosed) return;
    if (state.user?.uid != user.uid) {
      emit(
        AuthState.authenticated(
          AppUser(uid: user.uid, email: user.email ?? '', name: ''),
        ),
      );
    }
    _retryTimer = Timer(retryDelay, () {
      if (isClosed || _repository.currentUser?.uid != user.uid) return;
      _watchProfile(user);
    });
  }

  void _stopProfile() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _profileSubscription?.cancel();
    _profileSubscription = null;
  }

  Future<void> signOut() => _repository.signOut();

  Future<void> sendPasswordReset() async {
    final email = state.user?.email;
    if (email == null || email.isEmpty) {
      throw const AuthFailure('Не удалось определить email аккаунта');
    }
    await _repository.sendPasswordReset(email);
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    _stopProfile();
    return super.close();
  }
}
