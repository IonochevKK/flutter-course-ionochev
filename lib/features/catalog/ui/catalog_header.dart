import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../entities/book/model/book_category.dart';
import '../../../entities/book/model/book_sort.dart';
import '../../../entities/user/cubit/auth_cubit.dart';
import '../../../entities/user/cubit/favorites_cubit.dart';
import '../../../shared/router/routes.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';

class CatalogHeader extends StatefulWidget {
  const CatalogHeader({super.key});

  @override
  State<CatalogHeader> createState() => _CatalogHeaderState();
}

class _CatalogHeaderState extends State<CatalogHeader> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _subtitle(CatalogState state, FavoritesState favorites) {
    final subtitles = {
      CatalogStatus.failure: 'Нет данных',
      CatalogStatus.success:
          'В каталоге: ${state.totalCount} · '
          'В избранном: ${favorites.countAmong(state.allBookIds)}',
    };
    return subtitles[state.status] ?? 'Загружаем…';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cubit = context.read<CatalogCubit>();
    final favorites = context.watch<FavoritesCubit>().state;

    return BlocConsumer<CatalogCubit, CatalogState>(
      listenWhen: (prev, curr) => prev.query != curr.query,
      listener: (context, state) {
        if (state.query != _search.text) _search.text = state.query;
      },
      builder: (context, state) {
        final ready = state.status == CatalogStatus.success;
        return Container(
          color: scheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Каталог книг',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _subtitle(state, favorites),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.person_outline,
                    tooltip: 'Профиль',
                    onPressed: () => context.push(Routes.profile),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    icon: Icons.logout,
                    tooltip: 'Выйти',
                    onPressed: () => context.read<AuthCubit>().signOut(),
                  ),
                ],
              ),
              if (ready) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  onChanged: cubit.setQuery,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    fillColor: scheme.surfaceContainerLowest,
                    suffixIcon: state.query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _search.clear();
                              cubit.setQuery('');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'Все',
                        selected: state.category == null,
                        onTap: () => cubit.setCategory(null),
                      ),
                      for (final c in BookCategory.all)
                        _CategoryChip(
                          label: c,
                          selected: state.category == c,
                          onTap: () =>
                              cubit.setCategory(state.category == c ? null : c),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ] else
                const SizedBox(height: 10),
              Row(
                children: [
                  if (ready)
                    PopupMenuButton<BookSort>(
                      initialValue: state.sort,
                      onSelected: cubit.setSort,
                      itemBuilder: (_) => [
                        for (final s in BookSort.values)
                          PopupMenuItem(value: s, child: Text(s.label)),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              state.sort.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Icon(Icons.expand_more, size: 18),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  FilterChip(
                    avatar: Icon(
                      state.favoritesOnly
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: state.favoritesOnly
                          ? scheme.onPrimary
                          : scheme.onSurface,
                    ),
                    label: const Text('Только избранные'),
                    selected: state.favoritesOnly,
                    onSelected: (_) => cubit.toggleFavoritesOnly(),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: state.favoritesOnly
                          ? scheme.onPrimary
                          : scheme.onSurface,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          fontSize: 13,
          color: selected ? scheme.onPrimary : scheme.onSurface,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }
}
