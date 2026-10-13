import 'package:flutter/material.dart';

void main() {
  runApp(const CatalogApp());
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Космос',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}

class SpaceItem {
  final String title;
  final String subtitle;
  final String category;
  final IconData categoryIcon;
  final List<Color> colors;
  final bool liked;

  const SpaceItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryIcon,
    required this.colors,
    this.liked = false,
  });
}

const items = <SpaceItem>[
  SpaceItem(
    title: 'Меркурий',
    subtitle: 'Ближайшая к Солнцу планета, год длится 88 дней',
    category: 'Планета',
    categoryIcon: Icons.public,
    colors: [Colors.brown, Colors.grey],
  ),
  SpaceItem(
    title: 'Венера',
    subtitle: 'Самая горячая планета Солнечной системы',
    category: 'Планета',
    categoryIcon: Icons.public,
    colors: [Colors.orange, Colors.deepOrange],
    liked: true,
  ),
  SpaceItem(
    title: 'Земля',
    subtitle: 'Наш дом и единственная известная планета с жизнью',
    category: 'Планета',
    categoryIcon: Icons.public,
    colors: [Colors.blue, Colors.green],
    liked: true,
  ),
  SpaceItem(
    title: 'Марс',
    subtitle: 'Красная планета с самым высоким вулканом — Олимпом',
    category: 'Планета',
    categoryIcon: Icons.public,
    colors: [Colors.red, Colors.brown],
  ),
  SpaceItem(
    title: 'Юпитер',
    subtitle: 'Газовый гигант с Большим красным пятном',
    category: 'Планета',
    categoryIcon: Icons.public,
    colors: [Colors.amber, Colors.brown],
  ),
  SpaceItem(
    title: 'Сатурн',
    subtitle: 'Планета с самыми заметными кольцами',
    category: 'Планета',
    categoryIcon: Icons.public,
    colors: [Colors.yellow, Colors.orange],
    liked: true,
  ),
  SpaceItem(
    title: 'Восток-1',
    subtitle: 'Первый полёт человека в космос, 12 апреля 1961 года',
    category: 'Миссия',
    categoryIcon: Icons.rocket_launch,
    colors: [Colors.indigo, Colors.blue],
    liked: true,
  ),
  SpaceItem(
    title: 'Аполлон-11',
    subtitle: 'Первая высадка людей на Луну в 1969 году',
    category: 'Миссия',
    categoryIcon: Icons.rocket_launch,
    colors: [Colors.blueGrey, Colors.grey],
  ),
  SpaceItem(
    title: 'Вояджер-1 — самый далёкий от Земли рукотворный объект',
    subtitle: 'Запущен в 1977 году и покинул гелиосферу в 2012-м',
    category: 'Миссия',
    categoryIcon: Icons.rocket_launch,
    colors: [Colors.purple, Colors.deepPurple],
  ),
  SpaceItem(
    title: 'Космический телескоп Джеймс Уэбб',
    subtitle: 'Наблюдает Вселенную в инфракрасном диапазоне из точки L2',
    category: 'Миссия',
    categoryIcon: Icons.rocket_launch,
    colors: [Colors.amber, Colors.deepOrange],
    liked: true,
  ),
];

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Космос: планеты и миссии'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => CatalogCard(item: items[index]),
      ),
    );
  }
}

class CatalogCard extends StatelessWidget {
  final SpaceItem item;

  const CatalogCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardCover(item: item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(item.categoryIcon, size: 16, color: Colors.indigo),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardCover extends StatelessWidget {
  final SpaceItem item;

  const CardCover({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.colors,
              ),
            ),
          ),
          Center(
            child: Text(
              item.title.characters.first,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Icon(
              item.liked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: item.liked ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
