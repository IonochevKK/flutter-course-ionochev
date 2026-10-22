import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/model/book_category.dart';
import '../../../entities/book/repository/books_repository.dart';
import '../../../entities/user/cubit/auth_cubit.dart';
import '../../../shared/ui/labeled_field.dart';
import '../cubit/book_form_cubit.dart';

Future<void> showBookFormSheet(BuildContext context, {Book? book}) {
  final uid = context.read<AuthCubit>().state.user?.uid;
  if (uid == null) return Future.value();
  final repository = context.read<BooksRepository>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => BookFormCubit(repository, uid: uid, initial: book),
      child: BookFormSheet(book: book),
    ),
  );
}

class BookFormSheet extends StatefulWidget {
  const BookFormSheet({super.key, this.book});

  final Book? book;

  @override
  State<BookFormSheet> createState() => _BookFormSheetState();
}

class _BookFormSheetState extends State<BookFormSheet> {
  late final _name = TextEditingController(text: widget.book?.name);
  late final _author = TextEditingController(text: widget.book?.author);
  late final _year = TextEditingController(text: widget.book?.year.toString());
  late final _description = TextEditingController(
    text: widget.book?.description,
  );
  late final _coverUrl = TextEditingController(text: widget.book?.coverUrl);
  late final Set<String> _categories = {...?widget.book?.category};

  bool get _isEdit => widget.book != null;

  @override
  void dispose() {
    _name.dispose();
    _author.dispose();
    _year.dispose();
    _description.dispose();
    _coverUrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<BookFormCubit>().submit(
      name: _name.text,
      author: _author.text,
      year: _year.text,
      description: _description.text,
      coverUrl: _coverUrl.text,
      category: _categories.toList(),
    );
  }

  void _onStatus(BuildContext context, BookFormState state) {
    final messenger = ScaffoldMessenger.of(context);
    final message = switch (state.status) {
      BookFormStatus.saved =>
        _isEdit ? 'Изменения сохранены' : 'Книга добавлена',
      BookFormStatus.savedOffline =>
        'Сохранено. Синхронизируется, когда появится интернет',
      BookFormStatus.failure => 'Не удалось сохранить. Проверьте интернет',
      _ => null,
    };
    if (message == null) return;
    if (state.status != BookFormStatus.failure) Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocConsumer<BookFormCubit, BookFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onStatus,
      builder: (context, state) {
        final saving = state.isSaving;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEdit ? 'Редактирование' : 'Новая книга',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Название *',
                  controller: _name,
                  maxLength: BookLimits.name,
                  autofocus: !_isEdit,
                  errorText: state.nameError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => context.read<BookFormCubit>().clearErrors(),
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Автор',
                  controller: _author,
                  maxLength: BookLimits.author,
                  hint: 'Необязательно',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Год',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _year,
                      onChanged: (_) =>
                          context.read<BookFormCubit>().clearErrors(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Необязательно',
                        errorText: state.yearError,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Описание',
                  controller: _description,
                  maxLength: BookLimits.description,
                  hint: 'Необязательно',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Ссылка на обложку',
                  controller: _coverUrl,
                  maxLength: BookLimits.coverUrl,
                  hint: 'https://… (необязательно)',
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in BookCategory.all)
                      FilterChip(
                        avatar: Icon(
                          BookCategory.iconOf(c),
                          size: 16,
                          color: _categories.contains(c)
                              ? scheme.onPrimary
                              : scheme.onSurface,
                        ),
                        label: Text(c),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: _categories.contains(c)
                              ? scheme.onPrimary
                              : scheme.onSurface,
                        ),
                        selected: _categories.contains(c),
                        onSelected: (selected) => setState(
                          () => selected
                              ? _categories.add(c)
                              : _categories.remove(c),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Остальные поля заполнятся значениями по умолчанию',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: saving ? null : _submit,
                        child: saving
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEdit ? 'Сохранить' : 'Добавить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
