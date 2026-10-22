import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../entities/user/cubit/favorites_cubit.dart';
import '../../../shared/router/routes.dart';
import '../../../shared/ui/state_message.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import 'book_card.dart';
import 'catalog_header.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.onAddBook});

  final void Function(BuildContext context) onAddBook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CatalogHeader(),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, state) {
                  if (state.isRefreshing) return const _LoadingView();
                  final views = <CatalogStatus, Widget Function()>{
                    CatalogStatus.failure: () => StateMessage(
                      icon: Icons.wifi_off,
                      isError: true,
                      title: 'Не удалось загрузить каталог',
                      subtitle: 'Проверьте подключение к интернету и попробуйте ещё раз',
                      actionLabel: 'Обновить',
                      onAction: context.read<CatalogCubit>().load,
                    ),
                    CatalogStatus.success: () => _BooksList(state: state),
                  };
                  return views[state.status]?.call() ?? const _LoadingView();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<CatalogCubit, CatalogState>(
        buildWhen: (prev, curr) => prev.status != curr.status,
        builder: (context, state) => state.status == CatalogStatus.success
            ? FloatingActionButton(
                tooltip: 'Добавить книгу',
                onPressed: () => onAddBook(context),
                child: const Icon(Icons.add),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'Загружаем каталог…',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksList extends StatelessWidget {
  const _BooksList({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CatalogCubit>();
    final favorites = context.watch<FavoritesCubit>();
    final favoriteIds = favorites.state.ids;
    final books = state.visibleBooks(favoriteIds);

    if (state.books.isEmpty && state.category == null) {
      return const StateMessage(
        icon: Icons.menu_book_outlined,
        title: 'Каталог пока пуст',
        subtitle: 'Добавьте первую книгу кнопкой «+»',
      );
    }

    if (books.isEmpty) {
      final onlyFavorites =
          state.favoritesOnly && state.category == null && state.query.isEmpty;
      return StateMessage(
        icon: onlyFavorites ? Icons.favorite_border : Icons.search_off,
        title: onlyFavorites ? 'В избранном пока пусто' : 'Ничего не найдено',
        subtitle: onlyFavorites
            ? 'Нажмите на сердечко на карточке, чтобы сохранить книгу в избранное'
            : 'Попробуйте изменить запрос или фильтры',
        actionLabel: 'Показать все книги',
        onAction: cubit.showAll,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: books.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'Найдено: ${books.length}',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          );
        }
        final book = books[index - 1];
        return BookCard(
          key: ValueKey(book.id),
          book: book,
          liked: favoriteIds.contains(book.id),
          onTap: () => context.push(Routes.book(book.id)),
          onLike: () => favorites.toggle(book.id),
        );
      },
    );
  }
}
