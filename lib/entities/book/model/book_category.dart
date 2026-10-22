import 'package:flutter/material.dart';

abstract final class BookCategory {
  static const other = 'Другое';

  static const Map<String, IconData> icons = {
    'Роман': Icons.favorite_border,
    'Классика': Icons.account_balance_outlined,
    'Фантастика': Icons.rocket_launch_outlined,
    'Антиутопия': Icons.visibility_outlined,
    'Сказка': Icons.auto_awesome_outlined,
    'Детектив': Icons.search,
    'Поэзия': Icons.edit_note,
    other: Icons.menu_book_outlined,
  };

  static List<String> get all => icons.keys.toList();

  static IconData iconOf(String category) =>
      icons[category] ?? Icons.menu_book_outlined;
}
