import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/repository/books_repository.dart';
import '../../../entities/book/ui/book_cover.dart';
import '../../../entities/book/ui/category_tag.dart';
import '../../../entities/book/ui/like_button.dart';
import '../../../entities/user/cubit/auth_cubit.dart';
import '../../../entities/user/cubit/favorites_cubit.dart';
import '../../../shared/ui/state_message.dart';
import '../cubit/book_details_cubit.dart';

typedef EditBookCallback = void Function(BuildContext context, Book book);

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({
    super.key,
    required this.bookId,
    required this.onEdit,
  });

  final String bookId;
  final EditBookCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(bookId),
      create: (context) =>
          BookDetailsCubit(context.read<BooksRepository>(), bookId),
      child: BlocBuilder<BookDetailsCubit, BookDetailsState>(
        builder: (context, state) {
          final book = state.book;
          return switch (state.status) {
            BookDetailsStatus.loading => Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            ),
            BookDetailsStatus.failure => Scaffold(
              appBar: AppBar(),
              body: StateMessage(
                icon: Icons.wifi_off,
                isError: true,
                title: 'Не удалось загрузить книгу',
                subtitle:
                    'Проверьте подключение к интернету и попробуйте ещё раз',
                actionLabel: 'Обновить',
                onAction: context.read<BookDetailsCubit>().watch,
              ),
            ),
            BookDetailsStatus.found when book != null => _DetailsView(
              book: book,
              onEdit: onEdit,
            ),
            _ => Scaffold(
              appBar: AppBar(),
              body: StateMessage(
                icon: Icons.menu_book_outlined,
                title: 'Книга не найдена',
                subtitle: 'Возможно, её удалили',
                actionLabel: 'Назад',
                onAction: () => context.pop(),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.book, required this.onEdit});

  final Book book;
  final EditBookCallback onEdit;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить книгу?'),
        content: Text(
          '«${book.name}» будет удалена из каталога. '
          'Это действие нельзя отменить.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: OutlinedButton.styleFrom(minimumSize: const Size(110, 44)),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(110, 44),
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<BookDetailsCubit>();
    final favorites = context.read<FavoritesCubit>();
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    try {
      final synced = await cubit.delete();
      await favorites.remove(book.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            synced
                ? '«${book.name}» удалена'
                : '«${book.name}» удалится, когда появится интернет',
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Не удалось удалить книгу. Проверьте интернет'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = context.select((AuthCubit c) => c.state.user);
    final liked = context.select(
      (FavoritesCubit c) => c.state.contains(book.id),
    );
    final canEdit =
        user != null && (user.isAdmin || user.uid == book.creatorId);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _RoundButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Назад',
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                if (canEdit) ...[
                  _RoundButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Редактировать',
                    onPressed: () => onEdit(context, book),
                  ),
                  const SizedBox(width: 8),
                  _RoundButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Удалить',
                    color: scheme.error,
                    onPressed: () => _confirmDelete(context),
                  ),
                  const SizedBox(width: 8),
                ],
                LikeButton(
                  liked: liked,
                  size: 40,
                  onPressed: () =>
                      context.read<FavoritesCubit>().toggle(book.id),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Hero(
              tag: 'cover-${book.id}',
              child: BookCover(
                book: book,
                height: 220,
                letterSize: 110,
                borderRadius: 16,
                letterOpacity: 1,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              book.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${book.author} · ${book.year}',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final c in book.category) CategoryTag(c)],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Автор', value: book.author),
                  Divider(height: 1, color: scheme.outlineVariant),
                  _InfoRow(label: 'Год', value: '${book.year}'),
                  Divider(height: 1, color: scheme.outlineVariant),
                  _InfoRow(label: 'Категория', value: book.category.join(', ')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Описание',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              book.description.isEmpty
                  ? 'Описание пока не добавлено'
                  : book.description,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }
}
