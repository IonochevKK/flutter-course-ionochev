import 'package:flutter/material.dart';

import '../../domain/index.dart' as entities;
import '../widgets/index.dart' as widgets;

const _items = <entities.SpaceItem>[
  entities.SpaceItem(
    id: 1,
    title: 'Меркурий',
    subtitle: 'Ближайшая к Солнцу планета, год длится 88 дней',
    category: entities.SpaceCategory.planet,
    colors: [Colors.brown, Colors.grey],
  ),
  entities.SpaceItem(
    id: 2,
    title: 'Венера',
    subtitle: 'Самая горячая планета Солнечной системы',
    category: entities.SpaceCategory.planet,
    colors: [Colors.orange, Colors.deepOrange],
    description: 'Температура у поверхности превышает 460 °C.',
  ),
  entities.SpaceItem(
    id: 3,
    title: 'Земля',
    subtitle: 'Наш дом и единственная известная планета с жизнью',
    category: entities.SpaceCategory.planet,
    colors: [Colors.blue, Colors.green],
  ),
  entities.SpaceItem(
    id: 4,
    title: 'Марс',
    subtitle: 'Красная планета с самым высоким вулканом — Олимпом',
    category: entities.SpaceCategory.planet,
    colors: [Colors.red, Colors.brown],
  ),
  entities.SpaceItem(
    id: 5,
    title: 'Юпитер',
    subtitle: 'Газовый гигант с Большим красным пятном',
    category: entities.SpaceCategory.planet,
    colors: [Colors.amber, Colors.brown],
  ),
  entities.SpaceItem(
    id: 6,
    title: 'Сатурн',
    subtitle: 'Планета с самыми заметными кольцами',
    category: entities.SpaceCategory.planet,
    colors: [Colors.yellow, Colors.orange],
  ),
  entities.SpaceItem(
    id: 7,
    title: 'Восток-1',
    subtitle: 'Первый полёт человека в космос, 12 апреля 1961 года',
    category: entities.SpaceCategory.mission,
    colors: [Colors.indigo, Colors.blue],
    description: 'Пилот — Юрий Гагарин, один виток вокруг Земли.',
  ),
  entities.SpaceItem(
    id: 8,
    title: 'Аполлон-11',
    subtitle: 'Первая высадка людей на Луну в 1969 году',
    category: entities.SpaceCategory.mission,
    colors: [Colors.blueGrey, Colors.grey],
  ),
  entities.SpaceItem(
    id: 9,
    title: 'Вояджер-1',
    subtitle: 'Самый далёкий от Земли рукотворный объект',
    category: entities.SpaceCategory.mission,
    colors: [Colors.purple, Colors.deepPurple],
    description: 'Запущен в 1977 году, покинул гелиосферу в 2012-м.',
  ),
  entities.SpaceItem(
    id: 10,
    title: 'Телескоп Джеймс Уэбб',
    subtitle: 'Наблюдает Вселенную в инфракрасном диапазоне из точки L2',
    category: entities.SpaceCategory.mission,
    colors: [Colors.amber, Colors.deepOrange],
  ),
];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _likedIds = {};
  bool _onlyFavorites = false;

  void _toggleLike(int id) {
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
    final List<entities.SpaceItem> visibleItems = _onlyFavorites
        ? _items.where((item) => _likedIds.contains(item.id)).toList()
        : _items;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Космос: планеты и миссии'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
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
          Expanded(
            child: visibleItems.isEmpty
                ? const Center(
                    child: Text(
                      'Ничего не нашлось',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.separated(
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
                  ),
          ),
        ],
      ),
    );
  }
}
