import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../entities/user/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_form_cubit.dart';
import '../../features/auth/ui/auth_page.dart';
import '../../features/book_details/ui/book_details_page.dart';
import '../../features/book_form/ui/book_form_sheet.dart';
import '../../features/catalog/cubit/catalog_cubit.dart';
import '../../features/catalog/cubit/catalog_state.dart';
import '../../features/catalog/ui/catalog_page.dart';
import '../../features/profile/ui/profile_page.dart';
import '../../shared/router/routes.dart';

GoRouter createRouter(AuthCubit authCubit, Listenable refreshListenable) {
  return GoRouter(
    initialLocation: Routes.catalog,
    refreshListenable: refreshListenable,
    redirect: (context, state) =>
        redirectFor(authCubit.state.status, state.uri),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const AuthPage(mode: AuthMode.login),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => const AuthPage(mode: AuthMode.register),
      ),
      GoRoute(
        path: Routes.catalog,
        builder: (_, _) =>
            CatalogPage(onAddBook: (context) => showBookFormSheet(context)),
        routes: [
          GoRoute(
            path: 'book/:id',
            builder: (_, state) => BookDetailsPage(
              bookId: state.pathParameters['id']!,
              onEdit: (context, book) => showBookFormSheet(context, book: book),
            ),
          ),
          GoRoute(
            path: 'profile',
            builder: (_, _) => BlocBuilder<CatalogCubit, CatalogState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.totalCount != curr.totalCount ||
                  prev.allBookIds != curr.allBookIds,
              builder: (_, state) => ProfilePage(
                stats: state.status == CatalogStatus.success
                    ? CatalogStats(
                        totalCount: state.totalCount,
                        bookIds: state.allBookIds,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

String? redirectFor(AuthStatus status, Uri uri) {
  final location = uri.path;
  final onAuthPage = location == Routes.login || location == Routes.register;
  final onSplash = location == Routes.splash;
  final from =
      uri.queryParameters[Routes.fromParam] ??
      (onAuthPage || onSplash || location == Routes.catalog
          ? null
          : uri.toString());

  return switch (status) {
    AuthStatus.unknown =>
      onSplash ? null : Routes.withFrom(Routes.splash, from),
    AuthStatus.unauthenticated =>
      onAuthPage ? null : Routes.withFrom(Routes.login, from),
    AuthStatus.authenticated =>
      onAuthPage || onSplash ? from ?? Routes.catalog : null,
  };
}

class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
