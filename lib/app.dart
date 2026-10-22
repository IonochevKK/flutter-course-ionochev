import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'entities/book/repository/books_repository.dart';
import 'entities/user/cubit/auth_cubit.dart';
import 'entities/user/cubit/favorites_cubit.dart';
import 'entities/user/repository/auth_repository.dart';
import 'entities/user/repository/favorites_repository.dart';
import 'features/catalog/cubit/catalog_cubit.dart';
import 'shared/theme/theme_cubit.dart';

class App extends StatelessWidget {
  const App({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => BooksRepository()),
        RepositoryProvider(create: (_) => FavoritesRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(prefs)),
          BlocProvider(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                FavoritesCubit(context.read<FavoritesRepository>()),
          ),
          BlocProvider(
            create: (context) => CatalogCubit(context.read<BooksRepository>()),
          ),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final _refresh = StreamListenable(context.read<AuthCubit>().stream);
  late final GoRouter _router = createRouter(
    context.read<AuthCubit>(),
    _refresh,
  );

  @override
  void dispose() {
    _router.dispose();
    _refresh.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
      listener: (context, state) {
        final uid = state.user?.uid;
        context.read<FavoritesCubit>().setUser(uid);
        context.read<CatalogCubit>().setUser(uid);
      },
      child: MaterialApp.router(
        title: 'Каталог книг',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: _router,
      ),
    );
  }
}
