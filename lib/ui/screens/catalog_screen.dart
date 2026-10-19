import 'package:flutter/material.dart';

import '../../domain/index.dart' as entities;
import '../widgets/index.dart' as widgets;

const _defaultColors = ['#3F51B5', '#2196F3'];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.repository});

  final entities.SpaceRepository repository;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<String> _likedIds = {};
  bool _onlyFavorites = false;

  List<entities.SpaceItem> _items = [];
  bool _isLoading = true;
  String? _error;

  bool _showForm = false;
  bool _isSending = false;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  entities.SpaceCategory _newCategory = entities.SpaceCategory.planet;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await widget.repository.getItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } on entities.Failure catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить каталог: ${e.message}';
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final item = entities.SpaceItem(
      id: '',
      title: title,
      subtitle: _subtitleController.text.trim(),
      category: _newCategory.code,
      description: '',
      colors: _defaultColors,
    );
    try {
      final created = await widget.repository.createItem(item);
      if (!mounted) return;
      setState(() {
        _items = [created, ..._items];
        _titleController.clear();
        _subtitleController.clear();
      });
    } on entities.Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  void _toggleFilter() {
    setState(() => _onlyFavorites = !_onlyFavorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Космос: планеты и миссии'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            tooltip: _showForm ? 'Скрыть форму' : 'Добавить',
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'В избранном: ${_likedIds.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: _toggleFilter,
                  icon: Icon(
                    _onlyFavorites ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: const Text('Только избранные'),
                  style: _onlyFavorites
                      ? FilledButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Название *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(
              labelText: 'Краткое описание',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<entities.SpaceCategory>(
                  segments: [
                    for (final c in entities.SpaceCategory.values)
                      ButtonSegment(
                        value: c,
                        label: Text(c.label),
                        icon: Icon(c.icon),
                      ),
                  ],
                  selected: {_newCategory},
                  onSelectionChanged: (s) =>
                      setState(() => _newCategory = s.first),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSending ? null : _submit,
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Отправить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadItems,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить'),
              ),
            ],
          ),
        ),
      );
    }

    final visibleItems = _onlyFavorites
        ? _items.where((item) => _likedIds.contains(item.id)).toList()
        : _items;

    if (visibleItems.isEmpty) {
      return const Center(
        child: Text(
          'Ничего не нашлось',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: visibleItems.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = visibleItems[index];
        return widgets.SpaceItemCard(
          item: item,
          isLiked: _likedIds.contains(item.id),
          onLikeTap: () => _toggleLike(item.id),
        );
      },
    );
  }
}
