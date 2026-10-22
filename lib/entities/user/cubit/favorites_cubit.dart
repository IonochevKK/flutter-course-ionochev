import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/favorites_repository.dart';

class FavoritesState extends Equatable {
  const FavoritesState({this.uid, this.ids = const {}});

  final String? uid;
  final Set<String> ids;

  bool contains(String bookId) => ids.contains(bookId);

  int countAmong(Set<String> bookIds) => ids.where(bookIds.contains).length;

  @override
  List<Object?> get props => [uid, ids];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;
  StreamSubscription<Set<String>>? _subscription;

  void setUser(String? uid) {
    if (uid == state.uid) return;
    _subscription?.cancel();
    _subscription = null;
    emit(FavoritesState(uid: uid));
    if (uid == null) return;
    _subscription = _repository
        .watchFavorites(uid)
        .listen(
          (ids) => emit(FavoritesState(uid: uid, ids: ids)),
          onError: (Object error) => debugPrint('favorites: $error'),
        );
  }

  Future<void> toggle(String bookId) {
    return _set(bookId, liked: !state.contains(bookId));
  }

  Future<void> remove(String bookId) async {
    if (state.contains(bookId)) await _set(bookId, liked: false);
  }

  Future<void> _set(String bookId, {required bool liked}) async {
    final uid = state.uid;
    if (uid == null) return;
    _emitIds(uid, bookId, liked: liked);
    try {
      await _repository.setFavorite(uid: uid, bookId: bookId, liked: liked);
    } catch (_) {
      if (isClosed || state.uid != uid) return;
      _emitIds(uid, bookId, liked: !liked);
    }
  }

  void _emitIds(String uid, String bookId, {required bool liked}) {
    final ids = {...state.ids};
    liked ? ids.add(bookId) : ids.remove(bookId);
    emit(FavoritesState(uid: uid, ids: ids));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
